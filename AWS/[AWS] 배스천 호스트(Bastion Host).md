<h2> [AWS] 배스천 호스트(Bastion Host)</h2>



<h3>📌INDEX</h3> 

- [배스천 호스트(Bastion Host)](#배스천-호스트bastion-host란)
- [AWS를 통해 Bastion Host 구현해보기](#aws를-통해-bastion-host-구현해보기) 

<br>

<br>

<h2>배스천 호스트(Bastion Host)란?</h2>

Bastion Host란 침입 차단 소프트웨어가 설치되어 **내부와 외부 네트워크 사이에서 일종의 게이트 역할을 수행하는 호스트**

- 내부 네트워크와 외부 네트워크 사이에 위치하는 게이트웨이
- 보안 대책의 일환으로 사용됨
- 내부 네트워크를 겨냥한 공격에 대해 방어하도록 설계됨
- Bastion Host는 접근 제어 기능과 더불어 게이트웨이로서 가상 서버(Proxy Server)의 설치, 인증, 로그 등을 담당
- 위험에 노출되는 경우가 많기 때문에, Bastion Host는 네트워크 보안상 가장 중요한 방화벽 호스트임

<br>

<br>

<h2>AWS를 통해 Bastion Host 구현해보기</h2>

- Putty, xshell 아닌 Windows Terminal에서 진행
- 리전 : 서울
- VPC
  - Public Subnet : Bastion Host
  - Private Subnet : Web Server
- 다이어그램 by [여기](https://app.diagrams.net/)

<img src="https://blog.kakaocdn.net/dn/IBdK0/btrysBUqX6i/HWGMO9oENSr4qyaZ7Dj1sk/img.png" alt="img" style="zoom: 25%;" />



**1) [VPC 생성 - VPC 마법사 사용]**

- 가용 영역(AZ) 1개

- 퍼블릭, 프라이빗 서브넷 각각 1개
- NAT 게이트웨이 없음(Bastion Host 설정만 확인하기 위함)
- 엔드포인트 없음



**2) Windows Terminal(Powershell)를 통해 개인키 생성**

- .ssh 하위에 id_rsa 및 id_rsa.pub 파일이 생성된 것을 확인할 수 있음

```shell
PS C:\Users\USER> ssh-keygen
PS C:\Users\USER> ls .ssh


    디렉터리: C:\Users\USER\.ssh


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        2022-04-05   오후 8:49           2610 id_rsa

-a----        2022-04-05   오후 8:49            575 id_rsa.pub

-a----        2022-04-05   오후 4:46           3135 known_hosts

-a----        2022-01-30   오후 3:26             95 known_hosts.old
```



**3) 생성한 키페어 가져오기**

- [키 페어] - [작업] - [키 페어 가져오기]



**4) 보안 그룹 생성**

- [보안 그룹] - [보안 그룹 생성]
- 외부 네트워크에서 Bastion Host로의 보안 그룹 1개
- Bastion Host에서 서버로의 보안 그룹 1개



**5) EC2 인스턴스 생성**(Bastion Host)

- Bastion Host
- Amazon Linux AMI 4.14
- t2.micro
- VPC 선택
- Public Subnet
- 기존 보안 그룹 : myssh_bastion_host



**6) EC2 인스턴스 생성**(Web Server)

- Web Server
- Amazon Linux AMI 4.14
- t2.micro
- VPC 선택
- Private Subnet

- 기존 보안 그룹 : from_bastion_to_server



**7) 접속 확인**

- Bastion Host 접속
  - AWS에서 키를 다운받아 사용할 때는 -i 옵션 사용

```shell
PS C:\Users\USER> ssh ec2-user@[Bastion Host 퍼블릭IP주소]
```

- Bastion Host에서 Web Server 접속 시도
  - 접속이 차단되는 것을 확인할 수 있음
  - 윈도우에는 키 파일이 있지만, Bastion Host 서버에는 키 파일이 없기 때문

```shell
[ec2-user@ip-10-0-0-107 ~]$ ssh ec2-user@[Web Server 프라이빗IP주소]
[ec2-user@ip-10-0-0-107 .ssh]$ ssh ec2-user@10.0.129.53
The authenticity of host '10.0.129.53 (10.0.129.53)' can't be established.
ECDSA key fingerprint is SHA256:m1tHdm1iyqBrTuL6a/0969RNtcuwBLmOQzT9zqbYHpY.
ECDSA key fingerprint is MD5:2f:4d:b4:1b:9c:25:19:5c:61:b3:28:98:95:0a:e9:2c.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '10.0.129.53' (ECDSA) to the list of known hosts.

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
```

- 키 파일을 Bastion Host에 복사 후 권한 변경

```shell
[ec2-user@ip-10-0-0-107 ~]$ cd .ssh/
[ec2-user@ip-10-0-0-107 .ssh]$ vi id_rsa
[ec2-user@ip-10-0-0-107 .ssh]$ chmod 400 id_rsa
```

- scp 명령을 통해서도 접속 가능

```ssh
PS C:\Users\USER> scp .\id_rsa ec2-user@[Bastion Host IP주소]:~/ssh/id_rsa
```

- **⭐점프 호스트⭐**
  - ssh 명령 시 -J 옵션을 사용하여 연달아 이동(점프)할 수 있다
  - 공유하는 키가 달라도, 첫 클라이언트에 2가지 키가 모두 있다면 점프 가능

```shell
PS C:\Users\USER> ssh -J ec2-user@[Bastion Host IP주소] ec2-user@[Web Server 프라이빗IP주소]
```



