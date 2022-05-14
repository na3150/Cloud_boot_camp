# [Kubernetes] 쿠버네티스(Kubernetes)란? 

### 📌Index

- [쿠버네티스(Kubernetes)란?](#쿠버네티스kubernetes란)
- [쿠버네티스의 기능](#쿠버네티스의-기능)
- [쿠버네티스가 아닌 것](#쿠버네티스가-아닌-것)
-  [쿠버네티스 컴포넌트(구성요소)](#쿠버네티스-컴포넌트구성요소)
-  [애드온(Add-on)](#애드온add-on)

<br>

<br>

## 쿠버네티스(Kubernetes)란?

[쿠버네티스란 무엇인가?](https://kubernetes.io/ko/docs/concepts/overview/what-is-kubernetes/)

쿠버네티스(Kubernetes)란 **컨테이너화된 애플리케이션의 배포, 확장 및 관리를 자동화하는 오픈소스 시스템**이다.

Google이 내부 배포시스템으로 사용하던 `borg`를 기반으로 빠르게 발전하였고, 이후 Google이 [CNCF(Cloud Native Couputing Foundation)]([Cloud Native Computing Foundation (cncf.io)](https://www.cncf.io/))에 기부함으로써, 쿠버네티스는 오픈 소스 프로젝트가 되었다.

참고: [borg 기술 논문]([43438.pdf (storage.googleapis.com)](https://storage.googleapis.com/pub-tools-public-publication-data/pdf/43438.pdf)), [CNCF Cloud Native Interactive Landscape](https://landscape.cncf.io/)

<br>

쿠버네티스는 단순한 컨테이너 플랫폼이 아닌 마이크로 서비스, 클라우드 플랫폼을 지향하고, 컨테이너로 이루어진 것들을 손쉽게 담고 관리할 수 있는 그릇 역할을 한다. 서버리스, CI/CD, 머신러닝 등 다양한 기능이 쿠버네티스 플랫폼 위에서 동작한다. 

<br>

쿠버네티스(k8s)가 필요한 이유는 뭘까❔

 



![img](https://blog.kakaocdn.net/dn/lFLKh/btq4cE1xzK5/Bd3XxgcAmprrfWGkdsAJ4k/img.png)



<center>출처: https://kubernetes.io/</center>

<br>

쿠버네티스를 사용하면 **컨테이너화된 애플리케이션 환경(Containerized Application)을 탄력적으로 실행**할 수 있게 된다. 

프로덕션 환경에서는 애플리케이션을 실행하는 컨테이너를 관리하고 가동 중지 시간이 없는지 확인해야한다. 예를 들어, 컨테이너가 다운된다면 다른 컨테이너를 다시 시작하여 가동 중지 시간을 최소화해야한다.

이러한 동작은 시스템에 의해 처리할 수 있다면 어떨까?

이러한 문제를 **시스템에 의해 관리**되도록하는 것이 **쿠버네티스의 역할**이다!

<br>

<br>

## 쿠버네티스의 기능

쿠버네티스의 공식 홈페이지를 참고하면, 다음과 같은 기능들을 제공함을 알 수 있다.

 



![img](https://blog.kakaocdn.net/dn/bNiplk/btq4cvcoymp/LHsaIvLGMU4mDAYZ2kXrJK/img.png)



<center>출처: https://www.xenonstack.com/insights/kubernetes-deployment/</center>

 <br>

- **서비스 디스커버리와 로드 밸런싱** : DNS 이름을 사용하거나 자체 IP 주소를 사용하여 컨테이너를 노출
- **스토리지 오케스트레이션** : 로컬 저장소, 공용 클라우드 공급자 등과 같이 원하는 저장소 시스템을 자동으로 탑재 
- **자동화된 롤아웃과 롤백** : 원하는 상태를 서술하고 현재 상태를 원하는 상태로 설정한 속도에 따라 변경 가능 
- **자동화된 빈 패킹** : 각 컨테이너가 필요로 하는 CPU와 메모리(RAM)를 제공 
- **자동화된 복구(self-healing)** : 실패한 컨테이너를 다시 시작하고, 컨테이너를 교체
- **시크릿과 구성 관리** : 암호, OAuth 토큰 및 SSH 키와 같은 중요한 정보를 저장하고 관리 
- **자동 재시작 기능** : 컨테이너들을 모니터링, 쿠버네티스는 한 기능을 담당하는 컨테이너를 n개 보유하고 있어서 그 중 하나가 다운되면 빠르게 다른 하나를 가동시킴
- **컨테이너 스케일 조정** : 유저가 많거나 적음에 따라 쿠버네티스가 자동적으로 컨테이너 수를 조절
- **웹 사이트 다운 위험 방지** : 컨테이너 코드의 버그 수정, 버전 업데이트를 해야하는 경우 쿠버네티스가 컨테이너의 신규 버전을 차례로 업데이트 해준다.

 <br>

<br>

## 쿠버네티스가 아닌 것

쿠버네티스는 Platform as a Service(PaaS)가 제공하는 모든 기능을 제공하는 것은 아니다.

 PaaS가 일반적으로 제공하는 기능들은 제공하지만, **기본 솔루션이 선택적이며 추가나 제거가 용이**하다.

따라서 쿠버네티스가 제공하지 않는 것을 정확히 알고있어야한다. 

쿠버네티스는

- 애플리케이션의 유형을 제약하지 않는다. 컨테이너에서 잘 구동되는 애플리케이션이라면 쿠버네티스에서도 잘 동작할 것이다.
- 소스코드를  배포하지 않으며 애플리케이션을 빌드하지 않는다. 따라서 CI/CD는 별도로 구성해야한다.
- 미들웨어, 데이터 처리 프레임, 데이터베이스, 캐시 또는 클러스터 스토리지 시스템과 같은 애플리케이션 레벨의 서비스를 제공하지 않는다.
- 로깅, 모니터링 또는 경보 솔루션을 포함하지 않는다. 따라서 일반적으로 `Prometheus` 오픈소스를 사용하여 로깅 모니터링 경보 솔루션을 구축한다.

- 특정 언어(language)가 없다. 
- 머신설정, 유지보수, 관리, 자동복구 시스템 기능을 제공하지 않는다. 퍼블릭 클라우드는 프로바이더가 관리해주는 관리형 쿠버네티스를 제공하는 것이다. 

**중요 포인트**

- Saas가 아니라 PaaS이다.
- 로깅, 모니터링 기능을 가지고 있지 않다 
- 소스 코드, 배포(depoly) 기능을 기본적으로 가지고 있지 않다.

따라서 쿠버네티스가 제공하지 않는 로깅, 모니터링, 소스코드, 배포와 같은 기능들은 

별도로 구축을 해야한다. 

<br>

<br>

## 쿠버네티스 컴포넌트(구성요소)

쿠버네티스는 여러 개의 노드(예를 들어, 가상서버/Virtual Machine)로 구성된 **클러스터(cluster)**로 이루어져 있다. 

클러스터 : 논리적 혹은 물리적으로 여러 리소스들을 묶어서 사용, **한꺼번에 관리**하는 개념

![쿠버네티스 구성 요소](https://d33wubrfki0l68.cloudfront.net/2475489eaf20163ec0f54ddc1d92aa8d4c87c96b/e7c81/images/docs/components-of-kubernetes.svg)

<center>출처: https://kubernetes.io/ko/docs/concepts/overview/components/</center>

<br>

Cluster의 VM은 크게 `Control Plane`과 `node`로 나눠지며, `Control Plane`와 `node`는 각각의 VM을 사용한다. 

`Control Plane` 보다는 `Node`의 개수가 일반적으로 많다.

<br>

#### 🔹 [Control Plane(Master)](https://kubernetes.io/ko/docs/concepts/overview/components/#%EC%BB%A8%ED%8A%B8%EB%A1%A4-%ED%94%8C%EB%A0%88%EC%9D%B8-%EC%BB%B4%ED%8F%AC%EB%84%8C%ED%8A%B8)

- `Node`들을 관리하는 역할을 한다.
- `Control Plane`에 장애가 발생하면 `Node`를 관리할 수 있으므로 중복 구성을 권장하며, 일반적으로 3대로 구성한다. 
- `Split Brain` (어느 것을 종료시켜야할지, 어디로 찾아가야할지 모르는 문제)의 이유로 클러스터링은 절대 짝수개로 세팅하지 않는다. 

<br>

![img](https://blog.kakaocdn.net/dn/vFgU9/btq4cfujghF/86KkmJEn2ed0WCwsATHR9K/img.png)

<center>출처: https://subicura.com/2019/05/19/kubernetes-basic-1.html</center>

<br>

| **컴포넌트 명**         | **역할**                                  |
| ----------------------- | ----------------------------------------- |
| kube-apiserver          | 모든 요청을 처리하는 역할                 |
| kube-controller-manager | 다양한 컨트롤러(복제/배포/상태 등)를 관리 |
| kube-scheduler          | 상황에 맞게 적절한 Worker Node를 선택     |
| etcd                    | 클러스터 내의 데이터를 담는 저장소        |

**kube-apiserver**

API 서버는 쿠버네티스 컨트롤 플레인의 프론트 엔드로, 수평으로 확장되도록 디자인되어 더 많은 인스턴스를 배포해서 확장할 수 있다.

모든 쿠버네티스의 통신은 apiserver를 거쳐야하고, 그러므로 가장 중요한 server라고 할 수 있다.

**kube-controller-manager**

쿠버네티스 cluster 전체를 컨트롤 하는 쿠버네티스의 핵심으로, 다양한 컨트롤러(복제/배포/상태 등)를 관리한다.

4가지 기능(컨트롤러)

- 노드 컨트롤러: 노드가 다운되었을 때 통지와 대응에 관한 책임을 가진다.
- 레플리케이션 컨트롤러: 시스템의 모든 레플리케이션 컨트롤러 오브젝트에 대해 알맞은 수의 파드들을 유지시켜 주는 책임을 가진다. 
  - `k8s`의 핵심은 컨테이너의 복제(replica)이다.
  - 쿠버네티스는 컨테이너를 직접 컨트롤 하지않으며, `pod`를 컨트롤 (pod != container)한다.
  - `pod` : 클러스터에서 실행중인 컨테이너의 집합
- 엔드포인트 컨트롤러: 엔드포인트 오브젝트를 채운다(즉, 서비스와 파드를 연결시킨다.)
  - `k8s`의 서비스는 네트워크이다. (LB)
  - `pod`에 네트워크를 제공해주는 것이다.
- 서비스 어카운트 & 토큰 컨트롤러: 새로운 네임스페이스에 대한 기본 계정과 API 접근 토큰을 생성한다.
  - 인증을 관리한다. 

**kube-scheduler**

노드가 배정되지 않은 새로 생성된 파드를 감지하고, 실행할 노드를 선택하는 컨트롤 플레인 컴포넌트이다.

커널에서 가장 중요한 것이 바로 스케쥴러로, CPU, Memory, Graphic Card 등을 어떻게 얼마만큼 쓸것인 지, `pod`를 어디에 어떻게 배치할 지 등을 스케쥴링해주는 것이다.

스케줄링 결정을 위해서 고려되는 요소는 리소스에 대한 개별 및 총체적 요구 사항, 하드웨어/소프트웨어/정책적 제약, 어피니티(affinity) 및 안티-어피니티(anti-affinity) 명세, 데이터 지역성, 워크로드-간 간섭, 데드라인을 포함한다.

**etcd**

모든 클러스터 데이터를 담는 쿠버네티스 뒷단의 저장소로 사용되는 key-value 저장소(스토리지)로, 클러스터의 상태와 관련된 정보들(선언적인 데이터 `desired state` 등)이 저장된다.

`etcd`는 데이터를 저장하고 있으므로, 데이터가 없어지거나 접근할 수 없으면 아무것도 할 수 없게 된다. 

**cloud-controller-manager(optional)**

클라우드 컨트롤러 매니저를 통해 클러스터를 cloud provider의 API에 연결하고, 해당 클라우드 플랫폼과 상호 작용하는 컴포넌트와 클러스터와만 상호 작용하는 컴포넌트를 구분할 수 있게 해 준다.

온프레미스에서는 필요하지 않은 구성이다.

<br>

#### 🔹 [Node(Worker, Minions)](https://kubernetes.io/ko/docs/concepts/overview/components/#%EB%85%B8%EB%93%9C-%EC%BB%B4%ED%8F%AC%EB%84%8C%ED%8A%B8)

- 컨테이너화 된 애플리케이션을 실행한다.
- 실질적인 컨테이너들을 운영해주는 시스템이다.
- CRI(Container Runtime Interface) ->  `Docker`(혹은 Podman 등)가 설치되어있어야한다.

<br>

![img](https://blog.kakaocdn.net/dn/c94mmX/btq4dcjdjIz/wO5ri20IjKWAk1wJYICYK1/img.png)

<center>출처: https://subicura.com/2019/05/19/kubernetes-basic-1.html</center>

<br>

| **컴포넌트 명** | **역할**                                 |
| --------------- | ---------------------------------------- |
| pod             | 컨테이너화된 애플리케이션 그룹           |
| kubelet         | Node에 할당된 pod의 상태를 체크하고 관리 |
| kube-proxy      | pod로 연결되는 네트워크를 관리           |

**kubelet**

Container Runtime들을 관리해주는 Agent로, 노드에 할당된 Pod의 생명주기를 관리한다.

Pod을 생성하고 Pod 안의 컨테이너에 이상이 없는지 확인하면서 주기적으로 마스터에 상태를 전달하며, API 서버의 요청을 받아 컨테이너의 로그를 전달하거나 특정 명령을 대신 수행하기도 한다.

**kube-proxy(k-proxy)**

kube-proxy는 클러스터의 각 노드에서 실행되는 네트워크 프록시로,  Pod로 연결되는 네트워크(규칙)를 관리한다. 

이 네트워크 규칙이 내부 네트워크 세션이나 클러스터 바깥에서 Pod로 네트워크 통신을 할 수 있도록 해준다.

<br>

Control Plane의 `c-m`, `c-c-m`, `etcd`, `sched`, `api`도 모두 Pod이기 때문에, Control Plane에도 kubelet과 kube-proxy가 존재한다. 

<br>

<br>

## 애드온(Add-on)

 [애드온](https://kubernetes.io/ko/docs/concepts/cluster-administration/addons/)은 쿠버네티스 리소스([데몬셋](https://kubernetes.io/ko/docs/concepts/workloads/controllers/daemonset), [디플로이먼트](https://kubernetes.io/ko/docs/concepts/workloads/controllers/deployment/) 등)를 이용하여 클러스터 기능을 구현한다. 

말 그대로 추가 기능들이라고 생각하면 된다.

이들은 클러스터 단위의 기능을 제공하기 때문에 애드온에 대한 네임스페이스 리소스는 `kube-system` 네임스페이스에 속한다.

<br>

**DNS**

`kube-dns`라고도 하며, **클러스터 내부에서 사용**한다. 

서비스 디스커버리(Service Discovery)를 위해 클러스터 dns를 갖추어야한다.

예를 들어, 클러스터 내에 컨테이너가 여러개 있는 경우 서로를 찾을 때 사용한다.

**Core DNS**는 쿠버네티스 내에 DNS를 구성하기 위해 사용하는 오픈소스이다.

DNS 서비스는 여러 Add-on 중에 하나이지만 

**복잡함을 해결하기 위해 반드시 사용**해야하는 서비스이다. 

<br>

**컨테이너 리소스 모니터링**

`prometheus`를 사용하여 모니터링한다.

<br>

**클러스터-레벨 로깅**

ELK ElasticSearch 오픈 소스로 로깅한다.

<br>

<br>

<br>

<br>

<br>

<br>

참고

- https://kubernetes.io/ko/docs/concepts/overview/what-is-kubernetes/#why-you-need-kubernetes-and-what-can-it-do
- https://tech.ktcloud.com/67