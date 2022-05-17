# [Kubernetes] k8s Label, LabelSelector, Annotations

<br>

### 📌Index

- [Label](#label)
- [LabelSelector](#labelselector)
- [Annotations](#annotations)



<br>

<br>

## Label

[Labels](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/labels/)

`Label`은 `AWS`의 `TAG`와 비슷하여, `Label`은 리소스에 하나 이상 설정할 수 있고, 중복될 수 있다.

`Label`은 오브젝트의 특성을 식별하는 데 사용한다.

`metadata`의  키를 사용하며, 키는 중복이 가능하다. 

[권장 레이블](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/common-labels/) : 권장일 뿐 must는 아니다.

일반적으로 애플리케이션 이름, 버전, 도구, 만든 사용자 등을 붙여준다.

<br>
**유효한 레이블 조건**

- 63 자 이하(공백일 수도 있음)
- (공백이 아니라면) 시작과 끝은 알파벳과 숫자(`[a-z0-9A-Z]`)
- 알파벳과 숫자, 대시(`-`), 밑줄(`_`), 점(`.`)을 중간에 포함 가능

<br>

참고로 `kubernetes.io/`와 `k8s.io/` 접두사는 쿠버네티스의 핵심 컴포넌트로,

 [예약](https://kubernetes.io/ko/docs/reference/labels-annotations-taints/)되어 있다. (다른 곳에 쓰이고 있다)

<br>

##### 레이블 확인

```
$ kubectl get pods --show-labels
```

```
$ kubectl get pods <Pod> -o yaml
```

```
$ kubectl describe pods <Pod>
```

예시

```shell
$ kubectl get pods --show-labels
NAME    READY   STATUS    RESTARTS   AGE   LABELS
myweb   1/1     Running   0          38m   <none>
```

<br>

##### 레이블 생성

- 명령형 커맨드로 생성하기

```shell
$ kubectl label <RESOURCE> <RESOURCE NAME> KEY=VALUE
```

예시

기존에 있던 리소스에 레이블을 부여해보자. 참고로 `KEY` 값이 꼭 대문자여야하는 것은 아니다 

`리소스 리소스명`과 `리소스/리소스명` 모두 가능하다.

```shell
$ kubectl label pods myweb APP=apache
```

```shell
$ kubectl label pods/myweb APP=apache
```

확인

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

- `yaml` 파일로 생성하기

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

기존에 있던 레이블을 덮어쓸 때는 `--overwrite` 옵션을 사용해야한다.

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

##### 레이블 삭제

```shell
$ kubectl label pods <Pod> <label>-
```

예시

```shell
$ kubectl label pods myweb ENV-
pod/myweb labeled
$ kubectl get pods --show-labels
NAME    READY   STATUS    RESTARTS      AGE    LABELS
myweb   1/1     Running   1 (42m ago)   104m   APP=apache
```



접두사들은 예약이 되어있다??



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

`LabelSelector`는 검색과 리소스 간 연결을 위해 사용한다.

검색 시 `-l` 옵션을 사용한다.

검색하는 방법 2가지

- 일치성 기준
- 집합성 기준

<br>

##### 일치성(equality base)

- `=`
- `==` (`=`와 같음)
- `!=`

키(Key)만 매칭시키는 방법은 없다.

예시 1: 레이블이 `APP=apache` 인 것을 검색

```shell
$ kubectl get pods -l APP=apache
$ kubectl get pods -l APP==apache
```

```shell
$ kubectl get pods -l APP=apache
NAME    READY   STATUS    RESTARTS      AGE
myweb   1/1     Running   1 (51m ago)   113m
```

예시 2: 레이블이 `APP=apache`가 아닌 것을 검색

```shell
$ kubectl get pods -l 'APP!=apache'
```

<br>

##### 집합성(set base)

- `in`
  - `kubectl get pods -l 'ENV in (staging)'` : `ENV`에 `staging`이 있는 경우
  - `kubectl get pods -l 'APP in (nginx, apache)'` : `Value`가 여러개 들어갈 수 있음 
- `notin`
  - `kubectl get pods -l 'APP notin (apache)'` : `apache`가 포함되어있지 않는 경우 검색
- `exists`: 키만 매칭
  - `Value`는 상관없음
  - `kubectl get pods -l 'APP'`  : `APP` 키가 있는 경우 검색
- `doesnotexists`: 키 제외 매칭
  - `kubectl get pods -l '!APP'`

<br>

<br>

# Annotations

레이블과 비슷지만, `Annotaions`는 **비 식별 메타데이타**이다. 식별이 안되므로 렉터도 없다.

단어 자체의 의미는 주석이지만, 엄밀히 말하면 주석은 아니다.

도구 및 라이브러리와 같은 클라이언트에서 이 메타데이터를 검색(접근, Get)할 수 있으며, `key:Value` 쌍으로 구성된다.

<br>

어노테이션의 예시

- 빌드,릴리스 또는 타임 스탬프, 릴리스 ID, git 브랜치, PR 번호, 이미지 해시, 레지스토리 주소 등
- 로깅, 모니터링, 분석, 감사 리포지터리에 대한 포인터
- 디버깅 정보 : 이름, 버전, 빌드 정보
- 사용자 또는 도구/시스템 출처 정보
- 책임자의 전화번호 또는 호출기의 번호
- 최종 사용자의 지시 사항

<br>

 `Label`과 마찬가지로 `kubernetes.io/`와 `k8s.io/` 접두사는 쿠버네티스의 핵심 구성요소를 위해 예약되어있다.

문법도 `Label`과 거의 동일하다.

<br>

참고로 `Calico`를 사용했다면, `Calico`가 자동으로 파드에 관리 용도를 위해 비 식별 데이터를 붙여놓는다.

```
 annotations:
    cni.projectcalico.org/containerID: 36a3eacd1d7e1dd89ebb9577ae91509ba15e4c48600f27707937e98d99162efc
    cni.projectcalico.org/podIP: 10.233.92.14/32
    cni.projectcalico.org/podIPs: 10.233.92.14/32
```

<br>

**명령형 커맨드**

```shell
$ kubectl annotate <RESOURCE> <RESOURCE NAME> KEY=VALUE
```

예시

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

**어노테이션 수정**

변경 시에는 `--overwrite` 옵션을 사용해야한다.

```
$ kubectl annotate pods myweb created-by=Kim --overwrite
```

**어노테이션 삭제**

```
$ kubectl annotate pods myweb created-by-
```

**`yaml` 파일로 어노테이션 생성하기**

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

