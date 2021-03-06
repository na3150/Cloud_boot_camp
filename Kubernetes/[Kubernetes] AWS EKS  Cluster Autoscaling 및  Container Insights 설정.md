# [Kubernetes] AWS EKS : Cluster Autoscaling ๋ฐ  Container Insights ์ค์ 

<br>

### ๐Index

- [Cluster AutoScaling](#cluster-autoscaling)
- [์๋ ์ค์ผ์ผ๋ง](#์๋-์ค์ผ์ผ๋ง)
- [์๋ ์ค์ผ์ผ๋ง](#์๋-์ค์ผ์ผ๋ง)
- [CloudWatch Container Insight](#cloudwatch-container-insight)

<br>

<br>

## Cluster AutoScaling

### Kubernetes์ Cluster Autoscaling

Kubernetes๋ **Cluster AutoScaler๋ฅผ ํตํด ๋์ ์ผ๋ก ์ธํ๋ผ๋ฅผ ํ์ฅ**ํ  ์ ์๋ค.

Kubernetes [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)๋ Pod๊ฐ ์คํจํ๊ฑฐ๋ ๋ค๋ฅธ ๋ธ๋๋ก ๋ค์ ์์ฝ๋  ๋ ํด๋ฌ์คํฐ์ ๋ธ๋ ์๋ฅผ ์๋์ผ๋ก ์กฐ์ ํ๋ฉฐ,

Pod์ **๋ฆฌ์์ค ์์ฒญ์ ๋ฐ๋ผ ํด๋ฌ์คํฐ์ ๋ธ๋๋ฅผ ์ถ๊ฐํ๊ฑฐ๋ ์ ๊ฑฐ**ํ๋ค.

๋ง์ฝ ๋ฆฌ์์ค ๋ถ์กฑ์ผ๋ก ์ธํด ์ค์ผ์ค๋ง ๋๊ธฐ ์ํ์ Pod๊ฐ ์กด์ฌํ๋ ๊ฒฝ์ฐ Cluster AutoScaler๊ฐ ๋ธ๋๋ฅผ ์ถ๊ฐํ๋ค. 

์ถ๊ฐ ์, **์ค์ ํ Min, Max ๊ฐ์ ๋์ด๊ฐ์ง ์๋๋ก ๊ตฌ์ฑ** ํ  ์ ์๋ค.

<br>

![img](http://drive.google.com/uc?export=view&id=1XDum_t6J_lEt88o0X776XUxCHB-Ry_rW)

์ถ์ฒ: https://swalloow.github.io/eks-autoscale/

<br>

### EKS AutoScaler

EKS์ AutoScaler๋ AWS์ Auto Scaling Group์ ํ์ฉํ๋ค.

ASG๋ ์ฃผ๊ธฐ์ ์ผ๋ก ํ์ฌ ์ํ๋ฅผ ํ์ธํ๊ณ  Desired State๋ก ๋ณํํ๋ ๋ฐฉ์์ผ๋ก ๋์ํ๋ค.

์ฌ์ฉ์๋ ํด๋ฌ์คํฐ ๋ธ๋ ์๋ฅผ ์ ํํ๋ Min, Max ๊ฐ์ ์ง์ ํ  ์ ์๋ค.

<br>

<br>

## ์๋ ์ค์ผ์ผ๋ง

`eksctl scale` ๋ช๋ น์ด๋ฅผ ์ฌ์ฉํ์ฌ, ๋ธ๋๋ฅผ ์๋์ผ๋ก ์คํ ์ค์ผ์ผ๋ง์ด ๊ฐ๋ฅํ๋ค.

```shell
$ eksctl scale nodegroup --name [๋ธ๋๊ทธ๋ฃน๋ช] --cluster [ํด๋ฌ์คํฐ๋ช] [flags]
```

flags ํ์ธ

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

**์์**

Desired number of nodes(์ํ๋ ๋ธ๋์ ์)๋ฅผ ์์ ํด๋ณด์.

ํ์ฌ ๋ธ๋ ๊ทธ๋ฃน์ ์ํ๋ ๋ค์๊ณผ ๊ฐ๊ณ ,

```shell
$ eksctl get nodegroup --cluster myeks-custom
CLUSTER         NODEGROUP       STATUS  CREATED                 MIN SIZE        MAX SIZE        DESIRED CAPACITY       INSTANCE TYPE    IMAGE ID        ASG NAME                                                TYPE
myeks-custom    myeks-ng1       ACTIVE  2022-06-05T14:41:31Z    2               4               3                      t3.medium        AL2_x86_64      eks-myeks-ng1-8ac09a28-288f-6ab0-5ff3-f759aa3af27a      managed
```

๋ค์ ๋ช๋ น์ ํตํด Desired number of nodes๋ฅผ 2๋ก ์์ ํ  ์ ์๋ค.

```shell
eksctl scale nodegroup --name myeks-ng1 --cluster myeks-custom --nodes 2
```

`DESIRED`๊ฐ 2๋ก ๋ณ๊ฒฝ๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค.

```shell
$ eksctl get nodegroup --cluster myeks-custom
CLUSTER         NODEGROUP       STATUS  CREATED                 MIN SIZE        MAX SIZE        DESIRED CAPACITY       INSTANCE TYPE    IMAGE ID        ASG NAME                                                TYPE
myeks-custom    myeks-ng1       ACTIVE  2022-06-05T14:41:31Z    2               4               2                      t3.medium        AL2_x86_64      eks-myeks-ng1-8ac09a28-288f-6ab0-5ff3-f759aa3af27a      managed
```

<br>

<br>

## ์๋ ์ค์ผ์ผ๋ง

[AWS EKS AutoScaling ๊ณต์๋ฌธ์](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/autoscaling.html)์ ๋ฐ๋ผ ์งํํด๋ณด์.

ํด๋ฌ์คํฐ๋ ๋ค์ yaml ํ์ผ๋ก ์์ฑํ์๊ณ , IAM ์ ์ฑ ๋ฐ ์ญํ  ์์ฑ๊น์ง ์ถฉ์กฑ๋ ์ํ์ด๋ค.

<br>

`myeks.yaml`

```yaml
apiVersion: eksctl.io/v1alpha5 
kind: ClusterConfig 

metadata:
  name: myeks-custom #cluster ์ด๋ฆ
  region: ap-northeast-2 
  version: "1.22"

# ๊ฐ์ฉ์์ญ ์ง์ 
availabilityZones: ["ap-northeast-2a", "ap-northeast-2b",  "ap-northeast-2c"]

#IAM ๊ณ์ ์ ๋ง๋ค์ด ์ฐ๊ฒฐ
iam:
  withOIDC: true #OIDC(OpenID Connect) : eks์์ฅ์์ AWS IAM์ ์ธ๋ถ์ธ์ฆ์๋ฒ์ด๊ธฐ ๋๋ฌธ์ OIDC๋ฅผ true๋ก ํ์ง ์์ผ๋ฉด 
                 #                       AWS ๊ณ์ ๊ณผ eks ๊ณ์ ์ ์์ ํ ๋ณ๊ฐ์ด๋ค.
  serviceAccounts: #SA ๊ณ์  ์์ฑ -> ์ดํ addon ์ถ๊ฐํ  ๋ ํ์
    - metadata:
        name: aws-load-balancer-controller #SA ๊ณ์  ์ด๋ฆ
        namespace: kube-system
      wellKnownPolicies:
        awsLoadBalancerController: true #๊ณ์ ์ ๊ถํ ๋ถ์ฌ : ingress๋ฅผ ๋ง๋ค ๋ ์ฌ์ฉ
    - metadata:
        name: ebs-csi-controller-sa #SA ๊ณ์  ์ด๋ฆ
        namespace: kube-system
      wellKnownPolicies:
        ebsCSIController: true #๊ณ์ ์ ๊ถํ ๋ถ์ฌ : ebs
    - metadata: 
        name: cluster-autoscaler #SA ๊ณ์  ์ด๋ฆ
        namespace: kube-system
      wellKnownPolicies:
        autoScaler: true #๊ณ์ ์ ๊ถํ ๋ถ์ฌ

# Managed Node Groups : worker node ๊ทธ๋ฃน
managedNodeGroups: #์ฌ๋ฌ๊ฐ ์ธํ ๊ฐ๋ฅ
  # On-Demand Instance
  - name: myeks-ng1
    instanceType: t3.medium
    minSize: 2
    desiredCapacity: 3 #cluster ์คํ ์ค์ผ์ผ๋ง๋๋ค
    maxSize: 4
    privateNetworking: true #๊ธฐ๋ณธ์ ์ผ๋ก EC2๋ public์ ๋ฐฐ์น๋๋ค(์์ EXTERNAL-IP ๋ถ์ฌ๋ ๊ฒ ํ์ธํ์๋ค)
                            #์ธ๋ถ์ ๋ธ์ถ๋๋ ๊ฒ์ ์ํํ๊ธฐ ๋๋ฌธ์ private ๋ฐฐ์น์ ํํ๋ค
    ssh:
      allow: true 
      publicKeyPath: ./keypair/myeks.pub  #์ ์ํ  ssh ํค
    availabilityZones: ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
    iam:
      withAddonPolicies: #IAM ๊ณ์  ์ ์ฑ
        autoScaler: true
        albIngress: true
        cloudWatch: true #๋ก๊ทธ๋ฅผ ๋จ๊ธฐ๊ธฐ ์ํด
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

๋จผ์  Cluster Autoscaler YAMl ํ์ผ์ ๋ค์ด๋ฐ๋๋ค.

```
curl -o cluster-autoscaler-autodiscover.yaml https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

๋ค์์ผ๋ก `cluster-autoscaler-autodiscover.yaml`์์ `<YOUR CLUSTER NAME>`์ ํด๋ฌ์คํฐ๋ช์ผ๋ก ์์ ํ๋ค.

์์  ํด๋ฌ์คํฐ yaml ํ์ผ์์ ํ์ธํ  ์ ์๋ฏ์ด ๋ณธ ์ค์ต์์๋ myeks-custom์ด๋ค.

```
163: - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/myeks-custom
```

๊ทธ๋ฆฌ๊ณ  ์์  ์ฌํญ์ ์ ์ฉํ๋ค.

```
kubectl apply -f cluster-autoscaler-autodiscover.yaml
```

cluster-autoscaler๊ฐ ๋ฐฐํฌ๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค.

```shell
$ kubectl get po -n kube-system
NAME                                  READY   STATUS    RESTARTS   AGE
...
cluster-autoscaler-66d46c46d4-2vsz8   1/1     Running   0          2m19s
...
```

๋ค์ ๋ช๋ น์ด๋ฅผ ์คํํ์ ๋, annotation์ด ์ ์์ ์ผ๋ก ๋ค์ด๊ฐ์๊ธฐ ๋๋ฌธ์ ๋ฐ๋ก ์์ ํ  ํ์๋ ์๋ค.

๋ง์ฝ ์ค์ ์ด ์๋์ด์๋ค๋ฉด annotaion์ ๋ฐ๋์ ์ค์ ํด์ฃผ์.

```shell
kubectl describe sa cluster-autoscaler -n kube-system
```

๋ค์์ผ๋ก deployment์ `cluster-autoscaler.kubernetes.io/safe-to-evict` annotaion์ ์ถ๊ฐํ๋ค.

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
        cluster-autoscaler.kubernetes.io/safe-to-evict: "false" #์ถ๊ฐํ๊ธฐ
...
```

`spec.containers.command`์ `<YOUR CLUSTER NAME>`๋ฅผ ํด๋ฌ์คํฐ์ ์ด๋ฆ(myeks-custom)์ผ๋ก ๊ต์ฒดํ๊ณ  ๋ค์ ์ต์์ ์ถ๊ฐํ๋ค.

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
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/myeks-custom #ํด๋ฌ์คํฐ๋ช ์์ 
        - --balance-similar-node-groups #์ต์ ์ถ๊ฐ
        - --skip-nodes-with-system-pods=false #์ต์ ์ถ๊ฐ
```

<br>

๋ค์์ผ๋ก ์น ๋ธ๋ผ์ฐ์ ์ GitHub์์ Cluster Autoscaler [[๋ฆด๋ฆฌ์ค(releases)](https://github.com/kubernetes/autoscaler/releases)] ํ์ด์ง๋ฅผ ์ด๊ณ  ํด๋ฌ์คํฐ์ Kubernetes ๋ฉ์ด์  ๋ฐ ๋ง์ด๋ ๋ฒ์ ๊ณผ ์ผ์นํ๋ ์ต์  Cluster Autoscaler ๋ฒ์ ์ ๊ฒ์ํ์ฌ, ํด๋น ๋ฒ์ ์ผ๋ก image๋ฅผ ์์ ํ๋ค.

ํ์์ (2022.6)์์๋ `v1.22.2`์ด๋ค.

```
kubectl set image deployment cluster-autoscaler -n kube-system cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:v1.22.2
```

<br>

Cluster Autoscaler ๋ฅผ deploy ํ ํ์ ๋ก๊ทธ๋ฅผ ํ์ธํ์ฌ ์ ๋๋ก ๋์ํ๋์ง ํ์ธํ๋ค.

```shell
kubectl -n kube-system logs -f deployment.apps/cluster-autoscaler
```

<br>

**์์**

๋ค์๊ณผ ๊ฐ์ด deployment `myweb-deploy`๋ฅผ ์์ฑํ๋ค.

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

ํ์ฌ ํ๋๊ฐ 2๊ฐ์ธ ๊ฒ์ ํ์ธํ  ์ ์๋ค.

```shell
$ kubectl get po
NAME                            READY   STATUS    RESTARTS   AGE
myweb-deploy-5c4cbfd766-kjfzr   1/1     Running   0          40s
myweb-deploy-5c4cbfd766-mlj9f   1/1     Running   0          40s
```

๋ค์๊ณผ ๊ฐ์ด deployment์ replicase๋ฅผ 10์ผ๋ก ์์ ํ๋ค.

```shell
kubectl scale deploy myweb-deploy --replicas=10
```

ํ์ฌ ๋ธ๋๋ 2๊ฐ๊ฐ ์กด์ฌํ๊ณ , ํ๋๋ฅผ ํ์ธํด๋ณด๋ฉด ๋ค์๊ณผ ๊ฐ๋ค.

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

ํ์ฌ ๋ธ๋์ ๊ฐ์๊ฐ 2๊ฐ์ด๊ณ  ํ๋์ ๋ธ๋์ ์ต๋ 4๊ฐ๊น์ง ๋ฐฐ์น๋  ์ ์๊ธฐ ๋๋ฌธ์,

๋ธ๋์ ๋ฐฐ์น๋์ง ๋ชปํด Pending ์ํ์ ํ๋๊ฐ ์๋ ๊ฒ์ด๋ค.

```shell
$ eksctl get nodegroup --cluster myeks-custom
CLUSTER         NODEGROUP       STATUS  CREATED                 MIN SIZE        MAX SIZE        DESIRED CAPACITY       INSTANCE TYPE    IMAGE ID        ASG NAME                                                TYPE
myeks-custom    myeks-ng1       ACTIVE  2022-06-05T14:41:31Z    2               4               2                      t3.medium        AL2_x86_64      eks-myeks-ng1-8ac09a28-288f-6ab0-5ff3-f759aa3af27a      managed
```

pending ์ํ์ ํ๋๋ฅผ ์์๋ก ํ๊ฐ ์ ํํ์ฌ `kubectl describe` ๋ช๋ น์ด๋ก Events๋ฅผ ๋ณด๋ฉด

`2 Insufficient cpu`์ `pod triggered scale-up`์ ํ์ธํ  ์ ์๋ค.

```shell
Events:
  Type     Reason            Age   From                Message
  ----     ------            ----  ----                -------
  Waring  FailedScheduling  15s   default-scheduler   0/2 nodes are available: 2 Insufficient cpu.
  Normal   TriggeredScaleUp  9s    cluster-autoscaler  pod triggered scale-up: [{eks-myeks-ng1-8ac09a28-288f-6ab0-5ff3-f759aa3af27a 2->3 (max: 4)}]
```

์๊ฐ์ด ์ข ๋ ์ง๋๋ฉด node๊ฐ 3๊ฐ๋ก ์คํ ์ค์ผ์ผ๋ง๋๊ณ ,

```shell
$ kubectl get nodes
NAME                                                STATUS   ROLES    AGE     VERSION
ip-192-168-100-17.ap-northeast-2.compute.internal   Ready    <none>   13m     v1.22.6-eks-7d68063
ip-192-168-135-92.ap-northeast-2.compute.internal   Ready    <none>   6h33m   v1.22.6-eks-7d68063
ip-192-168-185-60.ap-northeast-2.compute.internal   Ready    <none>   27m     v1.22.6-eks-7d68063
```

ํ๋๊ฐ ๋ชจ๋ ๋ฐฐ์น๋์ด Running ์ํ๊ฐ ๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค.

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

EKS์์ **Conatiner Insight ๊ธฐ๋ฅ์ ์ฌ์ฉํ๋ฉด** Prometheus, EFK๋ฅผ ๊ตฌ์ฑํ์ง ์๋๋ผ๋

**๊ธฐ๋ณธ์ ์ธ ๋ชจ๋ํฐ๋ง๊ณผ ๋ก๊น์ด ๊ฐ๋ฅ**ํ๋ค.

<br>

[Container-Insights-setup-EKS-quickstart](https://docs.aws.amazon.com/ko_kr/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html)์ ๋ฐ๋ผ ์งํํด๋ณด์. ๋ณธ ์ค์ต์์๋ Fluent Bit๋ฅผ ์ฌ์ฉํ๋ค.

shell์ ์ฌ์ฉ์ค์ด๋ผ๋ฉด ๋ฐ๋ก ๋ค์ ๋ช๋ น์ ์คํํ๋ฉด ๋๊ณ ,

๊ธ์ด์ด๋ windows์์ ์ค์ต ์ค์ด๋ผ, bash๋ฅผ ์คํํ๊ธฐ ์ํด Git Bash๋ฅผ ์ฌ์ฉํ๋ค.

๐  [Git Bash ์ค์นํ๊ธฐ](https://github.com/git-for-windows/git/releases/download/v2.36.1.windows.1/Git-2.36.1-64-bit.exe)

```
ClusterName=myeks-custom
RegionName=ap-northeast-2
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${RegionName}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl apply -f - 
```

`amazon-cloudwatch` ๋ค์์คํ์ด์ค์ `cloudwatch-agent`์ `fluent-bit`๋ฅผ ํ์ธํ  ์ ์๋ค.

<u>**fluent bit๊ฐ ๋ก๊ทธ๋ฅผ ์์งํ๊ณ , cloudwatch๋ก ์ ์ก**</u>์ํจ๋ค.

```shell
$ kubectl get po -n amazon-cloudwatch
NAME                     READY   STATUS    RESTARTS   AGE
cloudwatch-agent-kgjwq   1/1     Running   0          63s
cloudwatch-agent-r68pk   1/1     Running   0          63s
fluent-bit-ht594         1/1     Running   0          63s
fluent-bit-rwsjb         1/1     Running   0          63s
```

<br>

AWS CloudWatch๋ฅผ ์ฝ์๋ก ์ ์ํด๋ณด๋ฉด ๋ค์๊ณผ ๊ฐ์ด ๋ก๊ทธ ๊ทธ๋ฃน๋ค์ ํ์ธํ  ์ ์๋ค.

- `/aws/eks/myeks-custom/cluster`  : ControlPlane์ ๋ก๊ทธ

- `/aws/containerinsights/myeks-custom/application` : ์ ํ๋ฆฌ์ผ์ด์์ ๋ก๊ทธ
- `/aws/containerinsights/myeks-custom/host` : ํธ์คํธ์ ๋ก๊ทธ
- `/aws/containerinsights/myeks-custom/performance` : ์ฑ๋ฅ ๋ฐ์ดํฐ ์์ง ๋ก๊ทธ

<br>

![image-20220606052711181](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220606052711181.png)

<br>

๋ก๊ทธ๋ค์ ๋ง๊ธฐ๊ฐ ์๊ณ , ๊ณ์ ์์ด๊ธฐ ๋๋ฌธ์ ์ ๊ด๋ฆฌํด์ฃผ์ด์ผํ๋ค.

<br>

[์ธ์ฌ์ดํธ] - [Container Insights]๋ฅผ ํด๋ฆญํ๋ฉด ๋ค์๊ณผ ๊ฐ์ ์ ๋ณด๋ค์ ํ์ธํ  ์ ์๋ค.

![image-20220606053310661](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220606053310661.png)

Prometheus๋ฅผ ์ฌ์ฉํ์ง ์๋๋ผ๋ CPU/Memory ๋ฆฌ์์ค๋ ๋ฑ์ ํ์ธํ  ์ ์๋ ๊ฒ์ด๋ค.

๋ค์๊ณผ ๊ฐ์ด ์ปจํ์ด๋ ๋งต๋ ํ์ธํ  ์ ์์ผ๋ฉฐ,

![image-20220606053844755](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220606053844755.png)

<br>

Performance monitoring๋ ๊ฐ๋ฅํ๋ค.

<br>

![image-20220606053916021](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220606053916021.png)

<br>

์ค์ต์ด ๋๋๊ณ  cluster์ ๋ก๊ทธ๋ฅผ ์ญ์ ํ๋ ๊ฒ์ ์์ง๋ง์.

```shell
eksctl delete cluster -f .\myeks.yaml --force --disable-nodegroup-eviction
```

<br>

Prometheus ๋ฐ EKF์ ๊ตฌ์ฑํ๋ ๋ด์ฉ์ ์๋์ ํฌ์คํ์์ ํ์ธํ  ์ ์๋ค.

- [k8s Logging : EFK ๊ฐ์ ๋ฐ ์ค์น](https://nayoungs.tistory.com/entry/Kubernetes-k8s-Logging-EFK-%EA%B0%9C%EC%9A%94-%EB%B0%8F-%EC%84%A4%EC%B9%98)
- [k8s monitoring : Helm์ผ๋ก Prometheus, Grafana ์ค์นํ๊ธฐ](https://nayoungs.tistory.com/entry/Kubernetes-k8s-Minitoring-Helm%EC%9C%BC%EB%A1%9C-Prometheus-Grafana-%EC%84%A4%EC%B9%98%ED%95%98%EA%B8%B0)

<br>

<br>

<br>

Reference

- https://swalloow.github.io/eks-autoscale/
- [AutoScaling - Amazon EKS](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/autoscaling.html)

<br>