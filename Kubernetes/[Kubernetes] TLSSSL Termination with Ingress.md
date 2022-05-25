# [Kubernetes] TLS/SSL Termination with Ingress

<br>

## TLS/SSL Termination이란?

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/SSL_termination_proxy.svg/480px-SSL_termination_proxy.svg.png" alt="img" style="zoom: 80%;" />

<br>

그림에서 Webservice는 Server이고, Proxy는 일반적으로 Load Balancer이다. 

TLS/SSL Termination이란 **Client와 LoadBalancer 사이에는 HTTPS 즉, TLS(암호화 제공)를 사용**하고,

**로드밸런서와 실제 서비스 사이에는 HTTP 즉, 평문 통신(암호화 제공X)**을 하는 방식을 말한다.

단, 외부에서 실제 서버로 접근하지 못한다는 전제 조건이 있어야한다.

<br>
모든 통신에 암호화를 사용하는 방식을 **종단간 암호화(E2EE, End to End Encryption)**라고 부르는데, 

TLS/SSL Termination보다 E2EE 방식이 더 안전하다고 생각이 들 수 있을 것 같다.

그러나 일반적으로 TLS/SSL Termination 방식을 선호하는데, 이유는 다음과 같다.

<br>

**E2EE의 단점**

- 개별 시스템마다(k8s의 경우 Pod마다) 인증서를 관리해야한다. 인증서는 정기적으로 갱신을 해줘야하기 때문에, 매우 번거로운 작업이라고 할 수 있다.

- CPU를 많이 사용하게 되는 요인 중 하나가 암호화/복호화이다. 즉, CPU 사용률이 높아지게 된다.
- 암호화가 내부 서버에서 끝나기 때문에, 프록시에서 복호화를 하지 않고 무조건 서버로 트래픽을 보내야하고, 따라서 해커로부터 서버로의 공격 트래픽을 막기 어렵다. 

**TLS/SSL Termination의 장점**

- 인증서를 로드밸런서에서만 관리하기 때문에, 통합 관리가 가능하고 따라서 인증서 관리가 비교적 용이하다.
- 암호화 구간이 인터넷 구간만 필요하기 때문에, CPU 사용률이 상대적으로 낮다. 단, 복호화를 로드밸런서에서 진행하므로 로드밸런서의 성능이 중요하게 작용한다.
- 비 암호화된 구간에 보안장비를 세팅하여, 해킹 공격 또는 비정상적인 트래픽을 탐지할 수 있다.

<br>

<br>

## TLS/SSL Termination with Ingress

대부분의 시스템은 TLS/SSL Termination 방식을 지원한다.

Kubernetes의 Ingress도 해당 방식을 지원하며, 실습을 통해 Ingress로 TLS/SSL Termination 구성을 해보자.

<br>

바로 실습을 시작하기 전에, Ingress 구성을 살펴보자.

#### TLS

`ing.spec.tls` : TLS Termination을 위해 존재하는 기능이다.

- `hosts` : 도메인, default는 wildcard host
- `secretName` : 인증서가 있는 secret의 이름

```shell
$ kubectl explain ing.spec.tls                              
KIND:     Ingress
VERSION:  networking.k8s.io/v1

RESOURCE: tls <[]Object>

DESCRIPTION:
     TLS configuration. Currently the Ingress only supports a single TLS port,
     443. If multiple members of this list specify different hosts, they will be
     multiplexed on the same port according to the hostname specified through
     the SNI TLS extension, if the ingress controller fulfilling the ingress
     supports SNI.

     IngressTLS describes the transport layer security associated with an
     Ingress.

FIELDS:
   hosts        <[]string>
     Hosts are a list of hosts included in the TLS certificate. The values in
     this list must match the name/s used in the tlsSecret. Defaults to the
     wildcard host setting for the loadbalancer controller fulfilling this
     Ingress, if left unspecified.

   secretName   <string>
     SecretName is the name of the secret used to terminate TLS traffic on port
     443. Field is left optional to allow TLS routing based on SNI hostname
     alone. If the SNI host in a listener conflicts with the "Host" header field
     used by an IngressRule, the SNI host is used for termination and value of
     the Host header is used for routing.
```

참고로 TCP에 3way-handshake가 있듯이 TLS는 4way-handshake 하게된다.

<br>

본 실습은 TLS/SSL Termination 테스팅을 위한 실습이기 때문에, 

OpenSSL을 통해 **자체 서명 인증서(SSC, Self Signed Certificate)를 사용**할 예정이다.

본 실습의 최종 모습을 간단하게 그림으로 나타내면 다음과 같다.

<img src="https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220525194842192.png" alt="image-20220525194842192" width=700 />

<br>

먼저 실습을 진행하기 위한 디렉토리를 만들자.

```shell
$ mkdir tls-termination
$ cd tls-termination
```

<br>

#### 자체 서명 인증서 생성

RSA알고리즘의 Private Key를 생성한다.

```shell
$ openssl genrsa -out nginx-tls.key 2048
```

Private Key를 넣어서 Public Key를 생성한다.

```shell
$ openssl rsa -in nginx-tls.key -pubout -out nginx-tls
```

CSR(Certificate Signing Request)를 생성한다.

```shell
$ openssl req -new -key nginx-tls.key -out nginx-tls.csr
```

3650일 동안 유효한 자체 서명 인증서를 생성한다.

```shell
$ openssl req -x509 -days 3650 -key nginx-tls.key -in nginx-tls.csr -out nginx-tls.crt
```

물론, 생성된 `nginx-tls.crt`는 자체 서명 인증서이기 때문에 보안상 문제가 있다. 테스트를 위해 사용하는 것이다.

<br>

이제 필요없는 파일은 다시 삭제해준다.

```shell
$ rm nginx-tls nginx-tls.csr
```

<br>

#### Secret 생성

다음으로 인증서가 담긴 [secret](https://nayoungs.tistory.com/entry/Kubernetes-k8s-ConfigMap%EA%B3%BC-Secret-feat-%EC%BB%A8%ED%85%8C%EC%9D%B4%EB%84%88-%ED%99%98%EA%B2%BD-%EB%B3%80%EC%88%98#%E-%-C%--%EF%B-%-F%--Secret)를 생성한다.

data에 `tls.crt` 파일과 `tls.key`의 내용을 기입해야하는데,

파일의 내용이 멀티라인으로 확인되기 때문에, 다음 명령어를 이용하면 한줄로 출력할 수 있다.

```shell
$ base64 nginx-tls.crt -w 0
```

```shell
$ base64 nginx-tls.key -w 0
```

출력된 값을 복사하여 data에 key-value 형식으로 각각 넣어준다.

`ingress-tls-secret.yaml`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ingress-tls-secret
type: kubernetes.io/tls
data:
  # base64 x509/nginx-tls.crt -w 0
  tls.crt: |
    LS0tLS1CRUd... #nginx-tls.crt 파일 내용 입력
  # base64 x509/nginx-tls.key -w 0
  tls.key: |
    LS0tLS1CRUdJ... #nginx-tls.key 파일 내용입력
```

<br>

#### RS, SVC, Ingress 생성

아래와 같이 ReplicaSets 파일을 작성한다.

`myweb-rs.yaml`

```yaml
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
          image: ghcr.io/c1t1d0s7/go-myweb
          ports:
            - containerPort: 8080
              protocol: TCP
```

아래와 같이 NodePort 타입의 서비스 파일을 작성한다.

`myweb-svc-np.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myweb-svc-np
spec:
  type: NodePort
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 8080
```

아래와 같이 wildcard dns를 사용하는 Ingress 파일을 작성한다.

`spec.tls` 필드에 호스트와 tls 인증서가 저장된 secret 이름을 입력한다.

`myweb-ing-tls.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myweb-ing-tls
spec:
  tls:
    - hosts:
        - '*.nip.io'
      secretName: ingress-tls-secret
  rules:
    - host: '*.nip.io'
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myweb-svc-np
                port:
                  number: 80
```

```shell
$ ls
ingress-tls-secret.yaml  myweb-ing-tls.yaml  myweb-rs.yaml  myweb-svc-np.yaml
$ kubectl create -f .
```

<br>

#### 접속 확인

자체서명 인증서를 이용한 경우, curl 명령시 `-k` 옵션을 사용해줘야한다.

```shell
$ curl -k https://192-168-100-100.nip.io 
Hello World!
myweb-rs-k4jtw
```

웹 브라우저로 접속해보면, 자체 서명 인증서이기 때문에 안전하지 않은 인증서라고 확인된다.

테스트를 위한 것이기 때문에 다음과 같이 [고급] - [이동]을 누르면 접속할 수 있다.

<img src="https://raw.githubusercontent.com/na3150/typora-img/main/img/https.png" alt="https" style="zoom:50%;" />



<img src="https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220525192209284.png" alt="image-20220525192209284" style="zoom:80%;" />



<br>

<br>

지금까지 쿠버네티스 Ingress를 통해 TLS/SSL Termination을 구성해보았다.

실습이 끝난 후 지워주는 것을 잊지 말자.

```shell
$ kubectl delete -f .
```



