# [Kubernetes] k8s Namespace

<br>

### ๐Index

- [์ด๋ฆ๊ณผ UID](#์ด๋ฆ๊ณผ-uid)

- [Namespace](#namespace)

<br>

<br>

## ์ด๋ฆ๊ณผ UID

[์ค๋ธ์ ํธ ์ด๋ฆ๊ณผ ID | Kubernetes](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/names/)

ํด๋ฌ์คํฐ์ ๊ฐ ์ค๋ธ์ ํธ๋ ํด๋น ์ ํ์ ๋ฆฌ์์ค์ ๋ํ์ฌ ๊ณ ์ ํ [*์ด๋ฆ*](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/names/#names) ์ ๊ฐ์ง๊ณ  ์๋ค. ์ด๋ฆ์ Namespace ๋ด์์ ์ ์ผํ๋ฉด ๋๋ค.

`Namespace`๋ ๋ถ๋ฆฌํ๊ธฐ ์ํ ์ฉ๋์, DNS์ด๋ฆ์ด ๋ถ๋ฆฌ๋๋ ์ฉ๋๋ฅผ ์ํด ์ฌ์ฉํ๋ค.

๊ธฐ๋ณธ์ ์ผ๋ก๋ `default Namespace`๋ฅผ ์ฌ์ฉํ๋ค.   

<br>

์ค๋ธ์ ํธ๋ฅผ ๋ฆฌ์์ค๋ก ๋ง๋ค ๋ ์ฟ ๋ฒ๋คํฐ์ค์ ์ปจํธ๋กค๋ฌ ๋งค๋์ ๋ ํด๋น๋๋ ๋ฆฌ์์ค์ `UID`๋ฅผ ๋ถ์ด๊ฒ ๋๊ณ ,

๋ชจ๋  ์ฟ ๋ฒ๋คํฐ์ค ์ค๋ธ์ ํธ๋ **์ ์ฒด ํด๋ฌ์คํฐ์ ๊ฑธ์ณ ๊ณ ์ ํ [*UID*](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/names/#uids)** ๋ฅผ ๊ฐ์ง๊ณ  ์๋ค.

<br>

<br>

## Namespace

namespace๋, **์ฟ ๋ฒ๋คํฐ์ค ํด๋ฌ์คํฐ ๋ด์ ๋ผ๋ฆฌ์ ์ธ ๋ถ๋ฆฌ ๋จ์**์ด๋ค.

๋ค์๊ณผ ๊ฐ์ด ๋ฆฌ์์ค๋ฅผ ๋ถ๋ฆฌํ  ์ ์๋ค.

**๋ฆฌ์์ค ๋ถ๋ฆฌ**

- ์๋น์ค ๋ณ
- ์ฌ์ฉ์ ๋ณ
- ํ๊ฒฝ: ๊ฐ๋ฐ, ์คํ์ด์ง, ํ๋ก๋์

๊ธฐ๋ณธ ์์ ๊ณต๊ฐ์ `default` namespace์ด๋ค. 

<br>

##### ๋ค์์คํ์ด์ค ํ์ธํ๊ธฐ

```shell
$ kubectl get namespaces
```

```shell
$ kubectl get ns
```

`--namespace` ์ต์์ ๋ช์ํ์ง ์์ผ๋ฉด ๋ชจ๋ default ๋ค์์คํ์ด์ค์์ ์ํ๋๋ค.

`-n` == `--namespace`

์์ : `default` ๋ค์์คํ์ด์ค์์ ์์ฑ๋ ํฌ๋ ํ์ธํ๊ธฐ

```shell
$ kubectl get pods --namespace default
NAME    READY   STATUS    RESTARTS   AGE
myweb   1/1     Running   0          47m
```

<br>

##### ๋ชจ๋  ๋ค์์คํ์ด์ค์ ๋ฆฌ์์ค ํ์ธ

`-A` == `--all-namespaces`

```shell
$ kubectl get <RESOURCE> namespaces -A
```

```shell
$ kubectl get <RESOURCE> --all-namespaces
```

์์

```shell
$ kubectl get pods --all-namespaces
```

<br>

- kube-system: Kubernetes์ ํต์ฌ ์ปดํฌ๋ํธ
- kube-public: ๋ชจ๋  ์ฌ์ฉ์๊ฐ ์ฝ๊ธฐ ๊ถํ(์ํผ์ ์ ๋ ์ด๋ค `Namespace`๋  ์ฝ๊ณ  ์ธ ์ ์๋ค)
- kube-node-lease: ๋ธ๋์ HeartBeat ์ฒดํฌ๋ฅผ ์ํ Lease ๋ฆฌ์์ค๊ฐ ์กด์ฌ
- default: ๊ธฐ๋ณธ ์์ ๊ณต๊ฐ

```shell
$ kubectl get pods -n kube-public
```

<br>

##### lease

`leases`๋ HB(Heart Beat) ์ฆ, ๋ธ๋๊ฐ ์ฃฝ์ด์๋์ง ์ด์์๋์ง ์ฒดํฌํ  ๋ ์ฌ์ฉํ๋ ๋ฆฌ์์ค์ด๋ค.

```shell
$ kubectl get leases -n kube-node-leases
```

๊ฒฐ๊ณผ๋ ๋ธ๋์ ๋ชฉ๋ก๊ณผ ๊ฐ๋ค.

<br>

##### Namespace ์์ฑํ๊ธฐ

๋ช๋ นํ ์ปค๋งจ๋๋ก ์์ฑํ๊ธฐ

```shell
$ kubectl create namespace developments
```

`yaml` ํ์ผ๋ก ์์ฑํ๊ธฐ

<br>

์์1

`ns-dev.yaml`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

์์2

`myweb-dev.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb
  namesapce: dev
spec:
  containers:
    - name: myweb
      image: httpd
      ports:
        - containerPort: 80
          protocol: TCP
```

์์ฑํ `yaml` ํ์ผ๋ก ํ๋๋ฅผ ์์ฑํ๋ค.

```shell
vagrant@k8s-node1:~/pod$ kubectl create -f dev-ns.yaml 
namespace/dev created
vagrant@k8s-node1:~/pod$ kubectl get ns
NAME              STATUS   AGE
default           Active   14h
dev               Active   3s
kube-node-lease   Active   14h
kube-public       Active   14h
kube-system       Active   14h
```

namespace๊ฐ ๋ค๋ฅด๋ฉด pod์ ์ด๋ฆ์ ๊ฐ์๋ ๋๊ณ , ์๋ 2๊ฐ์ `myweb`๋ ์๋ก ๋ค๋ฅธ ๊ฒ์ด๋ค.

-->  `default` ๋ค์์คํ์ด์ค์ `myweb`๊ณผ `dev` ๋ค์์คํ์ด์ค์ `myweb`

```shell
$ kubectl get pods
NAME    READY   STATUS    RESTARTS   AGE
myweb   1/1     Running   0          33m
$ kubectl get pods -n dev
NAME    READY   STATUS    RESTARTS   AGE
myweb   1/1     Running   0          38m
```

<br>

##### Namespace ์ญ์ ํ๊ธฐ

๋จ, ์ง์ธ ๋๋ ๋ค์์คํ์ด์ค์ ๋ฆฌ์์ค๊ฐ ์์ด์ผํ๋ค. 

```shell
$ kubectl delete ns <NAMESPACE>
```

```shell
$ kubectl delete pods <Pod> -n <NAMESPACE>
```

`pod` ์ญ์  ์, `-n` ์ต์์ ๋ถ์ด์ง ์์ผ๋ฉด `default namespace`์์ ์ญ์ ๋๋ฏ๋ก ์ฃผ์ํด์ผํ๋ค.

<br>

<br>
์ฐธ๊ณ  ์ฌํญ

`namespace.spec`์ ํ์ธํ๋ฉด `finalizers`๋ผ๋ ํ๋๋ฅผ ํ์ธํ  ์ ์๋ค.

```shell
$ kubectl explain namespace.spec
KIND:     Namespace
VERSION:  v1

RESOURCE: spec <Object>

DESCRIPTION:
     Spec defines the behavior of the Namespace. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status

     NamespaceSpec describes the attributes on a Namespace.

FIELDS:
   finalizers   <[]string>
     Finalizers is an opaque list of values that must be empty to permanently
     remove object from storage. More info:
     https://kubernetes.io/docs/tasks/administer-cluster/namespaces/
```

`Finalizers` ๋ ๋ฆฌ์์ค๋ฅผ ์ง์ธ ๋ ์ด๋ป๊ฒ ํ  ๊ฒ์ธ์ง์ ๋ํ ์ค์ ์ ํ๋ ๊ฒ์ด๋ค.

`yaml` ํ์ผ์ ํตํด ํ๋๋ฅผ ์์ฑํ  ๋, ์์ฃผ ๋๋ฌผ์ `spec`์ด ์๋ ๊ฒฝ์ฐ๊ฐ ์๋๋ฐ,

namespace๋ `Finalizers`๋ผ๋ ํ๋๊ฐ ์์ผ๋ฉด `spec`์ ์ค์ ํ  ์ด์ ๊ฐ ์๋ค.

<br>

<br>