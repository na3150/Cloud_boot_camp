# [Kubernetes] NLB, ALB로 EKS 배포하기 with yaml

<br>

### 📌Index

- [Network Load Balancer(NLB)](#network-load-balancernlb)
- [Ingress for ALB](#ingress-for-alb)

<br>

<br>

## Network Load Balancer(NLB)

참고 문서

- https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/network-load-balancing.html
- https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/alb-ingress.html
- https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/aws-load-balancer-controller.html

<br>

실습을 진행할 적당한 디렉토리를 만든다.

```
$ mkdir aws-eks
$ cd aws-eks
```

그리고 다음과 같이 yaml파일을 작성한다. 

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

이후에 필요시 EC2인스턴스에 ssh 연결하기 위해 key를 생성한다. 

```shell
$ mkdir keypair
$ ssh-keygen -f keypair/myeks
```

**클러스터 생성**

```shell
$ eksctl create cluster -f myeks.yaml
```

**클러스터 확인**

```shell
$ eksctl get clusters
NAME            REGION          EKSCTL CREATED
myeks           ap-northeast-2  True
myeks-custom    ap-northeast-2  True
```

**노드 그룹 확인**

```shell
$ eksctl get nodegroup --cluster myeks-custom
CLUSTER         NODEGROUP       STATUS  CREATED                 MIN SIZE        MAX SIZE DESIRED CAPACITY INSTANCE TYPE   IMAGE ID        ASG NAME                                 TYPE
myeks-custom    myeks-ng1       ACTIVE  2022-05-30T17:09:04Z    2               4        t3.medium        AL2_x86_64      eks-myeks-ng1-1cc08af8-9fbb-30f0-80e3-f26532578967      managed
```

쿠버네티스에도 sa 계정이 존재하며, aws iam에도 계정이 만들어져 권한이 부여된다.

```shell
$ kubectl get sa -n kube-system
NAME                                 SECRETS   AGE
aws-load-balancer-controller         1         24m
...
cluster-autoscaler                   1         24m
...
ebs-csi-controller-sa                1         24m
```

```shell
$ eksctl get iamserviceaccount --cluster myeks-custom
NAMESPACE       NAME                            ROLE ARN
kube-system     aws-load-balancer-controller    arn:aws:iam::xxxxxxxxxxxx:role/eksctl-myeks-custom-addon-iamserviceaccount-Role1-18T5Q789JXIIG
kube-system     aws-node                        arn:aws:iam::xxxxxxxxxxxx:role/eksctl-myeks-custom-addon-iamserviceaccount-Role1-WVXC3PZ31SRX
kube-system     cluster-autoscaler              arn:aws:iam::xxxxxxxxxxxx:role/eksctl-myeks-custom-addon-iamserviceaccount-Role1-1FMQN08KG5I2P
kube-system     ebs-csi-controller-sa           arn:aws:iam::xxxxxxxxxxxx:role/eksctl-myeks-custom-addon-iamserviceaccount-Role1-1VZI0D4A8UQXE
```

<br>

AWS 콘솔창에 접속해보면, 

Private Network에 배치되었기 때문에 PublicIP가 없는 것을 확인할 수 있다.

![image-20220531025029988](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220531025029988.png)

<br>

지금부터 네트워크 로드밸런서를 구성해보자.

<br>

`myapp.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myweb-deploy
spec:
  replicas: 3
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
          image: ghcr.io/c1t1d0s7/go-myweb
          ports:
            - containerPort: 8080
```

`mysvc.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myweb-svc-lb
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "external" #외부용
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "instance" #NLB의 타겟이 EC2 인스턴스
	service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing" #public subnet에 배치
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 8080
```

```shell
$ kubectl create -f myapp.yaml -f mysvc.yaml
```

myweb-svc의 EXTERNAL-IP가 Pending상태인 것을 확인할 수 있다.

```shell
$  kubectl get deploy,rs,po,svc,ep
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/myweb-deploy   3/3     3            3           52s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/myweb-deploy-657f957c85   3         3         3       52s

NAME                                READY   STATUS    RESTARTS   AGE
pod/myweb-deploy-657f957c85-j7k2t   1/1     Running   0          52s
pod/myweb-deploy-657f957c85-wd8sf   1/1     Running   0          52s
pod/myweb-deploy-657f957c85-xhj2n   1/1     Running   0          52s

NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/kubernetes     ClusterIP      10.100.0.1      <none>        443/TCP        58m
service/myweb-svc-lb   LoadBalancer   10.100.48.137   <pending>     80:32379/TCP   88s

NAME                     ENDPOINTS                                                      AGE
endpoints/kubernetes     192.168.111.160:443,192.168.153.209:443                        58m
endpoints/myweb-svc-lb   192.168.120.89:8080,192.168.136.196:8080,192.168.174.88:8080   88s
```

<br>

#### Helm을 이용한 AWS Load Balancer Controller 설치

ALB, NLB는 모두 AWS Load Balancer Controller가 설치되어있어야한다.

<br>

레포지토리를 추가한다.

```shell
$ helm repo add eks https://aws.github.io/eks-charts
$ helm repo update
```

로드밸런서를 배포한다.

```shell
$ helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=myeks-custom --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set image.repository=602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller
```

정상적으로 완료되면 다음과 같이 출력된다.

```shell
NAME: aws-load-balancer-controller
LAST DEPLOYED: Tue May 31 2022
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
AWS Load Balancer controller installed!
```

```shell
$ kubectl get svc
NAME           TYPE           CLUSTER-IP      EXTERNAL-IP                                                                         PORT(S)        AGE
kubernetes     ClusterIP      10.100.0.1      <none>                                                                              443/TCP        81m
myweb-svc-lb   LoadBalancer   10.100.48.137   k8s-default-mywebsvc-eed26917ed-199129362285b235.elb.ap-northeast-2.amazonaws.com   80:32379/TCP   24m
```

AWS 콘솔에서 확인하면 network 유형의 로드밸런서가 생성된 것을 확인할 수 있다.

<br>

![image-20220531032241563](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220531032241563.png)

<br>

로드밸런서로 정상적으로 접속되는 것을 확인할 수 있다!

<br>

![image-20220531032419868](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220531032419868.png)

<br>

<br>

## Ingress for ALB

참고 : https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/alb-ingress.html

앞선 NLB 실습에 이어서 진행한다.

<br>

먼저 실습을 진행할 적당한 디렉토리를 생성한다.

```shell
$ mkdir alb
$ cd alb
```

다음과 같이 Ingress 파일을 작성한다. 

`myweb-ing.yaml`


```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myweb-ing
  annotations:
    kubernetes.io/ingress.class: alb #alb를 사용한다는 의미
    alb.ingress.kubernetes.io/target-type: instance #target이 ec2 인스턴스
    alb.ingress.kubernetes.io/scheme: internet-facing #외부에 노출
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myweb-svc-lb
                port:
                  number: 80
```

```shell
$ kubectl create -f myweb-ing.yaml
```

인그레스 생성 후 AWS 콘솔에서 확인하면 application 타입의 로드밸런서가 생성된 것을 확인할 수 있다.

<br>

![image-20220531040130081](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220531040130081.png)

<br>

```shell
$ kubectl get ing
NAME        CLASS    HOSTS   ADDRESS                                                                       PORTS   AGE
myweb-ing   <none>   *       k8s-default-mywebing-2cd848a527-2069486546.ap-northeast-2.elb.amazonaws.com   80      111s
```

Ingress의 주소로 접속을 시도하면 정상적으로 접속되는 것을 확인할 수 있다.

<br>

![image-20220531035330436](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220531035330436.png)

<br>

**☁️ 참고**

- `alb.ingress.kubernetes.io/target-type`
  - instance: EC2 타겟
  - ip: Pod 타겟(Fargate)
- `alb.ingress.kubernetes.io/scheme`
  - internal: 내부
  - internet-facing: 외부
