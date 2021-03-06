# [Kubernetes] k8s Workload : Pod

<br>

### πIndex

- [νλ(Pod)λ?](#νλpodλ)

- [Pod μμ± λ° κ΄λ¦¬](#pod-μμ±-λ°-κ΄λ¦¬)
- [YAML νμΌλ‘ νλ μ μ](#yaml-νμΌλ‘-νλ-μ μ)
- [Pod λμμΈ](#pod-λμμΈ)
- [Pod ν¬νΈν¬μλ©](#pod-ν¬νΈν¬μλ©)

<br>

<br>

## νλ(Pod)λ?

[μν¬λ‘λ](https://kubernetes.io/ko/docs/concepts/workloads/)λ μΏ λ²λ€ν°μ€μμ κ΅¬λλλ μ νλ¦¬μΌμ΄μμ΄λ€. 

μν¬λ‘λκ° λ¨μΌ μ»΄ν¬λνΈμ΄κ±°λ ν¨κ» μλνλ μ¬λ¬ μ»΄ν¬λνΈμ΄λ  κ΄κ³μμ΄, 

**μΏ λ²λ€ν°μ€μμλ μν¬λ‘λλ₯Ό μΌλ ¨μ [νλ](https://kubernetes.io/ko/docs/concepts/workloads/pods) μ§ν© λ΄μμ μ€ν**νλ€.

<br>

`Pod`λ νλ μ΄μμ μ»¨νμ΄λ κ·Έλ£ΉμΌλ‘, μ»¨νμ΄λλ₯Ό μ€ννκΈ° μν μ€λΈμ νΈμ΄λ€.

**μΏ λ²λ€ν°μ€μμ κ΄λ¦¬ν  μ μλ κ°μ₯ μμ `Workload`λ  `Pod`**μ΄λ€.

μ¦, **μΏ λ²λ€ν°μ€λ μ»¨νμ΄λλ₯Ό μ§μ  μ»¨νΈλ‘€νμ§ μκ³ , νλλ§ κ΄λ¦¬**ν  μ μλ€

μ°Έκ³ λ‘ νλμ νλλ νλμ νΈμ€νΈμλ§ λ°°μΉλκ³ , νλμ λΈλμ λ°°μΉλλ€.

<br>

##### νλμ μ¬μ©

1. **λ¨μΌ μ»¨νμ΄λλ₯Ό μ€ννλ νλ**
   νλκ° νλμ μ»¨νμ΄λλ§ ν¬ν¨νλ κ²½μ°μ΄λ€. νλλ λ¨μν μ»¨νμ΄λλ₯Ό λλ¬μΌ λνΌμ΄λ©°, **μΏ λ²λ€ν°μ€λ μ»¨νμ΄λλ₯Ό μ§μ  κ΄λ¦¬νλ λμ  νλλ₯Ό κ΄λ¦¬**νλ€.
2. **ν¨κ» μλν΄μΌνλ μ¬λ¬ μ»¨νμ΄λλ₯Ό μ€ννλ νλ**
   ν¨κ» λ°°μΉλ μ»¨νμ΄λλ λ°μ ν κ²°ν©μ±μ κ°μ§λ©° λ¦¬μμ€λ₯Ό κ³΅μ νλ€. μ΄λ€μ νλμ **κ²°ν©λ μλΉμ€ λ¨μ**λ₯Ό νμ±νλ€.

<br>

**νλμ νλμλ λ°μ ν κ΄κ³λ₯Ό κ°μ§ μ»¨νμ΄λλ₯Ό λ°°μΉ**ν΄μΌνλ€.

WordPressλ₯Ό μμλ‘ μκ°ν΄λ³΄μ. νλμ νλμ WordPress μ»¨νμ΄λμ MySQL μ»¨νμ΄λλ₯Ό λμ΄λ λ κΉβ

λΆκ°λ₯νκ²μ μλλ, νλμ νλμ wordpress μ»¨νμ΄λμ mysql μ»¨νμ΄λλ₯Ό λλ κ²μ `Anti-Pattern`μ΄λ€.

**νλμ νλμλ λ°λμ νλμ `Main Application`λ§ μμ μ μμ΄μΌνλ€.** 

νλλ νΉμ  λΈλμ λ°°μΉλλλ°, ν΄λΉ λΈλμ λ¬Έμ κ° λ°μνλ€λ©΄ μλΉμ€λ₯Ό μ¬μ©ν  μ μκ²λ  μ μλ€.

`logs`μ κ°μ΄ λ¨μ΄μ ΈμμΌλ©΄ μλ―Έκ° μλ κ²½μ°μλ§ νλμ νλμ λ°°μΉνλ€. 

<br>

<br>

## Pod μμ± λ° κ΄λ¦¬

##### λͺλ Ήν μ»€λ§¨λλ‘ νλ μ€ν

```shell
$ kubectl run
```

```shell
$ kubectl run NAME --image=image [--env="key=value"] [--port=port] [--dry-run=server|client] [--overrides=inline-json]
[--command] -- [COMMAND] [args...] [options]
```

μμ

```shell
$ kubectl run myweb --image httpd
pod/myweb created
```

<br>

##### νλ μμΈ μ λ³΄ νμΈ

```shell
$ kubectl get pods
NAME    READY   STATUS    RESTARTS   AGE
myweb   1/1     Running   0          46s
```

- `NAME` : `Pod`μ μ΄λ¦

- `READY` : `μ€λΉλ μ»¨νμ΄λμ κ°μ/μ»¨νμ΄λμ μ΄ κ°μ`

- `RESTARTS` : μ¬μμ νμ

- `AGE` : νμ¬λ₯Ό κΈ°μ€μΌλ‘ λ§λ€μ΄μ§ μκ°

<br>
`-o wide` μ΅μμ μ¬μ©νλ©΄ λ μμΈν μ λ³΄κΉμ§ νμΈν  μ μλ€.

```shell
$ kubectl get pods -o wide
NAME    READY   STATUS    RESTARTS   AGE     IP            NODE    NOMINATED NODE   READINESS GATES
myweb   1/1     Running   0          2m58s   10.233.96.1   node2   <none>           <none>
```

μνλ νμμΌλ‘ `etcd`μ μ μ₯λ λ‘μ° λ°μ΄ν°λ₯Ό νμΈνλ κ²λ κ°λ₯νλ€.

```shell
$ kubectl get pods -o yaml
$ kubectl get pods -o json
```

<br>

**kubectl describe**

μ’ λ κΉλνκ² μ λλ ννλ‘ νμΈν  μ μλ€.

```shell
$ kubectl describe pods myweb
Name:         myweb
Namespace:    default
Priority:     0
Node:         node2/192.168.100.101
Start Time:   Tue, 17 May 2022 01:37:27 +0000
Labels:       run=myweb
Annotations:  cni.projectcalico.org/containerID: d934f2835963f3a41399d163e4831b1019a6d26cfaf8313078a6e0641bdfcc03
              cni.projectcalico.org/podIP: 10.233.96.1/32
              cni.projectcalico.org/podIPs: 10.233.96.1/32
Status:       Running
IP:           10.233.96.1
IPs:
  IP:  10.233.96.1
Containers:
  myweb:
    Container ID:   containerd://a4c734defa9212f176c05f3318560b0c218ab65ca2f021d7157e0c7cbd2bf0f3
    Image:          httpd
    Image ID:       docker.io/library/httpd@sha256:2d1f8839d6127e400ac5f65481d8a0f17ac46a3b91de40b01e649c9a0324dea0
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Tue, 17 May 2022 01:38:07 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-2g9hd (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-2g9hd:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  6m57s  default-scheduler  Successfully assigned default/myweb to node2
  Normal  Pulling    6m57s  kubelet            Pulling image "httpd"
  Normal  Pulled     6m38s  kubelet            Successfully pulled image "httpd" in 18.992429786s
  Normal  Created    6m17s  kubelet            Created container myweb
  Normal  Started    6m17s  kubelet            Started container myweb
```

μ¬κΈ°μ `Events`λ μ§μ ν λ¦¬μμ€μ `lifecycle`μ λν μ λ³΄μ΄λ€.

`Events` μ λ³΄λ `kubectl describe`λ₯Ό ν΅ν΄μλ§ νμΈν  μ μλ€.

λ‘κ·ΈλΌκ³ λ ν  μ μλλ°, μΏ λ²λ€ν°μ€μμ λ¦¬μμ€ μμ²΄μ λν μ΄λ²€νΈ λ‘κ·Έλ‘, μκ° μμΌλ‘ λνλλ€.

<br>

μ μκΈ?

`Events`μ λν΄μ λ μμΈν μ΄ν΄λ³΄μ. μ€λͺμ μν΄ μμλ‘ λ²νΈλ₯Ό λΆμλ€

```
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
 1.  Normal  Scheduled  6m57s  default-scheduler  Successfully assigned default/myweb to node2
 2.  Normal  Pulling    6m57s  kubelet            Pulling image "httpd"
 3.  Normal  Pulled     6m38s  kubelet            Successfully pulled image "httpd" in 18.992429786s
 4.  Normal  Created    6m17s  kubelet            Created container myweb
 5.  Normal  Started    6m17s  kubelet            Started container myweb
```

1. νλλ₯Ό λ§λ€ λ κ°μ₯ λ¨Όμ νλ κ²μ μ€μΌμ₯΄λ§μΌλ‘, μ€μΌμ₯΄λ¬κ° μ΄λ λΈλμ λ°°μΉν  μ§ κ²°μ ν΄μΌνλ€.

μ²«λ²μ§Έ μ΄λ²€νΈκ° `default-scheduler`λ‘ λΆν° μμ±λ κ²μ νμΈν  μ μλ€.

2. `node2`μ `kubelet`μΌλ‘ λΆν° μ΄λ―Έμ§λ₯Ό pulling νλ€.

1λ²μμ μ€μΌμ₯΄λ¬κ° `node2`μ λ°°μΉνκΈ° λλ¬Έμ΄λ€.

3. `Pulled`μ΄λ―λ‘, μ΄λ―Έμ§ pullingμ΄ μλ£λμλ€.
4. `kubelet`μ΄ `myweb` μ»¨νμ΄λλ₯Ό μμ±νλ€.
5. `kubelet`μ΄ `myweb` μ»¨νμ΄λλ₯΄ μ€ννμλ€.

<br>

λ§μ½ `Pod`κ° μ λλ‘ μλμ΄ μνλ€λ©΄ ν¬κ² 2κ°μ§λ₯Ό λ΄μΌνλ€.

- `Pod`κ° μ λλ‘ λ§λ€μ΄μ‘λμ§ -> μ€λΈμ νΈ λ¦¬μμ€ μμ²΄μ λ‘κ·Έ νμΈ
- μ»¨νμ΄λλ μ λλ‘ λ§λ€μ΄μ‘μΌλ, μ νλ¦¬μΌμ΄μμ΄ μ μ€ν μλ  λ --> μ νλ¦¬μΌμ΄μ λ‘κ·Έ νμΈ(μλμμ μ€λͺ)

<br>

##### μ νλ¦¬μΌμ΄μ λ‘κ·Έ νμΈνκΈ°

```shell
$ kubectl logs [Pod]
```

 `kubectl get pods`μ κ°μ΄ μλΈ μ»€λ§¨λ λ€μ μ’λ₯λ₯Ό μ§μ νλ κ²μ΄ μΌλ°μ μΈλ°,

μ νλ¦¬μΌμ΄μ λ‘κ·Έλ₯Ό λ³Ό μ μλ κ²μ `pod` λ°μ μκΈ° λλ¬Έμ λ³λλ‘ `pods`λ₯Ό λΆμ΄μ§ μλλ€.

```shell
$ kubectl logs myweb
```

<br>

##### νλ μ­μ 

```shell
$ kubectl delete pods [pod]
```

μμ

```shell
$ kubectl delete pods myweb
```

<br>

<br>

##### β­μμλ μ¬ν­

`ubuntu:focal` μ΄λ―Έμ§λ₯Ό μ¬μ©ν΄μ `pod` λ₯Ό μμ±ν΄λ³΄μ

```shell
$ kubectl run myubuntu --image ubuntu:focal
```

μκ°μ΄ μ‘°κΈ μ§λ λ€ νμΈν΄λ³΄λ©΄ `CrashLoopBackOff` μνκ° λλ κ²μ νμΈν  μ μλ€.

```shell
$ kubectl get pods
NAME       READY   STATUS             RESTARTS       AGE
myubuntu   0/1     CrashLoopBackOff   2 (18s ago)    7m38s
```

`kubectl describe pods` λͺλ Ήμ΄λ₯Ό ν΅ν΄ μ΄λ²€νΈ λ‘κ·Έλ₯Ό νμΈν΄λ³΄μ

```shell
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  49s               default-scheduler  Successfully assigned default/myubuntu to node3
  Normal   Pulled     7s (x4 over 48s)  kubelet            Container image "ubuntu:focal" already present on machine
  Normal   Created    7s (x4 over 48s)  kubelet            Created container myubuntu
  Normal   Started    7s (x4 over 48s)  kubelet            Started container myubuntu
  Warning  BackOff    7s (x5 over 47s)  kubelet            Back-off restarting failed container
```

λ§μ§λ§ μ΄λ²€νΈμ `Back-off restarting failed container`λ₯Ό νμΈν  μ μλ€.

`pod`λ μ’λ£λμ§ μλ μ νλ¦¬μΌμ΄μμ μ€ννλ κ²μ΄ κΈ°λ³Έ μμΉμΈλ°,

μΏ λ²λ€ν°μ€λ κΈ°λ³Έμ μΌλ‘ λ¬΄μ‘°κ±΄ `detach`λͺ¨λλ‘ μ€ννλ€. 

`ubuntu`λ μλ `attach`λͺ¨λ(`-it`)λ‘λ§ μ€νν΄μΌ μ ν¨νκΈ° λλ¬Έμ, μ νλ¦¬μΌμ΄μμ΄ μ’λ£λμκΈ° λλ¬Έμ΄λ€.

μ°Έκ³ λ‘ `-d` μ΅μμ κΈ°λ³Έμ΄κΈ° λλ¬Έμ μλΆμ¬λλκ³ , `-it` μ΅μμ μ κ³΅νκΈ°λ νλ€. 

```shell
$ kubectl run myubuntu2 --image ubuntu:focal -it bash
```

<br>

<br>

## YAML νμΌλ‘ νλ μ μ

λͺλ Ήνμ΄λ μμ΄μ μ¬μ©ν΄λ μκ΄μλ€.

`myweb.yaml`

```shell
apiVersion: v1
kind: Pod
metadata:
  name: myweb
spec:
  containers:
    - name: myweb
      image: httpd
```

**νλ μμ±**

```
$ kubectl create -f myweb.yaml
```

**νλ νμΈ**

```
$ kubectl get -f myweb.yaml
NAME    READY   STATUS    RESTARTS      AGE
myweb   1/1     Running   1 (22m ago)   4h53m
```

**μμΈ μ λ³΄ νμΈ λ° μ΄λ²€νΈ μ λ³΄ νμΈ**

```
$ kubectl describe -f myweb.yaml
```

**νλ μ­μ **

```
$ kubectl delete -f myweb.yaml
```

<br>

<br>

## Pod λμμΈ

<img src="https://d33wubrfki0l68.cloudfront.net/aecab1f649bc640ebef1f05581bfcc91a48038c4/728d6/images/docs/pod.svg" alt="νλ μμ± λ€μ΄μ΄κ·Έλ¨" width=500/>

`Web Server`κ° λ©μΈ κΈ°λ₯

- **λ¨μΌ μ»¨νμ΄λ** : μΌλ°μ μΈ νν
- **λ©ν° μ»¨νμ΄λ** : λ©μΈ μ νλ¦¬μΌμ΄μμ΄ μ‘΄μ¬νκ³ , λ©μΈ μ νλ¦¬μΌμ΄μ κΈ°λ₯μ νμ₯νκΈ° μν μ»¨νμ΄λλ₯Ό λ°°μΉ
  - `Main Car`(λ©μΈ), `Side Car`(λ³΄μ‘°)

<br>

νλλ κΈ°λ³Έμ μΌλ‘ νλμ μν μ»¨νμ΄λμ λ€νΈμνΉκ³Ό μ€ν λ¦¬μ§λΌλ λ κ°μ§ μ’λ₯μ κ³΅μ  λ¦¬μμ€λ₯Ό μ κ³΅νκ³ ,

νλμ **Podλ λ€νΈμν¬μ λ³Όλ₯¨μ κ³΅μ **νλ€. 

Podλ λ€νΈμν¬λ₯Ό κ³΅μ νλ―λ‘, **Podμλ νλμ IPλ§ λΆμ¬**λλ€.

<br>

##### μ¬μ΄λμΉ΄ ν¨ν΄

[The Distributed System ToolKit: Patterns for Composite Containers | Kubernetes](https://kubernetes.io/blog/2015/06/the-distributed-system-toolkit-patterns/)

`Composite Container` == `Multi Container` 

3κ°μ§ νμ : ν° λ²μμμ λ³΄λ©΄ λͺ¨λ μ¬μ΄λμΉ΄μΈλ°, κΈ°λ₯μ μΌλ‘ λΆλ₯ν κ²μ΄λ€.

- μ¬μ΄λμΉ΄ : λ©μΈ μ»¨νμ΄λμ κΈ°λ₯μ νμ₯ (μ: Log Saving)
- μ°λ²μλ : λ€νΈμν¬ νλ¦μ μ»¨νμ΄λ λ΄λΆμμ pod μΈλΆλ‘μ νλ¦μ κ°μ§κ³  μλ μ¬μ΄λμΉ΄ (μ: Proxy)
  - λ΄λΆμμ μΈλΆλ‘ λκ°λ νΈλν½μ μ‘°μ 
- μ΄λν° : λ€νΈμν¬μ νλ¦μ΄ μΈλΆμμ λ΄λΆλ‘μ νλ¦μ κ°μ§κ³  μλ μ¬μ΄λμΉ΄
  - μ»¨νμ΄λμ μΆλ ₯μ νμ€ν, λ‘κ·Έλ₯Ό κ°κ³΅ν΄μ ν¬λ§·ν(νμ€ν)

**νλλ λ³΄μ‘°μ μΈ κΈ°λ₯μ νλ μ¬μ΄λμΉ΄λ₯Ό ν¨κ» μ¬λ¦¬λ κ²μ΄μ§ λ©μΈ μ±μ ν¨κ» μ¬λ¦¬λ κ²μ μν°ν¨ν΄**μ΄λ€

<br>

##### β­μμλ μ¬ν­

λ€μ yaml νμΌμ ν΅ν΄ νλλ₯Ό μμ±ν΄λ³΄μ.

`myweb.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb
spec:
  containers:
    - name: myweb
      image: httpd
    - name: myweb2
      image: httpd
```

```shell
$ kubectl create -f myweb.yaml
```

μκ°μ΄ μ‘°κΈ μ§λ λ€ `kubectl get pods`λ‘ νμΈν΄λ³΄λ©΄ 2κ°μ μ»¨νμ΄λ μ€ 1κ°λ§ μ€λΉλ μνμ΄λ©°,

`STATUS`κ° `CrashLoopBackoff`μΈ κ²μ νμΈν  μ μλ€. 

```shell
$ kubectl get pods
NAME    READY   STATUS             RESTARTS      AGE
myweb   1/2     CrashLoopBackOff   1 (20s ago)   27s
```

`kubectl describe`λ‘ μμΈ μ λ³΄λ₯Ό νμΈν΄λ³΄μ

```shell
Containers:
  myweb:
    Container ID:   containerd://bcbebcc7b1a80523e9a10b31da831a18b426b005f134fdc31b2376ee92e80766
    Image:          httpd
    Image ID:       docker.io/library/httpd@sha256:2d1f8839d6127e400ac5f65481d8a0f17ac46a3b91de40b01e649c9a0324dea0
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Tue, 17 May 2022 10:41:34 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-pdj86 (ro)
  myweb2:
    Container ID:   containerd://bbd5515d5fe51161004306dd5f70de320e167ace1de3682f111a0bbb097d307a
    Image:          httpd
    Image ID:       docker.io/library/httpd@sha256:2d1f8839d6127e400ac5f65481d8a0f17ac46a3b91de40b01e649c9a0324dea0
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Tue, 17 May 2022 10:43:19 +0000
      Finished:     Tue, 17 May 2022 10:43:19 +0000
    Ready:          False
    Restart Count:  4
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-pdj86 (ro)
```

`myweb1`μ μ μμ μΌλ‘ μ€νλμ§λ§, `myweb2` κ³μ`Start`κ³Ό  `Backoff` μ λ°λ³΅νκ³  μλ€. μ κ·Έλ΄κΉβ

νλλ λμΌν λ€νΈμν¬λ₯Ό κ³΅μ νλ―λ‘, **ν¬νΈκ° κ²ΉμΉκΈ° λλ¬Έ**μ΄λ€.

κ·Έλ°λ° μ `myweb1`μ΄ μλ, `myweb2`κ° μλλ κ²μΌκΉ?

`Containers`λ λ¦¬μ€νΈλ‘, μμκ° μλ€. `myweb1`μ΄ λ¨Όμ  μμ±λκΈ° λλ¬Έμ΄λ€.

<br>

μ°Έκ³ λ‘ μλμ λͺλ Ήμ μ€ννλ©΄ μλ¬κ° λ°μνλ€. 

```shell
$ kubectl logs myweb
error: a container name must be specified for pod myweb, choose one of: [myweb myweb2]
```

 `Pod`μ μ»¨νμ΄λκ° νκ°μΌ λλ μ»¨νμ΄λλ₯Ό μ§μ νμ§ μμλ λμ§λ§, **μ¬λ¬κ°λ‘ κ΅¬μ±λ κ²½μ° μ»¨νμ΄λλ₯Ό μ§μ **ν΄μΌνλ€.

`-c` μ΅μμ ν΅ν΄ μ»¨νμ΄λλ₯Ό μ§μ ν  μ μλ€.

```shell
$ kubectl logs myweb -c myweb2
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.233.92.11. Set the 'ServerName' directive globally to suppress this message
(98)Address already in use: AH00072: make_sock: could not bind to address [::]:80
(98)Address already in use: AH00072: make_sock: could not bind to address 0.0.0.0:80
no listening sockets available, shutting down
AH00015: Unable to open logs
```

`could not bind to address` : ν¬νΈ μλ¬κ° λ κ²μ νμΈν  μ μλ€.

<br>

λν `pod`μ μ»¨νμ΄λκ° λͺκ°μ΄λ  νλμ λΈλ(`node3`)μ λ°°μΉλλ κ²μ νμΈν  μ μλ€.

```shell
$ kubectl get pods -o wide
NAME    READY   STATUS             RESTARTS      AGE     IP             NODE    NOMINATED NODE   READINESS GATES
myweb   1/2     CrashLoopBackOff   6 (69s ago)   7m11s   10.233.92.11   node3   <none>           <none>
```

λ€μ λͺλ Ήμ΄λ‘ λ€νΈμν¬λ₯Ό κ³΅μ νλ κ²λ νμΈν  μ μλ€

```shell
$ kubectl describe pods
```

<br>

<br>

## Pod ν¬νΈν¬μλ©

νλμ ν¬νΈν¬μλ©μ΄ κ°λ₯μ νλ, νλμ ν¬νΈν¬μλ©μ μΈλΆλ‘ λΈμΆμν€κΈ° μν΄ μ¬μ©νλ κ²μ΄ μλλ€.

ν¬κ·ΈλΌμ΄λ(foreground) μνλ‘ μλνλ©°, νμ€νΈ & λλ²κΉ λͺ©μ μΌλ‘ μ¬μ©νλ€.

```
$ kubectl port-forward TYPE/NAME [options] [LOCAL_PORT]:[REMOTE_PORT]
```

μΏ λ²λ€ν°μ€λ μΈλΆμ λΈμΆμν€κΈ° μν΄ λ€νΈμν¬(μλΉμ€) μ€λΈμ νΈλ₯Ό μ¬μ©ν΄μΌνλ€.

<br>

π» μ€μ΅

`myweb.yaml`

```shell
apiVersion: v1
kind: Pod
metadata:
  name: myweb
spec:
  containers:
    - name: myweb
      image: httpd
      ports:
        - containerPort: 80
          protocol: TCP     
```

```shell
$ kubectl create -f myweb.yaml 
```

0~1023λ² ν¬νΈλ μ΄λ €λ©΄ κ΄λ¦¬μ κΆνμ΄ νμνλ―λ‘ `8080` ν¬νΈλ‘ μ§ννλ€.

```shell
$ kubectl port-forward pods/myweb 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

λ€λ₯Έ ν°λ―Έλ μ°½μ μ΄μ΄ νμΈν΄λ³΄λ©΄ μ μμ μΌλ‘ μλνλ κ²μ νμΈν  μ μλ€.

```shell
$ curl localhost:8080
<html><body><h1>It works!</h1></body></html>
```

<br>

<br>