# [Kubernetes] k8s Monitoring : Metrics-Server

<br>

### ๐Index

- [Metrics-Server๋?](#metrics-server๋)
-  [Metrics-Server ์ค์นํ๊ธฐ](#metrics-server-์ค์นํ๊ธฐ)

<br>

<br>

## Metrics-Server๋?

์ฟ ๋ฒ๋คํฐ์ค์ Metrics-Server๋ ๊ฐ ๋ธ๋์ ์ค์น๋ **kubelet์ ํตํด node ๋ฐ pod์ CPU,Memory์ ์ฌ์ฉ๋ Metric์ ์์ง**ํ๋ค.

๊ณผ๊ฑฐ์๋ Heapster๋ฅผ ์ฌ์ฉํ์ผ๋, ๋ ์ด์ ๊ฐ๋ฐ๋๊ณ  ์์ง ์์(์ง์ ์ค๋จ) ์ด๋ฅผ ๋์ฒดํ๋ Metrics-Server๋ฅผ ์ฌ์ฉํ๋ค.

<br>

Metrics-Server๊ฐ ์์ด์ผ `kubectl top` ๋ช๋ น์ด๋ฅผ ์ฌ์ฉํ์ฌ <u>CPU/๋ฉ๋ชจ๋ฆฌ ์ฌ์ฉ๋ ๋ฑ์ ํ์ธ</u>ํ  ์ ์์ผ๋ฉฐ,

HPA(Horizontal Pod Autoscaler) ๋ฐ VPA(Vertical Pod Autoscaler)์ ์ฌ์ฉํ  ์ ์๋ค.

<br>

<br>

## Metrics-Server ์ค์นํ๊ธฐ

๋ค์ ๋ช๋ น์ ์ฌ์ฉํ์ฌ Metrics Server๋ฅผ ๋ฐฐํฌํ๋ค.

```shell
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

๋ค์ ๋ช๋ น์ ํตํด `metrics-server` deployment์์ ์ํ๋ ์์ Pod๋ฅผ ์คํํ๊ณ  ์๋์ง ํ์ธํ๋ค.

```shell
$ kubectl get deployment metrics-server -n kube-system
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
metrics-server   1/1     1            1           68m
```

```shell
$ kubectl get po -n kube-system
NAME                                  READY   STATUS    RESTARTS   AGE
...
metrics-server-64cf6869bd-cgw8l       1/1     Running   0          4m46s
```

`kubecto top` ๋ช๋ น์ด๋ก <u>metrics-server๊ฐ ์ ์์ ์ผ๋ก ์๋</u>ํ๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค. 

```shell
$ kubectl top nodes
NAME                                                 CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
ip-192-168-111-4.ap-northeast-2.compute.internal     58m          3%     630Mi           18%
ip-192-168-135-92.ap-northeast-2.compute.internal    53m          2%     604Mi           18%
ip-192-168-167-186.ap-northeast-2.compute.internal   49m          2%     571Mi           17%
```

<br>

โ๏ธ ์ฐธ๊ณ  

๋ง์ฝ, kubespray๋ก kubernetes ํ๊ฒฝ์ ๊ตฌ์ฑํ๋ค๋ฉด 

Ansible์ ์ฌ์ฉํ์ฌ addon์ผ๋ก metrics-server๋ฅผ ์ค์นํ๋ ๋ฐฉ๋ฒ์ ๋ค์๊ณผ ๊ฐ๋ค.

`๏ปฟ~/kubespray/inventory/mycluster/group_vars/k8s-cluster/addons.yml` ํ์ผ์ ๋ค์๊ณผ ๊ฐ์ด ์์ ํ๋ค.

```yaml
 16 metrics_server_enabled: true
```

ํ๋ ์ด๋ถ์ ์คํํ์ฌ ์ ์ฉํ๋ค.

```shell
ansible-playbook -i inventory/mycluster/inventory.ini cluster.yml -b
```

<br>

<br>

<br>

Reference

- https://potato-yong.tistory.com/150
- https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/metrics-server.html

<br>

<br>
