<h2> [AWS] Amazon ELB(Elastic Load Balancing)</h2>



<h3>📌INDEX</h3> 

- [로드 밸런싱(Load Balancing)이란?](#로드-밸런싱load-balancing이란)
- [Amazon ELB(Elastic Load Balancing)](#amazon-elbelastic-load-balancing)
- [ELB의 종류 및 유형](#elb의-종류-및-유형)

<br>

<br>

<h2>로드 밸런싱(Load Balancing)이란?</h2>

로드 밸런싱(Load Balancing)이란, **네트워크 트래픽을 하나 이상의 서버나 장비로 분산하기 위한 기술**

- 로드 밸런싱 서비스를 통해 외부에서 발생하는 많은 인터넷 트래픽을 여러 웹 서버나 장비로 부하는 분산시켜 처리할 수 있음

- 로드 밸런싱을 수행하는 소프트웨어나 하드웨어를 **로드 밸런서(Load Balancer)**라고 함



[이미지 출처](https://prev.github.io/posts/네이버-오픈소스로-확장성-있는-아키텍처를-1편/)

<img src="https://prev.github.io/attachs/scalable-architecture1/loadbalancer.png" alt="img" weight=400 height=300 />





<br>

**웹  트래픽 증가에 대한 처리 방식**



<img src="https://prev.github.io/attachs/scalable-architecture1/scale_up_out.png" alt="네이버 오픈소스를 활용하여 확장성 있는 서버 아키텍처를 구축하고 성능 개선해보기 - 1편 - Prev's Blog" weight=400 height=300 />



- **Scale-UP**(수직확장)
  - **기존보다 높은 성능을 보유한 웹 서버로 시스템을 업그레이드**함으로써 문제를 해결
  - 필요로 하는 성능이 높아질수록 비용이 기하급수적으로 늘어나는 단점이 있음
  - 하나의 서버에서 웹 서비스를 제공하여 서버 중지 및 장애로 인한 웹 서비스 가용성에 문제가 발생할 수 있음
- **Scale-Out**(수평확장)
  - Scale-UP과 반대되는 개념으로, 서버의 성능을 증가시키는 것이 아닌 **서버의 수를 증가**시키는 방향으로 전체적인 성능을 향상시키는 방법
  - Cluster 내 하나의 노드에 문제가 발생하여도 웹 서비스가 중단되지 않으므로, **가용성이 높은 웹 서비스**를 구성할 수 있음
  - 로드 밸런싱은 Scale-Out 방식의 서비스 구성에 주로 사용되며, 네트워크 트래픽을 서비스의 Port 단위로 제어하고, 트래픽을 분산 처리함으로써 높은 가용성과 부하 분산을 통한 고효율 웹 서비스를 제공


<br>

**로드 밸런싱 방식**

- **라운드 로빈(Round Robin)**
  - 현재 연결된 세션 수와 무관하게 순차적으로 연결 전달
  - 세션에 대한 보장을 제공하지 않음
  - ELB에서 트래픽 분산 시 일반적으로 사용하는 방식
    - 세션을 보장하지 않기 때문에, Sticky Session을 사용하면 처음에 연결된 Client에 별도의 HTTP 기반의 쿠키 값을 생성하여 다음번 연결 요청에 대해 **처음 접속했던 서버로 계속 연결하도록 트래픽을 처리**할 수 있음
- **해시(Hash)**
  - Hash 알고리즘을 이용한 로드 밸런싱 방식
  - 클라이언트-서버 간 세션을 유지 : 클라이언트가 동일 서버로 연결되도록 보장(세션 보장)
- **최소 연결 우선(Least Connection)**
  - 현재 연결된 세션 수에 따라 부하 분산
  - 세션 수를 고려하여 가장 작은 세션을 보유한 서버로 세션을 맺어주는 연결 방식
  - 세션에 대한 보장을 제공하지 않음
- **응답 시간 우선(Response Time)**
  - 빠른 응답이 가능한 서버로 세션을 연결
  - 세션에 대한 보장을 제공하지 않음

<br>

<br>

<h2>Amazon ELB(Elastic Load Balancing)</h2>

- 확장성, 성능, 보안성을 통한 애플리케이션 내결함성을 제공하는 로드 밸런서
- 단일 가용 영역 또는 여러 가용 영역에서 Amazon EC2 인스턴스 및 컨테이너, IP 주소와 같은 동일한 서비스를 제공하기 위해 준비된 여러 대상으로 애플리케이션 및 네트워크 트래픽을 자동으로 분산시킴

- **ELB의 주요 특징**
  - 수신되는 트래픽을 여러 EC2 인스턴스에 자동 배포
  - 애플리케이션의 내결함성을 확보하며, 네트워크 트래픽을 원활하게 대상으로 자동 분산 처리 기능 제공
  - 고가용성, 자동 조정 및 강력한 보안 서비스 제공
    - Sticky Session : 쿠키값으로 세션 보장
    - SSL Termination : 개별 인스턴스에 SSL 인증서 설치할 필요 X
  - Application Load Balancer, Network Load Balancer, Classic Load Balancer, Gateway LoadBalancer 등 네 가지 유형의 로드 밸런서를 지원하며, 애플리케이션의 필요에 따라 로드 밸런스
- 프리티어(Free Tier)
  - 클래식 및 애플리케이션 로드 밸런서 간에 공유되는 탄력적 로드 밸런서 750시간을 프리티어(Free Tier)로 제공
  - 클래식 로드 밸런서의 데이터 처리 15GB, 애플리케이션 로드 밸런서 15GB를 프리티어(Free Tier)로 제공
- 공식 문서 : [Elastic Load Balancing이란?](https://docs.aws.amazon.com/ko_kr/elasticloadbalancing/latest/userguide/what-is-load-balancing.html)



<img src="https://media.amazonwebservices.com/blog/2016/alb_routing_1.png" alt="AWS Application Load Balancer 서비스 공개 | Amazon Web Services 한국 블로그" style="zoom: 67%;" />

<br>

<br>

<h2>ELB의 종류 및 유형</h2>

Amazon ELB는 애플리케이션의 요구사항에 따라 4가지 중 하나의 유형을 선택하여 로드 밸런싱 서비스를 사용할 수 있음

<br>

**Application Load Balancer**

- OSI 모델 7계층(Application)에서 작동하며, **HTTP, HTTPS와 같은 고급 로드 밸런싱 서비스에 적합**
- 마이크로 서비스 및 컨테이너 기반 애플리케이션, 최신 애플리케이션 서비스에 최적화된 로드 밸런싱 제공, SSL/TLS 암호화 및 프로토콜 사용하여 보안성 보장

<img src="https://miro.medium.com/max/1200/0*UCFdX5MLOV2Pt3bL" alt="10 reasons why you should think about using an AWS Application Load Balancer  | by Florian Jakob | Ankercloud Engineering | Medium" weight=400 height=300 />

[이미지 출처](https://medium.com/ankercloud-engineering/10-reasons-why-you-should-think-about-using-an-aws-application-loadbalancer-945f57816c34)

<br>

**Network Load Balancer**

- OSI 모델 4계층(Transport Layer)에서 작동하며, **TCP 트래픽의 로드밸런싱 서비스에 적합**
- 짧은 지연 시간과 초당 수백만 개의 요청 처리가 가능하며, 가용 영역당 1개의 정적 주소를 사용하면서 트래픽의 변동이 심한 서비스에 최적화

<img src="https://res.cloudinary.com/hy4kyit2a/f_auto,fl_lossy,q_70/learn/modules/aws-application-deployment-and-monitoring/distribute-traffic-with-elastic-load-balancing/images/ff9ea83eed1829d66798972337355344_c-963-eaf-0-5733-434-e-b-3-f-6-0-a-5-c-6-aad-6-ca-4.png" alt="Distribute Traffic with Elastic Load Balancing Unit | Salesforce" weight=400 height=300 />

[이미지 출처](https://trailhead.salesforce.com/ko/content/learn/modules/aws-application-deployment-and-monitoring/distribute-traffic-with-elastic-load-balancing)

<img src="https://d2908q01vomqb2.cloudfront.net/5b384ce32d8cdef02bc3a139d4cac0a22bb029e8/2021/09/22/Picture1-3.png" alt="ALB가 NLB의 대상으로 등록된 ALB에 대한 PrivateLink 지원을 보여주는 상위 수준 다이어그램" weight=400 height=300 />

<br>

**Classic Load Balancer**

- OSI 모델 4계층/7계층에서 작동
- EC2-Classic 네트워크 내에 구축된 애플리케이션을 대상으로 제공


<br>


**Gateway Load Balaner**

- OSI 모델 3계층 게이트웨이 + 4계층 로드 밸런싱 작동
- IP, 인스턴스를 대상으로 적합, 라우팅 테이블을 통해 연결
- 최근에 생성된 서비스

<img src="https://d2908q01vomqb2.cloudfront.net/5b384ce32d8cdef02bc3a139d4cac0a22bb029e8/2020/11/14/GWLB-Overview-1024x351.png" alt="Integrate your custom logic or appliance with AWS Gateway Load Balancer |  Networking & Content Delivery" weight=400 height=300 />





공식 문서: [ELB 제품 비교](https://aws.amazon.com/ko/elasticloadbalancing/features/#Product_comparisons)

<br>

<br>
