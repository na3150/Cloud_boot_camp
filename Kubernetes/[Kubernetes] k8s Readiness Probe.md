# [Kubernetes] k8s 프로브(Probe) : Readiness Probe

Probe란, 컨테이너에서 Kubelet에 의해 주기적으로 수행되는 진단이다.

프로브에 대한 더 자세한 설명은 [Pod Lifecycle](https://nayoungs.tistory.com/entry/Kubernetes-Pod-Lifecycle)에서 확인할 수 있다.

<br>

##### readinessProbe 

컨테이너가 요청을 처리할 준비가 되었는지 여부를 나타낸다.

Service와 연결된 Pod를 확인하여 **Readiness Probe에 대해 응답이 없거나 실패 응답을 보낸다면,**

**해당 Pod를 사용불가능한 상태라고 판단하여 서비스 목록에서 제외**한다. (서비스들의 엔드포인트에서 파드의 IP주소를 제거)

![img](https://blog.kakaocdn.net/dn/m7Tcu/btrq33Lr7v6/dfo3dkl1nBfxPH1nRiy6Y0/img.png)

출처: https://jangcenter.tistory.com/112

<br>

만약 컨테이너가 **readinessProbe를 지원하지 않는다면(설정하지 않는다면), 기본 상태는** `Success` 이다.

따라서 readinessProbe 설정을 하지 않는다면,

요청을 보낸 후 정상적으로 작동중이지 않은 파드로부터 응답이 돌아오지 않는 문제가 발생할 수 있다.

- `svc.spec.template.spec.containers.readinessProbe`

```shell
$ kubectl explain rs.spec.template.spec.containers.readinessProbe 
KIND:     ReplicaSet
VERSION:  apps/v1

RESOURCE: readinessProbe <Object>

DESCRIPTION:
     Periodic probe of container service readiness. Container will be removed
     from service endpoints if the probe fails. Cannot be updated. More info:
     https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes

     Probe describes a health check to be performed against a container to
     determine whether it is alive or ready to receive traffic.

FIELDS:
   exec <Object>
     One and only one of the following should be specified. Exec specifies the
     action to take.

   failureThreshold     <integer>
     Minimum consecutive failures for the probe to be considered failed after
     having succeeded. Defaults to 3. Minimum value is 1.

   httpGet      <Object>
     HTTPGet specifies the http request to perform.

   initialDelaySeconds  <integer>
     Number of seconds after the container has started before liveness probes
     are initiated. More info:
     https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes

   periodSeconds        <integer>
     How often (in seconds) to perform the probe. Default to 10 seconds. Minimum
     value is 1.

   successThreshold     <integer>
     Minimum consecutive successes for the probe to be considered successful
     after having failed. Defaults to 1. Must be 1 for liveness and startup.
     Minimum value is 1.

   tcpSocket    <Object>
     TCPSocket specifies an action involving a TCP port. TCP hooks not yet
     supported

   terminationGracePeriodSeconds        <integer>
     Optional duration in seconds the pod needs to terminate gracefully upon
     probe failure. The grace period is the duration in seconds after the
     processes running in the pod are sent a termination signal and the time
     when the processes are forcibly halted with a kill signal. Set this value
     longer than the expected cleanup time for your process. If this value is
     nil, the pod's terminationGracePeriodSeconds will be used. Otherwise, this
     value overrides the value provided by the pod spec. Value must be
     non-negative integer. The value zero indicates stop immediately via the
     kill signal (no opportunity to shut down). This is a beta field and
     requires enabling ProbeTerminationGracePeriod feature gate. Minimum value
     is 1. spec.terminationGracePeriodSeconds is used if unset.

   timeoutSeconds       <integer>
     Number of seconds after which the probe times out. Defaults to 1 second.
     Minimum value is 1. More info:
     https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
```

<br>

**💻 실습**

프로브는 프로브 체크 메커니즘의 성공 여부에 따라 `Success` 또는 `Failure`가 된다.

다음과 같이 존재하지 않는 파일 `/tmp/ready`를 참조하게하여 **항상 실패하는 readinessProbe를 생성**해보자.

<br>

`myweb-rs.yaml`

```
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
          image: ghcr.io/c1t1d0s7/go-myweb:alpine
          ports:
            - containerPort: 8080
              protocol: TCP
          readinessProbe:
            exec:
              command:
                - ls
                - /tmp/ready
```

현재는 설명을 위해 `exec` 체크 메카니즘을 사용하였으나, 실제로는 일반적으로 `httpGet` 방식을 사용한다. 

<br>

`myweb-svc-lb.yaml`

```
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
$ kubectl create -f .
```

실패하는 readinsProbe를 작성했기 때문에, 해당 파드들을 사용 불가능한 상태라고 판단하게 되고, 

**서비스의 엔드포인트에서 파드의 IP주소를 제거**하게 된다.

상태를 확인해보면, `myweb-svc-lb`의 엔드포인트에 아무것도 없는 것을 확인할 수 있다.

```shell
$ kubectl get rs,po,svc,ep
NAME                       DESIRED   CURRENT   READY   AGE
replicaset.apps/myweb-rs   3         3         0       11m

NAME                 READY   STATUS    RESTARTS   AGE
pod/myweb-rs-kp4j2   0/1     Running   0          11m
pod/myweb-rs-md6bk   0/1     Running   0          11m
pod/myweb-rs-z7ld9   0/1     Running   0          11m

NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP       PORT(S)        AGE
service/kubernetes     ClusterIP      10.233.0.1     <none>            443/TCP        3d13h
service/myweb-svc-lb   LoadBalancer   10.233.2.195   192.168.100.240   80:31466/TCP   10m

NAME                     ENDPOINTS              AGE
endpoints/kubernetes     192.168.100.100:6443   3d13h
endpoints/myweb-svc-lb                          10m
```

접속을 시도해도, 당연히 404 Not Found가 출력된다.

```shell
$ curl 192.168.100.100                  
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
```

그렇다면 readinessProbe가 실패하지 않도록 파드 한개를 선택해서  `/tmp/ready` 파일을 생성해보자.

```shell
$ kubectl exec myweb-rs-kp4j2 touch /tmp/ready 
```

```shell
$ kubectl get po -o wide                 
NAME             READY   STATUS    RESTARTS   AGE   IP              NODE    NOMINATED NODE   READINESS GATES
myweb-rs-kp4j2   1/1     Running   0          16m   10.233.92.12    node3   <none>           <none>
myweb-rs-md6bk   0/1     Running   0          16m   10.233.90.96    node1   <none>           <none>
myweb-rs-z7ld9   0/1     Running   0          16m   10.233.96.106   node2   <none>           <none>
```

시간이 조금 지난 후, 수정한 파드가 엔드포인트에 추가된 것을 확인할 수 있다.

```shell
$ kubectl get po,svc,ep                          k8s-node1: Mon May 23 16:27:08 2022

NAME                 READY   STATUS    RESTARTS   AGE
pod/myweb-rs-kp4j2   1/1     Running   0          15m
pod/myweb-rs-md6bk   0/1     Running   0          15m
pod/myweb-rs-z7ld9   0/1     Running   0          15m

NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP       PORT(S)        AGE
service/kubernetes     ClusterIP      10.233.0.1     <none>            443/TCP        3d14h
service/myweb-svc-lb   LoadBalancer   10.233.2.195   192.168.100.240   80:31466/TCP   15m

NAME                     ENDPOINTS              AGE
endpoints/kubernetes     192.168.100.100:6443   3d14h
endpoints/myweb-svc-lb   10.233.92.12:8080      15m
```

로드밸런서를 통해 해당 파드에만 접속되는 것을 확인할 수 있다.

```shell
$ curl 192.168.100.240
Hello World!
myweb-rs-kp4j2
$ curl 192.168.100.240
Hello World!
myweb-rs-kp4j2
$ curl 192.168.100.240
Hello World!
myweb-rs-kp4j2
```

이제, 파드에서 다시 `/tmp/ready` 파일을 지워보자.

```shell
$ kubectl exec myweb-rs-kp4j2 -- rm /tmp/ready
```

엔드포인트에서 파드가 사라진 것을 확인할 수 있다.

```shell
$ kubectl get po,svc,ep                          k8s-node1: Mon May 23 16:31:02 2022

NAME                 READY   STATUS    RESTARTS   AGE
pod/myweb-rs-kp4j2   0/1     Running   0          19m
pod/myweb-rs-md6bk   0/1     Running   0          19m
pod/myweb-rs-z7ld9   0/1     Running   0          19m

NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP       PORT(S)        AGE
service/kubernetes     ClusterIP      10.233.0.1     <none>            443/TCP        3d14h
service/myweb-svc-lb   LoadBalancer   10.233.2.195   192.168.100.240   80:31466/TCP   19m

NAME                     ENDPOINTS              AGE
endpoints/kubernetes     192.168.100.100:6443   3d14h
endpoints/myweb-svc-lb                          19m
```

