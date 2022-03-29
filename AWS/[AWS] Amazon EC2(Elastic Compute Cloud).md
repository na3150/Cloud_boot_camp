<h1> [AWS] Amazon EC2(Elastic Compute Cloud) </h1>



<h3>📌INDEX</h3>

- [AWS IDC(Internet Data Center)](#aws-idc)
- [Amazon EC2란?](#amazon-ec2란)
- [Amazon EC2 인스턴스 유형](#amazon-ec2-인스턴스-유형)
- [Amazon EC2 구매 옵션](#amazon-ec2-구매-옵션)
- [Windows 서버용 EC2 인스턴스 만들기](#windows-서버용-ec2-인스턴스-만들기)
- [Windows 서비스 접속하기](#windows-서비스-접속하기)

<br>

<br>

<h2>AWS IDC</h2>

- Amazon Web Service(AWS)는 전세계를 대상으로 클라우드 서비스를 제공하기 위해 **전세계 주요 지역에 IDC(Internet Data Center)를 자체적으로 구축하여 운영**
- 클라우드 서비스를 위한 인프라 환경을 크게 리전(Region), 가용 영역(Availability Zone), 엣지 로케이션(Edge Location)으로 구분할 수 있음

- **리전(Region)**
  - 전세계 **주요 국가에 리전(Region)을 구축**하여 해당 위치에서 가장 가까운 곳에서 클라우드 서비스를 이용할 수 있도록 서비스를 제공
    - 재해 또는 불가항력으로 서버가 정지되었을 때 대처 가능
  - 리전별로 지원해주는 가장 머신 및 서비스가 다양
- **가용 영역(Availability Zone)**
  - 가용 영역이란 **데이터 센터**(Internet Data Center, IDC)를 말함
  - **AWS 하나의 리전(region)에 다수의 가용 영역(AZ)**을 보유
  - 가용 영역이 위치한 데이터 센터(IDC)는 같은 리전이라도 지리적으로 멀리 떨어져 있음
    - 하나의 가용 영역(AZ)이 재해, 정전, 테러 화재 등 다양한 이유로 작동 불능이 되더라도 다른 가용 영역(AZ)에서 서비스를 재개할 수 있도록 하기 위함
- **엣지 로케이션(Edge Location)**
  - Amazon의 CDN 서비스인 Cloud Front를 위한 캐시 서버(Cache Server)들의 모음을 의미
  - CDN 서비스는 Content Delivery Network의 약자로, 콘텐츠(HTML, 이미지, 동영상, 기타 파일)를 서버와 물리적으로 사용자들이 빠르게받을 수 있도록 전세계 곳곳에 위치한 캐시 서버에 복제해주는 서비스
  - 가까운 서버에 접속하여 다운로드 받는 것이 속도가 훨씬 빠르므로, CDN 서비스는 전세계 주요 도시에 캐시 서버를 구축해 놓음

<br>

<br>

<h2>Amazon EC2란? </h2>

- Amazon EC2는 **Elastic Compute Cloud**의 약자로 AWS 상에서 **안정적이며, 크기를 조정 가능한 컴퓨팅 파워를 제공하는 웹 서비스**
  - 클라우드에서 제공되는 크기를 조정할 수 있는 컴퓨팅 파워

- 이러한 가상화 서버(Virtual Server)를 '인스턴스(Instance)'라 부르며, 필요에 따라 한 개의 인스턴스에서 수천 개의 인스턴스로 손쉽게 컴퓨팅 파워를 확장할 수 있음

- **EC2의 주요 특징**
  - 한개에서 수천 개의 인스턴스로 확장 가능
  - 모든 공개된 AWS Region에서 사용 가능
  - 필요에 따라 인스턴스의 생성, 시작, 수정, 중단, 삭제 가능
  - Linux/Windows OS에서 사용 가능하며 모든 소프트웨어 설치 가능
  - 사용한 사용량에 대해서만 시간 단위 비용 과금
  - 다양한 비용 모델(온디맨드, 스팟, 예약) 선택 가능
- **프리티어(Free Tier)**
  - Linux/Windows t2.micro 인스턴스 월 750시간 제동(1GB 메모리, 32bit or 64bit 플랫폼 지원)
  - 가입 후 12개월 이후에 종료됨

<br>

<br>

<h2>Amazon EC2 인스턴스 유형</h2>

Amazon EC2 인스턴스의 유형은 크게 범용(M 시리즈), 컴퓨팅 최적와(C 시리즈), 스토리지 최적화(I시리즈, D 시리즈), GPU 최적화(G 시리즈), 메모리 최적화(R 시리즈)로 나눌 수 있음



- **범용(M 시리즈)**
  - 균형 있는 컴퓨팅, 메모리 및 네트워킹 리소스를 제공, 다양한 여러 워크로드에 사용 가능
  - 웹 서버 및 레포지토리와 같이 이러한 리소르를 동등한 비율로 사용하는 애플리케이션에 적합
- **컴퓨팅 최적화(C 시리즈)**
  - 고성능 프로세스를 활용하는 컴퓨팅 집약적인 애플리케이션에 적합
  - 배치 처리 워크로드, 미디어 트랜스코딩, 코성능 웹서버, HPC(고성능 컴퓨팅), 과학적 모델링, 전용 게임 서버 및 광고 서버 엔진, 기계 학습 추론 및 기타 컴퓨팅 집약적인 애플리케이션에 적압
- **스토리지 최적화(I 시리즈, D 시리즈)**
  - 로컬 스토리지에서 매우 큰 데이터 세트에 대해 많은 순차적 읽기 및 쓰기 액세스를 요구하는 워크로드를 위해 설계
  - 애플리케이션에 대해 대기 시간이 짧은, 수만 단위의 무작위 IOPS(초당 I/O 작업 수)를 지원하도록 최적화
- **GPU 최적화(G 시리즈)**
  - G3, G4dn, P2, P3 P3dn 및 P4d 인스턴스에서 최고의 성능을 달성하기 위해 사용
- **메모리 최적화(R 시리즈)**
  - 메모리에서 대규모 데이터 세트를 처리하는 워크로드를 위한 빠른 성능을 제공하기 위해 설계

<br>

<br>

<h2>Amazon EC2 인스턴스 구매 옵션</h2>

Amazon EC2는 사용자의 요구사항에 따라 비용을 최적화할 수 있도록 다음과 같은 구매 옵션을 제공함



- **온디맨드 인스턴스(On-Demand)** : 필요할 때 바로 생성해서 사용하는 방식으로 인스턴스에 대해 초 단위 비용을 지불
  - 시간당 컴퓨터 용량 비용 지불 및 장기 계약, 약정 없음
  - 증감하는 부하
- **예약 인스턴스(Reserved)** : 1년 또는 3년의 기간에 대한 약정을 통해 온디맨드보다 최대 75% 즈렴한 비용 지불
  - 확정된 사용률
- **스팟 인스턴스(spot)** : 경매 방식의 인스턴스로 스펙을 정해 비용을 입찰하여, 높은 가격을 입력한 사용자에게 인스턴스가 할당됨
  - 시간 무관한 부하
- **전용 인스턴스(Dedicated)** : 고객 전용이 하드웨어에서 인스턴스 서비스를 제공
  - 매우 민감한 부하

<br>

<br>

<h2>Windows 서버용 EC2 인스턴스 만들기</h2>

1)AWS 로그인

2)EC2 접속 > 인스턴스 > 인스터스 시작

![image-20220329185028295](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329185028295.png)

3)Windows Server 2022 Base 선택

![image-20220329185050798](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329185050798.png)

4)t2.micro 선택 후 다음

![image-20220329185131749](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329185131749.png)

5)별다른 설정 없이 다음

![image-20220329185123559](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329185123559.png)

6)별다른 설정 없이 다음

![ec2 5](C:\Users\USER\Desktop\ec2 5.jpg)

7)태그 추가 : 필수 아닌 선택, 이후 특정 인스턴스를 빠르게 찾기 위함

![image-20220329185409253](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329185409253.png)

8)보안 그룹 구성 : 자신의 ip 입력(ipfind 또는 네이버창에 ip 주소 입력 후 확인)

![image-20220329185427542](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329185427542.png)

9)검토 후 시작

![image-20220329185513723](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329185513723.png)

10)키 페어 생성

![image-20220329185526833](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329185526833.png)

11)키 페어 이름 입력 > 키 페어 다운로드 > 인스턴스 시작

![image-20220329185554742](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329185554742.png)

12)EC2에 다시 접속하여 생성된 인스턴스 확인

![image-20220329185636887](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329185636887.png)

13)EC2 접속 > 생성된 인스턴스 ID 클릭 > 연결 클릭

![image-20220329185841624](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329185841624.png)

14)RDP 클라이언트 > 암호 가져오기 클릭

![image-20220329185921709](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329185921709.png)

15)Browse 클릭 > .pem 확장자의 키(key) 열기

![image-20220329190002452](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329190002452.png)

16)암호 해독

![image-20220329190019625](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329190019625.png)

17)원격 데스크톱 파일 다운로드 > 연결

![image-20220329190038060](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329190038060.png)

18)암호 복사 > 입력

![image-20220329190055320](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329190055320.png)

19)'예' 클릭

![image-20220329190221194](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329190221194.png)

20)연결 완료

![image-20220329190427263](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329190427263.png)

<br>

<br>

<h2>Windows 서비스 접속하기</h2>

1)연결된 windows 서버에서 Server Manager 실행

![image-20220329190446406](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329190446406.png)

2)Add roles and features 클릭(대기 시간이 필요할 수 있음)

![image-20220329190513717](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329190513717.png)

3)모두 next > Server Roles에서 IIS 선택

![image-20220329190554494](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329190554494.png)

4)install 클릭

![image-20220329190610716](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329190610716.png)

5)설치 완료 후 close 클릭

![image-20220329190634195](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329190634195.png)

6)EC2 > 보안그룹 > HTTP 80번 포트 열어줌

![image-20220329190713798](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329190713798.png)

7)인스턴스의 퍼블릭 ip4 주소로 접속

![image-20220329190731122](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329190731122.png)

![image-20220329190752043](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329190752043.png)