<h2> [Linux] master/slave 설정</h2>



👉[미리 보고 와야할 글](https://nayoungs.tistory.com/89)



<h3>📌INDEX</h3>

- [Master/Slave 구조란?](#masterslave-구조란)
-  [Master/Slave 구조 설정](#MasterSlave-구조-설정)
  - [Master 서버 설정](#master-서버-설정)
  - [Slave 서버 설정](#slave-서버-설정)

<br>

<br>

<br>

<h2>Master/Slave 구조란?</h2>

- Primary Server(1차 네임 서버) : 해당 도메인을 관리하는 주 네임 서버
- Secondary Server(2차 네임 서버) : 주 네임 서버(1차 서버)를 백업(backup)해주는 서버
  - Primary 서버가 비정상적으로 운영될 때 혹은 부하는 분산 시키기 위해 다수 존재
  - 상시 Primary 서버의 data를 백업(backup) 받기 위해 동기화 설정 필요
- **Master/Slave 네임서버** :  마스터 네임서버가 동작하지 않을 경우, 슬레이브 네임서버가 마스터를 대신하여 클라이언트에게 도메인/IP주소 정보를 제공

- **Master** : 설정 변경의 주체, zone 파일을 관리
- **Slave** : Master의 설정 변경 사항을 전달 받아 자동으로 반영

- Master-Slave 구조에서 Data가 동기화 되는 것은 zone만 가능
  - named.conf에서 변경되는 내역은 slave에 반영되지 않음

<br>

<br>

<h2>Master/Slave 구조 설정</h2>



<h4>Master 서버 설정</h4>

- **/etc/named.conf -> zone 수정**
  - allow-transfer { [slave서버 ip 주소]; } ;

```shell
..
zone "test.example.com" IN {
        type master;
        file "test.example.com.zone";
        allow-transfer { 10.0.2.101; }; => 추가
};

zone "2.0.10.in-addr.arpa" IN {
        type master;
        file "10.0.2.100.zone";
        allow-transfer { 10.0.2.101; }; => 추가
};
...
```



- **zone 파일 수정**

  - /var/named/test.example.com.zone

    - 정방향 조회

    - NS 네임서버 추가 : slave 네임 서버
    - ipv4 주소 추가 : slave서버  ip 주소

  ```shell
  $TTL 3H
  @       IN SOA  test.example.com. root.test.example.com. (
                                          0       ; serial
                                          1D      ; refresh
                                          1H      ; retry
                                          1W      ; expire
                                          3H )    ; minimum
          NS      dns.test.example.com.
          NS      slave.test.example.com.          =>   추가
          A         10.0.2.2
  dns     A         10.0.2.10
  www     A         10.0.2.20
  ftp     A         10.0.2.30
  mail    A         10.0.2.40
  blog    A         10.0.2.50
  slave   A         10.0.2.101                     =>   추가
  ```

  - /var/named/10.0.2.0.zone

    - 역방향 조회

    - NS 네임서버 추가 : slave 네임 서버
    - slave 서버 PTR 추가

  ```shell
  $TTL 3H
  @       IN SOA  test.example.com. root.test.example.com. (
                                          0       ; serial
                                          1D      ; refresh
                                          1H      ; retry
                                          1W      ; expire
                                          3H )    ; minimum
          NS      dns.test.example.com.
          NS      slave.test.example.com.          =>   추가
          A         10.0.2.2
  
  10     PTR       dns.test.example.com.
  20     PTR       www.test.example.com.
  30     PTR       ftp.test.example.com.
  40     PTR       mail.test.example.com.
  50     PTR       blog.test.example.com.
  101    PTR       slave.test.example.com.       =>  추가
  ```

  

<h4>Slave 서버 설정</h4>

- 패키지 설치

```shell
[root@slave ~]# yum -y install bind bind-utils
```

- 방화벽 열기 (dns에 대해)

```sh
[root@slave ~]# firewall-cmd --add-service=dns --permanent
[root@slave ~]# firewall-cmd --reload
```

- 서버 주소 설정 및 호스트명 변경

```shell
[root@slave ~]# nmcli con add con-name static3 ifname enp0s3 type ethernet ip4 10.0.2.101/24 gw4 10.0.2.2
[root@slave ~]# nmcli con mod ipv4.dns 10.2.0.10
[root@slave ~]# nmcli con up static3
[root@slave ~]# hostnamectl set-hostname slave.test.example.com
```

- /etc/named.conf 설정
  - listen-on port 53 { any; }; => 모두 허용
  - listen-on-v6 port 53 { none; }; => ipv6 허용 X
  - allow-query     { any; }; => 모두 허용
  - zone 
    - type : slave
    - masters : master 서버의 ip 주소
    - /slaves 하위에 저장

```shell
...
options {
        listen-on port 53 { any; };
        listen-on-v6 port 53 { none; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        recursing-file  "/var/named/data/named.recursing";
        secroots-file   "/var/named/data/named.secroots";
        allow-query     { any; };
...        

zone "test.example.com" IN {
        type slave;
        masters { 10.0.2.10; };
        file "slaves/test.example.com.zone";
        notify no;
};

zone "2.0.10.in-addr.arpa" IN {
        type slave;
        masters { 10.0.2.10; };
        file "slaves/10.0.2.0.zone";
        notify no;
};
...
```

- 시스템 활성화

```shell
[root@slave ~]# systemctl start named
[root@slave ~]# systemctl enable named
```

- 확인
  - /var/named/slaves 를 확인해보면 master 서버의 zone파일이 백업(backup)및 저장된 것을 확인할 수 있다.

```shell
[root@slave ~]# ls /var/named/slaves
10.0.2.0.zone test.example.com.zone 
```



