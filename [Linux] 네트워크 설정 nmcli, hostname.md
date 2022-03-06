<h1> [Linux] 네트워크 설정: nmcli, hostname </h1>



<h3>📌INDEX</h3>

- [NetworkManager](#networkmanager)
- [네트워크 설정 방법 4가지](#네트워크-설정-방법-4가지)
  - [1. 직접 편집하기](#직접-편집하기)
  - [2. nmtui](#nmtui)
  - [3. 그래픽 도구](#그래픽-도구)
  - [4. nmcli](#nmcli)
-  [hostname](#hostname)



<br>
<br>

<h2>NetworkManager</h2>

- RHEL 6까지는 network.servie 사용
  - 직접 네트워크에 연결하는 방식
  - 인터페이스 카드에 직접 설정
- NetworkManager란 RHEL 7부터 **네트워크를 모니터링하고 관리하는 데몬**
  - 네트워크의 변경 사항을 탐지하고 설정해주는 역할을 수행
  - 연결이라는 논리적인 설정(유동 ip(connect), 고정 ip 연결)
- 설정 파일: /etc/sysconfig/nework-scripts/
- nmcli 명령을 통해 설정 파일 수정 가능
- 여러개의 **연결 설정 파일로 네트워크 관리** 가능

```shell
[root@localhost ~]# nmcli status NetworkManager
Error: argument 'status' not understood. Try passing --help instead.
[root@localhost ~]# systemctl status NetworkManager
● NetworkManager.service - Network Manager
   Loaded: loaded (/usr/lib/systemd/system/NetworkManager.service; enabled; vendor preset: enabled)
   Active: active (running) since 일 2022-03-06 16:47:13 KST; 37s ago
     Docs: man:NetworkManager(8)
 Main PID: 745 (NetworkManager)
    Tasks: 5
   CGroup: /system.slice/NetworkManager.service
           ├─745 /usr/sbin/NetworkManager --no-daemon
           ├─920 /sbin/dhclient -d -q -sf /usr/libexec/nm-dhcp-helper -pf /var/run/dhc...
           └─923 /sbin/dhclient -d -q -sf /usr/libexec/nm-dhcp-helper -pf /var/run/dhc...
 3월 06 16:47:17 localhost.localdomain NetworkManager[745]: <info>  [1646552837.6161]...
...
```

- 연결 설정 파일 : **/etc/sysconfig/nework-scripts/ifcfg-*** 파일
  - 초기 연결 설정 파일은 인터페이스 이름 앞에 ifcfg- 가 붙는 형태
  - 설정 파일의 이름은 사용자 편의로 변경 가능(ifcfg- 뒤 부터)

```shell
[root@localhost ~]# ls /etc/sysconfig/network-scripts/
ifcfg-enp0s3     ifdown-bnep  ifdown-routes  ifup-eth    ifup-ppp
ifcfg-enp0s8     ifdown-eth   ifdown-sit     ifup-ib     ifup-routes
ifcfg-enp0s9     ifdown-ib    ifdown-tunnel  ifup-ippp   ifup-sit
ifcfg-lo         ifdown-ippp  ifup           ifup-ipv6   ifup-tunnel
ifconfig-enp0s9  ifdown-ipv6  ifup-Team      ifup-isdn   ifup-wireless
ifdown           ifdown-isdn  ifup-TeamPort  ifup-plip   init.ipv6-global
ifdown-Team      ifdown-post  ifup-aliases   ifup-plusb  network-functions
ifdown-TeamPort  ifdown-ppp   ifup-bnep      ifup-post   network-functions-ipv6
```

```shell
[root@localhost ~]# ls /etc/sysconfig/network-scripts/ifcfg-*
/etc/sysconfig/network-scripts/ifcfg-enp0s3  /etc/sysconfig/network-scripts/ifcfg-enp0s9
/etc/sysconfig/network-scripts/ifcfg-enp0s8  /etc/sysconfig/network-scripts/ifcfg-lo
```

<br>
<br>

<h2>네트워크 설정 방법 4가지</h2>

- **connection** 이란?
  - IP 연결
  - 어떠한 인터페이스에 연결할 것인지 결정
  - 어떠한 네트워크 통신 방식을 사용할 것인지
    - wifi, ethernet, bluetooth 등



- 인터페이스 카드

  - enp0s3 : nat - 외부용
  - enp0s9 : 원격으로 사용하기 위한 내부용

  

    

<h4>직접 편집하기</h4>

- **/etc/sysconfig/network-scripts/ifcfg-***
- 하나의 인터페이스에 하나의 연결설정 파일만 활성화 가능
- vi 에디터를 이용하여 직접 파일을 편집함으로써 네트워크를 설정할 수 있다

```shell
[root@localhost ~]# vi /etc/sysconfig/network-scripts/ifcfg-enp0s9
```

```shell
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s9
UUID=509b32f3-83fd-443a-b4eb-b5e32db2e3ae
DEVICE=enp0s9
ONBOOT=no
~                                                                             ~                                                                             ~                                                                             ~                                                                              ~                                                                             ~                                                                              ~                                                                             ~                                                                             "/etc/sysconfig/network-scripts/ifcfg-enp0s9" 15L, 281C
```



<h4>nmtui</h4>

- 그래픽 도구를 이용하여 네트워크 설정 편집

<img src="https://user-images.githubusercontent.com/64996121/156922285-190adc98-3148-4cda-89ae-e6c430684d5a.PNG" width=400 height=280 />

<img src="https://user-images.githubusercontent.com/64996121/156922331-500a6c16-9cd9-4abc-a1fb-529c9b671751.PNG" width=400 height=280  />





<h4>그래픽 도구</h4>

- 그래픽 환경에서 시스템 도구를 통해 네트워크를 설정 및 수정할 수 있다.
- 프로그램 > 시스템 도구 > 네트워크 설정





<h4>nmcli</h4>

- nmcli + [tab 2번] -> 올 수 있는 서브 커맨드 확인 가능

```shell
[root@localhost ~]# nmcli
agent       device      help        networking
connection  general     monitor     radio
```



- **nmcli device** : device 종류 확인
  - device를 dev로 써도 가능

```shell
[root@localhost ~]# nmcli device
DEVICE      TYPE      STATE          CONNECTION
enp0s3      ethernet  연결됨         enp0s3
enp0s8      ethernet  연결됨         enp0s8
virbr0      bridge    연결됨         virbr0
enp0s9      ethernet  연결 끊겼음    --
lo          loopback  관리되지 않음  --
virbr0-nic  tun       관리되지 않음  --
```



- **nmcli connection show** : connection 종류 확인

```shell
[root@localhost ~]# nmcli connection show
NAME    UUID                                  TYPE      DEVICE
enp0s3  3d6d0ae5-78a1-4dad-b92b-2ab0c67cc40d  ethernet  enp0s3
enp0s8  8eff3d00-cb32-4591-b471-4c46e2a0da4d  ethernet  enp0s8
virbr0  7719f0d5-490e-491c-a0c3-5fc41074eacc  bridge    virbr0
enp0s9  509b32f3-83fd-443a-b4eb-b5e32db2e3ae  ethernet  --
```



- **nmcli con show [con-name]** : connection의 자세한 정보
  - ipv4.method : 
    - auto : 유동 ip
    - manual : 고정 ip 

```shell
[root@localhost ~]# nmcli con show enp0s9
connection.id:                          enp0s9
connection.uuid:                        509b32f3-83fd-443a-b4eb-b5e32db2e3ae
connection.stable-id:                   --
connection.type:                        802-3-ethernet
connection.interface-name:              enp0s9
connection.autoconnect:                 아니요
...
ipv4.method:                            auto
ipv4.dns:                               --
ipv4.dns-search:                        --
ipv4.dns-options:                       ""
ipv4.dns-priority:                      0
...
```



- **nmcli con add**
  - autoconnetion의 default는 yes
  - con-name ( == connection.id) : 연결 이름
  - ifname ( == connection.interface) : 연결할 인터페이스
  - type ( == connction.type) : 통신 방식
  - autoconnect ( == connection.autoconnect) : 부팅 시 자동 연결 설정
  - ip4 : ip 주소 지정
    - **반드시 prefix와 함께 작성**해야한다
  
  - **유동ip 설정하기**
    - **nmcli con add con-name [connetcion 이름] ifname [물리 장치] type [통신 방식] autoconnet [yes/no]**
  - **고정 ip 설정하기**
    - **nmcli con add con-name [connection 이름] ifname [물리 장치] type [통신 방식] autoconnect [yes/no] ip4 [ip 주소] gw4 [게이트웨이 주소]**



사용 예

- 유동 ip 설정 : dhcp
  - nmcli con 명령을 통해 dhcp가 잘 추가된 것을 확인할 수 있다

```shell
[root@localhost ~]# nmcli con add con-name dhcp ifname enp0s9 type ethernet autoconnect yes
연결 'dhcp' (5df4b352-d3f3-42ce-9861-0a8fa396aa54)이 성공적으로 추가되었습니다.
```

```shell
[root@localhost ~]# nmcli con
NAME    UUID                                  TYPE      DEVICE
dhcp    5df4b352-d3f3-42ce-9861-0a8fa396aa54  ethernet  enp0s9
enp0s3  3d6d0ae5-78a1-4dad-b92b-2ab0c67cc40d  ethernet  enp0s3
enp0s8  8eff3d00-cb32-4591-b471-4c46e2a0da4d  ethernet  enp0s8
virbr0  7719f0d5-490e-491c-a0c3-5fc41074eacc  bridge    virbr0
enp0s9  509b32f3-83fd-443a-b4eb-b5e32db2e3ae  ethernet  --
```

- 고정 ip 설정 : static
  - nmcli con 명령을 통해 static이 정상적으로 추가된 것을 확인할 수 있다
  - nmcli con show static 명령을 통해 ip 주소와 게이트웨이 주소 잘 추가된 것을 확인할 수 

```shell
[root@localhost ~]# nmcli con add con-name static ifname enp0s9 type ethernet ip4 192.168.56.201/24 gw4 192.168.56.1
연결 'static' (675fdbb4-a4f8-4ed9-85b9-8a7da18d8ee4)이 성공적으로 추가되었습니다.
```

```shell
NAME    UUID                                  TYPE      DEVICE
dhcp    5df4b352-d3f3-42ce-9861-0a8fa396aa54  ethernet  enp0s9
enp0s3  3d6d0ae5-78a1-4dad-b92b-2ab0c67cc40d  ethernet  enp0s3
enp0s8  8eff3d00-cb32-4591-b471-4c46e2a0da4d  ethernet  enp0s8
virbr0  7719f0d5-490e-491c-a0c3-5fc41074eacc  bridge    virbr0
enp0s9  509b32f3-83fd-443a-b4eb-b5e32db2e3ae  ethernet  --
static  675fdbb4-a4f8-4ed9-85b9-8a7da18d8ee4  ethernet  --
```

```shell
[root@localhost ~]# nmcli con show static
connection.id:                          static
connection.uuid:                        675fdbb4-a4f8-4ed9-85b9-8a7da18d8ee4
connection.stable-id:                   --
connection.type:                        802-3-ethernet
connection.interface-name:              enp0s9
...
ipv4.method:                            manual
ipv4.dns:                               --
ipv4.dns-search:                        --
ipv4.dns-options:                       ""
ipv4.dns-priority:                      0
ipv4.addresses:                         192.168.56.201/24
ipv4.gateway:                           192.168.56.1
...
```

- 유동 ip를 고정 ip로 수정해보자
  - 유동 ip를 고정 ip로 수정할 때에는 ip4.addresses와 ip4.gateway를 추가해줌으로써 수정할 수 있다.



- **nmcli con mod** 
  - 네트워크 수정할 때 사용



사용 예

- 위에서 add 한 dhcp 의 이름을 static2로 바꿔보자

  - **nmcli con mod [네트워크 이름] connection.id [변경할 네트워크 이름]**

  - nmcli con 명령을 통해 dhcp -> static으로 잘 변경된 것을 확인할 수 있다

```shell
[root@localhost ~]# nmcli con mod dhcp connection.id static2
[root@localhost ~]# nmcli con
NAME     UUID                                  TYPE      DEVICE
enp0s3   3d6d0ae5-78a1-4dad-b92b-2ab0c67cc40d  ethernet  enp0s3
enp0s8   8eff3d00-cb32-4591-b471-4c46e2a0da4d  ethernet  enp0s8
static2  5df4b352-d3f3-42ce-9861-0a8fa396aa54  ethernet  enp0s9
virbr0   2ee667ae-5cef-441e-a0a9-f41dcb6fde86  bridge    virbr0
enp0s9   509b32f3-83fd-443a-b4eb-b5e32db2e3ae  ethernet  --
static   675fdbb4-a4f8-4ed9-85b9-8a7da18d8ee4  ethernet  --
```

- 유동 ip인 static2을 고정 ip로 수정해보자.
  - **유동 ip를 고정ip로 수정할 때는 ipv4.addresses와 ipv4.gateway를 추가해준 뒤, ipv4.method를 manual로 수정**한다
    - ip주소를 할당하지 않고, manual로 수정하면 에러 발생
  - nmcli con show 명령을 통해, ip주소와 게이트웨이가 정상적으로 추가되고, 고정 ip(manual)로 변경된 것을 확인할 수 있다.

```shell
[root@localhost ~]# nmcli con mod static ipv4.addresses 192.168.56.220/24
[root@localhost ~]# nmcli con mod static2 ipv4.addresses 192.168.56.220/24
[root@localhost ~]# nmcli con mod static2 ipv4.gateway 192.168.56.1
[root@localhost ~]# nmcli con mod static2 ipv4.method manual
[root@localhost ~]# nmcli con show static2
connection.id:                          static2
connection.uuid:                        5df4b352-d3f3-42ce-9861-0a8fa396aa54
connection.stable-id:                   --
connection.type:                        802-3-ethernet
connection.interface-name:              enp0s9
connection.autoconnect:                 예
...
ipv4.method:                            manual
ipv4.dns:                               --
ipv4.dns-search:                        --
ipv4.dns-options:                       ""
ipv4.dns-priority:                      0
ipv4.addresses:                         192.168.56.220/24
ipv4.gateway:                           192.168.56.1
...
```

- static2에 dns 8.8.8.8을 추가해보자

```shell
[root@localhost ~]# nmcli con mod static2 ipv4.dns 8.8.8.8
[root@localhost ~]# nmcli con show static2
...
ipv4.dns:                               8.8.8.8
...
```

- **ip주소를 2개 가지는 것도 가능**하다
  - static2에 ip주소 192.168.56.221/24 를 추가해보자
    - nmcli con show명령을 통해 ip주소가 2개로 설정된 것을 확인할 수 있다

```shell
[root@localhost ~]# nmcli con mod static2 +ipv4.addresses 192.168.56.221/24
[root@localhost ~]# nmcli con show static2
...
ipv4.addresses:                         192.168.56.220/24, 192.168.56.221/24
...
```

- ip주소가 2개로 설정된 static2에서 **ip주소를 제거**해보자

```shell
[root@localhost ~]# nmcli con mod static2 -ipv4.addresses 192.168.56.221/24
[root@localhost ~]# nmcli con show static2
...
ipv4.addresses:                         192.168.56.220/24
...
```



- **nmcli con [up/down]**
  - up : 네트워크 활성화
  - down : 네트워크 비활성화



사용 예

- static 활성화
  - nmcli con 명령을 통해 static이 활성화된 것을 확인 가능

```shell
[root@localhost ~]# nmcli con up static
연결이 성공적으로 활성화되었습니다 (D-Bus 활성 경로: /org/freedesktop/NetworkManager/ActiveConnection/6)
[root@localhost ~]# nmcli con
NAME     UUID                                  TYPE      DEVICE
enp0s3   3d6d0ae5-78a1-4dad-b92b-2ab0c67cc40d  ethernet  enp0s3
enp0s8   8eff3d00-cb32-4591-b471-4c46e2a0da4d  ethernet  enp0s8
static   675fdbb4-a4f8-4ed9-85b9-8a7da18d8ee4  ethernet  enp0s9
virbr0   2ee667ae-5cef-441e-a0a9-f41dcb6fde86  bridge    virbr0
enp0s9   509b32f3-83fd-443a-b4eb-b5e32db2e3ae  ethernet  --
static2  5df4b352-d3f3-42ce-9861-0a8fa396aa54  ethernet  --
```

- static 비활성화

```shell
[root@localhost ~]# nmcli con down static
연결 'static'이(가) 성공적으로 비활성화되었습니다(D-Bus 활성 경로: /org/freedesktop/NetworkManager/ActiveConnection/6).
```





- **nmcli con reload**
  - nmcli를 이용하여 변경된 파일 reload
  - /etc/sysconfig/network-scripts/ifcfg-* 파일을 통해 수정했을 시에는 reload해줘야함

```shell
[root@localhost ~]# nmcli con reload
```



<br>

<br>

<h2>hostname</h2>

- **호스트명을 확인하거나 변경할 때 사용하는 명령어**
- 호스트명은 네트워크로 연결된 서버, 컴퓨터들을 구분하기 위한 것이다
- 확인 및 설정 파일: /etc/hostname
- **hostname [option]**
- 옵션
  - -a : 별칭명
  - -d : 도메인 명
  - -f : FQDN
  - -i : 호스트명 ip 주소
  - -v : 호스트명 버전



사용 예

- 호스트명 파일로 확인하기

```shell
[root@localhost ~]# cat /etc/hostname
localhost.localdomain
```

- 호스트명 **확인**

```shell
[root@localhost ~]# hostname
localhost.localdomain
```

- 호스트명 **변경** : 2가지 방법
  - **hostname [변경할 호스트명]** : 부팅하면 다시 변경(rollback)
  - **hostnamectl set-hostname [변경할 호스트명]** : **영구적**으로 변경

```shell
[root@localhost ~]# hostname nayoung
[root@localhost ~]# hostname
nayoung
[root@localhost ~]# hostnamectl set-hostname localhost.localdomain
[root@localhost ~]# hostname
localhost.localdomain
```

