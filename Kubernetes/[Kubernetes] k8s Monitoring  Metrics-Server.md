# [Kubernetes] k8s Monitoring : Metrics-Server

<br>

### 📌Index

- [Metrics-Server란?](#metrics-server란)
-  [Metrics-Server 설치하기](#metrics-server-설치하기)

<br>

<br>

## Metrics-Server란?

쿠버네티스의 Metrics-Server는 각 노드에 설치된 **kubelet을 통해 node 및 pod의 CPU,Memory의 사용량 Metric을 수집**한다.

과거에는 Heapster를 사용했으나, 더 이상 개발되고 있지 않아(지원 중단) 이를 대체하는 Metrics-Server를 사용한다.

<br>

Metrics-Server가 있어야 `kubectl top` 명령어를 사용하여 <u>CPU/메모리 사용량 등을 확인</u>할 수 있으며,

HPA(Horizontal Pod Autoscaler) 및 VPA(Vertical Pod Autoscaler)을 사용할 수 있다.

<br>

<br>

## Metrics-Server 설치하기

다음 명령을 사용하여 Metrics Server를 배포한다.

```shell
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

다음 명령을 통해 `metrics-server` deployment에서 원하는 수의 Pod를 실행하고 있는지 확인한다.

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

`kubecto top` 명령어로 <u>metrics-server가 정상적으로 작동</u>하는 것을 확인할 수 있다. 

```shell
$ kubectl top nodes
NAME                                                 CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
ip-192-168-111-4.ap-northeast-2.compute.internal     58m          3%     630Mi           18%
ip-192-168-135-92.ap-northeast-2.compute.internal    53m          2%     604Mi           18%
ip-192-168-167-186.ap-northeast-2.compute.internal   49m          2%     571Mi           17%
```

<br>

☁️ 참고 

만약, kubespray로 kubernetes 환경을 구성한다면 

Ansible을 사용하여 addon으로 metrics-server를 설치하는 방법은 다음과 같다.

`﻿~/kubespray/inventory/mycluster/group_vars/k8s-cluster/addons.yml` 파일을 다음과 같이 수정한다.

```yaml
 16 metrics_server_enabled: true
```

플레이북을 실행하여 적용한다.

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
