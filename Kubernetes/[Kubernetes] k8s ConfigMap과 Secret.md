# [Kubernetes] k8s ConfigMap과 Secret (feat. 컨테이너 환경 변수)

<br>

## 컨테이너 환경 변수

쿠버네티스 파드의 컨테이너를 위한 환경 변수를 정의하는 방법에 대해 알아본다.

<br>

`pods.spec.containers.env`

- `name`
- `value`

```shell
$ kubectl explain pods.spec.containers.env
KIND:     Pod
VERSION:  v1

RESOURCE: env <[]Object>

DESCRIPTION:
     List of environment variables to set in the container. Cannot be updated.

     EnvVar represents an environment variable present in a Container.

FIELDS:
   name <string> -required-
     Name of the environment variable. Must be a C_IDENTIFIER.

   value        <string>
     Variable references $(VAR_NAME) are expanded using the previously defined
     environment variables in the container and any service environment
     variables. If a variable cannot be resolved, the reference in the input
     string will be unchanged. Double $$ are reduced to a single $, which allows
     for escaping the $(VAR_NAME) syntax: i.e. "$$(VAR_NAME)" will produce the
     string literal "$(VAR_NAME)". Escaped references will never be expanded,
     regardless of whether the variable exists or not. Defaults to "".

   valueFrom    <Object>
     Source for the environment variable's value. Cannot be used if value is not
     empty.
```

<br>

다음과 같이 yaml 파일에 `env` 필드를 작성하여 파드의 컨테이너에 환경 변수를 제공해보자.

`myweb.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb-env
spec:
  containers:
    - name: myweb
      image: ghcr.io/c1t1d0s7/go-myweb:alpine
      env: #환경변수
        - name: MESSAGE
          value: "Customized Hello World"
```

```shell
$ kubectl create -f myweb.yaml            
pod/myweb-env created
$ kubectl get po              
NAME                                      READY   STATUS    RESTARTS   AGE
myweb-env                                 1/1     Running   0          5s
```

파드에 접속하여 환경변수를 확인해보면 환경 변수 `MESSAGE=Customized Hello World`가 

정상적으로 등록된 것을 확인할 수 있다. 

```shell
$ $ kubectl exec -it myweb-env -- sh
/ # env
KUBERNETES_PORT=tcp://10.233.0.1:443
KUBERNETES_SERVICE_PORT=443
HOSTNAME=myweb-env
SHLVL=1
HOME=/root
TERM=xterm
KUBERNETES_PORT_443_TCP_ADDR=10.233.0.1
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP=tcp://10.233.0.1:443
KUBERNETES_SERVICE_PORT_HTTPS=443
MESSAGE=Customized Hello World
KUBERNETES_SERVICE_HOST=10.233.0.1
PWD=/
```

<br>

<br>

## ConfigMap

[컨피그맵(ConfigMap)](https://kubernetes.io/ko/docs/concepts/configuration/configmap/)은 컨테이너에서 필요한 환경설정 내용을 컨테이너와 분리해서 제공해 주기 위한 기능으로,

`key-value` 쌍의 비기밀 데이터를 저장하는 데 사용하는 API 오브젝트이다.

**파드에서 환경 변수(변수:값) 또는 파일(파일명:내용)을 제공**할 수 있다.

<br>

**사용 용도**

- 환경 변수
- 볼륨/파일
  - 설정파일
  - 암호화 키/인증서

<br>

**리소스 확인**

```shell
$ kubectl api-resources| grep configmap 
configmaps                        cm           v1                                     true         ConfigMap
```

<br>

**리소스 정의 방법 확인**

```shell
$ kubectl explain cm                 
```

configmap은 spec이 없다.

<br>

#### immutable

`configmap.immuatable`

default는 false이고,

true로 설정하면 해당 값은 나중에 변경할 수 없다. --> replace, edit, patch 등이 불가능하다.

```shell
$ kubectl explain cm.immutable  
KIND:     ConfigMap
VERSION:  v1

FIELD:    immutable <boolean>

DESCRIPTION:
     Immutable, if set to true, ensures that data stored in the ConfigMap cannot
     be updated (only object metadata can be modified). If not set to true, the
     field can be modified at any time. Defaulted to nil.
```

<br>

#### data

`configmap.data`

해시 방식으로 `key:value`를 지정한다.

```shell
$ kubectl explain cm.data       
...
FIELD:    data <map[string]string>

DESCRIPTION:
     Data contains the configuration data. Each key must consist of alphanumeric
     characters, '-', '_' or '.'. Values with non-UTF-8 byte sequences must use
     the BinaryData field. The keys stored in Data must not overlap with the
     keys in the BinaryData field, this is enforced during validation process.
```

- **환경 변수** 제공하기 
  - `containers.envFrom.configMapRef` : **configMap의 모든 데이터를 제공**
  - `containers.env.valueFrom.configMapKeyRef` : **키를 직접 지칭**

```shell
$ ubectl explain pods.spec.containers.envFrom.configMapRef
...
RESOURCE: configMapRef <Object>

DESCRIPTION:
     The ConfigMap to select from

     ConfigMapEnvSource selects a ConfigMap to populate the environment
     variables with.

     The contents of the target ConfigMap's Data field will represent the
     key-value pairs as environment variables.

FIELDS:
   name <string>
     Name of the referent. More info:
     https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names

   optional     <boolean>
     Specify whether the ConfigMap must be defined
```

```shell
$ kubectl explain pods.spec.containers.env.valueFrom.configMapKeyRef
...
RESOURCE: configMapKeyRef <Object>

DESCRIPTION:
     Selects a key of a ConfigMap.

     Selects a key from a ConfigMap.

FIELDS:
   key  <string> -required-
     The key to select.

   name <string>
     Name of the referent. More info:
     https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names

   optional     <boolean>
     Specify whether the ConfigMap or its key must be defined
```

- **볼륨**으로 제공하기 : **`volumes.configMap`**

```shell
$ kubectl explain pods.spec.volumes.configMap 
...
FIELDS:
   defaultMode  <integer>
     Optional: mode bits used to set permissions on created files by default.
     Must be an octal value between 0000 and 0777 or a decimal value between 0
     and 511. YAML accepts both octal and decimal values, JSON requires decimal
     values for mode bits. Defaults to 0644. Directories within the path are not
     affected by this setting. This might be in conflict with other options that
     affect the file mode, like fsGroup, and the result can be other mode bits
     set.

   items        <[]Object>
     If unspecified, each key-value pair in the Data field of the referenced
     ConfigMap will be projected into the volume as a file whose name is the key
     and content is the value. If specified, the listed keys will be projected
     into the specified paths, and unlisted keys will not be present. If a key
     is specified which is not present in the ConfigMap, the volume setup will
     error unless it is marked optional. Paths must be relative and may not
     contain the '..' path or start with '..'.

   name <string>
     Name of the referent. More info:
     https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names

   optional     <boolean>
     Specify whether the ConfigMap or its keys must be defined
```

<br>

**💻 실습 1 : 환경변수 참조하기**

`mymessage.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mymessage
data: #key:value 지정
  MESSAGE: Customized Hello ConfigMap
```

`mymessage` 컨피그맵이 생성된 것을 확인할 수 있다. 

```shell
$ kubectl create -f mymessage.yaml     
configmap/mymessage created
$ kubectl get cm                  
NAME               DATA   AGE
kube-root-ca.crt   1      7d14h
mymessage          1      3s
```

key:value 쌍이 1개이기 때문에 DATA는 1개이다.

다음으로 `kubectl describe` 명령을 통해 확인해보자.

```shell
$  kubectl describe cm mymessage                    
Name:         mymessage
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
MESSAGE:  #key
----
Customized Hello ConfigMap  #value

BinaryData
====

Events:  <none>
```

<br>

컨피그맵 테스트를 위해 파드를 한개 생성한다.

`myweb-env.yaml` : 2가지 방식 중에 선택

- `envForm.configMapRef` : 컨피그맵의 모든 데이터를 등록

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb-env
spec:
  containers:
    - name: myweb
      image: ghcr.io/c1t1d0s7/go-myweb:alpine
      envFrom: 
        - configMapRef: #컨피그맵을 참조
            name: mymessage #컨피그맵의 이름
```

- `env.valueForm.configMapkeyRef` : 키를 직접 지정

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb-env
spec:
  containers:
    - name: myweb
      image: ghcr.io/c1t1d0s7/go-myweb:alpine
      env:
        valueFrom:
          configMapKeyRef:
            name: mymessage
            key: MESSAGE
```

```shell
$ kubectl create -f myweb-env.yaml   
```

sh을 통해 파드에 접속해보면, 환경변수 `MESSAGE`를 확인할 수 있다.

```shell
$ kubectl exec -it myweb-env -- sh            
/ # env
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT=tcp://10.233.0.1:443
HOSTNAME=myweb-env
SHLVL=1
HOME=/root
TERM=xterm
KUBERNETES_PORT_443_TCP_ADDR=10.233.0.1
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT_443_TCP=tcp://10.233.0.1:443
MESSAGE=Customized Hello ConfigMap
KUBERNETES_SERVICE_HOST=10.233.0.1
PWD=/
```

이와 같이 `envForm.configMapRef`를 통해 컨피그맵의 환경변수를 참조할 수 있고,

앞서 [컨테이너 환경변수]에서 살펴봤듯이 `env`를 통해 직접 환경변수를 제공할 수도 있다.

편한 방법을 골라 사용하면 된다.

<br>

<br>**💻 실습 2 : 파일로 참조하기**

`myweb-cmvol.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb-cm-vol
spec:
  containers:
    - name: myweb
      image: ghcr.io/c1t1d0s7/go-myweb:alpine
      volumeMounts:
        - name: cmvol
          mountPath: /myvol
  volumes: #볼륨 참조
    - name: cmvol
      configMap: #컨피그맵 이름
        name: mymessage
```

```shell
$  kubectl create -f myweb-cmvol.yaml 
pod/myweb-cm-vol created
$ kubectl get po                    
NAME                                      READY   STATUS    RESTARTS      AGE
myweb-cm-vol                              1/1     Running   0             5s
```

파드에 접속해서 확인해보면, `/myvol` 디렉토리에 `MESSAGE` 가 있는 것을 확인할 수 있다.

```shell
$ kubectl exec -it myweb-cm-vol -- sh
/ # cd /myvol
/myvol # ls -l MESSAGE
lrwxrwxrwx    1 root     root            14 May 24 15:53 MESSAGE -> ..data/MESSAGE
/myvol # cat MESSAGE
Customized Hello ConfigMap
```

**key가 파일명이 되고, 파일 안의 데이터가 value**가 된다.

<br>

<br>

## Secret

`value --base64--> encoded data` 

[시크릿(secret)](https://kubernetes.io/ko/docs/concepts/configuration/secret/)은 value를 base64로 인코딩하여 encoded data를 만든다.

시크릿은 암호, 키, 인증서 등 민감한 데이터를 저장하기위해 만들어졌으나, 

기본적으로 **base 인코딩만 할뿐 암호화를 하지 않기 때문에 안전하지 않다.**

<br>

시크릿을 파드와 함께 사용하는 방법

- 하나 이상의 컨테이너에 마운트된 [볼륨](https://kubernetes.io/ko/docs/concepts/storage/volumes/) 내의 [파일](https://kubernetes.io/ko/docs/concepts/configuration/secret/#시크릿을-파드의-파일로-사용하기)로써 사용.
- [컨테이너 환경 변수](https://kubernetes.io/ko/docs/concepts/configuration/secret/#시크릿을-환경-변수로-사용하기)로써 사용.
- 파드의 [이미지를 가져올 때 kubelet](https://kubernetes.io/ko/docs/concepts/configuration/secret/#imagepullsecrets-사용하기)에 의해 사용.

<br>

시크릿 타입

| 빌트인 타입                           | 사용처                                     |
| ------------------------------------- | ------------------------------------------ |
| `Opaque`                              | 임의의 사용자 정의 데이터(일반적인 텍스트) |
| `kubernetes.io/service-account-token` | 서비스 어카운트 토큰                       |
| `kubernetes.io/dockercfg`             | 직렬화 된(serialized) `~/.dockercfg` 파일  |
| `kubernetes.io/dockerconfigjson`      | 직렬화 된 `~/.docker/config.json` 파일     |
| `kubernetes.io/basic-auth`            | 기본 인증을 위한 자격 증명(credential)     |
| `kubernetes.io/ssh-auth`              | SSH를 위한 자격 증명                       |
| `kubernetes.io/tls`                   | TLS 클라이언트나 서버를 위한 데이터        |
| `bootstrap.kubernetes.io/token`       | 부트스트랩 토큰 데이터                     |

<br>

**리소스 정보**

```shell
$  kubectl api-resources| grep secret   
secrets                                        v1                                     true         Secret
```

<br>

**리소스 정의 방법 확인하기**

```shell
$ kubectl explain secret
```

- 환경변수 제공하기
  - `containers.envFrom.secretRef`
  - `containers.env.valueFrom.secretKeyRef`

```shell
$ ubectl explain pods.spec.containers.envFrom.secretRef
...
DESCRIPTION:
     The Secret to select from

     SecretEnvSource selects a Secret to populate the environment variables
     with.

     The contents of the target Secret's Data field will represent the key-value
     pairs as environment variables.

FIELDS:
   name <string>
     Name of the referent. More info:
     https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names

   optional     <boolean>
     Specify whether the Secret must be defined
```

```shell
$ kubectl explain pods.spec.containers.env.valueFrom.secretKeyRef   
...
RESOURCE: secretKeyRef <Object>

DESCRIPTION:
     Selects a key of a secret in the pod's namespace

     SecretKeySelector selects a key of a Secret.

FIELDS:
   key  <string> -required-
     The key of the secret to select from. Must be a valid secret key.

   name <string>
     Name of the referent. More info:
     https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names

   optional     <boolean>
     Specify whether the Secret or its key must be defined
```

- 파일로 제공하기
  - `volumes.secret.secretName`

```shell
$ kubectl explain pods.spec.volumes.secret.secretName                                     
KIND:     Pod
VERSION:  v1

FIELD:    secretName <string>

DESCRIPTION:
     Name of the secret in the pod's namespace to use. More info:
     https://kubernetes.io/docs/concepts/storage/volumes#secret
```

<br>

**💻 실습 1 : 시크릿 생성하기**

`mydata.yaml`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mydata
  type: Opaque
data:   
  id: admin
  pwd: P@ssw0rd
```

base64 인코딩을 하지 않았기 때문에, 실행 시 에러가 발생한다.

```shell
$ kubectl create -f mydata.yaml
error: error validating "mydata.yaml": error validating data: ValidationError(Secret.metadata): unknown field "type" in io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta; if you choose to ignore these errors, turn validation off with --validate=false
```

base인코딩 값을 확인하고, `mydata.yaml`파일을 수정한다.

```shell
$ echo "admin" | base64
YWRtaW4K
$ echo "P@ssw0rd" | base64
UEBzc3cwcmQK
```

`mydata.yaml`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mydata
type: Opaque
data:
  id: YWRtaW4K
  pwd: UEBzc3cwcmQK
```

```shell
$ kubectl create -f mydata.yaml
```

`mydata` 시크릿이 생성된 것을 확인할 수 있다.

```shell
$ kubectl get secret           
NAME                                 TYPE                                  DATA   AGE
mydata                               Opaque                                2      46s
```

secret은 configmap과 달리 데이터는 확인할 수 없고, 크기만 보여준다.

```shell
$ kubectl describe secret mydata
Name:         mydata
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
id:   6 bytes
pwd:  9 bytes
```

그러나 yaml로 보면, 인코딩된 데이터를 확인 가능하다.

```shell
$ kubectl get secret mydata -o yaml
apiVersion: v1
data:
  id: YWRtaW4K
  pwd: UEBzc3cwcmQK
kind: Secret
metadata:
  creationTimestamp: "2022-05-24T16:27:35Z"
  name: mydata
  namespace: default
  resourceVersion: "784587"
  uid: 692be111-7c60-4436-93a6-aa6fe56f813f
type: Opaque
```

<br>

**💻 실습 2 : 환경변수 참조하기**

secret 파일은 실습 1에서 사용한 것과 동일한 것을 사용한다.

`mydata.yaml`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mydata
type: Opaque
data:
  id: YWRtaW4K
  pwd: UEBzc3cwcmQK
```

configMap과 마찬가지고 2가지 방법이 가능하다.

- `envForm.secretRef`  

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb-secret
spec:
  containers:
    - name: myweb
      image: ghcr.io/c1t1d0s7/go-myweb:alpine
      envFrom:
        - secretRef:
            name: mydata
```

- `env.valueFrom.secretKeyRef`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb-env
spec:
  containers:
    - name: myweb
      image: ghcr.io/c1t1d0s7/go-myweb:alpine
      env:
        valueFrom:
          secretKeyRef:
            name: mydata 
            key: id
```

```shell
$ kubectl create -f myweb-secret.yaml
```

파드 컨테이너에 접속해서 환경 변수를 확인해보면,

`id`와 `pwd` 환경 변수가 정상적으로 설정된 것을 확인할 수 있다.

```shell
$ kubectl exec -it myweb-secret -- sh
/ # env
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT=tcp://10.233.0.1:443
HOSTNAME=myweb-secret
SHLVL=1
HOME=/root
id=admin
pwd=P@ssw0rd
TERM=xterm
KUBERNETES_PORT_443_TCP_ADDR=10.233.0.1
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT_443_TCP=tcp://10.233.0.1:443
KUBERNETES_SERVICE_HOST=10.233.0.1
```

<br>

**💻 실습 3 : 파일 참조하기**

secret 파일은 실습 1,2에서 사용한 것과 동일한 것을 사용한다.

`mydata.yaml`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mydata
type: Opaque
data:
  id: YWRtaW4K
  pwd: UEBzc3cwcmQK
```

`myweb-sec-vol.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb-sec-vol
spec:
  containers:
    - name: myweb
      image: ghcr.io/c1t1d0s7/go-myweb:alpine
      volumeMounts:
        - name: secvol
          mountPath: /secvol
  volumes:
    - name: secvol
      secret:
        secretName: mydata
```

```shell
$ kubectl create -f myweb-secret.yaml
```

파드 컨테이너에 접속해보면,

`secvol/` 디렉토리에 key 값이 `id`와 `pwd` 파일이 있는 것을 확인할 수 있고,

파일의 내용은 각각의 value값과 같은 것을 확인할 수 있다.

```shell
$ kubectl exec -it myweb-sec-vol -- sh
/ # ls secvol/
id   pwd
/ # cat secvol/id
admin
/ # cat secvol/pwd
P@ssw0rd
/ # exit
```

<br>

<br>

참고

https://arisu1000.tistory.com/27843
