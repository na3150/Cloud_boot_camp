# [Kubernetes] Minitoring : Helm으로 Prometheus, Grafana 설치하기

### 📌Index

- [Prometheus란?](#prometheus란)
- [Prometheus 설치](#prometheus-설치)

<br>

<br>

## Prometheus란?

Prometheus란 [SoundCloud](https://soundcloud.com/)가 개발한 솔루션으로, **오픈소스 모니터링 툴**이다.

<br>

#### Prometheus Architecture

빨간색으로 표시된 것이 프로메테우스의 컴포넌트이다.

<br>

<img src="https://prometheus.io/assets/architecture.png" alt="Prometheus architecture" style="zoom: 50%;" />

<br>

- `Retrieval` : Pushgateway 혹은 Targets으로부터 metrics를 pulling한다.
  - Short-lived jobs : 생명주기가 짧은 것들은 Pushgateway가 받아둔다.
  - Service Discovery : k8s apiserver에게 질의하면 수집 대상을 가지고 온다. 
- `TSDB `: 시계열(Time Series DB)은 시간대별로 데이터(시계열 데이터)를 저장하기에 최적화된 DB로, 이를 통해 데이터를 로컬(HDD/SSD)에 저장한다.
- `HTTP Server` : Dashboard로, 일반적으로 잘 사용하지는 않는다
- `Promethues web UI` : 웹 브라우저를 통해서 HTTP server에 접속하여 값들을 볼 수 있다. 일반적으로 테스트 용도로 사용한다.
- `Alertmanager ` : 알람 서비스로, 여러가지가 있지만 최근에는 일반적으로 Slack을 많이 사용한다.
- `Grafana` : Promethues는 시각화 도구가 부족하여, 대게 별도로 모니터링을 위해 Data Visualization tool인 [Grafana](https://grafana.com/) 오픈소스를 사용한다.

<br>

<br>

## Prometheus 설치

[Helm Chart](https://artifacthub.io/packages/helm/prometheus-community/prometheus)를 이용하여 Prometheus를 설치할 예정이다. Helm이 뭔지 모른다면 [Heml이란?](https://nayoungs.tistory.com/entry/Kubernetes-Helm%EC%9D%B4%EB%9E%80)을 참조하자.

GitHub URL 👉 [prometheus-community/helm-charts: Prometheus community Helm charts](https://github.com/prometheus-community/helm-charts/)

<br>

레포지토리를 추가하고,

```shell
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

인덱스를 업데이트한다.

```shell
$ helm repo update
```

다음과 같이 value를 수정(사용자화)하는 yaml 파일을 작성한다.

`prom-values.yaml`

```yaml
grafana:
  service:
    type: LoadBalancer
```

이때, 별도의 네임스페이스로 분리해주는 것이 좋다.

```shell
$ kubectl create ns monitor
```

다음과 같이 설치하면 **grafana까지 함께 설치**된다.

```shell
$ helm install prom prometheus-community/kube-prometheus-stack -f prom-values.yaml -n monitor
```

```shell
NAME: prom
LAST DEPLOYED: Fri May 27 05:58:16 2022
NAMESPACE: monitor
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitor get pods -l "release=prom"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```

```shell
$ helm list -n monitor
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS       CHART                    APP VERSION
prom    monitor         1               2022-05-27 05:50:25.628854911 +0000 UTC deployed     prometheus-15.9.0        2.34.0     
```

매번 네임스페이스를 지정해주는 것이 번거로우므로 `kubens`를 이용하여 네임스페이스를 변경하자.

```shell
$ kubens monitor           
Context "kubernetes-admin@cluster.local" modified.
Active namespace is "monitor".
```

모두 정상적으로 실행되고 있는 것을 확인할 수 있다.

```shell
$ kubectl get all
NAME                                                         READY   STATUS    RESTARTS   AGE
pod/alertmanager-prom-kube-prometheus-stack-alertmanager-0   2/2     Running   0          3m46
s
pod/prom-grafana-955fd56dd-86cjv                             3/3     Running   0          4m7s
pod/prom-kube-prometheus-stack-operator-f568c9fd4-t6cjp      1/1     Running   0          4m7s
pod/prom-kube-state-metrics-5c54c5d749-gjnks                 1/1     Running   0          4m7s
pod/prom-prometheus-node-exporter-bqz66                      1/1     Running   0          4m7s
pod/prom-prometheus-node-exporter-sbjkq                      1/1     Running   0          4m7s
pod/prom-prometheus-node-exporter-vgzls                      1/1     Running   0          4m7s
pod/prometheus-prom-kube-prometheus-stack-prometheus-0       2/2     Running   0          3m46
s

NAME                                              TYPE           CLUSTER-IP      EXTERNAL-IP
     PORT(S)                      AGE
service/alertmanager-operated                     ClusterIP      None            <none>
     9093/TCP,9094/TCP,9094/UDP   3m46s
service/prom-grafana                              LoadBalancer   10.233.13.77    192.168.100.2
40   80:31355/TCP                 4m7s
service/prom-kube-prometheus-stack-alertmanager   ClusterIP      10.233.50.157   <none>
     9093/TCP                     4m7s
service/prom-kube-prometheus-stack-operator       ClusterIP      10.233.62.80    <none>
     443/TCP                      4m7s
service/prom-kube-prometheus-stack-prometheus     ClusterIP      10.233.6.159    <none>
     9090/TCP                     4m7s
service/prom-kube-state-metrics                   ClusterIP      10.233.53.165   <none>
     8080/TCP                     4m7s
service/prom-prometheus-node-exporter             ClusterIP      10.233.26.62    <none>
     9100/TCP                     4m7s
service/prometheus-operated                       ClusterIP      None            <none>
     9090/TCP                     3m46s

NAME                                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILA
BLE   NODE SELECTOR   AGE
daemonset.apps/prom-prometheus-node-exporter   3         3         3       3            3
      <none>          4m7s

NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prom-grafana                          1/1     1            1           4m7s
deployment.apps/prom-kube-prometheus-stack-operator   1/1     1            1           4m7s
deployment.apps/prom-kube-state-metrics               1/1     1            1           4m7s
```

`prom-grafana` 로드밸런서의 EXTERNAL-IP로 접속하면 다음과 같은 화면을 확인할 수 있다.

![image-20220529203109120](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220529203109120.png)

패스워드는 [values.yaml](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml)에서 확인할 수 있다.

- ID: admin
- PWD: prom-operator

로그인 후 다음과 같이 클러스터의 CPU 사용량 등을 확인할 수 있다.

![image-20220529202228965](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220529202228965.png)

또한 다음과 같이 네임스페이스를 선택해서 확인할 수도 있다.

![image-20220529201737297](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220529201737297.png)

<br>

<br>