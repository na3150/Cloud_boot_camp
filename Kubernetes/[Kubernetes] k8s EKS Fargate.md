## [Kubernetes] EKS Fargate

**EKS(Elastic Kubernetes Service)에는 크게 <u>Fargate 시작 유형</u>과 <u>EC2 시작 유형</u>이라는 두 가지 모델**이 있다.

<br>

**Fargate 시작 유형** 

- 애플리케이션을 컨테이너로 패키징
- CPU와 메모리 요구 사항을 지정
- 네트워킹과 IAM 정책을 정의
- 애플리케이션을 시작

<br>

**EC2 시작 유형**

- 세분화된 제어 가능
- Amazon ECS 및 EKS를 사용하여
  - 서버 클러스터를 관리
  - 서버에 컨테이너를 배치하는 일정을 예약
  - Amazon ECS 및 EKS는 클러스터 내 모든 CPU, 메모리 및 기타 리소스를 계속 추적
  - 지정한 리소스 요구 사항에 따라 컨테이너를 실행하기에 가장 적합한 서버 찾기

<br>

EC2 시작 유형은 [여기](https://nayoungs.tistory.com/entry/Kubernetes-NLB-ALB%EB%A1%9C-EKS-%EB%B0%B0%ED%8F%AC%ED%95%98%EA%B8%B0-with-yaml)에서 살펴봤었다.

**Fargate는 EC2 인스턴스를 사용하지 않고, 바로 Pod로 배포**한다.

<br>

#### Fargate 고려 사항

- 일부 리전에서는 지원되지 않는다.
- Fargate는 노드를 추상화시킨 것으로, 노드가 없는 것이기 때문에 DaemonSets은 지원되지 않는다.
- Network Load Balancer(NLB) 및 Application Load Balancer(ALB)는 IP 대상을 통해서만 Fargate에서 사용할 수 있다.
  - `alb.ingress.kubernetes.io/target-type`을 **IP(Pod 타겟)로 지정**⭐해야한다.
- GPU가 있는 인스턴스 타입은 사용할 수 없다.

이외의 더 많은 사항은 [AWS Fargate 고려 사항](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/fargate.html)에서 확인할 수 있다.

<br>

**💻 실습** 

먼저 cluster 생성을 위한 yaml파일을 작성한다. 

이때, **Fargate 구성**은 다음과 같이 작성한다.

```yaml
# Fargate Profiles : Fargate를 배포하기 위한 구성
fargateProfiles:
  - name: fg-1
    selectors:
    - namespace: dev #선택적으로 구성
      labels:
        env: fargate #선택적으로 구성
```

`fargateProfiles`로 fargate를 사용할 조건을 지정한다.

여기서는 파드의 `namespace`가 `dev`이고, `label`이 `env:fargate`이면, 즉 **조건을 만족하면**

**Fargate 컨트롤러가 해당 파드를 인식하고 자동으로 Fargate에 배치**시킨다.

둘 중 하나라도 만족시키지 않으면 worker노드에 배치시키게 된다.

`myeks.yaml`

```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: myeks-custom
  region: ap-northeast-2
  version: "1.22"

# AZ
availabilityZones: ["ap-northeast-2a", "ap-northeast-2b",  "ap-northeast-2c"]

# IAM OIDC & Service Account
iam:
  withOIDC: true
  serviceAccounts:
    - metadata:
        name: aws-load-balancer-controller
        namespace: kube-system
      wellKnownPolicies:
        awsLoadBalancerController: true
    - metadata:
        name: ebs-csi-controller-sa
        namespace: kube-system
      wellKnownPolicies:
        ebsCSIController: true
    - metadata:
        name: cluster-autoscaler
        namespace: kube-system
      wellKnownPolicies:
        autoScaler: true

# Managed Node Groups
managedNodeGroups:
  # On-Demand Instance
  - name: myeks-ng1
    instanceType: t3.medium
    minSize: 2
    desiredCapacity: 3
    maxSize: 4
    privateNetworking: true
    ssh:
      allow: true
      publicKeyPath: ./keypair/myeks.pub
    availabilityZones: ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
    iam:
      withAddonPolicies:
        autoScaler: true
        albIngress: true
        cloudWatch: true
        ebs: true

# Fargate Profiles : Fargate를 배포하기 위한 구성
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

```shell
$ eksctl create cluster -f myeks.yaml
```

다음과 같이 Fargate에 배치시키지 않을 파드를 생성한다.

`nofg.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nofg
  labels:
    name: nofg
spec:
  containers:
  - name: nofg
    image: ghcr.io/c1t1d0s7/go-myweb
    ports:
      - containerPort: 8080
```

```shell
$ kubectl create -f nofg.yaml
```

<br>

다음으로 Fargate에 배치시킬 파드를 위해 dev 네임스페이스를 미리 생성한다.

```shell
$ kubectl create ns dev
```

Fargate에 배치시킬 파드는 다음과 같이 작성한다.

이때, 앞서 cluster yaml파일에서 작성했던 **`fargateProfiles` 조건을 만족**하도록 한다.

`fg.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: fg
  namespace: dev #ns 만족
  labels:
    name: fg
    env: fargate #label 만족
spec:
  containers:
  - name: fg
    image: ghcr.io/c1t1d0s7/go-myweb
    ports:
      - containerPort: 8080
```

```shell
$ kubectl create -f fg.yaml
```

<br>

**하나의 파드가 하나의 Fargate Node로 구성**되며, 

내부적으로 이 Fargate Node는 매우 경량의 VM이 사용된다.

```shell
$ kubectl get pod -o wide -n dev
NAME   READY   STATUS    RESTARTS   AGE        IP                        NODE     NOMINATED NODE                                READINESS GATES
fg     1/1     Running   0          45s   192.168.97.21   fargate-ip-192-168-97-21.ap-northeast-2.compute.internal   <none>   <none>
```

다음과 같이 fargate-ip 노드를 확인할 수 있다.

```shell
$ kubectl get nodes
NAME                                                       STATUS   ROLES    AGE     VERSION
fargate-ip-192-168-97-21.ap-northeast-2.compute.internal   Ready    <none>   44s     v1.22.6-eks-7d68063
ip-192-168-125-149.ap-northeast-2.compute.internal         Ready    <none>   6m43s   v1.22.6-eks-7d68063
ip-192-168-145-118.ap-northeast-2.compute.internal         Ready    <none>   6m39s   v1.22.6-eks-7d68063
ip-192-168-172-210.ap-northeast-2.compute.internal         Ready    <none>   6m38s   v1.22.6-eks-7d68063
```

다음으로 접속 테스트를 위해 deployment와 서비스를 생성해보자.

`myapp.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myfg
  namespace: dev
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myfg
  template:
    metadata:
      labels:
        app: myfg
        env: fargate
    spec:
      containers:
      - name: myfg
        image: ghcr.io/c1t1d0s7/go-myweb
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 8080
```

`mysvc.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysvc
  namespace: dev
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "external" #외부
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip" #ip대상 --> fargate 조건
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing" #외부
spec:
  selector:
    app: myfg
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

```shell
$ kubectl create -f myapp.yaml -f mysvc.yaml
```

다음으로 로드밸런서를 만들기 위해 helm으로 **aws load balancer controller를 설치**한다.

```shell
$ helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=myeks-custom --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set image.repository=602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller
```

생성된 결과는 다음과 같다.

파드 3개는 모두 다른 곳에 배치되었고, 로드밸런서가 생성된 것을 확인할 수 있다.

```shell
$ kubectl get all -n dev -o wide
NAME                        READY   STATUS    RESTARTS   AGE     IP                NODE                                                         NOMINATED NODE   READINESS GATES
pod/fg                      1/1     Running   0          12m     192.168.97.21     fargate-ip-192-168-97-21.ap-northeast-2.compute.internal     <none>           <none>
pod/myfg-5ffccc7d88-49282   1/1     Running   0          4m39s   192.168.181.189   fargate-ip-192-168-181-189.ap-northeast-2.compute.internal   <none>           <none>
pod/myfg-5ffccc7d88-5ndhf   1/1     Running   0          4m39s   192.168.123.110   fargate-ip-192-168-123-110.ap-northeast-2.compute.internal   <none>           <none>
pod/myfg-5ffccc7d88-bk8j4   1/1     Running   0          4m39s   192.168.144.224   fargate-ip-192-168-144-224.ap-northeast-2.compute.internal   <none>           <none>

NAME            TYPE           CLUSTER-IP       EXTERNAL-IP
                   PORT(S)        AGE     SELECTOR
service/mysvc   LoadBalancer   10.100.232.177   k8s-dev-mysvc-648fc756bf-378a6ef917f186c0.elb.ap-northeast-2.amazonaws.com   80:30961/TCP   3m54s   app=myfg

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                      SELECTOR
deployment.apps/myfg   3/3     3            3           4m39s   myfg         ghcr.io/c1t1d0s7/go-myweb   app=myfg

NAME                              DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES
     SELECTOR
replicaset.apps/myfg-5ffccc7d88   3         3         3       4m39s   myfg         ghcr.io/c1t1d0s7/go-myweb   app=myfg,pod-template-hash=5ffccc7d88
```

로드밸런서의 EXTERNAL-IP로 접속을 시도하면 정상적으로 접속되는 것을 확인할 수 있다.

<br>

![image-20220531095613806](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220531095613806.png)

<br>

실습을 마치고 클러스터를 삭제한다.

```shell
$ eksctl delete cluster -f .\myeks.yaml --force --disable-nodegroup-eviction
```

<br>

<br>

<br>

참고

- https://www.bespinglobal.com/tech-blog-180327-intro-aws-fargate/