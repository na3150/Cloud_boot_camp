# [Kubernetes] AWS EKS : Cluster Autoscaling 및  Container Insights 설정

<br>

### 📌Index

- [Cluster AutoScaling](#cluster-autoscaling)
- [수동 스케일링](#수동-스케일링)
- [자동 스케일링](#자동-스케일링)
- [CloudWatch Container Insight](#cloudwatch-container-insight)

<br>

<br>

## Cluster AutoScaling

### Kubernetes의 Cluster Autoscaling

Kubernetes는 **Cluster AutoScaler를 통해 동적으로 인프라를 확장**할 수 있다.

Kubernetes [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)는 Pod가 실패하거나 다른 노드로 다시 예약될 때 클러스터의 노드 수를 자동으로 조정하며,

Pod의 **리소스 요청에 따라 클러스터의 노드를 추가하거나 제거**한다.

만약 리소스 부족으로 인해 스케줄링 대기 상태의 Pod가 존재하는 경우 Cluster AutoScaler가 노드를 추가한다. 

추가 시, **설정한 Min, Max 값을 넘어가지 않도록 구성** 할 수 있다.

<br>

![img](http://drive.google.com/uc?export=view&id=1XDum_t6J_lEt88o0X776XUxCHB-Ry_rW)

출처: https://swalloow.github.io/eks-autoscale/

<br>

### EKS AutoScaler

EKS의 AutoScaler는 AWS의 Auto Scaling Group을 활용한다.

ASG는 주기적으로 현재 상태를 확인하고 Desired State로 변화하는 방식으로 동작한다.

사용자는 클러스터 노드 수를 제한하는 Min, Max 값을 지정할 수 있다.

<br>

<br>

## 수동 스케일링

`eksctl scale` 명령어를 사용하여, 노드를 수동으로 오토스케일링이 가능하다.

```shell
$ eksctl scale nodegroup --name [노드그룹명] --cluster [클러스터명] [flags]
```

flags 확인

```shell
$ eksctl scale nodegroup --cluster myeks-custom --help
Scale a nodegroup

Usage: eksctl scale nodegroup [flags]

Aliases: nodegroup, ng

General flags:
      --cluster string       EKS cluster name
  -n, --name string          Name of the nodegroup to scale
  -f, --config-file string   load configuration from a file (or stdin if set to '-')
  -N, --nodes int            desired number of nodes (required) (default -1)
  -M, --nodes-max int        maximum number of nodes (default -1)
  -m, --nodes-min int        minimum number of nodes (default -1)
  -r, --region string        AWS region. Defaults to the value set in your AWS config (~/.aws/config)
      --timeout duration     maximum waiting time for any long-running operation (default 25m0s)

AWS client flags:
  -p, --profile string         AWS credentials profile to use (defaults to value of the AWS_PROFILE environment variable)
      --cfn-role-arn string    IAM role used by CloudFormation to call AWS API on your behalf
      --cfn-disable-rollback   for debugging: If a stack fails, do not roll it back. Be careful, this may lead to unintentional resource consumption!

Common flags:
  -C, --color string   toggle colorized logs (valid options: true, false, fabulous) (default "true")
  -d, --dumpLogs       dump logs to disk on failure if set to true
  -h, --help           help for this command
  -v, --verbose int    set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging (default 3)
```

<br>

**예시**

Desired number of nodes(원하는 노드의 수)를 수정해보자.

현재 노드 그룹의 상태는 다음과 같고,

```shell
$ eksctl get nodegroup --cluster myeks-custom
CLUSTER         NODEGROUP       STATUS  CREATED                 MIN SIZE        MAX SIZE        DESIRED CAPACITY       INSTANCE TYPE    IMAGE ID        ASG NAME                                                TYPE
myeks-custom    myeks-ng1       ACTIVE  2022-06-05T14:41:31Z    2               4               3                      t3.medium        AL2_x86_64      eks-myeks-ng1-8ac09a28-288f-6ab0-5ff3-f759aa3af27a      managed
```

다음 명령을 통해 Desired number of nodes를 2로 수정할 수 있다.

```shell
eksctl scale nodegroup --name myeks-ng1 --cluster myeks-custom --nodes 2
```

`DESIRED`가 2로 변경된 것을 확인할 수 있다.

```shell
$ eksctl get nodegroup --cluster myeks-custom
CLUSTER         NODEGROUP       STATUS  CREATED                 MIN SIZE        MAX SIZE        DESIRED CAPACITY       INSTANCE TYPE    IMAGE ID        ASG NAME                                                TYPE
myeks-custom    myeks-ng1       ACTIVE  2022-06-05T14:41:31Z    2               4               2                      t3.medium        AL2_x86_64      eks-myeks-ng1-8ac09a28-288f-6ab0-5ff3-f759aa3af27a      managed
```

<br>

<br>

## 자동 스케일링

[AWS EKS AutoScaling 공식문서](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/autoscaling.html)에 따라 진행해보자.

클러스터는 다음 yaml 파일로 생성하였고, IAM 정책 및 역할 생성까지 충족된 상태이다.

<br>

`myeks.yaml`

```yaml
apiVersion: eksctl.io/v1alpha5 
kind: ClusterConfig 

metadata:
  name: myeks-custom #cluster 이름
  region: ap-northeast-2 
  version: "1.22"

# 가용영역 지정
availabilityZones: ["ap-northeast-2a", "ap-northeast-2b",  "ap-northeast-2c"]

#IAM 계정을 만들어 연결
iam:
  withOIDC: true #OIDC(OpenID Connect) : eks입장에서 AWS IAM은 외부인증서버이기 때문에 OIDC를 true로 하지 않으면 
                 #                       AWS 계정과 eks 계정은 완전히 별개이다.
  serviceAccounts: #SA 계정 생성 -> 이후 addon 추가할 때 필요
    - metadata:
        name: aws-load-balancer-controller #SA 계정 이름
        namespace: kube-system
      wellKnownPolicies:
        awsLoadBalancerController: true #계정에 권한 부여 : ingress를 만들 때 사용
    - metadata:
        name: ebs-csi-controller-sa #SA 계정 이름
        namespace: kube-system
      wellKnownPolicies:
        ebsCSIController: true #계정에 권한 부여 : ebs
    - metadata: 
        name: cluster-autoscaler #SA 계정 이름
        namespace: kube-system
      wellKnownPolicies:
        autoScaler: true #계정에 권한 부여

# Managed Node Groups : worker node 그룹
managedNodeGroups: #여러개 세팅 가능
  # On-Demand Instance
  - name: myeks-ng1
    instanceType: t3.medium
    minSize: 2
    desiredCapacity: 3 #cluster 오토스케일링된다
    maxSize: 4
    privateNetworking: true #기본적으로 EC2는 public에 배치된다(앞서 EXTERNAL-IP 부여된 것 확인했었다)
                            #외부에 노출되는 것은 위험하기 때문에 private 배치애햐한다
    ssh:
      allow: true 
      publicKeyPath: ./keypair/myeks.pub  #접속할 ssh 키
    availabilityZones: ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
    iam:
      withAddonPolicies: #IAM 계정 정책
        autoScaler: true
        albIngress: true
        cloudWatch: true #로그를 남기기 위해
        ebs: true

# Fargate Profiles
fargateProfiles:
  - name: fg-1
    selectors:
    - namespace: dev
      labels:
        env: fargate
        
        
# CloudWatch Logging
cloudWatch:
  clusterLogging:
    enableTypes: ["*"]
```

<br>

먼저 Cluster Autoscaler YAMl 파일을 다운받는다.

```
curl -o cluster-autoscaler-autodiscover.yaml https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

다음으로 `cluster-autoscaler-autodiscover.yaml`에서 `<YOUR CLUSTER NAME>`을 클러스터명으로 수정한다.

앞선 클러스터 yaml 파일에서 확인할 수 있듯이 본 실습에서는 myeks-custom이다.

```
163: - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/myeks-custom
```

그리고 수정 사항을 적용한다.

```
kubectl apply -f cluster-autoscaler-autodiscover.yaml
```

cluster-autoscaler가 배포된 것을 확인할 수 있다.

```shell
$ kubectl get po -n kube-system
NAME                                  READY   STATUS    RESTARTS   AGE
...
cluster-autoscaler-66d46c46d4-2vsz8   1/1     Running   0          2m19s
...
```

다음 명령어를 실행했을 때, annotation이 정상적으로 들어가있기 때문에 따로 수정할 필요는 없다.

만약 설정이 안되어있다면 annotaion을 반드시 설정해주자.

```shell
kubectl describe sa cluster-autoscaler -n kube-system
```

다음으로 deployment에 `cluster-autoscaler.kubernetes.io/safe-to-evict` annotaion을 추가한다.

```
kubectl -n kube-system edit deployment.apps/cluster-autoscaler
```

`spec.template.metadata.annotations`

```yaml
...
spec:
...
  template:
    metadata:
      annotations:
        cluster-autoscaler.kubernetes.io/safe-to-evict: "false" #추가하기
...
```

`spec.containers.command`의 `<YOUR CLUSTER NAME>`를 클러스터의 이름(myeks-custom)으로 교체하고 다음 옵션을 추가한다.

- `--balance-similar-node-groups`
- `--skip-nodes-with-system-pods=false`

```yaml
      - command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage= "false"
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/myeks-custom #클러스터명 수정
        - --balance-similar-node-groups #옵션 추가
        - --skip-nodes-with-system-pods=false #옵션 추가
```

<br>

다음으로 웹 브라우저의 GitHub에서 Cluster Autoscaler [[릴리스(releases)](https://github.com/kubernetes/autoscaler/releases)] 페이지를 열고 클러스터의 Kubernetes 메이저 및 마이너 버전과 일치하는 최신 Cluster Autoscaler 버전을 검색하여, 해당 버전으로 image를 수정한다.

현시점(2022.6)에서는 `v1.22.2`이다.

```
kubectl set image deployment cluster-autoscaler -n kube-system cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:v1.22.2
```

<br>

Cluster Autoscaler 를 deploy 한 후에 로그를 확인하여 제대로 동작하는지 확인한다.

```shell
kubectl -n kube-system logs -f deployment.apps/cluster-autoscaler
```

<br>

**예시**

다음과 같이 deployment `myweb-deploy`를 생성한다.

<br>

`sample.yaml`

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myweb-deploy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: myweb
          image: ghcr.io/c1t1d0s7/go-myweb:alpine
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: 200m
              memory: 200M
            limits:
              cpu: 200m
              memory: 200M
```

```shell
kubectl create -f sample.yaml
```

현재 파드가 2개인 것을 확인할 수 있다.

```shell
$ kubectl get po
NAME                            READY   STATUS    RESTARTS   AGE
myweb-deploy-5c4cbfd766-kjfzr   1/1     Running   0          40s
myweb-deploy-5c4cbfd766-mlj9f   1/1     Running   0          40s
```

다음과 같이 deployment의 replicase를 10으로 수정한다.

```shell
kubectl scale deploy myweb-deploy --replicas=10
```

현재 노드는 2개가 존재하고, 파드를 확인해보면 다음과 같다.

```shell
$ kubectl get po
NAME                            READY   STATUS    RESTARTS   AGE
myweb-deploy-5c4cbfd766-2php6   0/1     Pending   0          4s
myweb-deploy-5c4cbfd766-2xhzz   1/1     Running   0          4s
myweb-deploy-5c4cbfd766-2zx99   1/1     Running   0          4s
myweb-deploy-5c4cbfd766-77zsk   1/1     Running   0          4s
myweb-deploy-5c4cbfd766-9b7np   1/1     Running   0          4s
myweb-deploy-5c4cbfd766-fg92v   1/1     Running   0          10s
myweb-deploy-5c4cbfd766-rv66k   0/1     Pending   0          4s
myweb-deploy-5c4cbfd766-rwxnw   1/1     Running   0          4s
myweb-deploy-5c4cbfd766-wmxm8   1/1     Running   0          10s
myweb-deploy-5c4cbfd766-xmrvp   0/1     Pending   0          4s
```

현재 노드의 개수가 2개이고 하나의 노드에 최대 4개까지 배치될 수 있기 때문에,

노드에 배치되지 못해 Pending 상태의 파드가 있는 것이다.

```shell
$ eksctl get nodegroup --cluster myeks-custom
CLUSTER         NODEGROUP       STATUS  CREATED                 MIN SIZE        MAX SIZE        DESIRED CAPACITY       INSTANCE TYPE    IMAGE ID        ASG NAME                                                TYPE
myeks-custom    myeks-ng1       ACTIVE  2022-06-05T14:41:31Z    2               4               2                      t3.medium        AL2_x86_64      eks-myeks-ng1-8ac09a28-288f-6ab0-5ff3-f759aa3af27a      managed
```

pending 상태의 파드를 임의로 한개 선택하여 `kubectl describe` 명령어로 Events를 보면

`2 Insufficient cpu`와 `pod triggered scale-up`을 확인할 수 있다.

```shell
Events:
  Type     Reason            Age   From                Message
  ----     ------            ----  ----                -------
  Waring  FailedScheduling  15s   default-scheduler   0/2 nodes are available: 2 Insufficient cpu.
  Normal   TriggeredScaleUp  9s    cluster-autoscaler  pod triggered scale-up: [{eks-myeks-ng1-8ac09a28-288f-6ab0-5ff3-f759aa3af27a 2->3 (max: 4)}]
```

시간이 좀 더 지나면 node가 3개로 오토스케일링되고,

```shell
$ kubectl get nodes
NAME                                                STATUS   ROLES    AGE     VERSION
ip-192-168-100-17.ap-northeast-2.compute.internal   Ready    <none>   13m     v1.22.6-eks-7d68063
ip-192-168-135-92.ap-northeast-2.compute.internal   Ready    <none>   6h33m   v1.22.6-eks-7d68063
ip-192-168-185-60.ap-northeast-2.compute.internal   Ready    <none>   27m     v1.22.6-eks-7d68063
```

파드가 모두 배치되어 Running 상태가 된 것을 확인할 수 있다.

```shell
$ kubectl get po
NAME                            READY   STATUS    RESTARTS   AGE
myweb-deploy-5c4cbfd766-2php6   1/1     Running   0          2m44s
myweb-deploy-5c4cbfd766-2xhzz   1/1     Running   0          2m44s
myweb-deploy-5c4cbfd766-2zx99   1/1     Running   0          2m44s
myweb-deploy-5c4cbfd766-77zsk   1/1     Running   0          2m44s
myweb-deploy-5c4cbfd766-9b7np   1/1     Running   0          2m44s
myweb-deploy-5c4cbfd766-fg92v   1/1     Running   0          2m50s
myweb-deploy-5c4cbfd766-rv66k   1/1     Running   0          2m44s
myweb-deploy-5c4cbfd766-rwxnw   1/1     Running   0          2m44s
myweb-deploy-5c4cbfd766-wmxm8   1/1     Running   0          2m50s
myweb-deploy-5c4cbfd766-xmrvp   1/1     Running   0          2m44s
```

<br>

<br>

## CloudWatch Container Insight

EKS에서 **Conatiner Insight 기능을 사용하면** Prometheus, EFK를 구성하지 않더라도

**기본적인 모니터링과 로깅이 가능**하다.

<br>

[Container-Insights-setup-EKS-quickstart](https://docs.aws.amazon.com/ko_kr/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html)에 따라 진행해보자. 본 실습에서는 Fluent Bit를 사용한다.

shell을 사용중이라면 바로 다음 명령을 실행하면 되고,

글쓴이는 windows에서 실습 중이라, bash를 실행하기 위해 Git Bash를 사용했다.

👉  [Git Bash 설치하기](https://github.com/git-for-windows/git/releases/download/v2.36.1.windows.1/Git-2.36.1-64-bit.exe)

```
ClusterName=myeks-custom
RegionName=ap-northeast-2
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${RegionName}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl apply -f - 
```

`amazon-cloudwatch` 네임스페이스에 `cloudwatch-agent`와 `fluent-bit`를 확인할 수 있다.

<u>**fluent bit가 로그를 수집하고, cloudwatch로 전송**</u>시킨다.

```shell
$ kubectl get po -n amazon-cloudwatch
NAME                     READY   STATUS    RESTARTS   AGE
cloudwatch-agent-kgjwq   1/1     Running   0          63s
cloudwatch-agent-r68pk   1/1     Running   0          63s
fluent-bit-ht594         1/1     Running   0          63s
fluent-bit-rwsjb         1/1     Running   0          63s
```

<br>

AWS CloudWatch를 콘솔로 접속해보면 다음과 같이 로그 그룹들을 확인할 수 있다.

- `/aws/eks/myeks-custom/cluster`  : ControlPlane의 로그

- `/aws/containerinsights/myeks-custom/application` : 애플리케이션의 로그
- `/aws/containerinsights/myeks-custom/host` : 호스트의 로그
- `/aws/containerinsights/myeks-custom/performance` : 성능 데이터 수집 로그

<br>

![image-20220606052711181](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220606052711181.png)

<br>

로그들은 만기가 없고, 계속 쌓이기 때문에 잘 관리해주어야한다.

<br>

[인사이트] - [Container Insights]를 클릭하면 다음과 같은 정보들을 확인할 수 있다.

![image-20220606053310661](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220606053310661.png)

Prometheus를 사용하지 않더라도 CPU/Memory 리소스량 등을 확인할 수 있는 것이다.

다음과 같이 컨테이너 맵도 확인할 수 있으며,

![image-20220606053844755](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220606053844755.png)

<br>

Performance monitoring도 가능하다.

<br>

![image-20220606053916021](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220606053916021.png)

<br>

실습이 끝나고 cluster와 로그를 삭제하는 것을 잊지말자.

```shell
eksctl delete cluster -f .\myeks.yaml --force --disable-nodegroup-eviction
```

<br>

Prometheus 및 EKF을 구성하는 내용은 아래의 포스팅에서 확인할 수 있다.

- [k8s Logging : EFK 개요 및 설치](https://nayoungs.tistory.com/entry/Kubernetes-k8s-Logging-EFK-%EA%B0%9C%EC%9A%94-%EB%B0%8F-%EC%84%A4%EC%B9%98)
- [k8s monitoring : Helm으로 Prometheus, Grafana 설치하기](https://nayoungs.tistory.com/entry/Kubernetes-k8s-Minitoring-Helm%EC%9C%BC%EB%A1%9C-Prometheus-Grafana-%EC%84%A4%EC%B9%98%ED%95%98%EA%B8%B0)

<br>

<br>

<br>

Reference

- https://swalloow.github.io/eks-autoscale/
- [AutoScaling - Amazon EKS](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/autoscaling.html)

<br>