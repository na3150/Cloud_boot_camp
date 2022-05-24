# [Kubernetes] k8s 디플로이먼트(Deployments)

<br>

## Deployments란?

[디플로이먼트(deployment)](https://kubernetes.io/ko/docs/concepts/workloads/controllers/deployment/)란 K8s에서 애플리케이션 단위를 관리하는 **Controller**이며, 

Kubernetes의 최소 유닛인 Pod에 대한 기준 spec을 정의한 Object이다.

Kubernetes에서는 각 Object를 독립적으로 생성하기 보다는 Deployment를 통해서 생성하는 것을 권장하고 있으며, 

**Pod와 ReplicaSet의 기준 정보를 지정할 수 있다.**

ReplicaSets에 대한 자세한 설명은 [ReplicationController와 ReplicaSets](https://nayoungs.tistory.com/entry/Kubernetes-Controller-ReplicationController%EC%99%80-ReplicaSets)에서 확인할 수 있다.

<br>

<img src="https://blog.kakaocdn.net/dn/qvyCy/btqFNQRUYPV/b8mUvNa1WaeyGN7H0GtcE1/img.png" alt="img" style="zoom:67%;" />

출처: https://huisam.tistory.com/entry/k8s-deployment

<br>

이러한 Deployment는

1. Pod의 scale in / out 되는 기준을 정의한다.
2. Pod의 배포되고 update되는 모든 버전을 추적할 수 있다.
3. 배포된 Pod에 대한 rollback을 수행할 수 있다.

<br>

**즉, 개념적으로 Deployment = ReplicaSet + Pod + history이며 ReplicaSet 을 만드는 것보다 더 윗 단계의 선언(추상표현)이다.**

<br>

정리하면 Deployment가 ReplicaSets을 만들고, ReplicaSets이 Pod를 만든다.

즉, Deployment만 선언하면 ReplicaSets부터 Pod까지 만들어진다. 

이러한 이유로 ReplicaSets를 직접 생성하는 것보다는 일반적으로 Deployment를 많이 사용한다.

[deployment usecase](https://kubernetes.io/ko/docs/concepts/workloads/controllers/deployment/#유스케이스)

<br>

**리소스 확인**

```shell
$ kubectl api-resources| grep deployment
deployments                       deploy       apps/v1                                true         Deployment
```

<br>

**리소스 정의 방법 확인**

```shell
$ kubectl explain deployment.spec  
```

**필수 Field**

- Deployments의 설정 정보 (apiVersion, kind, metadata)

- ReplicaSets의 설정 정보 (replicas, selector)

- Pod의 설정 정보 (template)

<br>

##### strategy

- [deployment strategy](https://kubernetes.io/ko/docs/concepts/workloads/controllers/deployment/#전략) : 이전 파드를 새로운 파드로 대체하는 전략을 명시
- `deploy.spec.strategy`

```shell
$ kubectl explain deploy.spec.strategy
KIND:     Deployment
VERSION:  apps/v1

RESOURCE: strategy <Object>

DESCRIPTION:
     The deployment strategy to use to replace existing pods with new ones.

     DeploymentStrategy describes how to replace existing pods with new ones.

FIELDS:
   rollingUpdate        <Object>
     Rolling update config params. Present only if DeploymentStrategyType =
     RollingUpdate.

   type <string>
     Type of deployment. Can be "Recreate" or "RollingUpdate". Default is
     RollingUpdate.
```

- `Recreate` : 모든 것을 삭제하고 다시 시작한다.

- `rollingUpdate`(default) : 한번에 n개씩 Pod를 순차적으로 업데이트한다. (무중단 배포)

  - `maxSurge` :  rolling update 중 deployment에 설정되어 있는 기본 pod개수보다 여분의 pod가 몇개가 더 추가될 수 있는지를 설정 (default는 25%)

  - `maxUnavailable` : 업데이트하는 동안 몇 개의 pod가 이용 불가능하게 되어도 되는지를 설정
    - rolling update 중 unavailable 상태인 Pod의 최대 개수(default는 25%)
  - maxSurge와 maxUnavailable 값이 동시에 0이 될 수 없다.

```shell
$  kubectl explain deploy.spec.strategy.rollingUpdate
KIND:     Deployment
VERSION:  apps/v1

RESOURCE: rollingUpdate <Object>

DESCRIPTION:
     Rolling update config params. Present only if DeploymentStrategyType =
     RollingUpdate.

     Spec to control the desired behavior of rolling update.

FIELDS:
   maxSurge     <string>
     The maximum number of pods that can be scheduled above the desired number
     of pods. Value can be an absolute number (ex: 5) or a percentage of desired
     pods (ex: 10%). This can not be 0 if MaxUnavailable is 0. Absolute number
     is calculated from percentage by rounding up. Defaults to 25%. Example:
     when this is set to 30%, the new ReplicaSet can be scaled up immediately
     when the rolling update starts, such that the total number of old and new
     pods do not exceed 130% of desired pods. Once old pods have been killed,
     new ReplicaSet can be scaled up further, ensuring that total number of pods
     running at any time during the update is at most 130% of desired pods.

   maxUnavailable       <string>
     The maximum number of pods that can be unavailable during the update. Value
     can be an absolute number (ex: 5) or a percentage of desired pods (ex:
     10%). Absolute number is calculated from percentage by rounding down. This
     can not be 0 if MaxSurge is 0. Defaults to 25%. Example: when this is set
     to 30%, the old ReplicaSet can be scaled down to 70% of desired pods
     immediately when the rolling update starts. Once new pods are ready, old
     ReplicaSet can be scaled down further, followed by scaling up the new
     ReplicaSet, ensuring that the total number of pods available at all times
     during the update is at least 70% of desired pods.
```

<br>

**☁️ 참고**

데몬셋도 updateStrategy가 존재한다.

설정 방법은 Deployment의 strategy와 동일하다.

단, 데몬셋은 노드당 1개씩 존재하기 때문에, 중간에 다운타임이 발생할 수 있다.

```shell
$ kubectl explain ds.spec.updateStrategy          
KIND:     DaemonSet
VERSION:  apps/v1

RESOURCE: updateStrategy <Object>

DESCRIPTION:
     An update strategy to replace existing DaemonSet pods with new pods.

     DaemonSetUpdateStrategy is a struct used to control the update strategy for
     a DaemonSet.

FIELDS:
   rollingUpdate        <Object>
     Rolling update config params. Present only if type = "RollingUpdate".

   type <string>
     Type of daemon set update. Can be "RollingUpdate" or "OnDelete". Default is
     RollingUpdate.
```

<br>

##### minReadySeconds

pod의 status가 ready가 될 때까지의 최소 대기 시간이다. (default는 0)

pod가 실행된 후,  `.spec.minReadySeconds`에 설정된 시간동안은 트래픽을 받지 않는다.

그러나 [readinessProbe](https://nayoungs.tistory.com/entry/Kubernetes-k8s-%ED%94%84%EB%A1%9C%EB%B8%8CProbe-Readiness-Probe)가 세팅되어있으면, readinessProbe가 완료된 후 minReadySeconds는 무시되기 때문에,

minReadySeconds 보다는 readinessProbe를 사용하는 것을 더 권장한다. 

```shell
$ kubectl explain deploy.spec.minReadySeconds       
KIND:     Deployment
VERSION:  apps/v1

FIELD:    minReadySeconds <integer>

DESCRIPTION:
     Minimum number of seconds for which a newly created pod should be ready
     without any of its container crashing, for it to be considered available.
     Defaults to 0 (pod will be considered available as soon as it is ready)
```

<br>

##### revisionHistoryLimit

rollback을 위해 보유할 이전 버전 ReplicaSets(history)의 최대 개수이다.

default는 10이고, history는 최대 10개까지 남아있을 수 있다.

```shell
$ kubectl explain deploy.spec.revisionHistoryLimit
KIND:     Deployment
VERSION:  apps/v1

FIELD:    revisionHistoryLimit <integer>

DESCRIPTION:
     The number of old ReplicaSets to retain to allow rollback. This is a
     pointer to distinguish between explicit zero and not specified. Defaults to
     10.
```

<br>

**💻 실습** : Deployment + Service(LB) 생성하기

`myweb-deploy.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myweb-deploy
spec:
  replicas: 3 #RS 설
  selector:
    matchLabels:
      app: web
  template: #Pod 설정
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

`myweb-svc-lb.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myweb-svc-lb
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 8080
```

```shell
$ kubectl create -f myweb-deploy.yaml -f myweb-svc-lb.yaml
```

Deployment, ReplicatSets, Pod 그리고 Service와 Enpoints 까지 정상적으로 생성된 것을 확인할 수 있다.

```shell
$ kubectl get deploy,rs,po,svc,ep    
NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/myweb-deploy             3/3     3            3           8h

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/myweb-deploy-5d9fc76b4d             0         0         0       8h
replicaset.apps/myweb-deploy-7857988545             0         0         0       8h
replicaset.apps/myweb-deploy-7d649cccb8             3         3         3       7h58m

NAME                                          READY   STATUS    RESTARTS      AGE
pod/myweb-deploy-7d649cccb8-mjqkd             1/1     Running   1 (82m ago)   7h58m
pod/myweb-deploy-7d649cccb8-qt8rt             1/1     Running   1 (82m ago)   7h58m
pod/myweb-deploy-7d649cccb8-xn7d9             1/1     Running   1 (81m ago)   7h58m

NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP       PORT(S)        AGE
service/kubernetes     ClusterIP      10.233.0.1     <none>            443/TCP        4d9h
service/myweb-svc-lb   LoadBalancer   10.233.8.211   192.168.100.240   80:30786/TCP   6s

NAME                                                    ENDPOINTS                                                 AGE
endpoints/myweb-svc-lb                                  10.233.90.140:8080,10.233.92.55:8080,10.233.96.156:8080   6s
```

<br>

<br>

## Deployment Rollback 및 Rollout 기록 조회

```shell
$ kubectl rollout [커맨드] deploy [디플로이먼트 이름]
```

Command

- `history` : **rollout history를 확인**
- `pause`  :  리소스를 일시중지
- `restart ` :  리소스를 재시작
- `resume`  :  중지된 리소스를 다시 시작
- `status` : **deployment의 rollout 상태를 확인**
  - 변환하는 과정을 확인할 수 있다.
- `undo`  :  **deployment를 rollback**
  - 이전 상태로 되돌아가도 버전(revision)은 업그레이드한다.
  - `--to-revision`으로 버전을 지정 가능하다.
  - 버전(revision)을 지정하지 않으면 바로 이전 단계로 되돌아간다.

<br>

예시

deployment 상태 확인 : status

```shell
$ kubectl rollout status deploy myweb-deploy  
deployment "myweb-deploy" successfully rolled out
```

deployment history 및 revision 확인 : history

```shell
$ kubectl rollout history deploy myweb-deploy
deployment.apps/myweb-deploy 
REVISION  CHANGE-CAUSE
1         <none>
```

deployment 버전 되돌리기 : undo

```shell
$ kubectl rollout undo deploy myweb-deploy --to-revision=2
```

<br>

<br>

## Deployment 업데이트

```shell
$ kubectl set image deployment [디플로이먼트이름] [컨테이너이름]=[이미지]:[버전]
$ kubectl set image deployment/[디플로이먼트이름] [컨테이너이름]=[이미지]:[버전]
```

이미지를 수정하는 방법에는 patch, apply, edit 등등 여러가지 방법이 있지만, 

deployment는 `kubectl set image` 명령어를 사용할 수 있다.

<br>

예시

```shell
$ kubectl set image deployments myweb-deploy myweb=ghcr.io/c1t1d0s7/go-myweb:v2.0 --record
```

`kubectl rollout history` 명령 시 출력되는 **`CHANGE-CAUSE`(사유)는 `--record` 옵션을 사용한 경우만 기록**된다.

`--record` 옵션을 사용하지 않으면 `<none>`으로 기록된다.

CHANGE-CAUSE는 나중에 추적할 때에 필요할 수 있으므로 `--record` 옵션을 붙여주는 것이 좋다.

<br>

단, 파일 내용을 확인하지는 못하기 때문에, **파일을 수정하는 경우는 annotaions을 사용하는 것을 권장**한다.

annotation 사용 예시는 뒤의 실습2 에서 확인할 수 있다.

```shell
$ kubectl rollout history -f myweb-deploy.yaml 
deployment.apps/myweb-deploy 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         kubectl set image deployments myweb-deploy myweb=ghcr.io/c1t1d0s7/go-myweb:v2.0 --record=true
5         kubectl apply --filename=myweb-deploy.yaml --record=true
6         Change Go Myweb version from 3 to 4
```

`--revision` 옵션을 사용하면 상세정보를 볼 수 있다

<br>

<br>

**💻 실습 1** : Deployment의 롤백, 롤아웃, 업데이트

`myweb-deploy.yaml`

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
          image: ghcr.io/c1t1d0s7/go-myweb:v1.0
          ports:
            - containerPort: 8080
```

```shell
$ kubectl create -f myweb-deploy.yaml -f myweb-svc-lb.yaml
```

```shell
$ curl 192.168.100.240                                        

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0 100    61  100    61    0
0  15250      0 --:--:-- --:--:-- --:--:-- 15250
===Version 1.0===
Hello World!
myweb-deploy-7d649cccb8-9hqj6    Left  Speed
```

myweb-deploy의 이미지를 변경(업데이트)해보자.

```shell
$ kubectl set image deployments myweb-deploy myweb=ghcr.io/c1t1d0s7/go-myweb:v2.0 --record
```

`kubectl rollout status` 명령어를 통해 과정을 확인할 수 있다.

```shell
kubectl rollout status deploy myweb-deploy 
Waiting for deployment "myweb-deploy" rollout to finish: 1 out of 3 new replicas have been updated...
```

 버전이 2.0으로 업데이트 되고,

```shell
$ curl 192.168.100.240                                        

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0 100    61  100    61    0
0  15250      0 --:--:-- --:--:-- --:--:-- 15250
===Version 2.0===
Hello World!
myweb-deploy-7d649cccb8-9hqj6    Left  Speed
```

history를 확인할 수 있다.

```shell
$ kubectl rollout history deploy myweb-deploy      
deployment.apps/myweb-deploy 
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deployment myweb-deploy myweb=ghcr.io/c1t1d0s7/go-myweb:v2.0 --record=true
```

myweb-deploy를 롤백한 뒤 history를 살펴보면, 

원래 상태(이전)으로 돌아갔지만 REVISION이 증가한 것을 확인할 수 있다.

```shell
$ kubectl rollout undo deploy myweb-deploy   
deployment.apps/myweb-deploy rolled back
$ kubectl rollout history deploy myweb-deploy
deployment.apps/myweb-deploy 
REVISION  CHANGE-CAUSE
2         kubectl set image deployment myweb-deploy myweb=ghcr.io/c1t1d0s7/go-myweb:v2.0 --record=true
3         (none)
```

이번에는 set image 대신, yaml 파일을 수정하고`apply`명령어를 통해 이미지를  `3.0`으로 업데이트해보자.

`myweb-deploy.yaml`

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
          image: ghcr.io/c1t1d0s7/go-myweb:v3.0 #버전 수정
          ports:
            - containerPort: 8080
```

```shell
$ kubectl apply -f myweb-deploy.yaml --record
$ curl 192.168.100.240
===Version 3.0===
Hello World!
myweb-deploy-744cb77cb6-ct27v
```

이제 history를 확인해보면, CHANGE-CAUSE에 명령어가 저장된 것을 확인할 수 있다.

```shell
$ kubectl rollout history deploy myweb-deploy  
deployment.apps/myweb-deploy 
REVISION  CHANGE-CAUSE
2         kubectl set image deployment myweb-deploy myweb=ghcr.io/c1t1d0s7/go-myweb:v2.0 --record=true
3         <none>
4         kubectl apply --filename=myweb-deploy.yaml --record=true
```

`kubectl set image` 명령을 통해 이미지를 변경했을 때에는 변경된 내용을 history를 보고 알 수 있지만,

**파일 내용을 수정하고 `kubectl apply`하게 되면 history를 보고 이미지를 무엇으로 바꿨는지를 알 수 없다.**

따라서 파일을 수정할 때는 annotations를 사용하는 것을 권장한다.

<br>

<br>

**💻 실습 2** : Annotation을 이용한 버전 업그레이드 

annotation을 설정한 뒤, 이미지 버전을 업그레이드하고 history를 확인해보자.

<br>

`myweb-deploy.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myweb-deploy
  annotations: #annotaion
    kubernetes.io/change-cause: "Change Go Myweb version from 3 to 4"
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
          image: ghcr.io/c1t1d0s7/go-myweb:v4.0 #버전 수정
          ports:
            - containerPort: 8080
```

단, <u>**annotaion을 사용하는 경우는 `--record` 옵션을 사용하지 말아야한다.**</u>

```shell
$ kubectl apply -f myweb-deploy.yaml  
```

```shell
$ curl 192.168.100.240
===Version 4.0===
Hello World!
myweb-deploy-54948b568c-vvb5c
```

history를 확인해보면, annotation이 CHANGE-CAUSE로 기록된 것을 확인할 수 있다.

```shell
$ kubectl rollout history deploy myweb-deploy
deployment.apps/myweb-deploy 
REVISION  CHANGE-CAUSE
2         kubectl set image deployment myweb-deploy myweb=ghcr.io/c1t1d0s7/go-myweb:v2.0 --record=true
3         <nonde>
6         kubectl apply --filename=myweb-deploy.yaml --record=true
7         Change Go Myweb version from 3 to 4
```

<br>

<br>

<br>
참고 

https://blog.wonizz.tk/2019/09/17/kubernetes-deployment/

https://tech.kakao.com/2018/12/24/kubernetes-deploy/
