<h1> [Linux] 리눅스 방화벽 : firewalld</h2>



<h3>📌INDEX</h3>

- [리눅스 방화벽이란?](#리눅스-방화벽이란)
-  [zone](#zone)
-  [firewalld](#firewalld)
-  

<br>

<br>

<br>

<h2>리눅스 방화벽이란?</h2>

- 리눅스 방화벽(firewall)이란 **외부에서 시스템으로 접근하는 패킷을 차단하는 서비스**이다
- 규칙을 이용하여 접근을 허용하거나 차단할 수 있다

- 방화벽(firewall)은 일반적으로 신뢰할 수 있는 내부 네트워크, 신뢰할 수 없는 외부 네트워크 간의 장벽을 구성

- 서로 다른 네트워크를 지나는 데이터를 허용/거부하거나 검열/수정하는 하는 하드웨어 또는 소프트웨어 장치라고 할 수 있다
- iptables의 단점을 보완하기 위해 도입되었다
  - iptables : Netfilter 제어하는 도구를 사용하며, 설정을 변경하면 재시작해야한다는 단점이 존재 (Centos 7이전)
  - **firewall은 동적으로 방화벽 설정 변경**이 가능하다
    - Runtime : 시스템 운영중인 상태일 때 반영(실시간으로 변경)
    - Permanent : 서비스가 재시작 되었을 때도 반영(영구 설정), XML 파일

```shell
Netfilter(Kernel)      <- iptables(명령)          <- iptables(service)
                       <- firewall(service)      <- firewall-cmd
                                                 <- firewall-config
```

<br>

<br>

<h2>Zone</h2>

- zone이란, **사용자가 요구하는 정책 허용·특정 허용·거부·특정 거부 등에 맞게 그룹으로 관리되며, 처음 설정 시 기본적으로 내장되어있는 정책**이다

- zone 설정 디렉토리 : /usr/lib/firewalld/zones/

- 폐기(drop)과 거절(reject)의 차이

  - 폐기(drop) : 패킷을 받으면 응답없이 버린다
  - 거절(reject) : 패킷을 받으면 거부한다라는 ICMP 패킷을 보내준다

- **pre-defined zone(zone의 종류)**

  - 나가는 패킷 모두 허용함

  - block  : 들어오는 모든 패킷 거부
  - dmz : SSH를 제외하고 들어오는 모든 패킷 거부(reject)
  - drop : 들어오는 모든 패킷 폐기(drop), ICMP 에러도 폐기(drop)
  - external : SSH를 제외하고 들어오는 모든 패킷 거부(reject)
  - internal : SSH, dhcpv6-cilent, ipp-client, mdns, samba-client를 제외하고 들어오는 모든 패킷 거부(reject)
  - home : SSH, dhcpv6-client, ipp-client, mdns, samba-client를 제외하고 들어오는 모든 패킷 거부(reject)
  - public  : SSH, dhcpv6-client를 제외하고 들어오는 모든 패킷 거부(reject)
  - trusted : 들어오는 모든 패킷 허용
  - work : SSH, ipp-client, dhcpv6-client를 제외하고 들어오는 모든 패킷 거부

- **public zone이 default**이다

<br>

<br>

<h2> firewalld</h2>

- firewalld는 초기에 기본 설정으로 zone이 생성되어 있다
- **firewalld** : Centos의 방화벽 관리 데몬

- 사용 법: **firewall-cmd [option]**
- 옵션
  - --state : firewalld 실행 상태 확인
  - --get-default-zone : 현재 기본 영역 표시
  - --set-default-zone [zone] : 기본 zone 설정
  - --get-zones : 사용 가능한 모든 zone 나열
  - --get-services : 사용 가능한 모든 서비스 나열
  - --get-active-zones : 현재 사용중인 모든 zone과 인터페이스 및 소스정보 나열
  - --add-source=[ip주소] --zone=[zone] : 출발지 주소 규칙 추가
    - --zone 옵션을 통해 zone 지정해주지 않으면 자동으로 기본 영역에 추가
  - --remove-source=[ip주소] : ip주소를 지정된 영역에서 제거
  - --add-interface=[ifname] --zone=[zone] : 특정 영역에 interface 연결 추가
  - --change-interface=[ifname] --zone=[zone] : 영역에 연결된 interface 변경
  - --list-all --zone=[zone] : 영역에 구성된 모든 인터페이스, 소스, 서비스, 포트 나열
    - zone을 지정해주지 않으면 전체 zone에 대한 자세한 정보 나열
  - --add-port=[prot|protocol|service] --zone=[zone] : 해당 포트나 프로토콜 혹은 서비스에 대한 트래픽 허용
    - --permanent 옵션을 사용하지 않으면 현재의 설정이 변경되며, 영구설정 지정 안됨
    - 포트를 지정할 때에는 tcp, udp 등을 지정해줘야함
  - --reload : 런타임 구성 삭제, 영구 구성 적용
    - firewall-cmd 명령 사용 후 **--reload 해주지 않으면, 영구저장X**
  - --runtime-to-permanent : 실행중 설정을 영구 설정으로 변경



사용 예

- firewalld 실행 상태를 확인해보자

```shell
[root@server ~]# firewall-cmd --state
running
```

- 현재의 기본 zone 을 확인해보자

```shell
[root@server ~]# firewall-cmd --get-default-zone
public
```

- 기본 zone을 home으로 변경해보자
  - --get-default-zone으로 확인

```shell
[root@server ~]# firewall-cmd --set-default-zone home
success
[root@server ~]# firewall-cmd --get-default-zone
home
```

- home zone에 80번 포트(tcp)에 대한 트래픽을 허용해보자(영구적으로)
  - tcp를 명시해줘야한다

```shell
[root@server ~]# firewall-cmd --add-port=80/tcp --permanent --zone=home
success
[root@server ~]# firewall-cmd --reload
success
```

- home zone에  2049번 포트(udp)에 대한 트래픽을 허용해보자(영구적으로)

```shell
[root@server ~]# firewall-cmd --add-port=2049/udp --permanent --zone=home
success
[root@server ~]# firewall-cmd --reload
success
```

- 열어준 포트를 확인해보자

```shell
[root@server ~]# firewall-cmd --list-ports
80/tcp 2049/udp
```

- home zone에 ICMP 프로토콜에 대한 트레픽을 허용해보자(영구적으로)

```shell
[root@server ~]# firewall-cmd --add-protocol=ICMP --permanent --zone=home
success
[root@server ~]# firewall-cmd --reload
success
```

- home zone에 nfs 서비스에 대한 트래픽을 허용해보자(영구적으로)

```shell
[root@server ~]# firewall-cmd --add-service=nfs --permanent --zone=home
success
[root@server ~]# firewall-cmd --reload
success
```

- home zone의 상태를 확인해보자

```shell
[root@server ~]# firewall-cmd --list-all --zone=home
home (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8 enp0s9
  sources:
  services: ssh mdns samba-client dhcpv6-client nfs
  ports: 80/tcp 2049/udp
  protocols: ICMP
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

- centos 컴퓨터에서 http://192.168.56.100/index.html 을 접속했을 경우, this is centos라고 출력되도록 해보자

```shell
[root@server ~]# echo "This is Centos" > /var/www/html/index.html
[root@server ~]# systemctl start httpd
[root@server ~]# systemctl enable httpd
Created symlink from /etc/systemd/system/multi-user.target.wants/httpd.service to /usr/lib/systemd/system/httpd.service.
[root@server ~]# firewall-cmd --add-service=http --permanent
fisuccess
[root@server ~]# firewall-cmd --reload
success
```



⭐ **항상 [패키지 설치 + 실행(활성화) + 방화벽 설정(포트 열어주기)]은 한 세트**

```shell
[root@server ~]# yum -y install httpd
[root@server ~]# systemctl start httpd
[root@server ~]# systemctl enable httpd
[root@server ~]# firewall-cmd --add-servie=httpd --permanent
[root@server ~]# firewall-cmd --reload
```

