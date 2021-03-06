<h2> [Linux] master/slave ์ค์ </h2>

<br>

๐[๋ฏธ๋ฆฌ ๋ณด๊ณ  ์์ผํ  ๊ธ](https://nayoungs.tistory.com/89)


<br>
<h3>๐INDEX</h3>

- [Master/Slave ๊ตฌ์กฐ๋?](#masterslave-๊ตฌ์กฐ๋)
-  [Master/Slave ๊ตฌ์กฐ ์ค์ ](#masterslave-๊ตฌ์กฐ-์ค์ )
   - [Master ์๋ฒ ์ค์ ](#master-์๋ฒ-์ค์ )
   - [Slave ์๋ฒ ์ค์ ](#slave-์๋ฒ-์ค์ )

<br>

<br>

<br>

<h2>Master/Slave ๊ตฌ์กฐ๋?</h2>

- Primary Server(1์ฐจ ๋ค์ ์๋ฒ) : ํด๋น ๋๋ฉ์ธ์ ๊ด๋ฆฌํ๋ ์ฃผ ๋ค์ ์๋ฒ
- Secondary Server(2์ฐจ ๋ค์ ์๋ฒ) : ์ฃผ ๋ค์ ์๋ฒ(1์ฐจ ์๋ฒ)๋ฅผ ๋ฐฑ์(backup)ํด์ฃผ๋ ์๋ฒ
  - Primary ์๋ฒ๊ฐ ๋น์ ์์ ์ผ๋ก ์ด์๋  ๋ ํน์ ๋ถํ๋ ๋ถ์ฐ ์ํค๊ธฐ ์ํด ๋ค์ ์กด์ฌ
  - ์์ Primary ์๋ฒ์ data๋ฅผ ๋ฐฑ์(backup) ๋ฐ๊ธฐ ์ํด ๋๊ธฐํ ์ค์  ํ์
- **Master/Slave ๋ค์์๋ฒ** :  ๋ง์คํฐ ๋ค์์๋ฒ๊ฐ ๋์ํ์ง ์์ ๊ฒฝ์ฐ, ์ฌ๋ ์ด๋ธ ๋ค์์๋ฒ๊ฐ ๋ง์คํฐ๋ฅผ ๋์ ํ์ฌ ํด๋ผ์ด์ธํธ์๊ฒ ๋๋ฉ์ธ/IP์ฃผ์ ์ ๋ณด๋ฅผ ์ ๊ณต

- **Master** : ์ค์  ๋ณ๊ฒฝ์ ์ฃผ์ฒด, zone ํ์ผ์ ๊ด๋ฆฌ
- **Slave** : Master์ ์ค์  ๋ณ๊ฒฝ ์ฌํญ์ ์ ๋ฌ ๋ฐ์ ์๋์ผ๋ก ๋ฐ์

- Master-Slave ๊ตฌ์กฐ์์ Data๊ฐ ๋๊ธฐํ ๋๋ ๊ฒ์ zone๋ง ๊ฐ๋ฅ
  - named.conf์์ ๋ณ๊ฒฝ๋๋ ๋ด์ญ์ slave์ ๋ฐ์๋์ง ์์

<br>

<br>

<h2>Master/Slave ๊ตฌ์กฐ ์ค์ </h2>



<h4>Master ์๋ฒ ์ค์ </h4>

- **/etc/named.conf -> zone ์์ **
  - allow-transfer { [slave์๋ฒ ip ์ฃผ์]; } ;

```shell
..
zone "test.example.com" IN {
        type master;
        file "test.example.com.zone";
        allow-transfer { 10.0.2.101; }; => ์ถ๊ฐ
};

zone "2.0.10.in-addr.arpa" IN {
        type master;
        file "10.0.2.100.zone";
        allow-transfer { 10.0.2.101; }; => ์ถ๊ฐ
};
...
```



- **zone ํ์ผ ์์ **

  - /var/named/test.example.com.zone

    - ์ ๋ฐฉํฅ ์กฐํ

    - NS ๋ค์์๋ฒ ์ถ๊ฐ : slave ๋ค์ ์๋ฒ
    - ipv4 ์ฃผ์ ์ถ๊ฐ : slave์๋ฒ  ip ์ฃผ์

  ```shell
  $TTL 3H
  @       IN SOA  test.example.com. root.test.example.com. (
                                          0       ; serial
                                          1D      ; refresh
                                          1H      ; retry
                                          1W      ; expire
                                          3H )    ; minimum
          NS      dns.test.example.com.
          NS      slave.test.example.com.          =>   ์ถ๊ฐ
          A         10.0.2.2
  dns     A         10.0.2.10
  www     A         10.0.2.20
  ftp     A         10.0.2.30
  mail    A         10.0.2.40
  blog    A         10.0.2.50
  slave   A         10.0.2.101                     =>   ์ถ๊ฐ
  ```

  - /var/named/10.0.2.0.zone

    - ์ญ๋ฐฉํฅ ์กฐํ

    - NS ๋ค์์๋ฒ ์ถ๊ฐ : slave ๋ค์ ์๋ฒ
    - slave ์๋ฒ PTR ์ถ๊ฐ

  ```shell
  $TTL 3H
  @       IN SOA  test.example.com. root.test.example.com. (
                                          0       ; serial
                                          1D      ; refresh
                                          1H      ; retry
                                          1W      ; expire
                                          3H )    ; minimum
          NS      dns.test.example.com.
          NS      slave.test.example.com.          =>   ์ถ๊ฐ
          A         10.0.2.2
  
  10     PTR       dns.test.example.com.
  20     PTR       www.test.example.com.
  30     PTR       ftp.test.example.com.
  40     PTR       mail.test.example.com.
  50     PTR       blog.test.example.com.
  101    PTR       slave.test.example.com.       =>  ์ถ๊ฐ
  ```

  

<h4>Slave ์๋ฒ ์ค์ </h4>

- ํจํค์ง ์ค์น

```shell
[root@slave ~]# yum -y install bind bind-utils
```

- ๋ฐฉํ๋ฒฝ ์ด๊ธฐ (dns์ ๋ํด)

```sh
[root@slave ~]# firewall-cmd --add-service=dns --permanent
[root@slave ~]# firewall-cmd --reload
```

- ์๋ฒ ์ฃผ์ ์ค์  ๋ฐ ํธ์คํธ๋ช ๋ณ๊ฒฝ

```shell
[root@slave ~]# nmcli con add con-name static3 ifname enp0s3 type ethernet ip4 10.0.2.101/24 gw4 10.0.2.2
[root@slave ~]# nmcli con mod ipv4.dns 10.2.0.10
[root@slave ~]# nmcli con up static3
[root@slave ~]# hostnamectl set-hostname slave.test.example.com
```

- /etc/named.conf ์ค์ 
  - listen-on port 53 { any; }; => ๋ชจ๋ ํ์ฉ
  - listen-on-v6 port 53 { none; }; => ipv6 ํ์ฉ X
  - allow-query     { any; }; => ๋ชจ๋ ํ์ฉ
  - zone 
    - type : slave
    - masters : master ์๋ฒ์ ip ์ฃผ์
    - /slaves ํ์์ ์ ์ฅ

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

- ์์คํ ํ์ฑํ

```shell
[root@slave ~]# systemctl start named
[root@slave ~]# systemctl enable named
```

- ํ์ธ
  - /var/named/slaves ๋ฅผ ํ์ธํด๋ณด๋ฉด master ์๋ฒ์ zoneํ์ผ์ด ๋ฐฑ์(backup)๋ฐ ์ ์ฅ๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค.

```shell
[root@slave ~]# ls /var/named/slaves
10.0.2.0.zone test.example.com.zone 
```



