<h1>IP(Internet Protocol)</h1>



<h3>📌INDEX</h3>

- [IP의 이해](#ip의-이해)
- [IP 주소 체계](#ip-주소-체계)
-  [IP 주소](#ip-주소)
   -  [A 클래스](#a-클래스class)
   -  [B 클래스](#b-클래스class)
   -  [C 클래스](#c-클래스class)
   -  [IP 주소 각 클래스별 정리](#ip주소-각-클래스별-정리)

<br><br>

<h2>IP의 이해</h2>

- 네트워크에 접속되어 있는 각 컴퓨터에 **고유한 식별 번호**가 부여되어야 정확한 데이터 송수신이 가능함

- 인터넷에 연결되어 있는 모든 컴퓨터에게 고유의 주소를 부여하게 되는데 이를 **IP 주소(IP Address)**라고 함

- 8비트 크기의 필드 4개를 이용하여 구성한 **32비트(4바이트) 논리 주소**

- ×××.×××.×××.×××, 즉 163.152.19.114처럼 **.(점)으로 구분한 10진수 형태 네 개**로 구성된다. 

- 한 바이트가 가질 수 있는 10진수는 0~255이므로, IP주소의 값은 0.0.0.0에서 255.255.255.255까지이다.

  
<br><br>
<h2>IP 주소 체계</h2>

- IP주소는 **네트워크 주소(net id)**와 **호스트 주소(host id)**로 이루어져있다.
- IP주소는 **classful address**이다. (클래스로 구분)

<br>

<img src="https://user-images.githubusercontent.com/64996121/153587276-e6d4296d-b1df-4ef1-9824-8ed7a37bda82.PNG" width="550" height="120"/>



- 네트워크 주소
  - 전체 네트워크를 보다 작은 네트워크로 분할하여 각 호스트가 속한 네트워크를 대표하는 데 사용
  - 8비트, 16비트, 24비트의 크기로 분류
- 호스트 주소
  - 네트워크 주소로 표현되는 네트워크 내부에서 각 호스트의 주소를 표현
  - 전체 32 비트에서 네트워크 주소를 제외한 나머지에 해당


<br><br>
<h2>IP 주소</h2>

- IP주소의 효율적인 배정을 위하여 설계 시 **클래스**라는 개념을 도입 -> **classful **
- 클래스에는 A, B, C, D, E 다섯 가지 종류
  - D 클래스는 IP 멀티 캐스팅용
  - E 클래스는 자원 확보를 위한 예비용
  - 실제 사용하는 것은 A, B, C 클래스 3가지 종류 
  - 클래스는 IP주소의 맨처음 바이트의 시작 1비트가
    - 0으로 시작 : A클래스
    - 10으로 시작: B클래스
    - 110으로 시작: C클래스
    - 1110으로 시작: D클래스
    - 1111으로 시작: E클래스
- **모든 네트워크 구간**에서는 **항상 2개의 주소가 실제 사용가능 주소에서 제외**된다.
  - 네트워크 구간의 첫 주소: 네트워크 주소
  - 네트워크 구간의 마지막 주소: 브로드캐스팅 주소

- **A 클래스(class)**
  - **네트워크 주소로 8비트, 호스트 주소로 24비트** 사용
  - 가장 왼쪽 비트가 **'0'** => A클래스를 구분하는 식별자
  - 첫 번째 옥텟이 netid(7비트)
  - 첫 번째 바이트의 첫 비트가 0으로 시작, 맨 처음 숫자는 0~127로 시작
  - 범위:  0.0.0.0~127.255.255.255
  - 127.×.×.× : 시스템 루프백 주소(가상으로 할당한 인터넷 주소)라서 사용하지 않 음
  -  **실질적인 범위 : 1.0.0.0~126.255.255.255**
  -  2^7 = 128 중 126개 사용(2 개는 특수 목적에 사용)
  - 2^24 = 16,777,216 중 16,777,214 개의 호스트 사용(hostid가 모두 0인 것과 모 두 1인 것은 특별한 의미를 갖는 주소)

- **B 클래스(class)**

  - B 클래스를 구분하는 데 사용되는 식별자는 **'10'**으로 시작
  - **네트워크 주소에 16비트, 호스트 주소에 16비트**를 배정하는 클래스
  - IP 주소의 시작이 128~191로 시작하고, 기본 네트워크 마스크는 255.255.0.0
  - **범위:  128.0.0.0~191.255.0.0**
  - 호스트 주소는 2바이트로 호스트 65,534개 구성
  -  IP 주소가 128.1.1.1인 호스트는 128.1.0.0 네트워크에 속하며, 호스트 주소는 1.1이다.
  - 가장 왼쪽 2 비트가 “10”이며, 두개의 옥텟이 netid(14 비트)
  -  2^14 = 16,384개 사용 가능
  -  2^16 = 65,536개중 65,534개 호스트(라우터) 사용 가능(2개는 특별한 주소)

- **C 클래스(class)**

  - C클래스를 구분하는 데 사용되는 식별자는 **'110'**으로 시작
  - **네트워크 주소에 24비트, 호스트 주소에 8비트 사용**
    - 호스트를 최대 254개 사용 가능
  - IP 주소의 시작이 192~223으로 시작, 기본 네트워크 마스크는 255.255.255.0
  - **범위 : 192.0.0.0~223.255.255.0**
  - 200.100.100.100 => 200.100.100(netid) 100(hosted)
  - 2^21 = 2,097,152개의 네트워크를 가질 수 있음
  
<img src="https://user-images.githubusercontent.com/64996121/153588578-e3b015cb-5b96-4d66-8a59-7fd71368a104.PNG" width="500" height="350"/>

- D 클래스
  - D 클래스의 IP 주소 시작은 224 ~ 339 까지
  - 멀티캐스트 용도로 사용
- E 클래스
  - E 클래스의 IP 주소 시작은 240  ~ 255 까지
  - 미래를 위해 남겨놓은 주소
  - 255.255.255.255는 전체 컴퓨터에 대한 프로드 캐스트 주소로 사용
- **IP주소 각 클래스별 정리**

<img src="https://user-images.githubusercontent.com/64996121/153586658-11be46cc-8760-4ec3-9b80-cad6c7f9e171.PNG" style="zoom:80%;" />


- 사설 IP주소
  - IP 주소 중 인터넷에서 사용하지 않는 주소
  - IP 주소 부족을 해결하는 방안

- Class IP주소 예외
  - A class
    -  0.0.0.0 -> 모든IP를 의미한 주소 예약
    - 10.X.X.X -> 사설 IP로 예약
    -  127.X.X.X-> 로컬 루프백 IP로 예약
  - B class
    - 172.16.X.X ~ 172.31.X.X -> 사설 IP 예약
  - C class
    - 192.168.0.0 ~ 192.168.255.0 -> 사설 IP 예약
  - D class, E class
    - 255.255.255.255 -> Local BroadCast 주소
