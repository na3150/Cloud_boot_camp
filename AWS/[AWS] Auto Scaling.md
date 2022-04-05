<h1> [AWS] Amazon Auto Scaling </h1>



<h3>📌INDEX</h3> 

- [가용성(Availability)](#가용성availability)

- [Amazon Auto Scaling](#amazon-auto-scaling)
- [Auto Scaling과 Load Balancer 실습](#auto-scaling과-load-balancer-실습)

<br>

<br>

<h2>가용성(Availability)</h2>

가용성이란, **해당 시스템이나 서비스가 가동 및 실행되는 시간의 비율을 말함**

- 서버와 네트워크, 프로그램 등의 정보 시스템이 정상적으로 사용 가능한 정도
- 가동률이 높다는 것을 의미하며, 이러한 가용성은 보통 '9'로 측정
- 고가용성(High Availabiliy, HA) : 정보 시스템이 상당히 오랜 기간 동안 지속적으로 정상 운영이 가능한 성질

- 세븐 나인 : 99.99999의 가용성, 상징적인 의미, 절대로 장애가 일어나면 안되는 서비스들
- SLA(Service-Level Agreement) : [SLA Calculator](https://uptime.is/)

<br>

<br>

<h2>Amazon Auto Scaling</h2>

Amazon Web Services Auto Scaling은 **서버나 애플리케이션을 모니터링하고 리소스를 자동으로 조정(Scale In/Scale Out)하여, 최대한 저렴한 비용으로 안정적이고 예측 가능한 성능을 유지**

- 성능과 비용을 최적화하도록 애플리케이션 규모 조정
- 로드 밸런서는 단순히 연결시켜놓은 것이고, 스케일링은 이루어지지 않음
- **주요 특징**
  - Auto Scaling을 사용하여 애플리케이션 가용성을 간편하게 관리
  - 사용자가 정의한 조건에 따라 EC2 용량이 자동으로 확장/축소
  - 실행중인 EC2 인스턴스의 수를 원하는 수준으로 유지 가능
  - 수요가 급증할 경우 인스턴스의 수를 자동으로 증가(Scale In)
  - 수요가 적을 경우 자동으로 용량을 감소시켜 비용 낭비를 최소화(Scale Out)
- 프리 티어(Free Tier)
  - Auto Scaling의 사용을 무료이지만, AWS 리소스에 대한 비용과 CloudWatch 비용은 발생됨
- **Auto Scaling Group**
  - 인스턴스의 조정 및 관리 목적으로 구성된 논리적 그룹으로, Auto Scaling을 수행하는 인스턴스의 모음
  - 오토 스케일링 그룹을 사용하여 지정된 조건에 따라 자동으로 인스턴스의 수를 늘리거나, 비정상적으로 동작하는 경우 고정된 수의 인스턴스를 유지하거나, 비용 절감을 위해 인스턴스의 수를 자동으로 조정할 수 있음
- **시작 구성**
  - Auto Scaling 그룹에서 인스턴스를 시작하는 데 사용하는 템플릿
  - AMI,  인스턴스 유형, 키 페어, 하나 이상의 보안 그룹, EBS 등 인스턴스에 대한 정보를 지정
  - 시작 구성은 여러 개의 Auto Scaling 그룹에 지정될 수 있으나, Auto Scaling 그룹은 하나의 시작 구성만을 지정할 수 있음
  - 시작 구성은 한번 생성한 이후에는 수정/변경할 수 없음
    - 시작 구성을 변경하고자 한다면, 시작 구성을 새롭게 생성하여 Auto Scaling 그룹을 업데이트 해야함
- **시작 템플릿**
  - EC2 인스턴스 시작에 필요한 구성 정보를 모아둔 template
  - 시작 구성과 달리 버전 관리 가능
  - AMI, 인스턴스 유형, 키페어, 네트워크 플랫폼, 보안그룹 등에 대한 정보를 지정

- **Auto Scaling 그룹 조정**
  - 인스턴스의 수를 늘리거나 줄이는 기능
  - 조정 작업은 이벤트와 함께 시작되거나, Auto Scaling 글부의 인스턴스를 시작하거나 종료하도록 수행하는 조정 작업과 함께 수행됨
  - 인스턴스의 조정 옵션
    - 현재 인스턴스 수준 유지 관리: 최소 또는 항상 지정된 수의 인스턴스를 실행 유지 관리하도록 구성
    - 수동 조정: Auto Scaling 그룹에서 최소, 최대 또는 원하는 용량의 변경 사항을 조정 변경
    - 일정을 기반으로 조정: 예측 가능한 일정에 따라 수요가 증가하거나 감소하는 경우, 일정에 따른 확장 및 축소 작업을 시간 및 날짜 함수를 통해 자동으로 수행되도록 구성할 수 있음
    - **온디맨드 기반 조정**: 리소스를 조정하는 가장 효과적인 방법으로, 인스턴스의 CPU 사용률이 15분 동안 90% 유지될 때마다 인스턴스를 확장하도록 구성하는 정책을 생성할 수 있음
      - **변화하는 조건에 따라 효과적으로 자원의 조정**을 가능하게함
      - CPU, 메모리 사용량, 네트워크의 대역폭이 **일정 수준 이상인 경우 새로운 인스턴스를 시작**하고, 네트워크 대역폭이 **다시 내려가면 인스턴스를 종료**하는 정책을 수립하여 적용가능
      - 이러한 모니터링 기반의 조정은 2개의(확장/축소) 정책을 통해 작업을 수행

- 공식 문서: [Auto Scaling이란?](https://docs.aws.amazon.com/ko_kr/ko_kr/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html)

<br>

<br>

<h2>Auto Scaling과 Load Balancer 실습</h2>

- AWS Auto Scaling을 이용한 자동화 구현
- 리전(Region) : 서울(Seoul)



**1) AMI 이미지를 위한 EC2 인스턴스 생성**

- [EC2] - [인스턴스 시작]
- AWS Linux 4.14
- [인스턴스 세부 정보 구성] - [사용자 데이터]
  - 사용자 데이터 이외에 default로 설정 : 이미지 생성용이기 때문에 기본 설정으로 진행
  - 사용자 데이터(user-data)는 sudo 안붙여도 됨
    - cloud-init이  root로 실행함
  - /var/lib/cloud/instance/user-data.txt 에 저장됨
  - `#!` : (shebang) 방법을 지정해주는 것. 어떤 인터프리터(runtime)로 실행할 지 알려주는 것

```shell
#!/bin/sh
yum install -y httpd
systemctl start httpd
systemctl enable httpd
HOSTNAME=`hostname`
echo "<h1> ${HOSTNAME} </h1>" > /var/www/html/index.html
```
![0](https://user-images.githubusercontent.com/64996121/161803969-e44a1d41-fdd2-4009-8b62-93180da447c8.png)



- 새 보안 그룹 생성
  - 이미지 생성용이므로, 보안 그룹은 SSH만 열어줌


![1](https://user-images.githubusercontent.com/64996121/161804027-e6221617-c5f8-4c14-83d7-f3bc982820d1.png)


- 기존 키 페어 사용
  - [Bastion Host 실습](https://nayoungs.tistory.com/113)에서 생성한 키 사용


![2](https://user-images.githubusercontent.com/64996121/161804099-59dbf6ce-2810-43aa-a453-cd538703b6a2.png)




**2) 참고: 생성한 인스턴스에 접속해보자**

- Windows Terminal로 접속

```shell
PS C:\Users\USER> ssh ec2-user@3.36.119.163
The authenticity of host '3.36.119.163 (3.36.119.163)' can't be established.
ECDSA key fingerprint is SHA256:3QUtUlF15ZPS7DcK3c4d6kf4NpyCKAOz3KM79uLpNE8.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '3.36.119.163' (ECDSA) to the list of known hosts.

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
```

- fingerprint : 지문,  키를 `SHA256` 해시 알고리즘의  결과가 맞는지 확인 
  - `.ssh\known_hosts` 에 지문 남음, 말 그대로 알고있는 호스트 
  - yes하고 나면 known_hosts에 등록되고, 다음에 같은 곳에 접속할 때 fingerprint 남길건지 안물어봄

- 사용자 데이터(user-data) 확인해보기

```shell
[ec2-user@ip-172-31-0-125 ~]$ sudo cat /var/lib/cloud/instance/user-data.txt
#!/bin/sh
yum install -y httpd
systemctl start httpd
systemctl enable httpd
HOSTNAME=`hostname`
echo "<h1> ${HOSTNAME} </h1>" > /var/www/html/index.html
```



**3) 이미지 생성**

- 이름과 설명 지정 후 [이미지 생성]

- 이미지 생성 후 EC2 는 종료할 것

![3](https://user-images.githubusercontent.com/64996121/161804187-9e143c41-c8fe-4171-a647-e9535f5ea540.png)
![4](https://user-images.githubusercontent.com/64996121/161804307-f86377a2-3646-4fb9-9768-9cb11dfcb210.png)



**4) 시작 템플릿 생성**

![5](https://user-images.githubusercontent.com/64996121/161804346-f554daa9-4d3e-42fa-9200-c43264b53963.png)

- 이름 및 설명, Auto Scaling 체크

![6](https://user-images.githubusercontent.com/64996121/161804366-4d8a0d6f-341f-41d7-8d1f-12f841f4d65a.png)


- [내 AMI] - [myweb] 
  - 좀 전에 생성한 AMI 선택

![7](https://user-images.githubusercontent.com/64996121/161804390-d59ba424-204f-4360-9559-cf429faecfe6.png)


- 프리티어 t2.micro 선택 및 기존 키 페어 선택

![8](https://user-images.githubusercontent.com/64996121/161804432-c0375bf1-06c8-42df-8353-69f49473421c.png)


- 보안 그룹 생성
  - `HTTP`, `SSH`
  - 원본주소는 어디서든지 접속 가능

![9](https://user-images.githubusercontent.com/64996121/161804447-64dfa561-86f4-4e9d-901b-2ddefd8fcd2d.png)


**5) Auto Scaling 그룹 생성**

![10](https://user-images.githubusercontent.com/64996121/161804704-43b1e99c-3aa5-46ba-9931-95843a402bb2.png)

- Auto Scaling 이름 및 시작 템플릿 지정(좀 전에 만든 템플릿)

![11](https://user-images.githubusercontent.com/64996121/161804736-a2c0dcf5-2812-43ec-aa80-81c777a50ec7.png)


- VPC(default 선택) 및 가용영역, 서브넷 선택
  - 스케일링을 어디까지 할 것인지 정하는 것
  - 가용성에 영향주는 요소
  - 여기서는 4개 모두 선택

![Inked12_LI](https://user-images.githubusercontent.com/64996121/161804926-48ad8315-fa02-4d8d-81bd-e0b14bd144c4.jpg)


- 새 로드 밸런서에 연결(생성)
  - 웹이기 때문에 `Application Load Balancer`
  - 로드 밸런서 체계 : `Internet-facing`
    - Internal : 외부에 노출되지 않는 로드밸런서
    - Internet-facing : 인터넷 연결용, 인터넷에 연결되어있는
  - 대상 그룹 생성 : 일반적으로 로드 밸런서의 백엔드
  - CloudWatch를 통해 모니터링하는 것이 좋음

![13](https://user-images.githubusercontent.com/64996121/161804988-66add60b-70e0-421e-8dae-1cf315124443.png)
![14](https://user-images.githubusercontent.com/64996121/161805048-60c1a541-a906-4c02-8777-921e409d900c.png)
![15](https://user-images.githubusercontent.com/64996121/161805072-5dd443df-371e-415a-bf8f-c1e3f1ddd15a.png)


- 그룹 크기 선택
  - 원하는 용량(desire)는 일반적으로 최소용량과 최대용량의 중간값 또는 최솟값
  - 최소 용량 : Scale-In 
  - 최대 용량 : Scale-Up

![16](https://user-images.githubusercontent.com/64996121/161805098-be3e0fc1-7b00-42f1-91d5-d4fb7809199a.png)


- 조정 정책
  - `동적 조정`은 조건에 따라 자동으로 스케일링 되는 것이고, `없음`은 사용자가 수동으로 스케일링
    - 동적 세팅이 일반적
  - 대상값 : threshold
    - 여기서는 지표가 CPU, 대상값이 50으로 '`CPU의 평균 사용률이 50%를 넘어가면`'을 의미 
    - 일반적으로 50~70으로 지정
  - 인스턴스 요구 사항 
    - 대상값에 도달했을 때 바로 스케일링 할 것인지, 워밍업(유예시간)을 둘 것인지
    - 여기에서 300으로 지정하면, '`300초 동안 CPU평균 사용률이 50%를 넘어가면`' , '`300초 동안 CPU 평균 사용률이 50%이상을 유지하면`' 스케일링(조정) 함
    - 0으로 지정하면 50%를 넘어가는 순간 바로 스케일링(인스턴스 중지)
    - 워밍업 시간이 낮을 수록 좋아 보일 수 있으나, 스케일링이 반복적으로 일어나서  오히려 성능이 저하될 수 있으므로, 어느정도 워밍업 시간을 주는 것이 좋음

![17](https://user-images.githubusercontent.com/64996121/161805136-63cd0ce8-79d6-49a6-ac4c-2e78febff31b.png)


- 알림 설정은 하지 않음
- [Auto Scaling 그룹 생성]



**6) 생성 결과 확인**

- Auto Scaling 그룹, 로드밸런서, 대상 그룹, 인스턴스 등이 생성된 것을 확인할 수 있음

![18](https://user-images.githubusercontent.com/64996121/161805219-365245f0-12d4-4b09-87bd-62e60174bfb0.png)
![19](https://user-images.githubusercontent.com/64996121/161805249-54e0db93-645e-42cb-86e6-2224d6247c59.png)
![Inked20_LI](https://user-images.githubusercontent.com/64996121/161805432-1f147d6e-0876-4523-9a07-06be0d9d214b.jpg)


**7) 오토 스케일링 작동확인을 위해 인스턴스에 부하 주기**

- Windows 터미널에서 인스턴스 접속 

```shell
PS C:\Users\USER> ssh ec2-user@[인스턴스 IP주소]
```
- 현재 CPU 사용률이 매우 낮음 

![21](https://user-images.githubusercontent.com/64996121/161805849-69b7e807-3386-4de8-8cab-5d51f710206d.png)


- 스케일링 작동을 확인하기 위해 부하 주기

```shell
[ec2-user@ip-172-31-0-125 ~]$ sha256sum /dev/zero
```

![22](https://user-images.githubusercontent.com/64996121/161806308-6d6b287d-5a91-4bed-bd1c-e70ac0106d30.png)


- 인스턴스의 개수가 자동으로 늘어났으면 성공!
- 시간이 지난 후에도 CPU 사용률이 일정 수준이상을 유지해서 인스턴스가 1개 더 생성되는 것을 확인할 수 있음
