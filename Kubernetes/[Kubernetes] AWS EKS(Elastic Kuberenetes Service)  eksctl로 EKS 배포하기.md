# [Kubernetes] AWS EKS(Elastic Kubernetes Ser) : eksctl을 이용한 EKS 배포

<br>

## AWS EKS

AWS EKS(Elastic Kubernetes Service)란, **k8s ControlPlane이나 Worker Node를 설치 및 운영할 필요 없이**  

AWS에서 쿠버네티스를 손쉽게 실행할 수 있도록 지원하는 **관리형 서비스**이다.

<br>

<img src="https://images.velog.io/images/seunghyeon/post/4d5953f0-f728-44bc-9b53-4cb86f48e88a/eks.png" alt="EKS와 K8S의 차이점" style="zoom: 33%;" />

<br>

 고급 설정은 [eksctl](https://eksctl.io/)로만 가능하기 때문에, 일반적으로 AWS 관리 콘솔은 이용하지 않는다. 

<br>

#### EKS 환경 구성

chocolatey를 이용하여 `awscli`, `aws-iam-authenticator`,` eksctl`, `kubernetes-helm`을 설치한다.

```shell
$ choco install awscli aws-iam-authenticator eksctl kubernetes-helm
```

AWS IAM 사용자를 생성하고, aws configure로 액세스키와 시크릿 키를 등록한다.

```shell
$ aws configure
```

사용자를 확인한다.

```shell
$ aws sts get-caller-identity
```

<br>

<br>

#### eksctl을 이용한 EKS 배포

다음과 같이 `eksctl` 명령어로 클러스터를 생성한다.

```shell
$ eksctl create cluster --name myeks --nodes=3 --region=ap-northeast-2
```

create시 다양한 옵션을 사용할 수 있고, 자세한 사항은  [eksctl 공식 문서](https://eksctl.io/)에서 확인할 수 있다.

<br>

클러스터 생성 완료 후, AWS에 접속해서 확인해보자.

 `eksctl`로 클러스터를 만들게 되면, AWS CloudFormation(CFN)이라는 IaC 도구에 Stack을 만들게 된다. 

<br>

CloudFormation에 stack이 생성된 것을 확인할 수 있고, 기본적으로 클러스터 하나당 

controlplane(`eksctl-myeks-cluster`)과 worker node(`eksctl-myeks-nodegroup`), 2개의 stack이 생성된다. 

![image-20220531002505288](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220531002505288.png)



EC2가 3개 생성된 것과

![image-20220531002725389](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220531002725389.png)

볼륨이 생성된 것도 확인할 수 있다.

![image-20220531002547765](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220531002547765.png)

시작 템플릿과 Auto Scaling Group이 자동으로 세팅되어있으며,

![image-20220531002608462](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220531002608462.png)

![image-20220531002649847](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220531002649847.png)

이외에도 VPC, 서브넷, 인터넷 게이트웨이 등등이 자동으로 세팅이 이루어지게 된다.

<br>

cluster 생성 후에는 AWS 콘솔에서 수정 및 삭제를 하면 꼬일 수 있으므로 권장하지 않는다.

지울 때는 `eksctl delete` 명령어를 이용하자.

<br>

kubeconfig 파일을 확인해보면, cluster, context, user가 생성된 것을 확인할 수 있다.

```shell
$ kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.100.100:6443
  name: cluster.local
- cluster: #클러스터 생성
    certificate-authority-data: DATA+OMITTED
    server: https://xxxxxxxx.gr7.ap-northeast-2.eks.amazonaws.com
  name: myeks.ap-northeast-2.eksctl.io
contexts:
- context: #context 생성
    cluster: myeks.ap-northeast-2.eksctl.io
    user: eksadmin@myeks.ap-northeast-2.eksctl.io
  name: eksadmin@myeks.ap-northeast-2.eksctl.io
- context:
    cluster: cluster.local
    user: kubernetes-admin
  name: kubernetes-admin@cluster.local
current-context: eksadmin@myeks.ap-northeast-2.eksctl.io
kind: Config
preferences: {}
users:
- name: eksadmin@myeks.ap-northeast-2.eksctl.io #IAM 계정과 연결된 사용자
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - token
      - -i
      - myeks
      command: aws-iam-authenticator
      env:
      - name: AWS_STS_REGIONAL_ENDPOINTS
        value: regional
      - name: AWS_DEFAULT_REGION
        value: ap-northeast-2
      interactiveMode: IfAvailable
      provideClusterInfo: false
- name: kubernetes-admin
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
```

context는 eksadmin으로 자동 설정된다.

```shell
$ kubectl config get-contexts
CURRENT   NAME                                      CLUSTER                          AUTHINFO                                  NAMESPACE
*         eksadmin@myeks.ap-northeast-2.eksctl.io   myeks.ap-northeast-2.eksctl.io   eksadmin@myeks.ap-northeast-2.eksctl.io
          kubernetes-admin@cluster.local            cluster.local                    kubernetes-admin
```

<br>

다음과 같이 worker node를 확인할 수 있는데, minikube, kubespray와 달리 EXTERNAL-IP가 부여된다. 

이 EXTERNAL-IP는 AWS EC2에서 확인할 수 있는 퍼블릭IP이다.

```shell
$ kubectl get nodes -o wide
NAME                                               STATUS   ROLES    AGE   VERSION               INTERNAL-IP     EXTERNAL-IP    OS-IMAGE         KERNEL-VERSION                 CONTAINER-RUNTIME
ip-192-168-56-81.ap-northeast-2.compute.internal   Ready    <none>   59m   v1.22.6-eks-7d68063   192.168.56.81   43.200.8.110   Amazon Linux 2   5.4.190-107.353.amzn2.x86_64   docker://20.10.13
ip-192-168-8-78.ap-northeast-2.compute.internal    Ready    <none>   59m   v1.22.6-eks-7d68063   192.168.8.78    3.38.185.153   Amazon Linux 2   5.4.190-107.353.amzn2.x86_64   docker://20.10.13
ip-192-168-92-17.ap-northeast-2.compute.internal   Ready    <none>   59m   v1.22.6-eks-7d68063   192.168.92.17   3.39.246.48    Amazon Linux 2   5.4.190-107.353.amzn2.x86_64   docker://20.10.13
```

`aws-node` 파드는 vagrant나 minikube에서는 볼 수 없는,

AWS EC2 인스턴스와 연결하기 위한 애플리케이션이 포함된 파드로, 노드 개수 만큼 `aws-node` 파드가 존재한다.

```shell
$ kubectl get po -A
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-gqlqr             1/1     Running   0          53m
kube-system   aws-node-khrtl             1/1     Running   0          53m
kube-system   aws-node-m94sn             1/1     Running   0          53m
kube-system   coredns-556f6dffc4-c7lnb   1/1     Running   0          62m
kube-system   coredns-556f6dffc4-j2xks   1/1     Running   0          62m
kube-system   kube-proxy-mmfjq           1/1     Running   0          53m
kube-system   kube-proxy-q4kcg           1/1     Running   0          53m
kube-system   kube-proxy-wd6v8           1/1     Running   0          53m
```

<br>

Test를 위해 deployment를 생성하고 외부에 노출(expose)해보자.

```shell
$ kubectl create deploy myapp --image nginx --replicas 3
$ kubectl expose deploy myapp --name mysvc --port 80 --target-port 80 --type NodePort
```

```shell
$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.100.0.1      <none>        443/TCP        86m
mysvc        NodePort    10.100.224.88   <none>        80:32136/TCP   14s
$ kubectl get nodes -o wide
NAME                                               STATUS   ROLES    AGE   VERSION               INTERNAL-IP     EXTERNAL-IP    OS-IMAGE         KERNEL-VERSION                 CONTAINER-RUNTIME
ip-192-168-56-81.ap-northeast-2.compute.internal   Ready    <none>   77m   v1.22.6-eks-7d68063   192.168.56.81   43.200.8.110   Amazon Linux 2   5.4.190-107.353.amzn2.x86_64   docker://20.10.13
ip-192-168-8-78.ap-northeast-2.compute.internal    Ready    <none>   77m   v1.22.6-eks-7d68063   192.168.8.78    3.38.185.153   Amazon Linux 2   5.4.190-107.353.amzn2.x86_64   docker://20.10.13
ip-192-168-92-17.ap-northeast-2.compute.internal   Ready    <none>   77m   v1.22.6-eks-7d68063   192.168.92.17   3.39.246.48    Amazon Linux 2   5.4.190-107.353.amzn2.x86_64   docker://20.10.13
```

그러나 아직 보안 그룹을 설정해두지 않았기 때문에 접속은 불가능하다.

```shell
$ curl 3.39.246.48:32136
```

서비스의 타입을 LoadBalancer로 수정해보자.

```shell
$ kubectl edit svc mysvc
```

로드 밸런서로 수정 후 AWS 로드밸런서를 확인하면 유형이 classic인 것을 확인할 수 있다. (default가 classic)

![image-20220531004808510](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220531004808510.png)

원래 서비스의 로드밸런서 타입은 클라우드를 위한 기능이나, 

온프레미스에서 사용하기 위해 metallb 등의 애드온을 붙여서 사용하는 것이다.

<br>

로드밸런서의 DNS로 접속하면 정상적으로 접속되는 것을 확인할 수 있다.

![image-20220531011944370](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220531011944370.png)

`eksctl`을 사용하면 default가 classic타입이나, classic Load Balancer는 되도록이면 안쓰는 것이 좋다.

<br>

eksctl에서 기본적으로 제공되지 않는 요소

- Load Balancer Service = classic(default)
  - nlb로 바꿔줘야한다.
- Ingress가 안된다.
- `kubectl top` 명령어가 안된다. 즉, HPA가 안된다.

<br>

옵션으로 설정을 지정하는데는 한계가 있기 때문에 일반적으로는 파일(yaml)로 작성한다.  

<br>

<br>