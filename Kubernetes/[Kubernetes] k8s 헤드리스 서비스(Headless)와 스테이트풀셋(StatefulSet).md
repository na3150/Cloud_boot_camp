# [Kubernetes] k8s 헤드리스 서비스(Headless)와 스테이트풀셋(StatefulSet)

<br>

### 📌Index

- [헤드리스(Headless) 서비스](#헤드리스headless-서비스)
- [스테이트 풀셋(StatefulSets)](#스테이트-풀셋statefulsets)

<br>

<br>

## 헤드리스(Headless) 서비스

헤드리스(Headless) 서비스는 **StatefulSet과 함께 사용**하는 것으로, 

` .spec.clusterIP`의 필드 값을 None으로 설정하여 **클러스터 IP가 없는 서비스**이다.

<br>

**💻 실습** : 일반적인 ClusterIP 서비스와 Headless 서비스의 비교

먼저 **일반적인 ClusterIP 서비스**를 다음과 같이 작성한다.

`myweb-svc.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myweb-svc
spec:
  type: ClusterIP
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 8080
```

다음으로, ` .spec.clusterIP`의 필드 값이 None으로 설정된 **Headless 서비스**를 생성한다.

`myweb-svc-headless.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myweb-svc-headless
spec:
  type: ClusterIP
  clusterIP: None # <-- Headless Service
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 8080
```

파드를 생성하기 위해 ReplicaSets을 다음과 같이 작성한다. 

`myweb-rs.yaml`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myweb-rs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
      env: dev
  template:
    metadata:
      labels:
        app: web
        env: dev
    spec:
      containers:
        - name: myweb
          image: ghcr.io/c1t1d0s7/go-myweb
          ports:
            - containerPort: 8080
              protocol: TCP
```

```shell
$ kubectl create -f .
```

모두 생성 후, 헤드리스 서비스의 CLUSTER-IP가 None인 것을 확인할 수 있고,

`myweb-svc`와 `myweb-svc-headless`는 동일한 셀렉터를 사용하고 있기 때문에 동일한 구성을 갖고있다.

```shell
$ kubectl get svc,ep
NAME                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/myweb-svc            ClusterIP   10.233.19.251   <none>        80/TCP    2m12s
service/myweb-svc-headless   ClusterIP   None            <none>        80/TCP    2m12s

NAME                                                    ENDPOINTS                                           
endpoints/myweb-svc                                     10.233.90.185:8080,10.233.92.98:8080,10.233.96.206:8080   2m12s
endpoints/myweb-svc-headless                            10.233.90.185:8080,10.233.92.98:8080,10.233.96.206:8080   2m12s
```

접속 테스트를 위해 임시 파드 `nettool`을 띄워보자.

**일반적인 서비스는 질의 시, 서비스의 IP가 출력**된다.

```shell
$  kubectl run nettool -it --image ghcr.io/c1t1d0s7/network-multitool --rm

If you don't see a command prompt, try pressing enter.
/ # host myweb-svc
myweb-svc.default.svc.cluster.local has address 10.233.19.251
```

이와 달리, **헤드리스 서비스를 질의하는 경우 다음과 같이 파드의 IP가 출력된다.**

```shell
$ / # host myweb-svc-headless
myweb-svc-headless.default.svc.cluster.local has address 10.233.96.206
myweb-svc-headless.default.svc.cluster.local has address 10.233.90.185
myweb-svc-headless.default.svc.cluster.local has address 10.233.92.98
```

즉, 서비스의 IP자체가 없는 것(헤드리스 서비스)이다.

현재는 FQDN이 모두 같기 때문에 크게 의미가 없지만,

스테이트풀셋을 설정하면 파드가 고유성을 갖게되고, FQDN이 달라져 의미있어지게 된다. 

--> **파드를 구분**할 수 있게 된다

결론적으로 **헤드리스 서비스와 스테이트 풀셋을 함께 사용해야한다.**

<br>

<br>

## 스테이트 풀셋(StatefulSets)

[스테이트풀셋(StatefulSets)](https://kubernetes.io/ko/docs/concepts/workloads/controllers/statefulset/)이란, 애플리케이션의 스테이트풀을 관리하는데 사용하는 워크로드 API 오브젝트이다.

<br>

ReplicaSets이 파드 복제본을 생성할 때는 파드의 이름 및 IP 주소만 다를 뿐 나머지는 모두 똑같은 파드를 생성하게 된다.

만약 파드가 PVC를 참조한다면, 이 역시 동일한 PVC를 연결하게 되고, 해당 PVC는 특정한 하나의 PV에 연결된다. 

즉, 항상 똑같은 볼륨에 연결한다는 의미로, 고유성이 없다.

 <br>

<img src="https://mblogthumb-phinf.pstatic.net/MjAyMDA0MDFfMjI1/MDAxNTg1NzMxNDQ4OTE2.lCe_tb-aErmkJbTQhKdneSrYBNW4H8FJiGdWaWNph2gg.bJr1fEno5KpYVQtKwEsFtcuz1MM6K2ehw3UBNxpzy_wg.PNG.isc0304/image.png?type=w800" alt="img" style="zoom:80%;" />

출처: https://m.blog.naver.com/PostView.naver?isHttpsRedirect=true&blogId=isc0304&logNo=221885403537

<br>

반면에 **스테이트풀셋**은 파드 집합의 디플로이먼트와 스케일링을 관리하며, **파드들의 순서 및 고유성을 보장한다.**

(**고유성 : 동일한 이름과 동일한 id로 동일한 노드에 생성**된다)

단, **반드시 헤드리스 서비스와 함께 사용**해야한다. 

헤드리스 서비스가 있다면, 별도로 일반 서비스를 추가하는 것은 사용자의 선택이다.

<br>

**☁️ 참고**

Pets & Cattle : [The History of Pets vs Cattle and How to Use the Analogy Properly | Cloudscaling](http://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/)

PetSet --> StatefuleSet

Cattle은 고유성(상태, State)을 가지고 있지 않기 때문에 언제든지 교체가 가능한 반면,

Pet은 각자 고유성을 가지고 있고, 교체가 쉽지 않다.

<br>

**스테이트풀셋의 사용**

- 안정된, 고유한 네트워크 식별자
- 안정된, 지속성을 갖는 스토리지
- 순차적인, 정상 배포(graceful deployment)와 스케일링
- 순차적인, 자동 롤링 업데이트

<br>

**제한 사항**

스테이트풀셋은 각 포드의 상태를 유지할 수 있는 장점과 함께 몇가지 문제를 해결해야 한다. 

1 스테이트풀셋과 관련된 볼륨이 삭제되지 않는다 (관리 필요)

2 스테이트풀셋에 연결하는 스토리지는 반드시 PVC이어야하고,  PV나 스토리지클래스로 프로비저닝을 수행해야한다.

3 롤링업데이트를 수행하는 경우 수동으로 복구해야 할 수 있다. (롤링업데이트 수행 시 기존의 스토리지와 충돌로 인해 애플리케이션이 오류가 발생할 수 있다는 의미).

4 포드 네트워크 ID를 유지하기 위해 헤드레스(headless) 서비스가 필요하다.

<br>

상태를 유지할 수 있다는 장점도 있지만, 이로 인해 **포드를 각각 따로 관리해줘야 하는 문제도 함께 동반**한다.

 따라서 스테이트풀셋을 사용할 건지 디플로이먼트를 사용할 것인지는 프로젝트의 상황에 따라 선택해야한다.

<br>

여기 클러스터 도메인, 서비스 이름, 스테이트풀셋 이름을 선택을 하고, 그 선택이 스테이트풀셋 파드의 DNS이름에 어떻게 영향을 주는지에 대한 약간의 예시가 있다.

| 클러스터 도메인 | 서비스 (ns/이름) | 스테이트풀셋 (ns/이름) | 스테이트풀셋 도메인             | 파드 DNS                                     | 파드 호스트 이름 |
| --------------- | ---------------- | ---------------------- | ------------------------------- | -------------------------------------------- | ---------------- |
| cluster.local   | default/nginx    | default/web            | nginx.default.svc.cluster.local | web-{0..N-1}.nginx.default.svc.cluster.local | web-{0..N-1}     |
| cluster.local   | foo/nginx        | foo/web                | nginx.foo.svc.cluster.local     | web-{0..N-1}.nginx.foo.svc.cluster.local     | web-{0..N-1}     |
| kube.local      | foo/nginx        | foo/web                | nginx.foo.svc.kube.local        | web-{0..N-1}.nginx.foo.svc.kube.local        | web-{0..N-1}     |

<br>

**리소스 확인**

```shell
$ kubectl api-resources| grep sts   
statefulsets                      sts          apps/v1                                true         StatefulSet
certificatesigningrequests        csr          certificates.k8s.io/v1                 false        CertificateSigningRequest
```

<br>

**리소스 정의 방법 확인**

```shell
$ kubectl explain sts.spec  
```

<br>

#### ServiceName

`sts.spec.serviceName`

연결하고자 하는 **헤드리스 서비스를 지정**한다. 또한 연결하고자 하는 **레이블도 일치**시켜야한다.

```shell
$ kubectl explain sts.spec.serviceName
```

<br>

#### volumeClaimTemplates

`sts.spec.volumeClaimTemplates`

**PVC를 만들 때 사용하는 템플릿**이다.

⭐**파드들이 고유한 데이터를 별도로 가질 수 있게 되는 것**이다.

```shell
$ kubectl explain sts.spec.volumeClaimTemplates
```

`sts.spec.volumeClaimTemplates.spec` 

PVC의 spec이다.

```shell
$ $ kubectl explain sts.spec.volumeClaimTemplates.spec
```

- `accessMode`
- `dataSource`
- `dataSourceRef`
- `resources`
- `selector`
- `storageClassName`
- `volumeMode`
- `volumeName`

<br>

<br>

**💻 실습 1** : 헤드리스서비스와 스테이트풀셋의 결합으로 파드 특정하기

먼저 스테이트풀셋과 함께 사용할 헤드리스 서비스를 작성한다.

`myweb-svc-headless.yaml`

```yaml
$ apiVersion: v1
kind: Service
metadata:
  name: myweb-svc-headless
spec:
  type: ClusterIP
  clusterIP: None # <-- Headless Service
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 8080
```

다음과 같이 스테이트풀셋을 작성한다.

`myweb-sts.yaml`

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: myweb-sts
spec:
  replicas: 3 
  serviceName: myweb-svc-headless
  selector:
    matchLabels:
      app: web
      env: dev
  template:
    metadata:
      labels:
        app: web
        env: dev
    spec:
      containers:
        - name: myweb
          image: ghcr.io/c1t1d0s7/go-myweb
          ports:
            - containerPort: 8080
              protocol: TCP
```

```shell
$ kubectl create -f myweb-svc-headless.yaml 
service/myweb-svc-headless created
$ kubectl create -f myweb-sts.yaml         
statefulset.apps/myweb-sts created
```

생성된 스테이트풀셋과 파드를 확인해보면,

<u>**스테이트풀셋은 기본적으로 뒤에 서수가 붙게된다.**</u>

```shell
$ kubectl get sts,po      
NAME                         READY   AGE
statefulset.apps/myweb-sts   3/3     9s

NAME                                          READY   STATUS    RESTARTS       AGE
pod/myweb-sts-0                               1/1     Running   0              9s
pod/myweb-sts-1                               1/1     Running   0              6s
pod/myweb-sts-2                               1/1     Running   0              4s
```

이 상태에서 파드를 한개 지워보자.

```shell
$ kubectl delete po myweb-sts-2
```

그러면 `myweb-sts-2`가 종료(Terminating)되고, 다시 똑같은 이름의 파드가 생성된다.

스테이트풀셋을 설정하면 **이름이 고정적이고, 즉 예측이 가능**하다.

또한 **한번에 지워지지 않고, 한번에 생성되지 않는다.**

즉 <u>**항상 순서대로 삭제, 생성된다.**</u>⭐

<br>

테스트를 위해 임시로 `nettool` 파드를 띄워보자.

헤드리스 서비스를 질의하면 파드의 IP가 출력되는 것을 확인할 수 있고,

```shell
$  kubectl run nettool -it --image ghcr.io/c1t1d0s7/network-multitool --rm

If you don't see a command prompt, try pressing enter.
/ # host myweb-svc-headless
myweb-svc-headless.default.svc.cluster.local has address 10.233.92.106
myweb-svc-headless.default.svc.cluster.local has address 10.233.96.212
myweb-svc-headless.default.svc.cluster.local has address 10.233.90.191
```

또한, **파드의 이름으로 쿼리(Query)를 보낼 수 있다.**

물론 풀네임은 `myweb-sts-N.myweb-svc-headless.default.svc.cluster.local`이다.

```shell
/ # host myweb-sts-0.myweb-svc-headless
myweb-sts-0.myweb-svc-headless.default.svc.cluster.local has address 10.233.92.106
/ # host myweb-sts-0.myweb-svc-headless.default.svc.cluster.local
myweb-sts-0.myweb-svc-headless.default.svc.cluster.local has address 10.233.92.106
/ # host myweb-sts-1.myweb-svc-headless.default.svc.cluster.local
myweb-sts-1.myweb-svc-headless.default.svc.cluster.local has address 10.233.96.212
/ # host myweb-sts-2.myweb-svc-headless.default.svc.cluster.local
myweb-sts-2.myweb-svc-headless.default.svc.cluster.local has address 10.233.90.191
```

즉, <u>**헤드리스 서비스와 스테이트풀셋을 결합하면 파드를 특정할 수 있다.**</u>⭐

<br>

<br>

**💻 실습 2** : PVC Template 사용하기

다음과 같이 `sts.spec.volumeClaimTemplates` 필드를 작성하여 PVC를 설정한다.

`myweb-sts-vol.yaml`

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: myweb-sts-vol
spec:
  replicas: 3
  serviceName: myweb-svc-headless
  selector:
    matchLabels:
      app: web
      env: dev
  template:
    metadata:
      labels:
        app: web
        env: dev
    spec:
      containers:
        - name: myweb
          image: ghcr.io/c1t1d0s7/go-myweb:alpine
          ports:
            - containerPort: 8080
              protocol: TCP
          volumeMounts:
            - name: myweb-pvc
              mountPath: /data
  volumeClaimTemplates:
    - metadata:
        name: myweb-pvc
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 1G
        storageClassName: nfs-client
```

**☁️ 참고**

ReplicaSets나 Deployment를 이용하는 경우는 여러개의 파드가 볼륨에 동시에 쓰기를 해야하기 때문에

accessMode가 ReadWriteMany가 필요했으나,

스테이트풀셋은 파드가 별도의 볼륨을 가지기 때문에 accessMode를 Many로 세팅할 필요가 없다.

<br>

```shell
$  kubectl create -f myweb-svc-headless.yaml -f myweb-sts-vol.yaml     
```

생성이 완료된 후 상태를 확인해보면 다음과 같다.

```shell
$ kubectl get sts,po,pv,pvc           
NAME                             READY   AGE
statefulset.apps/myweb-sts-vol   3/3     23s

NAME                                          READY   STATUS    RESTARTS      AGE
pod/myweb-sts-vol-0                           1/1     Running   0             23s
pod/myweb-sts-vol-1                           1/1     Running   0             20s
pod/myweb-sts-vol-2                           1/1     Running   0             17s
pod/nfs-client-provisioner-758f8cd4d6-2sqcr   1/1     Running   6 (36m ago)   21h

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                               STORAGECLASS   REASON   AGE
persistentvolume/pvc-a8ac3f68-7e90-40a3-8267-8290f41d6605   1G         RWO            Delete           Bound    default/myweb-pvc-myweb-sts-vol-0   nfs-client              23s
persistentvolume/pvc-d5f84265-59ee-4ed8-b8bf-34c1f3a60da0   1G         RWO            Delete           Bound    default/myweb-pvc-myweb-sts-vol-1   nfs-client              20s
persistentvolume/pvc-eb12b4dc-66bd-4c74-8c47-909b0bdd80a6   1G         RWO            Delete           Bound    default/myweb-pvc-myweb-sts-vol-2   nfs-client              17s

NAME                                              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/myweb-pvc-myweb-sts-vol-0   Bound    pvc-a8ac3f68-7e90-40a3-8267-8290f41d6605   1G         RWO            nfs-client     23s
persistentvolumeclaim/myweb-pvc-myweb-sts-vol-1   Bound    pvc-d5f84265-59ee-4ed8-b8bf-34c1f3a60da0   1G         RWO            nfs-client     20s
persistentvolumeclaim/myweb-pvc-myweb-sts-vol-2   Bound    pvc-eb12b4dc-66bd-4c74-8c47-909b0bdd80a6   1G         RWO            nfs-client     17s
```

또한 다음을 통해 스케일링으로 **파드를 한개 줄여도, PVC는 지워지지 않고 그대로**인 것을 확인할 수 있다. 

```shell
$ kubectl scale sts myweb-sts-vol  --replicas=2                                          
statefulset.apps/myweb-sts-vol scaled
$ kubectl get sts,po,pv,pvc                    
NAME                             READY   AGE
statefulset.apps/myweb-sts-vol   2/2     111s

NAME                                          READY   STATUS    RESTARTS      AGE
pod/myweb-sts-vol-0                           1/1     Running   0             111s
pod/myweb-sts-vol-1                           1/1     Running   0             108s
pod/nfs-client-provisioner-758f8cd4d6-2sqcr   1/1     Running   6 (37m ago)   21h

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                               STORAGECLASS   REASON   AGE
persistentvolume/pvc-a8ac3f68-7e90-40a3-8267-8290f41d6605   1G         RWO            Delete           Bound    default/myweb-pvc-myweb-sts-vol-0   nfs-client              111s
persistentvolume/pvc-d5f84265-59ee-4ed8-b8bf-34c1f3a60da0   1G         RWO            Delete           Bound    default/myweb-pvc-myweb-sts-vol-1   nfs-client              108s
persistentvolume/pvc-eb12b4dc-66bd-4c74-8c47-909b0bdd80a6   1G         RWO            Delete           Bound    default/myweb-pvc-myweb-sts-vol-2   nfs-client              105s

NAME                                              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/myweb-pvc-myweb-sts-vol-0   Bound    pvc-a8ac3f68-7e90-40a3-8267-8290f41d6605   1G         RWO            nfs-client     111s
persistentvolumeclaim/myweb-pvc-myweb-sts-vol-1   Bound    pvc-d5f84265-59ee-4ed8-b8bf-34c1f3a60da0   1G         RWO            nfs-client     108s
persistentvolumeclaim/myweb-pvc-myweb-sts-vol-2   Bound    pvc-eb12b4dc-66bd-4c74-8c47-909b0bdd80a6   1G         RWO            nfs-client     105s
```

다시 스케일링을 통해 **파드를 한개 늘려보면**, 볼륨의 수는 여전히 3개이다.

즉, **기존의 볼륨을 그대로 사용**한다는 것을 확인할 수 있다.

```shell
$ kubectl scale sts myweb-sts-vol  --replicas=3
statefulset.apps/myweb-sts-vol scaled
$ kubectl get sts,po,pv,pvc                    
NAME                             READY   AGE
statefulset.apps/myweb-sts-vol   3/3     2m16s

NAME                                          READY   STATUS    RESTARTS      AGE
pod/myweb-sts-vol-0                           1/1     Running   0             2m16s
pod/myweb-sts-vol-1                           1/1     Running   0             2m13s
pod/myweb-sts-vol-2                           1/1     Running   0             2s
pod/nfs-client-provisioner-758f8cd4d6-2sqcr   1/1     Running   6 (37m ago)   21h

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                               STORAGECLASS   REASON   AGE
persistentvolume/pvc-a8ac3f68-7e90-40a3-8267-8290f41d6605   1G         RWO            Delete           Bound    default/myweb-pvc-myweb-sts-vol-0   nfs-client              2m16s
persistentvolume/pvc-d5f84265-59ee-4ed8-b8bf-34c1f3a60da0   1G         RWO            Delete           Bound    default/myweb-pvc-myweb-sts-vol-1   nfs-client              2m13s
persistentvolume/pvc-eb12b4dc-66bd-4c74-8c47-909b0bdd80a6   1G         RWO            Delete           Bound    default/myweb-pvc-myweb-sts-vol-2   nfs-client              2m10s

NAME                                              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/myweb-pvc-myweb-sts-vol-0   Bound    pvc-a8ac3f68-7e90-40a3-8267-8290f41d6605   1G         RWO            nfs-client     2m16s
persistentvolumeclaim/myweb-pvc-myweb-sts-vol-1   Bound    pvc-d5f84265-59ee-4ed8-b8bf-34c1f3a60da0   1G         RWO            nfs-client     2m13s
persistentvolumeclaim/myweb-pvc-myweb-sts-vol-2   Bound    pvc-eb12b4dc-66bd-4c74-8c47-909b0bdd80a6   1G         RWO            nfs-client     2m10s
```

ReplicaSets과 같은 경우는 파드들에 볼륨이 공유되었지만,

StatefulSets은 직접 접속해서 확인해보면 **볼륨이 공유되지 않는다는 것을 확인**할 수 있다. (개별 볼륨)

```shell
$ ubectl exec myweb-sts-vol-0 -it -- sh            
/ # cd /data
/data # touch a b c
/data # ls
a  b  c
/data # exit
$ kubectl exec myweb-sts-vol-1 -it -- sh
/ # cd /data
/data # ls
/data # touch x y z
/data # exit
$ kubectl exec myweb-sts-vol-2 -it -- sh
/ # cd /data
/data # ls
/data # 
```

또한 파드를 지웠다가 다시 접속해서 확인해보면 데이터가 그대로인것을 확인할 수 있다.

즉, **파드를 지워도 다시 똑같은 파드가 만들어지고 똑같은 볼륨에 연결**된다.

```shell
$ kubectl delete po myweb-sts-vol-1     
pod "myweb-sts-vol-1" deleted
$ kubectl get po                   
NAME                                      READY   STATUS    RESTARTS      AGE
myweb-sts-vol-0                           1/1     Running   0             8m
myweb-sts-vol-1                           1/1     Running   0             4s
myweb-sts-vol-2                           1/1     Running   0             5m46s
nfs-client-provisioner-758f8cd4d6-2sqcr   1/1     Running   6 (43m ago)   21h
$ kubectl exec myweb-sts-vol-1 -it -- sh
/ # cd /data
/data # ls
x  y  z
```

스테이트풀셋을 제거해도 PV와 PVC는 남아있기 때문에 별도로 제거해줘야한다.

```shell
$ kubectl delete -f .
$ kubectl delete pvc --all         
persistentvolumeclaim "myweb-pvc-myweb-sts-vol-0" deleted
persistentvolumeclaim "myweb-pvc-myweb-sts-vol-1" deleted
persistentvolumeclaim "myweb-pvc-myweb-sts-vol-2" deleted
```

<br>

<br>

**💻 실습 3** : MySQL

실제로 StatefulSets은 **데이터베이스 서버에서 마스터(RW), 슬레이브(RO) 와 같은 구성을 할 때,** 

**마스터 DB 파드와 슬레이브 DB 파드를 구분하기 위해 많이 사용된다.**

[Run a Replicated Stateful Application | Kubernetes](https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/)에 따라 진행해보자.

<br>

다음과 같이 configMap을 생성한다.

`mysql-configmap.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql
  labels:
    app: mysql
data:
  primary.cnf: |
    # Apply this config only on the primary.
    [mysqld]
    log-bin
  replica.cnf: |
    # Apply this config only on replicas.
    [mysqld]
    super-read-only
```

**Master와 slave를 구분하기 위하여 헤드리스 서비스를 사용**한다.

서비스 yaml 파일은 변경할 사항이 없으므로, 링크를 통해 `mysql-services.yaml` 파일을 받는다.

```shell
$ kubectl apply -f https://k8s.io/examples/application/mysql/mysql-services.yaml
```

여기서 Master가 헤드리스 서비스이고, Slave는 일반적인 ClusterIP 타입의 서비스이다.

<br>

다음으로 아래와 같이 스테이트 풀셋을 만든다. 

기본 설정에서 첫번째 컨테이너의 resources의 cpu와 memory만 수정한다.

`mysql-statfulset.yaml`

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  selector:
    matchLabels:
      app: mysql
  serviceName: mysql
  replicas: 2
  template:
    metadata:
      labels:
        app: mysql
    spec:
      initContainers:
      - name: init-mysql
        image: mysql:5.7
        command:
        - bash
        - "-c"
        - |
          set -ex
          # Generate mysql server-id from pod ordinal index.
          [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
          ordinal=${BASH_REMATCH[1]}
          echo [mysqld] > /mnt/conf.d/server-id.cnf
          # Add an offset to avoid reserved server-id=0 value.
          echo server-id=$((100 + $ordinal)) >> /mnt/conf.d/server-id.cnf
          # Copy appropriate conf.d files from config-map to emptyDir.
          if [[ $ordinal -eq 0 ]]; then
            cp /mnt/config-map/primary.cnf /mnt/conf.d/
          else
            cp /mnt/config-map/replica.cnf /mnt/conf.d/
          fi
        volumeMounts:
        - name: conf
          mountPath: /mnt/conf.d
        - name: config-map
          mountPath: /mnt/config-map
      - name: clone-mysql
        image: gcr.io/google-samples/xtrabackup:1.0
        command:
        - bash
        - "-c"
        - |
          set -ex
          # Skip the clone if data already exists.
          [[ -d /var/lib/mysql/mysql ]] && exit 0
          # Skip the clone on primary (ordinal index 0).
          [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
          ordinal=${BASH_REMATCH[1]}
          [[ $ordinal -eq 0 ]] && exit 0
          # Clone data from previous peer.
          ncat --recv-only mysql-$(($ordinal-1)).mysql 3307 | xbstream -x -C /var/lib/mysql
          # Prepare the backup.
          xtrabackup --prepare --target-dir=/var/lib/mysql
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
      containers:
      - name: mysql
        image: mysql:5.7
        env:
        - name: MYSQL_ALLOW_EMPTY_PASSWORD
          value: "1"
        ports:
        - name: mysql
          containerPort: 3306
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
        resources:
          requests:
            cpu: 300m
            memory: 300M
        livenessProbe:
          exec:
            command: ["mysqladmin", "ping"]
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
        readinessProbe:
          exec:
            # Check we can execute queries over TCP (skip-networking is off).
            command: ["mysql", "-h", "127.0.0.1", "-e", "SELECT 1"]
          initialDelaySeconds: 5
          periodSeconds: 2
          timeoutSeconds: 1
      - name: xtrabackup
        image: gcr.io/google-samples/xtrabackup:1.0
        ports:
        - name: xtrabackup
          containerPort: 3307
        command:
        - bash
        - "-c"
        - |
          set -ex
          cd /var/lib/mysql

          # Determine binlog position of cloned data, if any.
          if [[ -f xtrabackup_slave_info && "x$(<xtrabackup_slave_info)" != "x" ]]; then
            # XtraBackup already generated a partial "CHANGE MASTER TO" query
            # because we're cloning from an existing replica. (Need to remove the tailing semicolon!)
            cat xtrabackup_slave_info | sed -E 's/;$//g' > change_master_to.sql.in
            # Ignore xtrabackup_binlog_info in this case (it's useless).
            rm -f xtrabackup_slave_info xtrabackup_binlog_info
          elif [[ -f xtrabackup_binlog_info ]]; then
            # We're cloning directly from primary. Parse binlog position.
            [[ `cat xtrabackup_binlog_info` =~ ^(.*?)[[:space:]]+(.*?)$ ]] || exit 1
            rm -f xtrabackup_binlog_info xtrabackup_slave_info
            echo "CHANGE MASTER TO MASTER_LOG_FILE='${BASH_REMATCH[1]}',\
                  MASTER_LOG_POS=${BASH_REMATCH[2]}" > change_master_to.sql.in
          fi

          # Check if we need to complete a clone by starting replication.
          if [[ -f change_master_to.sql.in ]]; then
            echo "Waiting for mysqld to be ready (accepting connections)"
            until mysql -h 127.0.0.1 -e "SELECT 1"; do sleep 1; done

            echo "Initializing replication from clone position"
            mysql -h 127.0.0.1 \
                  -e "$(<change_master_to.sql.in), \
                          MASTER_HOST='mysql-0.mysql', \
                          MASTER_USER='root', \
                          MASTER_PASSWORD='', \
                          MASTER_CONNECT_RETRY=10; \
                        START SLAVE;" || exit 1
            # In case of container restart, attempt this at-most-once.
            mv change_master_to.sql.in change_master_to.sql.orig
          fi

          # Start a server to send backups when requested by peers.
          exec ncat --listen --keep-open --send-only --max-conns=1 3307 -c \
            "xtrabackup --backup --slave-info --stream=xbstream --host=127.0.0.1 --user=root"
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
      volumes:
      - name: conf
        emptyDir: {}
      - name: config-map
        configMap:
          name: mysql
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

```shell
$ kubectl create -f .
```

생성 후 바로 파드의 상태를 확인해보면, [초기화 컨테이너(initContainer)](https://nayoungs.tistory.com/entry/Kubernetes-k8s-Volume-1-emptyDir-initContainer-hostPath#%E-%-C%--%EF%B-%-F%--initContainer-%EC%B-%--%EA%B-%B-%ED%--%--%--%EC%BB%A-%ED%--%-C%EC%-D%B-%EB%--%---)가 사용되는 것을 확인할 수 있다.

```shell
$ kubectl get sts,po,pv,pvc
NAME                     READY   AGE
statefulset.apps/mysql   0/3     13s

NAME                                          READY   STATUS     RESTARTS      AGE
pod/mysql-0                                   0/2     Init:0/2   0             13s
pod/nfs-client-provisioner-758f8cd4d6-2sqcr   1/1     Running    6 (68m ago)   22h

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS   REASON   AGE
persistentvolume/pvc-7844cd7b-3b8f-4f3c-a22f-714ba1889c08   10Gi       RWO            Delete           Bound    default/data-mysql-0   nfs-client              13s

NAME                                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/data-mysql-0   Bound    pvc-7844cd7b-3b8f-4f3c-a22f-714ba1889c08   10Gi       RWO            nfs-client     13s
```

시간이 지나면 파드가 모두 Running 상태가 된다.

**0번이 master(RW)이고 1번이 slave(RO)**이다.

```shell
$ kubectl get sts,po,pv,pvc,svc,ep        
NAME                     READY   AGE
statefulset.apps/mysql   2/2     39s

NAME                                          READY   STATUS    RESTARTS      AGE
pod/mysql-0                                   2/2     Running   0             39s
pod/mysql-1                                   2/2     Running   0             21s

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS   REASON   AGE
persistentvolume/pvc-80cc45b7-77cd-4377-88a3-0c353e76d9c1   10Gi       RWO            Delete           Bound    default/data-mysql-0   nfs-client              39s
persistentvolume/pvc-c7dfa8f0-557b-4bb2-85c3-a11bdef69dc0   10Gi       RWO            Delete           Bound    default/data-mysql-1   nfs-client              21s

NAME                                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/data-mysql-0   Bound    pvc-80cc45b7-77cd-4377-88a3-0c353e76d9c1   10Gi       RWO            nfs-client     39s
persistentvolumeclaim/data-mysql-1   Bound    pvc-c7dfa8f0-557b-4bb2-85c3-a11bdef69dc0   10Gi       RWO            nfs-client     21s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/mysql        ClusterIP   None            <none>        3306/TCP   27m
service/mysql-read   ClusterIP   10.233.41.119   <none>        3306/TCP   27m

NAME                                                    ENDPOINTS                               AGE
endpoints/mysql                                         10.233.92.111:3306,10.233.96.218:3306   27m
endpoints/mysql-read                                    10.233.92.111:3306,10.233.96.218:3306   27m
```

테스트를 위해 임시러 `nettool` 파드를 띄워 접속해보자. 

Master(헤드리스서비스)로 질의하면 파드의 IP가 출력되고,

Slave(ClusterIP서비스)로 질의하면 ClusterIP가 출력되는 것을 확인할 수 있다.

```shell
$ kubectl run nettool -it --image ghcr.io/c1t1d0s7/network-multitool --rm

If you don't see a command prompt, try pressing enter.
/ # host mysql
mysql.default.svc.cluster.local has address 10.233.92.111
mysql.default.svc.cluster.local has address 10.233.96.218
/ # host mysql-read
mysql-read.default.svc.cluster.local has address 10.233.41.119
```

mysql-0 (Master)에 접속해보자.

`mysql-statefulset.yaml`을 보면, 

`MYSQL_ALLOW_EMPTY_PASSWORD`이 활성화되어있어서 패스워드 없이 접속할 수 있다.

```shell
/ # mysql -h mysql-0.mysql -u root
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 57
Server version: 5.7.38-log MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MySQL [(none)]>
```

`nayoungs` 데이터베이스를 생성해보자.

```shell
MySQL [(none)]> create database nayoungs;
Query OK, 1 row affected (0.010 sec)

MySQL [(none)]> show databases;
+------------------------+
| Database               |
+------------------------+
| information_schema     |
| mysql                  |
| nayoungs                |
| performance_schema     |
| sys                    |
| xtrabackup_backupfiles |
+------------------------+
6 rows in set (0.009 sec)

MySQL [(none)]> exit
Bye
```

그리고 나와서 mysql-1 (Slave)에 접속해보자.

`nayoungs` 데이터베이스가 있는 것을 확인할 수 있고, Slave(RO)이기 때문에 drop 및 수정이 불가능하다.

```shell
/ # mysql -h mysql-1.mysql -u root
...
MySQL [(none)]> show databases;
+------------------------+
| Database               |
+------------------------+
| information_schema     |
| mysql                  |
| nayoungs                |
| performance_schema     |
| sys                    |
| xtrabackup_backupfiles |
+------------------------+
6 rows in set (0.015 sec)

MySQL [(none)]> drop database nayouns;
ERROR 1290 (HY000): The MySQL server is running with the --super-read-only option so it cannot execute this statement
MySQL [(none)]> exit
Bye
```

다시 mysql-0으로 접속하면 drop이 가능하다.

```shell
/ # mysql -h mysql-0.mysql -u root
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 148
Server version: 5.7.38-log MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MySQL [(none)]> show databases;
+------------------------+
| Database               |
+------------------------+
| information_schema     |
| mysql                  |
| nayoungs                |
| performance_schema     |
| sys                    |
| xtrabackup_backupfiles |
+------------------------+
6 rows in set (0.024 sec)

MySQL [(none)]> drop database nayouns;
Query OK, 0 rows affected (0.023 sec)

MySQL [(none)]> exit
Bye
```

다시 mysql-1로 접속하면, `nayoungs` 데이터베이스가 drop된 것을 확인할 수 있다.

```shell
/ # mysql -h mysql-1.mysql -u root
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 153
Server version: 5.7.38 MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MySQL [(none)]> show databases;
+------------------------+
| Database               |
+------------------------+
| information_schema     |
| mysql                  |
| performance_schema     |
| sys                    |
| xtrabackup_backupfiles |
+------------------------+
5 rows in set (0.010 sec)
```

즉, **Master와 Slave은 동기화**된다는 것을 알 수 있다. 

또한 여기서 **스케일링을 통해 파드를 늘려도, 바로 동기화된다.**

<br>

테스트를 위해 Master로 접속해서, 

데이터베이스 `nayoungs`를 만들고 `message` 테이블을 만들어 `hello mysql` 데이터를 넣어보자.

```shell
$ kubectl run nettool -it --image ghcr.io/c1t1d0s7/network-multitool --rm

If you don't see a command prompt, try pressing enter.
/ # mysql -h mysql-0.mysql -u root
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 42
Server version: 5.7.38-log MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MySQL [(none)]> create database nayoungs;
Query OK, 1 row affected (0.007 sec)

MySQL [(none)]> used database nayoungs;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'used database nayoungs' at line 1
MySQL [(none)]> use nayoungs;
Database changed
MySQL [nayoungs]> create table nayoungs.message (message VARCHAR(50));
Query OK, 0 rows affected (0.024 sec)

MySQL [nayoungs]> show tables;
+--------------------+
| Tables_in_nayoungs |
+--------------------+
| message            |
+--------------------+
1 row in set (0.002 sec)

MySQL [nayoungs]> insert into nayoungs.message values ("hello mysql");
Query OK, 1 row affected (0.013 sec)

MySQL [nayoungs]> select * from message;
+-------------+
| message     |
+-------------+
| hello mysql |
+-------------+
1 row in set (0.001 sec)

MySQL [nayoungs]> exit
Bye
```

이 상태에서 스케일링을 통해 파드를 1개 늘린 뒤,

```shell
$ kubectl scale sts mysql --replicas=3
```

생성된 `mysql-2`로 접속해보면 **데이터가 바로 동기화**되어있는 것을 확인할 수 있다.

```shell
$ kubectl run nettool -it --image ghcr.io/c1t1d0s7/network-multitool --rm

If you don't see a command prompt, try pressing enter.
/ # mysql -h mysql-2.mysql -u root -e 'select * from nayoungs.message;'
+-------------+
| message     |
+-------------+
| hello mysql |
+-------------+
```

<br>

<br>

<br>

참고

https://nearhome.tistory.com/107

https://m.blog.naver.com/PostView.naver?isHttpsRedirect=true&blogId=isc0304&logNo=221885403537