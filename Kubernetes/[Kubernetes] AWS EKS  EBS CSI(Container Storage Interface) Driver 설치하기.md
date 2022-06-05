# [Kubernetes] AWS EKS : EBS CSI(Container Storage Interface) Driver 설치하기

<br>

[CSI(Container Storage Interface)](https://kubernetes-csi.github.io/docs/introduction.html)란, Kubernetes와 같은 CO(컨테이너 오케스트레이션 시스템)의 **컨테이너화된 워크로드에 임의의 블록 및 파일 스토리지 시스템을 노출하기 위한 표준 인터페이스**이다.

<br>

[Amazon EBS CSI Driver](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/ebs-csi.html)를 사용하면 **표준 Kubernetes 인터페이스를 사용**하여, AWS에서 EKS 및 자체 관리형 Kubernetes 클러스터 모두에서 실행되는 애플리케이션에 대해 **블록 스토리지를 간단하게 구성하고 사용**할 수 있다.

Amazon EBS CSI Driver에서는Amazon EKS 클러스터가 영구 볼륨을 위해 <u>Amazon EBS 볼륨의 수명 주기를 관리</u>할 수 있게 해준다.

클러스터를 처음 생성할 때는 Amazon EBS CSI Driver가 설치되지 않으며, 

드라이버를 사용하려면 <u>Amazon EKS 추가 기능</u> 또는 자체 관리형 추가 기능으로 드라이버를 추가해야 한다.

<br>

아래 그림은 일반적인 CSI Driver의 구조이다.

AWS EBS CSI driver 역시 다음과 같은 구조를 가지는데, 우측 StatefulSet 또는 Deployment로 배포된 controller Pod이 AWS API를 사용하여 실제 EBS volume을 생성하는 역할을 한다. 좌측 DaemonSet으로 배포된 node Pod은 AWS API를 사용하여 Kubernetes node (EC2 instance)에 EBS volume을 attach 해준다.

<br>

![CSI structure](https://hyperconnect.github.io/assets/2021-07-05-ebs-csi-gp3-support/01-csi-structure.png)

<br>

<br>

### EBS CSI Driver 설치하기

[managing-ebs-csi](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/managing-ebs-csi.html)에 따라 설치해보자.

[NLB, ALB로 EKS 배포하기](https://nayoungs.tistory.com/entry/Kubernetes-NLB-ALB%EB%A1%9C-EKS-%EB%B0%B0%ED%8F%AC%ED%95%98%EA%B8%B0-with-yaml)에 이어서 진행하며, 현재 IAM 계정 설정까지 완료된 상태(yaml 파일에 정의)이다.

addon 설치부터 진행하며, 클러스터 yaml파일은 다음과 같다.

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

클러스터 생성이 되어있지 않다면, 다음 명령을 통해 클러스터를 생성한다.

```shell
eksctl create cluster -f myeks.yaml
```

생성 후, 다음과 같이 role을 확인할 수 있다.

```shell
$ eksctl get iamserviceaccount --cluster myeks-custom
NAMESPACE       NAME                            ROLE ARN
kube-system     aws-load-balancer-controller    arn:aws:iam::xxxxxxxxxxxx:role/eksctl-myeks-custom-addon-iamserviceaccount-Role1-8AMSGCDRD4JC
kube-system     aws-node                        arn:aws:iam::xxxxxxxxxxxx:role/eksctl-myeks-custom-addon-iamserviceaccount-Role1-1SIOBJ3B0WDDL
kube-system     cluster-autoscaler              arn:aws:iam::xxxxxxxxxxxx:role/eksctl-myeks-custom-addon-iamserviceaccount-Role1-86B8C7A4ZBUF
kube-system     ebs-csi-controller-sa           arn:aws:iam::xxxxxxxxxxxx:role/eksctl-myeks-custom-addon-iamserviceaccount-Role1-1NNQO9W67BBCY
```

다음으로, `aws-ebs-csi-driver` 애드온을 설치한다.

```shell
eksctl create addon --name aws-ebs-csi-driver --cluster myeks-custom --service-account-role-arn  arn:aws:iam::[account]:role/eksctl-myeks-custom-addon-iamserviceaccount-Role1-15HLE8HBOD9CN --force
```

`ebs-csi-*` 파드가 생성된 것을 확인할 수 있다.

```shell
$ kubectl get po -A
NAMESPACE     NAME                                  READY   STATUS    RESTARTS   AGE
...
kube-system   ebs-csi-controller-84bcf56778-5mbk7   6/6     Running   0          25m
kube-system   ebs-csi-controller-84bcf56778-p7snc   6/6     Running   0          25m
kube-system   ebs-csi-node-fzl2v                    3/3     Running   0          25m
kube-system   ebs-csi-node-qgw25                    3/3     Running   0          25m
kube-system   ebs-csi-node-sd45p                    3/3     Running   0          25m
...                  1/1     Running   0          66m
```

이제 <u>**EBS 스냅샷 및 EBS 사이즈 조정**</u> 등의 기능을 사용할 수 있게 된 것이다.

<br>

**`eksctl`을 사용하여 Amazon EBS CSI 추가 기능을 제거하려면** 클러스터 이름을 수정하고 다음 명령을 실행한다.

```shell
eksctl delete addon --cluster [클러스터 이름] --name aws-ebs-csi-driver --preserve
```

<br>

<br>

<br>

Reference

- https://aws.amazon.com/ko/about-aws/whats-new/2021/05/amazon-ebs-container-storage-interface-driver-is-now-generally-available/

- https://nyyang.tistory.com/112

- https://hyperconnect.github.io/2021/07/05/ebs-csi-gp3-support.html