# [Kubernetes] 유용한 k8s 관리 도구 모음 : Lens, k9s, VSCode 

<br>

### 📌Index

- [Lens](#lens)
- [k9s](#k9s)
- [VSCode](#visual-studio-code)

<br>

<br>

## Lens

[Lens](https://k8slens.dev/)는 명령어를 사용하지 않고도, **cluster의 정보(node, pod, ns 등등)을 GUI로 확인 가능한 툴**이다.

<br>

<img src="https://cdn.thenewstack.io/media/2021/05/3f22a773-lens-blog-image-768x576-1.png" alt="Mirantis' Kubernetes IDE Lens Catalogs the Full Cloud Native Stack – The  New Stack" style="zoom:50%;" />

<br>

kubernetes IDE 형태로 제공한다.

<br>

Lens는 choco로 설치가 가능하다.

단, choco로 패키지를 설치할 때는 관리자 권한이 필요하기 때문에

터미널을 관리자 모드로 실행해야한다.

``` shell
$ choco install lens
```

이때, 윈도우에서 Lens를 사용하기 위해서는 k8s cluster에 접근이 가능해야하기 때문에, 윈도우에 kubeconfig 파일을 세팅해둬야한다.

설치완료 후 Lens 애플리케이션을 실행하고, 로그인한다. 

다음과 같이 kubeconfig의 context를 확인할 수 있고,

<br>

<img src="https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220530181004963.png" alt="image-20220530181004963" style="zoom: 67%;" />

<br>

Lens내에서 터미널 실행이 가능하며, 파드를 exec로 실행시키는 것도 가능하다

<img src="https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220530181103186.png" alt="image-20220530181103186" style="zoom:50%;" />

<br>

<br>

## k9s

https://k9scli.io/

k9s는 **터미널 상에서 cluster 정보를 text기반의 형식 TUI로 확인할 수 있는 툴**이다.

<br>

<img src="https://k9scli.io/assets/k9s.png" alt="K9s - Manage Your Kubernetes Clusters In Style" style="zoom:50%;" />

k9s 또한 choco로 설치가 가능하다.

```shell
$ choco install k9s
```

<br>

`k9s`를 입력하면 실행할 수 있다.

```shell
$ k9s
```

![image-20220530181302224](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220530181302224.png)

k9s를 실행하면 상단에 단축키 명령을 확인할 수 있고, 좌측 하단에서 무엇을 보고 있는 지 확인할 수 있다.

exec 실행과 포트 포워딩도 가능하며, 전체적으로 Lens와 유사하다.

<br>

<br>

## Visual Studio Code

마지막으로 VSCode이다. 

VSCode는 원격 접속 시에도 많이 사용하지만,

Extenstion을 설치함으로써 쿠버네티스 관리 툴로도 사용이 가능하다.

<br>

<img src="https://images.velog.io/images/namtaehyun/post/fe5d86d3-f734-4943-b087-3f3e02b9d5ab/vscode.png" alt="vscode for mac 한글이 잘 안쳐질 때" style="zoom: 33%;" />



다음과 같이 extension의 kubernetes를 설치한다.

![image-20220530182513900](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220530182513900.png)

설치 후 좌측에서 쿠버네티스 클릭 후, 클러스터를 선택할 수 있으며,

Namespace, Workloads 등등의 리소스를 확인, 수정 및 관리할 수 있다.

![image-20220530182636518](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220530182636518.png)

<br>

VSCode 사용 시 아주 편리하게 사용할 수 있는 기능은 바로 기본 뼈대 구성을 해주는 것이다.

yaml 파일을 생성하고 원하는 type을 입력했을 때, 나타나는 아이콘이 붙어있는 것을 클릭하면

![image-20220530182725781](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220530182725781.png)

다음과 같이 기본 뼈대를 구성해준다.

![image-20220530182833243](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220530182833243.png)

또한, ctrl + shift + p 또는 F1 키 클릭 후 나타나는 입력창에서

명령어를 입력하지 않고도 create, delete 등등 가능하다

![image-20220530183057245](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220530183057245.png)

<br>

<br>

<br>

지금까지 쿠버네티스 작업 시 유용하게 사용할 수 있는 관리 툴들을 살펴보았다.