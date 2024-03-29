<h1>TCP/IP</h1>

<h3>📌INDEX</h3>

- [TCP/IP 정의](#tcpip-정의)
-  [TCP/IP 특징](#tcpip-특징)
-  [RFC](#rfc)
-  [TCP/IP 모델](#tcpip-모델)
- - [응용 계층](#응용-계층application-layer)
  - [전송 계층](#전송-계층transport-layer)
  - [네트워크 계층](#네트워크-계층인터넷-계층)
  - [네트워크 접속 계층](#네트워크-접속-계층physicaldata-link-layer)
  - [프로토콜](#프로토콜)



<br>

<h2>TCP/IP 정의</h2>

- **네트워크와 네트워크를 연결하는 데 사용하는 프로토콜**
- 전송 제어 프로토콜(TCP: Transmission Control Protocol)과 인터넷 프로토콜(Internet Protocol)을 의미
- 인터넷에서 사용하는 응용 프로그램은 대부분 이 TCP/IP 프로토콜을 이용하여 데이터를 교환
<br>


<h2>TCP/IP 특징</h2>

- 오픈(OPEN) 되어있다.

​         - TCP/IP의 프로토콜은 표준안 회의(ITEF)에서 결정되는데 IETF에는 누구나 참여가능

- TCP/IP에서는 프로토콜의 사양보다 실제 작동되는 프로토콜인지를 중시

​          - TCP/IP에서는 사양이 어느정도 결정되면 직접 프로토콜이 작동되는지 테스트함(에러 발생시 도큐먼트 수정반복)

​           - TCP/IP 프로토콜은 위와같이 실제 작동되는지를 중시하여 사양이 정해지고 있으며, 따라서 안정성과 실용성이 타 프로토콜보다 높음


<br>
<h2>RFC</h2>

- TCP/IP의 프로토콜은 IETF회의에 의해 표준화
- 표준화하려고 하는 프로토콜은 RFC(Request For Comments)라는 도큐멘트로 인터넷에 올려짐
- RFC의 구성은 FYI(사양서, 작동/운영정보 등)
- RFC는 수정이 불가능하고 갱신하려면 새로운 RFC 번호를 부여햐여 갱신해야함
- 갱신 시, RFC번호가 바뀌기 때문에 위를 묶기 위해 STD라는 번호를 부여 가능
- 표준으로 등록된 프로토콜은 RFC, Draft 단계를 거치며 이미 많은 운용실적을 가졌기 때문에 **실용성이 높은 기술이다. (TCP/IP의 장점)**




<br>
<h2>TCP/IP 모델</h2>

- **TCP/IP모델은 4개의 계층으로 구성**
- 하위 계층 3개는 OSI 참조 모델의 하위 4계층(물리 계층, 데이터 링크 계층, 네트워크 계층, 전송 계층)과 일치
- TCP/IP 모델의 응용 계층에서는 OSI 참조 모델의 최상위 3계층(세션 계층, 표현 계층, 응용 계층)의 역할을 담당
- **TCP/IP 프로토콜 구조 : *네트워크 접속 계층, 인터넷 계층, 전송 계층, 응용 계층*으로 구분**

![TCPIP프로토콜 구조](https://user-images.githubusercontent.com/64996121/153196072-d37caced-7aa2-4220-9c6f-a2c5079ebbc3.PNG)


<br>
<h3>응용 계층(Application Layer)</h3>

- TCP/IP 프로토콜의 범위는 응용 계층의 프로토콜까지 포함
- 해당되는 프로토콜과 서비스에는 Telnet, FTP(File Transfer Protocol), SMTP(Simple Network Transfer Protocol), SSH 등
- 인터넷 메일 프로그램이나 웹 브라우저 등이 사용자가 직접 사용하는 TCP/IP의 프로토콜을 이용한 응용 프로그램들로 응용 계층 분류
- 응용 프로그램들로 제공되는 서비스는 **표현 계층과 세션 계층에서 정의**

![응용계층](https://user-images.githubusercontent.com/64996121/153196119-2498b068-d1df-4c87-8ea3-fbe06375a164.PNG)


- 응용 계층에서는 **네트워크 접근 수단을 제공**한다.


<br>
<h3>전송 계층(Transport Layer)</h3>

- 상위 계층에서 볼 때, 두 개의 호스트간의 자료 전송을 담당하는 계층 (서비스와 관련)
- **TCP, UDP** 두 종류의 프로토콜이 사용
- 네트워크 양단의 송수신 호스트 사이에서 **신뢰성 있는 전송 기능 제공**
- OSI 모델에서 **세션 계층의 일부 기능(해당 연결에 대한 시작·유지·종료)**과 **전송 계층에 해당**

- **TCP(Transmission Control Protocol: 전송 제어 프로토콜)는** 송신지에서 수신지까지 문자 스트림을 전송하는데, 두 응용 계층이 서로 대화하는 것을 허용하는 **신뢰성 있는 프로토콜**
- - 신뢰성이 있는 만큼 헤더의 오류코드에 대응할 수 있는 각종 정보가 들어있음
  - 패킷에 시퀀스 번호를 부여하여 순서가 올바르도록 관리

- **UDP(User Datagram Protocol: 사용자 데이터그램(커넥션리스형) 프로토콜)**는 OSI 참조모델에서 정의하는 전송계층의 일부 역할을 무시(ex. ACK 패킷 확인 X)하는 단순한 전송 프로토콜
- - UDP는 TCP에 비해 **신뢰성이 낮으며, 흐름 제어 및 오류 검출 등의 기능이 없어** **패킷을 빠르게 전송**해야하는 응용 계층에서 사용

- 전송 계층에서는 송신지에서 수신지까지 메시지 전송 기능을 제공한다.

![네트워크 계층](https://user-images.githubusercontent.com/64996121/153196144-310c315c-93df-4e38-87f5-a5c6b076c66c.PNG)

<br>
<h3>네트워크 계층(인터넷 계층)</h3>

- TCP/IP 모델의 인터넷 계층은 OSI 참조 모델의 네트워크 계층과 비슷하여 '네트워크 계층' 이라고도 함
- 인터넷 계층은 몇 가지 프로토콜을 포함하는데, 가장 중요한 프로토콜인 IP(Internet Protocol: 인터넷 프로토콜)는 **IP 데이터그램이라는 패킷을 만들고, 수신지에 해당 패킷을 전송**



- 기본 기능: **송수신 호스트 사이의 패킷 전달 경로를 선택**
- 네트워크 계층의 주요 기능: **라우팅, 혼잡 제어, 패킷의 분할과 병합**
- **라우팅 **
- - **라우팅 테이블: 네트워크 구성 형태에 관한 정보를 관리**
  - **라우팅: 송수신 호스트 사이의 패킷 전달 경로를 선택**하는 과정


<br>
<h3>네트워크 접속 계층(Physical&Data link Layer)</h3>

- TCP/IP 모델은 대부분 하나의 네트워크나 다른 네트워크의 송신지에서 수신지까지 데이터를 주고받는데, 물리 계층과 데이터 링크 계층에서 하는 일은 **LAN과 WAN을 연결하여 인터넷을 구성**하는 것

- 데이터링크 계층(흐름제어, 오류제어), 물리 계층(물리적 링크의 설정, 유지, 해제 담당)

- 운영체제의 네트워크 카드와 디바이스 드라이버 등과 같이 **하드웨어적인 요소와 관련되는 모든 것을 지원**하는 계층

- **송신측**: 상위 계층으로부터 전달받은 패킷에 물리적 주소인 **MAC 주소 정보를 가지고 있는 헤더를 추가**하여 **프레임 생성, 프레임을 물리 계층으로 전달**

- **수신측**: 데이터 링크 계층에서 **추가된 헤더를 제거하여 상위 계층인 네트워크 계층으로 전달**

- 프레임의 크기는 네트워크 토폴로지에 의해 결정

- - <h6>*네트워크 토폴로지:  컴퓨터 네트워크의 요소들(노트,링크 등)을 물리적으로 연결해 놓은 것, 또는 그 연결 방식</h6>


<br>
<h3>프로토콜</h3>

- TCP/IP 계층 구조

![tcpip 계층구조](https://user-images.githubusercontent.com/64996121/153196167-5cc0d901-cfa9-45fb-bf6e-3e6e1145a6dc.PNG)

- **TCP/UDP**: 사용자 데이터를 전송하는 전송 계층 프로토콜
- **IP**: 사용자 데이터를 전송하는 네트워크 계층 프로토콜
- ARP와 RARP 
- - **ARP: IP주소를 MAC 주소로 변환**
    -  보내기 전에 ARP에게 물어보고 ARP에게 답장받으면 받은 IP주소로 패킷 전송
  - RARP: MAC 주소를 IP주소로 변환
- **ICMP**
- - 오류 메시지를 전송하는 프로토콜
  - IP 프로토콜에 캡슐화되어 전송됨

   
