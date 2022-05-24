# [Kubernetes] k8s Volume: 동적 프로비저닝(Provisioning) with NFS & 기본 스토리지 클래스

<br>

동적 프로비저닝(Dynamic Provisioning)은, **사용자가 PVC를 만들면 알아서 PV를 만들고 Volume과의 연결을 진행**한다.

동적으로 PV를 생성하기 위해서는 [스토리지 클래스(storageClass)](https://kubernetes.io/ko/docs/concepts/storage/storage-classes/)가 필요하다.

**`StorageClassName` 필드에 사전 생성된 StorageClass Object를 기입하는 것으로 동적 PV가 생성가능**하다

이러한 StorageClass는 추가적으로 생성이 가능하며 Default를 설정할 수 있다.

<br>

[스토리지 클래스 프로비저너](https://kubernetes.io/ko/docs/concepts/storage/storage-classes/#프로비저너)를 보면, 동적 프로비저닝을 지원하는 다양한 형태의 스토리지들을 볼 수 있다.

내부 프로비저너는 자체적으로 쿠버네티스에 포함되어있는 것이고, 

그렇지 않은 것(예: NFS)은 별도로 외부 프로비저너를 구성해야한다.

<br>

<br>

**💻 실습** : NFS Dynamic Provisioner 구성

NFS 스토리지를 동적으로 프로비저닝해보자. 

NFS는 내부 프로비저너가 아니므로, [nfs-subdir-external-provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner)를 통해 별도로 외부 프로비저너를 구성한다.

(Helm을 사용지 않는 방법으로)

<br>

홈 디렉토리에서 `git clone`을 통해 동기화시킨다.

```
$ git clone https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner.git
```

`nfs-subdir-external-provisioner` 디렉토리가 생성된 것을 확인할 수 있고,

이 디렉토리 내부의 `/deploy` 디렉토리로 이동한다.

```
$ cd nfs-subdir-external-provisioner/deploy
```

`rbac.yaml` 파일을 수정 없이 바로 실행시킨다.

```
$ kubectl create -f rbac.yaml
```

`deployment.yaml` 파일을 주석 설명에 따라 수정한다.

`deployment.yaml`

```yaml
...
          env: #환경변수
            - name: PROVISIONER_NAME
              value: k8s-sigs.io/nfs-subdir-external-provisioner
            - name: NFS_SERVER #실제 NFS 서버의 위치
              value: 192.168.100.100 #IP주소 수정
            - name: NFS_PATH #실제 NFS 서버의 Path
              value: /nfsvolume #path 수정
      volumes:
        - name: nfs-client-root
          nfs:
            server: 192.168.100.100 #IP주소 수정
            path: /nfsvolume #path 수정
...
```

수정한 `deployment.yaml` 파일을 실행한다.

```
$ kubectl create -f deployment.yaml
```

`class.yaml` 파일을 수정 없이 바로 실행한다. 해당 class가 우리가 사용할 스토리지 클래스이다.

```
$ kubectl create -f class.yaml
```

설치된 환경을 살펴보면 다음과 같다.

```shell
$ kubectl get deploy,rs,po        
NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nfs-client-provisioner   1/1     1            1           8h

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/nfs-client-provisioner-758f8cd4d6   1         1         1       8h

NAME                                          READY   STATUS    RESTARTS       AGE
pod/myweb-env                                 1/1     Running   2 (125m ago)   7h39m
pod/nfs-client-provisioner-758f8cd4d6-2sqcr   1/1     Running   2 (125m ago)   8h
```

스토리지 클래스를 확인해보자.

클라우드가 아니기 때문에 일반적으로 `Immediate`으로 설정된다. (클라우드는 `WaitForFirstConsumer`)

```shell
$ kubectl get sc 
NAME         PROVISIONER                                   RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client   k8s-sigs.io/nfs-subdir-external-provisioner   Delete          Immediate           false                  47s
```

<br>

다음과 같이 `storageClassName`을 스토리지클래스이름과 맞춰주면, pvc를 만들었을 때,

PVC가 PV를 만들어서 NFS 스토리지를 연결시켜준다.

`mypvc-dynamic.yaml`

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc-dynamic
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1G
  storageClassName: 'nfs-client'  #스토리지클래스 이름 수정 (kubectl get sc로 확인한 이름)
```

```shell
$ kubectl create -f mypvc-dynamic.yaml
```

PV와 PVC가 생성된 것을 확인할 수 있다.

PVC의 STATUS가 `Bound`인 것을 확인할 수 있고, 연결된 볼륨은 랜덤하게 만들어진다.

PVC 볼륨이 PV의 NAME에 붙어있으며, CLAIM이 `default/mypvc-dynamic`인 것을 확인할 수 있다.

```shell
$ kubectl get pv,pvc                  
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   REASON   AGE
persistentvolume/pvc-b4ab8b93-3486-4cb7-8c87-6960f5198328   1G         RWX            Delete           Bound    default/mypvc-dynamic   nfs-client              80s

NAME                                  STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/mypvc-dynamic   Bound    pvc-b4ab8b93-3486-4cb7-8c87-6960f5198328   1G         RWX            nfs-client     80s
```

즉, **PVC만 만들면 스토리지 클래스에 의해서 PV가 만들어지고, 구성이 된다.**

그리고 앞서 볼륨 경로로 설정한 `/nfsvolume`를 확인해보면 디렉토리가 만들어져있는 것을 확인할 수 있다.

데이터들은 이 디렉토리에 저장되게 된다.

```shell
$ sudo ls /nfsvolume   
default-mypvc-dynamic-pvc-b4ab8b93-3486-4cb7-8c87-6960f5198328
```

 현재는 디렉토리가 비어져있고, 다음과 같이 `index.html` 파일을 만들자.

```shell
$ echo "<h1> Hello NFS Dynamic Provision </h1>" | sudo tee /nfsvolume/XXX/index.html
```

지금까지 pv, pvc가 생성된 것을 확인할 수 있었고, 이제 테스트를 위해 ReplicaSets과 Service를 생성하자.

<br>

`myweb-rs-dynamic.yaml`

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
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: myweb
          image: httpd
          volumeMounts:
            - name: myvol
              mountPath: /usr/local/apache2/htdocs
      volumes:
        - name: myvol
          persistentVolumeClaim:
            claimName: mypvc-dynamic
```

`myweb-svc-lb.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myweb-svc-lb
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 80
  selector:
    app: web%            
```

```shell
$ kubectl create -f myweb-rs-dynamic.yaml -f myweb-svc-lb.yaml
```

접속 확인

```shell
$ curl 192.168.100.240
<h1> Hello NFS Dynamic Provision </h1>
```

![image-20220524233631644](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220524233631644.png)

마지막으로 삭제를 진행한다.

```shell
$ kubectl delete -f .                    
persistentvolumeclaim "mypvc-dynamic" deleted
replicaset.apps "myweb-rs-dynamic" deleted
service "myweb-svc-lb" deleted
```

스토리지 클래스의 `RECLAIMPOLICY `정책이 `Delete`이기 때문에 pvc를 지우면 pv도 함께 지워진다.

```shell
$ kubectl get pv,pvc
No resources found
```

```shell
$ kubectl get sc          
NAME                   PROVISIONER                                   RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client (default)   k8s-sigs.io/nfs-subdir-external-provisioner   Delete          Immediate           false                  9h
```

삭제될 때 `/nfsvolume`의 데이터도 지워지며, 남기고 싶으면 `RECLAIMPOLICY`를 `RETAIN`으로 설정하면 된다.

<br>

<br>

## 기본(default) 스토리지 클래스

여러 스토리지 클래스 중에서도 클러스터에서 기본적으로 사용되는 스토리지 클래스가 있다.

기본 스토리지 클래스는 옵션으로 **명시적으로 지정해주지 않아도 기본적으로 선택되는 스토리지 클래스**이다.

기본 스토리지 클래스는 스토리지 클래스가 여러개일 때 실제로 많이 사용되는 개념이다.

<br>

다음과 같이 annotations을 추가하여 `class.yaml` 파일을 수정한다.

`~/nfs-subdir-external-provisioner/deploy/class.yaml`

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-client
  annotations: #annotation
    storageclass.kubernetes.io/is-default-class: "true" #default 클래스 설정
provisioner: k8s-sigs.io/nfs-subdir-external-provisioner # or choose another name, must match deployment's env PROVISIONER_NAME'
parameters:
  archiveOnDelete: "false"
```

`kubectl apply`를 통해 변경사항을 반영한다.

```shell
$ kubectl apply -f class.yaml
```

`nfs-client` 스토리지 클래스가 default(기본) 스토리지 클래스로 설정된 것을 확인할 수 있다.

```shell
$  kubectl get sc          
NAME                   PROVISIONER                                   RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client (default)   k8s-sigs.io/nfs-subdir-external-provisioner   Delete          Immediate           false                  9h
```

annotation을 제거하면 default 스토리지 클래스 설정이 해제되고,

```shell
$ kubectl annotate
 sc nfs-client storageclass.kubernetes.io/is-default-class-
storageclass.storage.k8s.io/nfs-client annotated
$ kubectl get sc
NAME         PROVISIONER                                   RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client   k8s-sigs.io/nfs-subdir-external-provisioner   Delete          Immediate           false                  9h
```

다시 annotation을 추가하면 default 스토리지 클래스로 설정되는 것을 확인할 수 있다.

```shell
$ kubectl annotate sc nfs-client storageclass.kubernetes.io/is-default-class="true"
storageclass.storage.k8s.io/nfs-client annotated
$ kubectl get sc
NAME                   PROVISIONER                                   RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client (default)   k8s-sigs.io/nfs-subdir-external-provisioner   Delete          Immediate           false                  9h
```

이와 같이 `nfs-client`를 default 스토리지 클래스로 설정하면,

PVC 생성 시, 아래와 같이 

스토리지 클래스를 명시하지 않아도, 자동으로 `nfs-client` 스토리지 클래스가 선택된다.

`mypvc-dynamic.yaml`

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc-dynamic
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1G
```

<br>

<br>

<br>

참고

https://jangcenter.tistory.com/119