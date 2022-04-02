<h1> [AWS] VPC(Virtual Private Cloud) </h1>



<h3>📌INDEX</h3>

- [VPN](#vpnvirtualprivatenetwork)
- [VPC](#vpcvirtualprivatecloue)
- [VPC의 구성 요소](#vpc의-구성-요소)
- [VPC와 서브넷(Subnet)](#vpc와-서브넷subnet)
- [라우팅 테이블(Routing Table)](#라우팅-테이블routing-table)
-  [VPC의 주요 서비스](#vpc의-주요-서비스)

<br>

<br>

<h2>VPN(Virtual Private Network)</h2>

VPN은 **Virtaul Private Network**의 약자로, 큰 규모의 조직이 여러 곳에 분산되어 있는 **컴퓨터들을 연결하는 보안성이 높은 사설 네트워크**(Private Network)를 만들거나, 인터넷을 활용하여 원격지 간에 네트워크를 서로 연결하고 **암호화 기술을 적용하여 보다 안정적이며, 보안성 높은 통신 서비스를 제공**하는 서비스

- Amazon Web Services(AWS)는 VPC(Virtaul Private Cloud)와 VPC Gateway를 통해 On-Premise의  VPN 장비와 Amazon Web Services 간의 VPN을 연결할 수 있음
- 보안성 높은 하이브리드 클라우드(Hybrid Cloud)를 구현하여 원활한 클라우드 컴퓨팅 서비스를 지원

<br>

<br>

<h2>VPC(Virtual Private Cloud)</h2>

Amazon VPC는 **Virtual Private Cloud**의 약자로, AWS 클라우드에서 **논리적으로 격리된 네트워크 공간을 할당하여 가상 네트워크에서 AWS 리소스를 이용할 수 잇는 서비스를 제공**

- Amazon VPC 자체 IP 주소 범위, 서브넷(Subnet) 생성, 라우팅 테이블(Routing Table) 및 네트워크 게이트웨이 구성 선택 등 가상 네트워킹 환경을 완벽하게 제어할 수 있음
- VPC에서 IPv4, IPv6를 모두 사용하여 리소스와 애플리케이션에 안전하고 쉽게 액세스 할 수 있음

- 네트워크의 구성을 손쉽게 정의할 수 할 수 있으며, 보안 그룹(Security Group) 및 네트워크 제어 목록(Network Access Control List)을 포함한 다중 보안 계층을 활용하여 각 서브넷(Subnet)에서 EC2 인스턴스에 대한 액세스를 제어할 수 있음
- 기업의 데이터 센터와 VPC 사이에 하드웨어 가상 사설 네트워크 연결을 생성하여, AWS 클라우드를 기업의 데이터 센터를 확장할 것처럼 사용할 수 있음

- **VPC의 주요 특징**
  - AWS에 사설 네트워크 구축
  - 회사와 AWS 간 VPN을 연결하거나 가상 네트워킹 구현
  - 기존 데이터 센터와의 연결을 통해 하이브리드(Hybrid) 환경 구성
  - AWS를 회사 인프라의 일부처럼 사용할 수 있으며, 내부 시스템 소프트웨어의 연동이 매우 쉬움(예: 메일, 그룹웨어와 같은 업무 시스템, 파일 서버 등)
  - 세심한 네트워크 설정 가능
  - 모든 리전(Region)에서 이용 가능

- 프리 티어(Free Tier)
  - VPC 자체는 비용이 발생하지 않지만, VPN 연결 시 네트워크 송/수신에 따른 종량제 비용 발생
- 공식 문서 : [VPC란 무엇인가?]([Amazon VPC란 무엇인가? - Amazon Virtual Private Cloud](https://docs.aws.amazon.com/ko_kr/vpc/latest/userguide/what-is-amazon-vpc.html)) 

<br>

<br>

<h2>VPC의 구성 요소</h2>

**Private IP**

- 인터넷을 통해 연결할 수 없는, **VPC 내부에서만 사용할 수 있는 IP주소**
- priavate IP는 VPC에서 시작된 인스턴스 서브넷의 범위에서 자동으로 할당됨
- 동일 네트워크에서 인스턴스 간 통신에 사용할 수 있음
- 기본 private 주소와 별도로 보조 private IP주소라는 추가 프라이빗 주소를 할당할 수 있음

**Public IP**

- **인터넷을 통해 연결할 수 있는 IP주소로, 인스턴스와 인터넷 간의 통신을 위해 사용**
- EC2 생성 시 옵션으로 퍼블릭 IP주소의 사용 여부를 선택할 수 있으며, 인스턴스에서 퍼블릭 IP주소를 수동으로 연결하거나 해제할 수 없음
- 인스턴스가 재부팅되면 새로운 퍼블릭 IP주소가 할당됨

**Elastic IP**

- 동적 컴퓨팅을 위해 고안된 **고정 퍼블릭 IP주소**
- VPC의 모든 인스턴스와 네트워크 인터페이스에 탄성 IP를 할당할 수 있음

- 다른 인스턴스에 주소를 신속하게 다시 매칭하여 인스턴스 장애 조치를 수행할 수 있음
- 탄력적 IP 주소의 효율적인 활용을 위해 탄력적 IP주소가 실행 중인 인스턴스와 연결되어 있지 않거나, 중지된 인스턴스 또는 분리된 네트워크 인터페이스와 연결되어있는 경우 시간당 요금이 부과됨
- 사용 가능한 탄력적 IP 주소는 5개로 제한되며, 이를 절약하기 위해 NAT 디바이스를 사용할 수 있음
- 공식 문서 : [네트워크 인터페이스 및 VPC에서 실행 중인 인스턴스에 탄력적 IP 주소 연결 - Amazon Virtual Private Cloud](https://docs.aws.amazon.com/ko_kr/vpc/latest/userguide/vpc-eips.html)

<br>

<br>

<h2>VPC와 서브넷(Subnet)</h2>

- VPC는 사용자의 AWS 계정을 위한 전용의 가상 네트워크를 말함

- 이러한 VPC는 AWS 클라우드에서 다른 가상 네트워크가 논리적으로 분리되어 있으며, Amazon EC2 인스턴스와 같은 AWS 리소스를 VPC에서 실행할 수 있음

- **VPC 내부의 네트워크에서 목적에 따라 분리된 IP Block의 모음을 서브넷(Subnet)**이라고 함
  - 네트워크상 서브넷과 동일한 개념
- VPC는 리전(Region)의 모든 가용 영역(Availability Zone)에 적용되며, 각 가용 영역에 하나 이상의 서브넷을 추가할 수 있음
- **서브넷은 단일 가용 영역에서만 생성**할 수 있으며, 여러 가용 영역으로 확장할 수 없음

- **VPC와 서브넷의 사이즈**
  - VPC를 생성할 때는 VPC에서 사용하게 될 IP 주소의 범위 CIDR(Classless Inter-Domain Routing) 블록 형태로 지정해야함 ex) 10.0.0.0/16
  - 허용된 블록 크기 : `/16` 넷마스크 (IP 주소 65,536개) ~ `/28` 넷마스크(IP 주소 16개)
    - ex) 10.0.0.0/24 -> 256개의 IP 주소 지원, 각각 128개의 IP주소를 지원하는 2개의 서브넷으로 나눌 수 있음
  - 각 서브넷 **CIDR 블록에서 첫 4개의 IP 주소와 마지막 IP 주소는 사용자가 사용할 수 없으므로 인스턴스에 할당할 수 없음**
    - 예시
      - 10.0.0.0: 네트워크 주소
      - 10.0.0.1: AWS에서 VPC 라우터용으로 예약한 주소
      - 10.0.0.2: AWS에서 예약한 주소. DNS 서버의 IP 주소는 기본 VPC 네트워크 범위에 2를 더한 주소이다. CIDR 블록이 여러 개인 VPC의 경우, DNS 서버의 IP 주소가 기본 CIDR에 위치한다. 또한 각 서브넷 범위의 기본에 2를 더한 주소를 VPC의 모든 CIDR 블록에 대해 예약한다. 
      - 10.0.0.3: AWS에서 앞으로 사용하려고 예약한 주소.
      - 10.0.0.255: 네트워크 브로드캐스트 주소. VPC에서는 브로드캐스트를 지원하지 않으므로, 이 주소를 예약
- **퍼블릭 서브넷(Public Subnet)** 
  - 서브넷 네트워크 트래픽이 인터넷 게이트웨이(Internet Gateway, IGW)로 라우팅이 되는서브넷
  - EC2 인스턴스가 IP를 통해 인터넷과 통신을 할 수 있게 하려면, 퍼블릭 IP주소나 탄력적 IP주소가 있어야함
  - 일반적으로 인터넷망을 통해 섭시르르 수행하는 웹서버(Web Server)는 퍼블릭 서브넷에 생성
- **프라이빗 서브넷(Private Subnet)**
  - 인터넷 게이트웨이(IGW)로 라우팅되지 않는 서브넷
  - 일반적으로 인터넷에 직접적으로 연결할 필요가 없고, 보다 높은 보안성을 필요로하는 DB서버는 프라이빗 서브넷에 생성
- 공식 문서 : [VPC 및 서브넷 개요](https://docs.aws.amazon.com/ko_kr/vpc/latest/userguide/VPC_Subnets.html)

<br>

<br>

<h2>라우팅 테이블(Routing Table)</h2>

- 각 서브넷은 서브넷 외부로 나가는 **아웃바운드(Outbound) 트래픽에 대해 허용된 경로를 지정하는 라우팅 테이블(Routing Table)**이 연결되어있어야함
- 라우팅 테이블의 각 라우팅은 트래픽을 전달할 IP 주소 범위(대상 주소)와 트래픽을 전송할 게이트웨이, 네트워크 인터페이스 또는 연결(대상)을 지정

- 생성된 서브넷은 자동으로 VPC의 기본 라우팅 테이블과 연결되며, 테이블의 내용을 변경할 수 있음
- 서브넷 간의 통신이나 VPC간의 원활한 통신을 위해 이용
- 라우팅 테이블은 VPC의 서브넷 내에서 생성된 네트워크 패킷이 목적지 주소로 이용하기 위해 어떤 경로로 이동되어야 하는지를 알려주는 나침반과 비슷한 개념으로 이해
- 공식 문서 : [VPC의 라우팅 테이블 관리 - Amazon Virtual Private Cloud](https://docs.aws.amazon.com/ko_kr/vpc/latest/userguide/VPC_Route_Tables.html#RouteTables)

<br>

<br>

<h2>VPC의 주요 서비스</h2>

**보안 그룹(Security Group)과 네트워크 액세스 제어 목록(Network ACL)**

- VPC에서 네트워크 통신과 트래픽에 대해 IP와 Port를 기준으로 통신을 허용하거나 차단하기 위한 기능
- VPC의 보안 그룹과 네트워크 ACL을 통해 AWS 상에서 방화벽과 동일한 기능을 사용할 수 있음
- 필요에 따라 보안 그룹과 네트워크 ACL을 선택적으로 적용하여 사용



![보안그룹과 ACL](C:\Users\USER\Desktop\보안그룹과 ACL.PNG)





**VPC 피어링 연결(VPC Peering Connection)**

- 피어링 연결은 비공개적으로 두 VPC간에 트래픽을 라우팅할 수 잇게 하기 위한 **서로 다른 VPC간의 네트워크 연결을 제공**
- VPC 피어링을 통해 동일한 네트워크에 속한 것과 같이 서로 다른 VPC의 인스턴스 간에 통신 가능
- 자체 VPC 간, 다른 AWS 계정에서 VPC를 사용하여 또는 다른 AWS 리전에서 VPC를 사용하여 VPC 피어링 연결을 만들 수 있음
- 공식 문서 : [VPC peering이란?](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html)

![             A VPC peering connection         ](https://docs.aws.amazon.com/vpc/latest/peering/images/peering-intro-diagram.png)





**NAT(Network Address Translation) 게이트 웨이**

- NAT는 외부 네트워크에 알려진 것과 다른 IP 주소를 사용하는 내부 네트워크에서, **내부 IP 주소를 외부 IP 주소로 변환하는 작업을 수행하는 서비스**이다
- NAT 게이트웨이는 프라이빗 서브넷 내에 있는 인스턴스를 인터넷 또는 다른 AWS 서비스에 연결하기 위해 사용
- 혹은 외부망 또는인터넷에서 해당 인스턴스에 연결하지 못하도록 구성하기 위해 사용

- 외부에 공개될 필요가 없거나, 보안상 중요한 서비스이지만 윈도우 패치나 보안 업데이트, 소프트웨어 업데이트를 인터넷을 통해 통해 받아야하는 경우 NAT 게이트웨이나 NAT 인스턴스(NAT Instance)를 사용
- NAT 게이트웨이를 구성하기 위한 3가지 조건
  - NAT 게이트를 생성하기 위해 퍼블릭 서브넷(Public Subnet)을 지정
  - NAT 게이트웨이와 연결할 탄력적 IP(Elastic IP) 주소 필요
  - NAT 게이트웨이를 만든 후 인터넷 트래픽이 NAT 게이트웨이로 통신이 가능하도록 프라이빗 서브넷(Private Subnet)과 연결된 라우팅 테이블(Routing Table) 업데이트
- **프라이빗 서브넷(Private Subnet)의 인스턴스가 NAT 게이트웨이 구성을 통해 인터넷과 통신할 수 있음**

- 공식 문서 

  - [NAT 게이트웨이](https://docs.aws.amazon.com/ko_kr/vpc/latest/userguide/vpc-nat-gateway.html)
  - [NAT 인스턴스](https://docs.aws.amazon.com/ko_kr/vpc/latest/userguide/VPC_NAT_Instance.html)

  

![img](https://media.vlpt.us/images/ownown/post/474dcf0b-a6b8-406b-a764-8cce92c78b4a/image.png)





**VPC Endpoint**

- 프라이빗 서브넷(Private Subnet)에 위치한 인스턴스는 인터넷과 연결되어있는 S3와 같은 공용 리소스를 연결할 수 없음
- 이러한 경우 S3에 연결하기 위해서는 NAT 게이트웨이나 NAT 인스턴스가 필요
- **VPC Endpoint 를 이용하면 빠르고 손쉽게 S3, DynamoDB에 연결할 수 있음**
- 공식 문서
  - [AWS PrivateLink 및 VPC 엔드포인트를 사용하여 VPC를 다른 AWS 서비스에 연결 - Amazon Virtual Private Cloud](https://docs.aws.amazon.com/ko_kr/vpc/latest/userguide/endpoint-services-overview.html)
  - [VPC 엔드포인트 - Amazon Virtual Private Cloud](https://docs.aws.amazon.com/ko_kr/vpc/latest/privatelink/vpc-endpoints.html)



![ 			인터페이스 엔드포인트를 사용하여 AWS 서비스에 액세스 		](https://docs.aws.amazon.com/ko_kr/vpc/latest/userguide/images/vpc-endpoint-privatelink-diagram.png)





**VPN(Virtual Private Network) 연결**

- 기본적으로 Amazon VPC에서 서비스되는 인스턴스는 On-Premise에 있는 서버나 IDC 내의 시스템과 통신할 수 없음
  - 인터넷을 통해 강제로 통신하도록 구성할 수 있으나, 보안적으로 취약
- VPN 연결은 **VPC와 자체 네트워크 사이의 연결을 의미**
- AWS VPC 내 인스턴스와 IDC 내 시스템 간의 데이터 통신을 위해 VPC에 가상의 프라이빗(Private) 게이트웨이를 연결하고 사용자 지정 라우팅 테이블을 생성하며, 보안 그룹의 규칙을 업데이트하고, AWS 관리형 VPN 연결을 생성하여 VPC에서 원격의 네트워크에 접속 가능하도록 하이브리드 클라우드(Hybrid Cloud) 환경을 구성할 수 있음