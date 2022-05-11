

### ✔️ VPC 마법사를 통해 Public Subnet과 Private Subnet 만들기



- - **Amazon VPC(Virtual Private Cloud)를 구성하고 퍼블릿 서브넷과 프라이빗 서브넷을 생성하여 NAT 게이트웨이를 통해 프라이빗 인스턴스가 인터넷에 연결**되도록 실습을 진행할 예정
  - Amazon VPC는 비용이 발생하지 않으나, VPC 외부로 데이터를 송신하는 경우 사용량에 비례하여 Outbound 트래픽에 대한 비용이 발생할 수 있음

 

**1) [로그인] - [VPC 페이지 접속]**

- 글쓴이는 리전(Region)을 임의로 '**시드니**' 선택

 

 

**2) NAT 게이트웨이에 사용할 탄력적 IP 할당을 위해 [탄력적 IP]로 이동하여 [탄력적 IP 주소 할당] 버튼을 클릭**



![img](https://blog.kakaocdn.net/dn/b9lVdX/btryccmyrQA/4MlZlFxNi3GkSkjKmMkiA0/img.png)



 

**3) [탄력적 IP 주소 할당] 페이지에서 [할당] 버튼 클릭**



![img](https://blog.kakaocdn.net/dn/coCGWl/btrycCd4g9S/B3T26KPmUJhE5HRAyVFcwK/img.png)



 

**4) 탄력적 IP 생성된 것 확인**

- 탄력적 IP가 연결은 아직 안되어있음



![img](https://blog.kakaocdn.net/dn/PNUmm/btrx9AIXDQ0/okAQMygjmTVbhK5Jtovbik/img.jpg)



 

 

**5) [VPC 대시보드] - [VPC 마법사 시작]**

- 현재는 VPC 1개
- 가용 영역(AZ) 만큼의 서브넷(Subnet)이 있음



![img](https://blog.kakaocdn.net/dn/m2Hei/btrycxqsKJi/LqLZk7JkviPPl1czFo4XH0/img.png)



 

**6) 이름 태그 생성 - 가용 영역(AZ) 1개 - 퍼블릭, 프라이빗 서브넷 수 각각 1개(prefix : /24)**

- 리전(Region)별로 각각 public 1개, private 1개가 생성됨
- AZ 사용자 지정 옵션 : 원하는 가용영역을 선택할 수 있음 ex) ap-southeast-2a, ap-southeast-2b, ap-southeast-2c
- 여기서는 가용영역 a 선택(default)



![img](https://blog.kakaocdn.net/dn/bimOHQ/btrycPj6WA3/qkao05yuOnGTl9lXKcsLSK/img.png)

![img](https://blog.kakaocdn.net/dn/0MajE/btrx7nC02v2/N5LoOQH5ZD3WB9SLxXTT5K/img.png)



 

 

**7) \**NAT 게이트웨이 1개 - DNS\** 호스트 이름 활성화 - VPC 생성**

- private 서브넷이 1개이므로 NAT 게이트웨이 1개 (인터넷이 여러개이고, 더 빠르게 하기 위해서 'AZ당 1개'를 선택하는 경우도 있음)
- 인터넷게이트웨이(IGW)는 안에서 밖으로, 밖에서 안으로 들어오는 것이 모두 가능하지만, **NAT는 안에서 밖으로 나가는 것만 가능**
- DNS 호스트 이름을 활성화하면 호스트 이름을 IP 주소와 비슷하게 사용할 수 있음



![img](https://blog.kakaocdn.net/dn/buASVP/btrx6Nu72gZ/lIBD77Xicru1NQ5ITLQLd0/img.png)

![img](https://blog.kakaocdn.net/dn/bBPP30/btryan3G48Y/m240DmuVQf93q7KuTnoJ3K/img.png)



 

 

**8) 편의를 위해 탭 1개 더 생성 - [VPC 대시보드]**

- VPC 1개가 늘어난 것을 확인할 수 있음 : + myvpc1
- 서브넷 2개가 늘어난 것을 확인할 수 있음 : +public subnet + private subnet



![img](https://blog.kakaocdn.net/dn/c3ExQf/btryaH1UGaz/D0k2qfm2SPo5kQtesC4lq0/img.png)



 

 

**9) public, private 서브넷의 라우팅 테이블 확인해보기**

 

**- public subnet routing table**



![img](https://blog.kakaocdn.net/dn/vn0V4/btryaH1Vd6h/aTbRYg8ckDZWgc7bS3Uvck/img.jpg)



- **VPC(myvpc1)과 인터넷 게이트웨이(igw)**가 들어있음

 

**- private subnet routing table**

 



![img](https://blog.kakaocdn.net/dn/bwl5rP/btryamjrD9D/3kV7KZgdtrzO2GjORMx3DK/img.jpg)



- private subnet은 인터넷 게이트웨이가 아닌 **nat 게이트웨이로 연결**되어있음



![img](https://blog.kakaocdn.net/dn/d19pdJ/btrybFpi7P7/vCURMKWDDDSZbi0EDnDiSk/img.jpg)



- **nat 게이트웨이에는 이전에 생성한 탄력적 ip가 할당**되어있는 것을 확인할 수 있음

 

 

**10) VPC 에 private subnet과 public subnet 만들기 완료**

- 현상황을 그림으로 표현하자면 아래와 같다고 볼 수 있다
- (NAT 게이트웨이의 원활한 표현을 위해 프라이빗 서브넷에 인스턴스 있다고 가정하고 표현함)



![img](https://blog.kakaocdn.net/dn/bQfzFu/btrx74DlShz/cs8YED3fELhnFKWjPwmUHK/img.png)



 

 

 

 

### ✔️ VPC 삭제하기



- VPC를 삭제할 때는 **순서가 중요**하다
- 주의: 이름 없는 것들은 default로, 건들면 안됨
- 먼저 순서를 확인해보자

**1) Private Subnet 삭제 과정**

1-1) 인스턴스(instance)삭제 (인스턴스가 있는 경우)**
**

1-2) NAT gateway 삭제 : deleting -> deleted

1-3) 탄력적 IP 주소 릴리즈 : 반환해주지 않으면 시간 당 비용 발생

1-4) 서브넷(subnet) 삭제

1-5) 라우팅 테이블(routing table) 삭제

1-6) 엔드 포인트(endpoint) 삭제

 

**2) Public Subnet 삭제 과정**

2-1) 인스턴스(instance)삭제

2-2) 인터넷 게이트웨이(igw) 분리

2-3) 인터넷 게이트웨이(igw) 삭제

2-4) 서브넷(subnet) 삭제

2-5) 라우팅 테이블(routing table) 삭제

 

**3) VPC 삭제**

 

- 무작정 VPC를 삭제하는 것은 아래에서 확인할 수 있듯이 불가능하다



![img](https://blog.kakaocdn.net/dn/HgGxh/btrycxjX2v1/CdCu3r0c01u5v7SNkTbsKk/img.jpg)



 

- **먼저 NAT 게이트웨이를 삭제하자**



![img](https://blog.kakaocdn.net/dn/3K89U/btrx9AiblIo/4EmtgStNosS719ASkDNzHk/img.jpg)



 

- **탄력적 IP 주소 릴리즈** 



![img](https://blog.kakaocdn.net/dn/mBmEh/btrydfJVQGJ/VxTnBeBhWONvZAdU3FXMbk/img.jpg)



 

- **서브넷 삭제(public과 private 함께 삭제함)**



![img](https://blog.kakaocdn.net/dn/bJzK5I/btryaHnDYZX/qMJ740ppklRDb1tOdruKKK/img.jpg)



 

- **라우팅 테이블 삭제(public과 private 함께 삭제함)**



![img](https://blog.kakaocdn.net/dn/FAvZi/btrx9B9eZp7/t1Q2ert76VStIkr5NytFhK/img.jpg)



 

- **엔트 포인트 삭제**



![img](https://blog.kakaocdn.net/dn/6Dhpu/btrycdeZSH0/tmPXNHQBkKeSpnaWYHxc2k/img.jpg)



 

- **게이트 웨이를 VPC에서 분리 및 삭제**



![img](https://blog.kakaocdn.net/dn/BvjoS/btrycwMbcfn/aooAgNQjkDhtaJIfDdJis1/img.jpg)

![img](https://blog.kakaocdn.net/dn/bMxkxI/btrydga4GPU/RX9SSKpX6jM0yuTrz9Ok2k/img.jpg)



 

- **VPC 삭제**



![img](https://blog.kakaocdn.net/dn/beKX4J/btrycPEHx5E/3p1HtxLyXPQXVwOile26H0/img.jpg)



 

 

 

 

### ✔️ 수동으로 Public Subnet, Private Subnet 생성하기



👉 VPC 마법사를 통해서가 아닌 **수동으로 생성**하는 것도 가능

- VPC에서 하나의 가용 영역안에 public 서브넷과 private 서브넷 생성하기
- public 서브넷에 EC2 Linux 인스턴스

 

\1) VPC 생성

\2) public과 private 서브넷 생성

\3) public 라우팅 테이블 생성 : 생성된 VPC와 연결

\4) 인터넷 게이트웨이 생성 : public 용

\5) 게이트웨이를 VPC에 연결

\6) VPC의 라우팅 테이블(기본 라우팅 테이블) 편집 : '0.0.0.0/0' 인터넷 게이트웨이 목적지 추가

\7) 퍼블릭 라우팅 테이블 편집 : '0.0.0.0/0' 인터넷 게이트웨이 목적지 추가

\8) 퍼블릭 서브넷 라우팅 테이블 연결 편집 -> 퍼블릭 라우팅 테이블 연결

\9) 퍼블릭 서브넷에 인스턴스 생성

- Linux AMI 선택
- '퍼블릭 IP 자동 할당' 옵션 활성화
- 보안 그룹 구성 : SSH(나의 IP주소), ICMP(VPC IP주소), TCP(0.0.0.0/0) 
- 키 생성 : 외부에서 게이트웨이로 접속할 때 사용, public 서브넷에서 private 서브넷에 접속할 때 사용

\10) 외부에서의 접속 테스트

- xshell : 다운받은 key를 통해 연결
- httpd 서비스 사용(보안 그룹에 80번 포트 등록해두었어야함)

```shell
# sudo yum install -y httpd
# sudo systemctl start httpd
# sudo systemctl enable httpd
# echo "TEST PAGE" > index.html
# sudo cp index.html /var/www/html
```

- 인스턴스의 퍼블릭 IP 주소로 브라우저 접속 : TEST PAGE 나오면 성공

\11) 프라이빗 라우팅 테이블 생성

- 생성된 VPC 연결

\12) NAT 게이트웨이 생성 : private 용

- private 서브넷에 연결
- 연결 유형 : 퍼블릭 -> NAT게이트웨이는 퍼블릭에 있어야 외부 인터넷과 통신 가능
- 탄력적 IP 할당 -> 탄력적 IP 먼저 생성하고 NAT 게이트웨이 생성해도 OK
- NAT게이트웨이를 통해서 밖에서 내부에 못들어오게 하고, 내부에서는 밖에 나갈 수 있도록 하기 위해 사용

\13) 프라이빗 라우팅 테이블 편집

- 디폴트(default) 라우트(0.0.0.0/0) -> NAT 게이트웨이 

\14) 프라이빗 서브넷 라우팅 테이블 연결 편집 -> 프라이빗 라우팅 테이블 연결

\15) 라우팅 테이블의 서브넷 연결 편집(명시적 연결)

- private은 private과 public은 public과 연결

\16) 프라이빗 서브넷에 인스턴스 생성

- Linux AMI 선택
- 네트워크: 생성한 VPC와 연결
- private 서브넷 연결
- 퍼블릭 IP 자동할당 "비활성화"(default) : 프라이빗 서브넷에 위치시킬 것으로, 외부에서 접속 불가능해야하기 때문에 퍼블릭 IP를 받으면(할당하면) 안됨
- 보안그룹 : SSH(퍼블릭 서브넷 IP(10.0.0.0/24): 퍼블릭에서 접근할 것이므로), ICMP(10.0.0.0/16 : ping 테스트용), HTTP(80번 포트 10.0.0.0/24 : 웹 테스트할 경우)  
- 퍼블릿 서브넷의 인스턴스를 생성할 때 생성한 키 사용(기존의 키 사용)

\17) 접속 테스트

- xshell 사용 : 기존의 key를 통해 연결
- 퍼블릭 인스턴스의 퍼블릭 IP로 접속
- 기존의 key를 메모장(text파일)로 열어서 전체 복사 Ctrl+C
- .ssh/ 하위에 key 파일 생성 후 붙여넣기 후 저장 (확장자가 꼭 .pem 일 필요는 X , 그냥 key여도 가능)

```shell
# vim .ssh/key.pem
```

 

- 권한 변경(기존: 664) -> 관리자(나)만 볼 수 있도록 400

```shell
# chmod 400 .ssh/key.pem
```

 

- ssh로 프라이빗 인스턴스에 접속 : 접속되면 성공

```shell
# ssh -i ssh/key.pem ec2-user@[프라이빗 서브넷의 프라이빗 IP 주소]
```

 

\18) 수동 생성 완료!

- 현 상황과 외부접속테스트(SSH, 동일한 KEY) 까지 표시해보면 다음과 같이 볼 수 있을 것 같다

 



![img](https://blog.kakaocdn.net/dn/DldkL/btrybWL8VVF/JtGC0pEpnhiEyrMJ05awek/img.png)



 

 

 