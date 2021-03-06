# [Kubernetes] k8s Label, LabelSelector, Annotations

<br>

### πIndex

- [Label](#label)
- [LabelSelector](#labelselector)
- [Annotations](#annotations)



<br>

<br>

## Label

[Labels](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/labels/)

`Label`μ `AWS`μ `TAG`μ λΉμ·νμ¬, `Label`μ λ¦¬μμ€μ νλ μ΄μ μ€μ ν  μ μκ³ , μ€λ³΅λ  μ μλ€.

`Label`μ μ€λΈμ νΈμ νΉμ±μ μλ³νλ λ° μ¬μ©νλ€.

`metadata`μ  ν€λ₯Ό μ¬μ©νλ©°, ν€λ μ€λ³΅μ΄ κ°λ₯νλ€. 

[κΆμ₯ λ μ΄λΈ](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/common-labels/) : κΆμ₯μΌ λΏ mustλ μλλ€.

μΌλ°μ μΌλ‘ μ νλ¦¬μΌμ΄μ μ΄λ¦, λ²μ , λκ΅¬, λ§λ  μ¬μ©μ λ±μ λΆμ¬μ€λ€.

<br>
**μ ν¨ν λ μ΄λΈ μ‘°κ±΄**

- 63 μ μ΄ν(κ³΅λ°±μΌ μλ μμ)
- (κ³΅λ°±μ΄ μλλΌλ©΄) μμκ³Ό λμ μνλ²³κ³Ό μ«μ(`[a-z0-9A-Z]`)
- μνλ²³κ³Ό μ«μ, λμ(`-`), λ°μ€(`_`), μ (`.`)μ μ€κ°μ ν¬ν¨ κ°λ₯

<br>

μ°Έκ³ λ‘ `kubernetes.io/`μ `k8s.io/` μ λμ¬λ μΏ λ²λ€ν°μ€μ ν΅μ¬ μ»΄ν¬λνΈλ‘,

 [μμ½](https://kubernetes.io/ko/docs/reference/labels-annotations-taints/)λμ΄ μλ€. (λ€λ₯Έ κ³³μ μ°μ΄κ³  μλ€)

<br>

##### λ μ΄λΈ νμΈ

```
$ kubectl get pods --show-labels
```

```
$ kubectl get pods <Pod> -o yaml
```

```
$ kubectl describe pods <Pod>
```

μμ

```shell
$ kubectl get pods --show-labels
NAME    READY   STATUS    RESTARTS   AGE   LABELS
myweb   1/1     Running   0          38m   <none>
```

<br>

##### λ μ΄λΈ μμ±

- λͺλ Ήν μ»€λ§¨λλ‘ μμ±νκΈ°

```shell
$ kubectl label <RESOURCE> <RESOURCE NAME> KEY=VALUE
```

μμ

κΈ°μ‘΄μ μλ λ¦¬μμ€μ λ μ΄λΈμ λΆμ¬ν΄λ³΄μ. μ°Έκ³ λ‘ `KEY` κ°μ΄ κΌ­ λλ¬Έμμ¬μΌνλ κ²μ μλλ€ 

`λ¦¬μμ€ λ¦¬μμ€λͺ`κ³Ό `λ¦¬μμ€/λ¦¬μμ€λͺ` λͺ¨λ κ°λ₯νλ€.

```shell
$ kubectl label pods myweb APP=apache
```

```shell
$ kubectl label pods/myweb APP=apache
```

νμΈ

```shell
$ kubectl get pods --show-labels
NAME    READY   STATUS    RESTARTS      AGE   LABELS
myweb   1/1     Running   1 (37m ago)   99m   APP=apache
$ kubectl label pods myweb ENV=staging
pod/myweb labeled
$ kubectl get pods --show-labels
NAME    READY   STATUS    RESTARTS      AGE    LABELS
myweb   1/1     Running   1 (38m ago)   101m   APP=apache,ENV=staging
```

- `yaml` νμΌλ‘ μμ±νκΈ°

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb-label
  labels:
      APP: apache
      ENV: development
spec:
  containers:
    - name: myweb
      image: httpd
      ports:
        - containerPort: 80
          protocol: TCP
```

```shell
$ kubectl get pods myweb-label --show-labels
NAME          READY   STATUS    RESTARTS   AGE   LABELS
myweb-label   1/1     Running   0          68s   APP=apache,ENV=development
```

κΈ°μ‘΄μ μλ λ μ΄λΈμ λ?μ΄μΈ λλ `--overwrite` μ΅μμ μ¬μ©ν΄μΌνλ€.

```shell
$ kubectl label pods myweb ENV=staging
error: 'ENV' already has a value (developments), and --overwrite is false
$ kubectl label pods myweb ENV=staging --overwrite
pod/myweb labeled
$ kubectl get pods --show-labels
NAME    READY   STATUS    RESTARTS      AGE    LABELS
myweb   1/1     Running   1 (41m ago)   103m   APP=apache,ENV=staging
```

<br>

##### λ μ΄λΈ μ­μ 

```shell
$ kubectl label pods <Pod> <label>-
```

μμ

```shell
$ kubectl label pods myweb ENV-
pod/myweb labeled
$ kubectl get pods --show-labels
NAME    READY   STATUS    RESTARTS      AGE    LABELS
myweb   1/1     Running   1 (42m ago)   104m   APP=apache
```



μ λμ¬λ€μ μμ½μ΄ λμ΄μλ€??



```shell
$ kubectl get nodes --show-labels
NAME    STATUS   ROLES                  AGE   VERSION   LABELS
node1   Ready    control-plane,master   15h   v1.22.8   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=node1,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node-role.kubernetes.io/master=,node.kubernetes.io/exclude-from-external-load-balancers=
node2   Ready    <none>                 15h   v1.22.8   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=node2,kubernetes.io/os=linux
node3   Ready    <none>                 15h   v1.22.8   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=node3,kubernetes.io/os=linux
```

<br>

<br>

## LabelSelector

`LabelSelector`λ κ²μκ³Ό λ¦¬μμ€ κ° μ°κ²°μ μν΄ μ¬μ©νλ€.

κ²μ μ `-l` μ΅μμ μ¬μ©νλ€.

κ²μνλ λ°©λ² 2κ°μ§

- μΌμΉμ± κΈ°μ€
- μ§ν©μ± κΈ°μ€

<br>

##### μΌμΉμ±(equality base)

- `=`
- `==` (`=`μ κ°μ)
- `!=`

ν€(Key)λ§ λ§€μΉ­μν€λ λ°©λ²μ μλ€.

μμ 1: λ μ΄λΈμ΄ `APP=apache` μΈ κ²μ κ²μ

```shell
$ kubectl get pods -l APP=apache
$ kubectl get pods -l APP==apache
```

```shell
$ kubectl get pods -l APP=apache
NAME    READY   STATUS    RESTARTS      AGE
myweb   1/1     Running   1 (51m ago)   113m
```

μμ 2: λ μ΄λΈμ΄ `APP=apache`κ° μλ κ²μ κ²μ

```shell
$ kubectl get pods -l 'APP!=apache'
```

<br>

##### μ§ν©μ±(set base)

- `in`
  - `kubectl get pods -l 'ENV in (staging)'` : `ENV`μ `staging`μ΄ μλ κ²½μ°
  - `kubectl get pods -l 'APP in (nginx, apache)'` : `Value`κ° μ¬λ¬κ° λ€μ΄κ° μ μμ 
- `notin`
  - `kubectl get pods -l 'APP notin (apache)'` : `apache`κ° ν¬ν¨λμ΄μμ§ μλ κ²½μ° κ²μ
- `exists`: ν€λ§ λ§€μΉ­
  - `Value`λ μκ΄μμ
  - `kubectl get pods -l 'APP'`  : `APP` ν€κ° μλ κ²½μ° κ²μ
- `doesnotexists`: ν€ μ μΈ λ§€μΉ­
  - `kubectl get pods -l '!APP'`

<br>

<br>

# Annotations

λ μ΄λΈκ³Ό λΉμ·μ§λ§, `Annotaions`λ **λΉ μλ³ λ©νλ°μ΄ν**μ΄λ€. μλ³μ΄ μλλ―λ‘ λ ν°λ μλ€.

λ¨μ΄ μμ²΄μ μλ―Έλ μ£Όμμ΄μ§λ§, μλ°ν λ§νλ©΄ μ£Όμμ μλλ€.

λκ΅¬ λ° λΌμ΄λΈλ¬λ¦¬μ κ°μ ν΄λΌμ΄μΈνΈμμ μ΄ λ©νλ°μ΄ν°λ₯Ό κ²μ(μ κ·Ό, Get)ν  μ μμΌλ©°, `key:Value` μμΌλ‘ κ΅¬μ±λλ€.

<br>

μ΄λΈνμ΄μμ μμ

- λΉλ,λ¦΄λ¦¬μ€ λλ νμ μ€ν¬ν, λ¦΄λ¦¬μ€ ID, git λΈλμΉ, PR λ²νΈ, μ΄λ―Έμ§ ν΄μ, λ μ§μ€ν λ¦¬ μ£Όμ λ±
- λ‘κΉ, λͺ¨λν°λ§, λΆμ, κ°μ¬ λ¦¬ν¬μ§ν°λ¦¬μ λν ν¬μΈν°
- λλ²κΉ μ λ³΄ : μ΄λ¦, λ²μ , λΉλ μ λ³΄
- μ¬μ©μ λλ λκ΅¬/μμ€ν μΆμ² μ λ³΄
- μ±μμμ μ νλ²νΈ λλ νΈμΆκΈ°μ λ²νΈ
- μ΅μ’ μ¬μ©μμ μ§μ μ¬ν­

<br>

 `Label`κ³Ό λ§μ°¬κ°μ§λ‘ `kubernetes.io/`μ `k8s.io/` μ λμ¬λ μΏ λ²λ€ν°μ€μ ν΅μ¬ κ΅¬μ±μμλ₯Ό μν΄ μμ½λμ΄μλ€.

λ¬Έλ²λ `Label`κ³Ό κ±°μ λμΌνλ€.

<br>

μ°Έκ³ λ‘ `Calico`λ₯Ό μ¬μ©νλ€λ©΄, `Calico`κ° μλμΌλ‘ νλμ κ΄λ¦¬ μ©λλ₯Ό μν΄ λΉ μλ³ λ°μ΄ν°λ₯Ό λΆμ¬λλλ€.

```
 annotations:
    cni.projectcalico.org/containerID: 36a3eacd1d7e1dd89ebb9577ae91509ba15e4c48600f27707937e98d99162efc
    cni.projectcalico.org/podIP: 10.233.92.14/32
    cni.projectcalico.org/podIPs: 10.233.92.14/32
```

<br>

**λͺλ Ήν μ»€λ§¨λ**

```shell
$ kubectl annotate <RESOURCE> <RESOURCE NAME> KEY=VALUE
```

μμ

```shell
$ kubectl annotate pods myweb created-by=Jang
pod/myweb annotated
vagrant@k8s-node1:~/annotation$ kubectl get pods -o yaml | head
apiVersion: v1
items:
- apiVersion: v1
  kind: Pod
  metadata:
    annotations:
      cni.projectcalico.org/containerID: 36a3eacd1d7e1dd89ebb9577ae91509ba15e4c48600f27707937e98d99162efc
      cni.projectcalico.org/podIP: 10.233.92.14/32
      cni.projectcalico.org/podIPs: 10.233.92.14/32
      created-by: Jang
```

**μ΄λΈνμ΄μ μμ **

λ³κ²½ μμλ `--overwrite` μ΅μμ μ¬μ©ν΄μΌνλ€.

```
$ kubectl annotate pods myweb created-by=Kim --overwrite
```

**μ΄λΈνμ΄μ μ­μ **

```
$ kubectl annotate pods myweb created-by-
```

**`yaml` νμΌλ‘ μ΄λΈνμ΄μ μμ±νκΈ°**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb-label-anno
  labels:
    APP: apache
    ENV: staging
  annotations:
    Created-by: Jang
spec:
  containers:
    - name: myweb
      image: httpd
      ports:
        - containerPort: 80
          protocol: TCP
```

