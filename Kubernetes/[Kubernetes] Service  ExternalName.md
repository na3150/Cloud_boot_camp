# [Kubernetes] Service : ExternalName

<br>

#### ✔Service : ExternalName 타입

외부에서 접근하기 위한 종류가 아니라, 내부 파드가 외부의 특정 FQDN에 쉽게 접근하기 위한 서비스이다.

k8s cluster의 coredns 서비스가 특정 FQDN에 대한 CNAME(서비스의 FQDN)을 제공함에 따라 해당 CNAME을 이용하여 쉽게 통신할 수 있다.

즉, **클러스터 내부에서 클러스터 외부의 특정 서비스에 접속하기 위해 DNS CNAME을 설정**하는 것이다.

접속하기 위한 외부 FQDN 주소가 바뀌더라도, CNAME은 그대로 유지할 수 있어 애플리케이션을 다시 작성하거나 빌드하지 않아도 된다.

- CNAME : 도메인 별명(별칭)

<br>

##### externalName

- `svc.spec.externalName`
- ExternalName이 함께 사용함

```shell
$ kubectl explain svc.spec.externalName             
KIND:     Service
VERSION:  v1

FIELD:    externalName <string>

DESCRIPTION:
     externalName is the external reference that discovery mechanisms will
     return as an alias for this service (e.g. a DNS CNAME record). No proxying
     will be involved. Must be a lowercase RFC-1123 hostname
     (https://tools.ietf.org/html/rfc1123) and requires `type` to be
     "ExternalName".
```

<br>

**💻 실습**

`weather-ext-svc.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: weather-ext-svc
spec:
  type: ExternalName
  externalName: wttr.in
```

```shell
$ kubectl create -f weather-ext-svc.yaml 
service/weather-ext-svc created
```

```shell
$ kubectl get svc                       
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
weather-ext-svc   ExternalName   <none>          wttr.in       <none>         3s
```

임시로 파드를 띄워 서비스명으로 질의를 해보면 `wttr.in` 을 확인할 수 있다.

```shell
$ kubectl run nettool -it --image ghcr.io/c1t1d0s7/network-multitool --rm

If you don't see a command prompt, try pressing enter.
/ # host weather-ext-svc
weather-ext-svc.default.svc.cluster.local is an alias for wttr.in.
wttr.in mail is handled by 10 chub.in.
```

이와같이, 이름으로 매핑하게되면 외부의 다른 서비스 경로를 바꿀 때 편리하게 사용할 수 있다.

