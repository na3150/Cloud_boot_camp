# [Kubernetes] k8s Logging : EFK 개요 및 설치

<br>

### 📌Index

- [EKF란?](#efk란)
- [EFK 설치하기](#efk-설치하기)

<br>

<br>

## EFK란?

**EFK stack은 [Elasticsearch](https://www.elastic.co/kr/what-is/elasticsearch), [Fluent bit(Fluentd)](https://www.fluentd.org/), [Kibana](https://www.elastic.co/kr/what-is/kibana) 3개의 플랫폼 조합**을 뜻하며,

클러스터 환경에서 **로그의 수집, 검색, 시각화**를 가능하게 한다.  

<br>

<img src="https://velog.velcdn.com/images%2Fborab%2Fpost%2F6d3b94e7-2ebe-4307-9994-c49da2a0bb03%2Fimage.png" alt="img" style="zoom:50%;" />



<br>

그림을 보면 알 수 있듯이, **각 클러스터에 fluent bit가 daemonset으로 log를 수집**한다.

**elasticsearch는 fluent bit가 수집한 로그를 저장하며, 요청에 따라 검색**을 한다. 

**마지막으로 유저가 용이하게 사용할 수 있도록 kibana로 시각화 한다.**

<br>

#### FluentBit

Log는 `/var/log `(시스템 로그)또는  `/var/log/container`(파드 로그) 또는 `/var/log/pods`(파드 로그)에 저장된다.

(이때 `/var/log/container`에서  `/var/log/pods`로 심볼릭 링크가 연결되어있다)

**Fluent Bit는 이러한 로그 파일들을 수집**한다. 

즉, Fluent Bit는 로그 수집기이며, 로그 컬렉터, 로그 스트리머 등으로 불린다.

Fluent Bit는 이렇게 **수집된 로그들을 Elastic Search로 전송**한다.

<br>

#### Elastic Search

elastic search는 로그 저장소 및 **검색 엔진**으로, 

데이터를 저장하는 저장소가 있고, 이 **저장소에서 로그를 검색** 한다.

<br>

#### Kibana

Elastic Search를 Kibana를 통해 시각적으로 확인한다.

즉, **수집한 로그를 시각화 하는 대시 보드**이다.

단, 무인증 형태이기 때문에 실무에서 사용할 때는 유의해야한다.

<br>

☁️ 참고

- ELK Stack: Elasticsearch + Logstash + Kibana 
- **EFK Stack**: Elasticsearch + Fluentd + Kibana
  - Elasticsearch +  Fluent Bit + Kibana
- Elastic Stack: Elasticsearch + Beat + Kibana

메모리 사용량 : Fluent Bit < Fluentd < Logstash

기능 : Logstash > Fluentd > Fluent Bit

<br>

**fluentd vs fluentbit**

`fluent bit`는 자바 런타임이 필요한 JRuby `logstash` 에서 

가벼워진 자바 런타임이 필요하지 않는 CRuby `fluentd`에서 

더욱 경량화 된 C로 만들어진 전송에 특화된 로그 수집기이다.

fluent bit 공식 사이트에 들어가면 이 둘의 차이를 디테일하게 확인할 수 있다.

<img src="https://velog.velcdn.com/images%2Fborab%2Fpost%2Fc0127775-9d1b-4945-a1c7-eeb34bd1fcd6%2Fimage.png" alt="img" style="zoom: 33%;" />

결론적으로 요약하자면 fluentd는 플러그인 등 확장성이 좋고, fluent bit는 리소스를 적게 차지 한다. 

<br>

<br>

## EFK 설치하기

[Helm](https://nayoungs.tistory.com/entry/Kubernetes-Helm%EC%9D%B4%EB%9E%80-Helm%EC%9D%98-%EA%B0%9C%EC%9A%94%EC%99%80-%EC%82%AC%EC%9A%A9%EB%B2%95)을 이용하여 EFK를 설치해보자.

<br>

#### Elasticsearch

먼저 helm으로 레포지토리(저장소)를 추가하고, 업데이트한다.

```shell
$ helm repo add elastic https://helm.elastic.co
$ helm repo update
```

해당 레포지토리에서 elasticsearch와 kibana를 설치할 예정이다.

```shell
$ helm search repo elastic
NAME                                                    CHART VERSION   APP VERSION     DESCRIPTION                                       
...
elastic/elasticsearch                                   7.17.3          7.17.3          Official Elastic helm chart for Elasticsearch     
...
elastic/kibana                                          7.17.3          7.17.3          Official Elastic helm chart for Kibana            
...
```

다음으로 몇가지를 수정(사용자화)하기 위해 values를 `es-value.yaml`로 받아온다.

```shell
$ helm show values elastic/elasticsearch > es-value.yaml
```

테스트를 위한 것이기 때문에, 복제본의 개수와 리소스를 줄여서 다음과 같이 수정한다.

`es-value.yaml`

```
 18 replicas: 1
 19 minimumMasterNodes: 1
 
 80 resources:
 81   requests:
 82     cpu: "500m"
 83     memory: "1Gi"
 84   limits:
 85     cpu: "500m"
 86     memory: "1Gi"
```

`logging` namespace를 생성하고, 해당 ns에 elasticsearch를 설치한다.

```shell
$ kubectl create ns logging
```

```shell
$ helm install elastic elastic/elasticsearch -f es-value.yaml -n logging
```

<br>

#### Fluent Bit

Fluent Bit는 Helm차트가 있긴 하지만 버전이 낮으므로, [GitHub](https://github.com/fluent/fluent-bit-kubernetes-logging)에서 clone 한다.

```shell
$ git clone https://github.com/fluent/fluent-bit-kubernetes-logging.git
```

```shell
$ cd fluent-bit-kubernetes-logging
```

Service Account와 Role, RoleBinding을 설치한다. 

SA, Role, RoleBinding을 모른다면 [여기](https://nayoungs.tistory.com/entry/Kubernetes-RBAC-%EB%B0%8F-%EC%9D%B8%EC%A6%9D)를 참조하면 된다.

```shell
$ kubectl create -f fluent-bit-service-account.yaml
$ kubectl create -f fluent-bit-role-1.22.yaml
$ kubectl create -f fluent-bit-role-binding-1.22.yaml
```

다음으로 `output/elasticsearch` 디렉토리로 이동한다.

```shell
$ cd output/elasticsearch
```

총 3개의 파일이 있는데, 

```shell
$ ls
fluent-bit-configmap.yaml  fluent-bit-ds-minikube.yaml  fluent-bit-ds.yaml
```

`fluent-bit-configmap.yaml`는 공통적으로 적용되는 설정파일이고,

`fluent-bit-ds-minikube.yaml`는 [minikube](https://nayoungs.tistory.com/entry/Kubernetes-k8s-minikube-%EC%84%A4%EC%B9%98-%EB%B0%8F-%EC%82%AC%EC%9A%A9%EB%B2%95)에서 사용하는 것이고,

일반은 `fluent-bit-ds.yaml`파일(데몬셋)이다.

```shell
$ kubectl create -f fluent-bit-configmap.yaml
```

```shell
$ kubectl get svc -n logging
NAME                            TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)             AGE
elasticsearch-master            ClusterIP      10.233.21.152   <none>            9200/TCP,9300/TCP   27m
elasticsearch-master-headless   ClusterIP      None            <none>            9200/TCP,9300/TCP   27m
```

Fluent가 Elastic Search로 로그를 보낼 수 있도록

다음과 같이  `fluent-bit-ds.yaml`을 Elastic Search 서비스 이름에 맞춰서 수정하고, 생성한다.

```
 32         - name: FLUENT_ELASTICSEARCH_HOST
 33           value: "elasticsearch-master"
```

```shell
$ kubectl create -f fluent-bit-ds.yaml
```

<br>

#### Kibana

kibana는 앞서 설치한 elasticsearch와 동일한 레포지토리에서 설치한다.

먼저 다음과 같이 values를 `kibana-value.yaml`로 받아오고, 리소스를 수정한다.

또한, 외부에 노출시키기 위해 서비스타입을 LoadBalancer로 수정한다.

```shell
$ helm show values elastic/kibana > kibana-value.yaml
```

`kibana-value.yaml`

```
 49 resources:
 50   requests:
 51     cpu: "500m"
 52     memory: "1Gi"
 53   limits:
 54     cpu: "500m"
 55     memory: "1Gi"
 
119 service:
120   type: LoadBalancer
```

```shell
$ helm install kibana elastic/kibana -f kibana-value.yaml -n logging
```

<br>

#### 작동 확인

설치한 것들이 잘 작동되는지 테스트를 진행해보자.

```shell
$ kubectl port-forward -n logging elasticsearch-master-0 9200:9200
```

터미널을 하나 더 열어서 `curl`명령어로 확인했을 때,

다음과 같이 `tagline`이 `You Know, for Search`라고 출력되면 정상적으로 작동되고 있다는 뜻이다.

```shell
$ curl localhost:9200
{
  "name" : "elasticsearch-master-0",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "XXXXXXXXXXXXXXXXXX",
  "version" : {
    "number" : "7.17.3",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "XXXXXXXXXXXXXXXXXX",
    "build_date" : "XXXXXXXXXXXXXXXXXX",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

```shell
$ curl localhost:9200/_cat/indices
green  open .kibana_task_manager_7.17.3_001 wfOp9T0iSsq8Zavb4VL3cQ 1 0   17 3804 538.4kb 538.4kb
green  open .apm-custom-link                xqGEj2XRRcqzwUvIE0Dlzw 1 0    0    0    226b    226b
green  open .apm-agent-configuration        X6DIUnXrR8e2ZgBnhrcQ4Q 1 0    0    0    226b    226b
yellow open logstash-2022.06.01             Ip_APCbFTj2qixXWd5GF_g 1 1 4676    0  15.8mb  15.8mb
green  open .kibana_7.17.3_001              ygYwoZG8Qf6605QRGP_JhA 1 0   22    4   4.7mb   4.7mb
```

다음으로 kibana에 접속한다.

```shell
$ kubectl get svc -n logging
NAME                            TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)             AGE
elasticsearch-master            ClusterIP      10.233.21.152   <none>            9200/TCP,9300/TCP   27m
elasticsearch-master-headless   ClusterIP      None            <none>            9200/TCP,9300/TCP   27m
kibana-kibana                   LoadBalancer   10.233.19.27    192.168.100.240   5601:31535/TCP      18m
```

kibana의 EXTERNAL-IP와 PORT `192.168.100.240:5601` 로 접속을 시도하면 

다음과 같이 정상적으로 접속되는 것을 확인할 수 있다.

<br>![image-20220601211936193](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220601211936193.png)

<br>

#### 세팅하기

`Explore on my own`을 클릭하고,

[Management] - [Stack Management]를 클릭한다.

![1-eks](https://raw.githubusercontent.com/na3150/typora-img/main/img/1-eks.png)

[Kibana] - [Index Patterns] - [Create index pattern]을 클릭한다.

Elastic Search에서 index는 database이다. 

![2-eks](https://raw.githubusercontent.com/na3150/typora-img/main/img/2-eks.png)

`logstash-xxxx.xx.xx` 파일을 확인할 수 있는데, 

이것은 Fluent Bit가 Elastic Search에 전송한 로그파일로, 하루에 1개씩 생성된다.

Name에 모든 로그 파일을 수집하도록 `logstash-*`를 입력하고 Timestamp field는 `@timestamp`를 선택한다.

![3-eks](https://raw.githubusercontent.com/na3150/typora-img/main/img/3-eks.png)

[Analytics] - [Discover]를 클릭한다.

![4-eks](https://raw.githubusercontent.com/na3150/typora-img/main/img/4-eks.png)

그러면 다음과 같이 로그들을 확인할 수 있다. 여기서 KQP는 Kibana Query Language이다.

![6-eks](https://raw.githubusercontent.com/na3150/typora-img/main/img/6-eks.jpg)

Search 창에 원하는 키워드를 입력하여 검색이 가능하다.

<br>

<br>

<br>
참고

- https://byeongjo-kim.tistory.com/35

- https://velog.io/@borab/EFK-Stack-%EA%B5%AC%EC%B6%95-docker-compose