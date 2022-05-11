











<h3>「미니 프로젝트 1」 결과보고서</h3>
<h4>리눅스 인프라 구축을 통한 WordPress구현</h4>
<h4>프로젝트 참여자: 2022_s3_성나영</h4>


<br>

<br>

<h3>📌목차</h3>



**1.프로젝트 개요**

- 1-1. 프로젝트 주제 선정 동기 및 목표
- 1-2. 프로젝트 특징
- 1-3. 프로젝트 환경
- 1-4. 프로젝트 일정



**2.프로젝트 개발 과정**

- 2-1. DB서버 패키지 설치 및 네트워크 설정
- 2-2. Web 서버 패키지 설치 및 네트워크 설정
- 2-3. DB 서버: wordpress 데이터베이스 설정
- 2-4. Web 서버: wordpress 설치
- 2-6. Web 서버: apache 설정
- 2-7. DB서버 & 웹 서버 연결완료
- 2-8. DNS 서버 설정
- 2-9. Web 서버 : dns 주소 등록 및 도메인 등록
- 2-10. https 설정



**3.프로젝트 최종 결과**

<br><br>

<br>

<h2>1. 프로젝트 개요</h2>

<h4>1-1. 프로젝트 주제 선정 동기 및 목표</h4>

 playdata 클라우드 부트캠프 4기 수업의 일환으로 미니 프로젝트를 진행하게 됨. 해당 프로젝트에서는 리눅스 인프라 구축을 통한 wordpress를 구현하는 것이 목표임.



<h4>1-2. 프로젝트 특징</h4>

하나의 서버가 아닌, DB 서버, Web서버, DNS 서버로 총 3개의 서버를 각각 구축하여 연동하는 데에 최종적인 목적이 있음.



<h4>1-3. 프로젝트 환경</h4>

- 환경 구성

| <img src="https://images.velog.io/images/kdh10806/post/589f5ddd-a1c9-4bfc-b2e4-7b213f732374/Google_Chrome_logo_and_wordmark_(2015).png" alt="chrome - velog" width=300 /> | 인프라 구축 완료 후 도메인 접속 확인을 위해 사용             |
| ------------------------------------------------------------ | :----------------------------------------------------------- |
| <img src="https://user-images.githubusercontent.com/64996121/159122795-657ac14d-76e0-4d4a-bbab-df4750ecb79f.png" alt="image" width=300 /> | **DB server, Web server, DNS server를 리눅스로 운영하기 위해 사용** |
| <img src="https://user-images.githubusercontent.com/64996121/162645341-02a44943-a246-4e3e-8d93-2bef3f3d4af4.png" alt="그림입니다.  원본 그림의 이름: mem00001ce40001.tmp  원본 그림의 크기: 가로 318pixel, 세로 159pixel" width=300 /> | **CentOS 환경을 구축하기 위해 설치한 가상화 소프트웨어**     |



- 인프라 구축환경

|   WordPress    |                      |
| :------------: | :------------------: |
| **Web server** |      **apache**      |
|    **PHP**     | **동적 컨텐츠 이용** |
| **DB server**  |     **MariaDB**      |
| **DNS server** |      **named**       |











- 서버 구성

| Web server(apache+PHP+wordpress) | enp0s8<br>ipv4 : 192.168.56.101<br>gateway : 192.168.56.2<br>dns : 10.0.2.10 |
| :------------------------------: | :----------------------------------------------------------: |
|          **DB server**           | **enp0s8<br>ipv4 : 192.168.56.107<br>gateway : 192.168.56.1<br>dns : 10.0.2.10** |
|          **DNS server**          | **enp0s3<br>ipv4 : 10.0.2.10<br>gateway : 10.0.2.1<br>dns : 10.0.2.10** |



- 서버 구조도

  <img src="https://user-images.githubusercontent.com/64996121/162645771-0cfdc32a-7299-46b5-af56-a27d91bc64df.png" alt="그림입니다.  원본 그림의 이름: 서버 구조도.PNG  원본 그림의 크기: 가로 1062pixel, 세로 640pixel" width=500/> 

<h4>1-4. 프로젝트 일정</h4>

| **일정**                                                     | **추진내용**                                                 | **3/14** | **3/15** | **3/16** | **3/17** |
| :----------------------------------------------------------- | ------------------------------------------------------------ | :------: | :------: | :------: | -------- |
| 주제 선정                                                    | 주제 확인 및 최종 목표 설정                                  |    ✔️     |    ✔️     |          |          |
| 자료 수집                                                    | 1. Linux 기본 명령어 복습<br>2. 네트워크 설정 복습<br>3. apache 복습<br>4. SQL 복습<br>5. DNS 서버 구축 과정 복습 |    ✔️     |    ✔️     |          |          |
| 환경 구축                                                    | Virtual Box를 통해 DB, Web, DNS 서버 생성                    |    ✔️     |    ✔️     |          |          |
| 개발                                                         | DB 서버와 Web 서버 구현 후 연동<br>DNS 서버 구현 후 DB, Web서버와  연동 |          |    ✔️     |    ✔️     |          |
| 테스트                                                       | wordpress가 정상적으로 실행되는지, 도메인 등록 등 확인       |          |    ✔️     |    ✔️     |          |
| 보고서 작성 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | 최종 결과보고서 작성                                         |          |          |          | ✔️        |

<br>

<br>

<h2>2. 프로젝트 개발 과정</h2>


<h4>2-1. DB서버 패키지 설치 및 네트워크 설정</h4>

- **릴리즈 버전 확인**

```
[root@localhost ~]# cat /etc/redhat-release
CentOS Linux release 7.5.1804 (Core)
```

- **yum 업데이트**
  - latest버전의 다운로드를 위하여 업데이트

```
[root@localhost ~]# yum -y update
```

- **MariaDB.repo 파일 생성**
  - vi에디터를 통해 해당 내용 저장
  - MariaDB 10.1 부터는 yum을 통한 다운로드가 불가
  - 10.2 버전 이상을 다운받기 위함임

```
[root@localhost ~]# cat /etc/yum.repos.d/MariaDB.repo
#MariaDB 10.2 CentOS repository list - created 2022-03-09 15:37 UTC
# https://mariadb.org/download/
[mariadb]
name = MariaDB
baseurl = https://mirror.yongbok.net/mariadb/yum/10.2/centos7-amd64
gpgkey=https://mirror.yongbok.net/mariadb/yum/RPM-GPG-KEY-MariaDB
gpgcheck=1
```

- **Mariadb-server 버전확인**
  - 버전 10.2.43 임을 확인

```
[root@localhost ~]# yum info Mariadb-server
Name        : MariaDB-server
Arch        : x86_64
Version     : 10.2.43
Release     : 1.el7.centos
Size        : 24 M
Repo        : mariadb
...
```

- **yum을 이용하여 mariaDB 설치**

```
[root@localhost ~]# yum install -y MariaDB-server MariaDB-client
```

- **MariaDB 패키지 이름 확인**

```
[root@localhost ~]# rpm -qa MariaDB*
MariaDB-server-10.2.43-1.el7.centos.x86_64
MariaDB-client-10.2.43-1.el7.centos.x86_64
MariaDB-common-10.2.43-1.el7.centos.x86_64
MariaDB-compat-10.2.43-1.el7.centos.x86_64
```

- **MariaDB-server 실행파일, 데몬명 확인**
  - grep 명령어를 함께 사용하여 빠르게 확인

```
[root@localhost ~]# rpm -ql MariaDB-server | grep mariadb.service
/usr/bin/mariadb-service-convert
/usr/lib/systemd/system/mariadb.service
/usr/share/man/man1/mariadb-service-convert.1.gz
/usr/share/mysql/systemd/mariadb.service
```

```
[root@localhost ~]# rpm -ql MariaDB-server | grep mysql_secure_installation
/usr/bin/mysql_secure_installation
/usr/share/man/man1/mysql_secure_installation.1.gz
```

- **mariadb.service 시작 및 활성화**
  - mariadb 서비스를 실행할 수 있게 하기 위함

```
[root@localhost ~]# systemctl start mariadb.service
[root@localhost ~]# systemctl enable mariadb.service
```

- **mysql_secure_installtion 보안 설정**
  - root 암호 설정
  - anonymous 접속 차단
  - 원격 접속 허용 
    - 웹서버와 DB서버를 따로 구현할 예정이므로
  - test 데이터베이스 삭제 
  - 저장

```
[root@localhost ~]# mysql_secure_installation
...
Set root password? [Y/n] y
New password:
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] no
 ... skipping.

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] yes
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

- **방화벽에 mariadb (3306포트 추가)**
  - 웹서버와 DB를 별도로 할 예정이므로
  - 설정 후 --list-all 옵션을 통해 추가된 것 확인

```
[root@localhost ~]# systemctl enable mariadb.service
[root@localhost ~]# firewall-cmd --add-port=3306/tcp --zone=public --permanent
success
[root@localhost ~]# firewall-cmd --reload
success
[root@localhost ~]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8 enp0s9
  sources:
  services: dhcpv6-client ssh
  ports: 3306/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

- **고정 ip 설정**
  - 네트워크 설정을 해줌으로써 yum 또는 외부 인터넷으로의 접근이 가능해짐
  - DB서버에서는 enp0s8을 사용함
  - ip주소를 지정해줌으로써 이후 서버간 연동에 이용

```
[root@localhost ~]# nmcli con add con-name static_db ifname enp0s8 type ethernet ip4 192.168.56.107/24 gw4 192.168.56.1
[root@localhost ~]# nmcli con up static_db
```

- **호스트명 변경**

```
[root@localhost ~]# hostnamectl set-hostname dbserver
[root@localhost ~]# hostname
dbserver
```

<br>

<br>

<h4>2-2. Web 서버 패키지 설치 및 네트워크 설정</h>

- **DB서버와 동일하게 yum update 완료**
- **웹서버 설치 및 확인**
  - apache : http 웹 서버

```
[root@localhost ~]# yum install httpd
[root@localhost ~]# rpm -qa httpd
httpd-2.4.6-97.el7.centos.4.x86_64
```

```
[root@localhost ~]# yum install httpd
[root@localhost ~]# rpm -aq httpd
httpd-2.4.6-97.el7.centos.4.x86_64
[root@localhost ~]# rpm -ql httpd
/etc/httpd
/etc/httpd/conf
/etc/httpd/conf.d
/etc/httpd/conf.d/README
/etc/httpd/conf.d/autoindex.conf
/etc/httpd/conf.d/userdir.conf
/etc/httpd/conf.d/welcome.conf
```

- **방화벽 설정**
  - http 서비스를 사용할 수 있도록 방화벽 설정
  - 재시작 이후에도 자동적으로 설정되도록 —permanent 옵션 추가 

```
[root@localhost ~]# firewall-cmd --add-service=http --permanent
success
[root@localhost ~]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: dhcpv6-client http ssh
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

- **PHP 설치 과정**
  - 7.4 버전의 php가 설치되어야함
  - 바로 설치하면 5.4버전이 설치되므로, remi와 yum-utils을 통해 버전을 변경

```
[root@localhost ~]# yum install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
```

```
[root@localhost ~]# yum -y install yum-utils
```

```
[root@localhost ~]# yum-config-manager --disable remi-php54 (php5.4버전 끄기)
[root@localhost ~]# yum-config-manager --enable remi-php74 (php7.4버전 켜기)
```

```
[root@localhost ~]# yum install php74
[root@localhost ~]# yum install -y php74-php php-cli php74-scldevel
```

- **웹 데몬 재시작**
  - 변경사항을 시스템에 반영시키기 위해 웹 데몬을 재시작

```
[root@localhost ~]# systemctl restart httpd.service
[root@localhost ~]# systemctl status httpd.service
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: active (running) since 화 2022-03-15 10:11:16 KST; 6s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 22357 (httpd)
   Status: "Processing requests..."
    Tasks: 7
   CGroup: /system.slice/httpd.service
           ├─22357 /usr/sbin/httpd -DFOREGROUND
           ├─22358 /usr/sbin/httpd -DFOREGROUND
           ├─22359 /usr/sbin/httpd -DFOREGROUND
           ├─22360 /usr/sbin/httpd -DFOREGROUND
           ├─22361 /usr/sbin/httpd -DFOREGROUND
           ├─22362 /usr/sbin/httpd -DFOREGROUND
           └─22363 /usr/sbin/httpd -DFOREGROUND

 3월 15 10:11:16 localhost.localdomain systemd[1]: Starting The Apache H...
 3월 15 10:11:16 localhost.localdomain httpd[22357]: AH00558: httpd: Cou...
 3월 15 10:11:16 localhost.localdomain systemd[1]: Started The Apache HT...
Hint: Some lines were ellipsized, use -l to show in full.
```

- **php 및 httpd 버전 확인**
  - php가 버전 7.4 이상임을 확인

```
[root@localhost ~]# rpm -qa php74
php74-1.0-3.el7.remi.x86_64
[root@localhost ~]# rpm -qa httpd
httpd-2.4.6-97.el7.centos.4.x86_64
```

- **고정 ip 설정**
  - web서버에서는 enp0s8 사용
  - ip주소를 지정해줌으로써 이후 서버간 연동에 이용

```
[root@localhost ~]# nmcli con add con-name static_web ifname enp0s8 type ethernet ip4 192.168.56.101/24 gw4 192.168.56.2
연결 'static_web' (d8a09917-af58-4986-9942-33e2f7cc1ba4)이 성공적으로 추가되었습니다.
[root@localhost ~]# nmcli con up static_web
연결이 성공적으로 활성화되었습니다 (D-Bus 활성 경로: /org/freedesktop/NetworkManager/ActiveConnection/5)
```

- **호스트명 설정**

```
[root@localhost ~]# hostnamectl set-hostname webserver
[root@localhost ~]# hostname
webserver
```

<br>

<br>

<h4>2-3. DB 서버: wordpress 데이터베이스 설정</h4>

- **데이터베이스 원격 접속 허용**
  - wordpress 게시판에 사용할 데이터베이스, 사용자 생성 및 권한 부여

```
[root@dbserver ~]# mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 8
Server version: 10.2.43-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE wordpress;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> USE wordpress
Database changed
MariaDB [wordpress]> CREATE USER adminuser@loaclhost IDENTIFIED BY 'dkagh1.';
Query OK, 0 rows affected (0.00 sec)

MariaDB [wordpress]> GRANT ALL PRIVILEGES ON wordpress.* TO adminuser@'%' IDENTIFIED BY 'dkagh1.';
Query OK, 0 rows affected (0.00 sec)

MariaDB [wordpress]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.00 sec)

MariaDB [wordpress]> exit
Bye
```

<br>

<br>

<h4>2-4. Web 서버: wordpress 설치</h4>

- **URL로 설치하기 위한 wget 패키지 설치**

```
[root@webserver ~]# yum -y install wget
```

- **URL로 wordpress 설치**
  - URL:  https://wordpress.org/latest.tar.gz

```
[root@webserver ~]# wget https://wordpress.org/latest.tar.gz
[root@webserver ~]# file latest.tar.gz
latest.tar.gz: gzip compressed data, from Unix, last modified: Fri Mar 11 09:39:52 2022
```

- **-C 옵션을 통해 위치 지정하여 아카이브 해제**
  - 해제할 디렉토리: /var/www/html

```
[root@webserver ~]# tar -xvzf latest.tar.gz -C /var/www/html
```

```
[root@webserver ~]# ls /var/www/html/wordpress
index.php        wp-blog-header.php    wp-includes        wp-settings.php
license.txt      wp-comments-post.php  wp-links-opml.php  wp-signup.php
readme.html      wp-config-sample.php  wp-load.php        wp-trackback.php
wp-activate.php  wp-content            wp-login.php       xmlrpc.php
wp-admin         wp-cron.php           wp-mail.php
```

-  **게시판에 업로드되는 파일을 저장하기 위한 디렉토리 생성**

```
[root@webserver ~]# mkdir /var/www/html/wordpress/uploads
```

<br>

<br>

<h4>2-5. Web 서버: wordpress 구성</h4>

- **wordpress 샘플 파일 확인**

```
[root@webserver ~]# ls -l /var/www/html/wordpress/wp-config-sample.php
-rw-r--r--. 1 nobody nfsnobody 3001 12월 14 17:44 /var/www/html/wordpress/wp-config-sample.php
```

- **/var/www/html/wordpress/ 로 이동**

```
[root@webserver ~]# cd /var/www/html/wordpress/
[root@webserver wordpress]#
```

- **wp-config-sample.php 파일을 복사하여 사용**

```
[root@webserver wordpress]# cp wp-config-sample.php wp-config.php
```

- **압축해제된 wordpress 디렉토리와 그 하위 디렉토리의 소유자,소유그룹을 apache로 변경**

```
[root@webserver wordpress]# chown -R apache:apache /var/www/html/wordpress
```

```
[root@webserver wordpress]# ls -l /var/www/html/wordpress/
합계 216
-rw-r--r--.  1 apache apache   405  2월  6  2020 index.php
-rw-r--r--.  1 apache apache 19915  1월  1 09:15 license.txt
-rw-r--r--.  1 apache apache  7437 12월 29 02:38 readme.html
drwxr-xr-x.  2 apache apache     6  3월 15 11:28 uploads
...
```

- **vim 에디터를 통해 wp-config.php 파일 수정**
  - DB서버에서 설정한 내용을 반영
  - 데이터베이스 이름 : wordpress
  - 사용자 : useradmin
  - 패스워드 : dkagh1.
  - db서버 ip 주소 : 192.168.56.107

```
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress’ );

/** Database username */
define( 'DB_USER', 'useradmin' );

/** Database password */
define( 'DB_PASSWORD', 'dkagh1.' );

/** Database hostname */
define( 'DB_HOST', '192.168.56.107' );
```

<br>

<br>

<h4>2-6. Web 서버: apache 설정</h4>

- **/etc/httpd/conf/httpd.conf 파일 수정**

  - /etc/httpd/conf/httpd.conf : 리눅스 아파치 웹 서버의 메인 설정 파일

  - DocumentRoot 수정 -> /var/www/html/wordpress
  - IfModule 수정 : index.html -> index.php

```
[root@webserver ~]# vim /etc/httpd/conf.d/httpd.conf
[root@webserver ~]# cat /etc/httpd/conf.d/httpd.conf
...
DocumentRoot "/var/www/html/wordpress"
...
<IfModule dir_module>
    DirectoryIndex index.php
</IfModule>
```

- **SELinux 설정**
  - 외부 접근을 허용하기 위해 SELinux를 임시적으로 비활성화

```
[root@webserver ~]# setenforce 0
```

- **❗ "Your PHP installation appears to be missing the MySQL extension which is required by WordPress" 오류 발생**

  - php의 MySQL 확장패키지를 설치함으로써 문제를 해결할 수 있었음

    <img src="https://user-images.githubusercontent.com/64996121/162645629-3988cffe-355d-4647-b4c8-0aabe78dd6a7.PNG" alt="그림입니다.  원본 그림의 이름: CLP00001ce40001.bmp  원본 그림의 크기: 가로 1020pixel, 세로 192pixel" style="zoom: 67%;" />  

```
[root@localhost ~]# yum install php php-mysql
```

<br>
<br>

<h4>2-7. DB서버 & 웹 서버 연결완료</h4>

- **http://[ip주소] 접근**
  - DocumentRoot : /var/www/html/wordpress

  <img src="https://user-images.githubusercontent.com/64996121/158532228-b7d6c8e5-759a-4a79-964f-b9dc30232081.PNG" alt="그림입니다.  원본 그림의 이름: mem00001ce40003.png  원본 그림의 크기: 가로 932pixel, 세로 896pixel" style="zoom: 33%;" />  

  <img src="https://user-images.githubusercontent.com/64996121/158532261-d614e7f2-a73a-4d30-8afa-d5ede28080c5.jpg" alt="그림입니다.  원본 그림의 이름: mem00001ce40004.jpg  원본 그림의 크기: 가로 984pixel, 세로 936pixel" width=314 height=300 />  

  <img src="https://user-images.githubusercontent.com/64996121/158532330-3f312d41-5d8a-48ca-be17-356fa3e5f7eb.PNG" alt="그림입니다.  원본 그림의 이름: mem00001ce40005.png  원본 그림의 크기: 가로 953pixel, 세로 745pixel"  width=314 height=280 />  

  <img src="https://user-images.githubusercontent.com/64996121/158532384-08a39c60-8afd-407b-880d-0dc50ac21d7c.PNG" alt="그림입니다.  원본 그림의 이름: mem00001ce40006.png  원본 그림의 크기: 가로 1280pixel, 세로 628pixel" style="zoom: 45%;" />  



- **DB서버에서 wordpress 테이블 확인**
  - 정상적으로 반영된 것을 확인할 수 있음

```
MariaDB [wordpress]> SHOW TABLEs;
+-----------------------+
| Tables_in_wordpress   |
+-----------------------+
| wp_commentmeta        |
| wp_comments           |
| wp_links              |
| wp_options            |
| wp_postmeta           |
| wp_posts              |
| wp_term_relationships |
| wp_term_taxonomy      |
| wp_termmeta           |
| wp_terms              |
| wp_usermeta           |
| wp_users              |
+-----------------------+
12 rows in set (0.00 sec)
```

<br>

<br>

<h4>2-8. DNS 서버 설정</h4>

- **패키지 설치**

```
[root@server ~]# yum -y install bind bind-utils
```

- **네트워크 설정**
  - gateway주소는 `ip route` 명령을 통해 확인

```
[root@server ~]# nmcli con add con-name static_dns ifname ensp0s3 type ethernet ip4 10.0.2.10/24 gw4 10.0.2.1
[root@server ~]# nmcli con mod static_dns ipv4.dns 10.0.2.10
[root@server ~]# nmcli con up static_dns
```

```
[root@server ~]# cat /etc/resolv.conf
# Generated by NetworkManager
search ny.project.com
nameserver 10.0.2.10
```

- **호스트네임 설정**

```
[root@server ~]# hostnamectl set-hostname [host명]
```

- **/etc/named.conf 설정**
  - 53번 포트에 대해 모든 접속 허용
  - ipv6는 사용하지 않으므로 none 지정
  - zone을 추가하여 zone파일(ny.project.com.zone)을 설정함

```
[root@server ~]# vi /etc/named.conf
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
zone "." IN {
        type hint;
        file "named.ca";
};

//zone 추가
zone "ny.project.com" IN {
        type master; //master 1차 DNS server로 구성
        file "ny.project.com.zone"; //zone 파일 이름 지정
};

```

- **/var/named => zone 설정**
  - 존의 named.empty파일을 복사하여 zone파일에 이용
  - 네임서버를 지정하고, dns서버/Web서버/db서버의 도메인네임을 ip주소를 통해 지정함

```
[root@server named]# cd /var/named
[root@server named]# cp named.empty ny.project.com.zone
[root@server named]# vi ny.project.com.zone
```

```
[root@server named]# cat encore.class4.zone
$TTL 3H
@       IN SOA  encore.class4.  root.encore.class4. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      server.encore.class4. //네임 서버 지정
        A       10.0.2.1
dns     A       10.0.2.10
db      A       192.168.56.107
web     A       192.168.56.101
```

- **서비스 활성화**

```
[root@server named]# systemctl start named.service
[root@server named]# systemctl enable named.service
```

- **권한 설정**
  - 소유자와 그룹이 읽고 쓸 수 있도록 권한 변경
  - 그룹 소유자를 named로 변경함으로써 named 서비스가 접근할 수 있도록 설정

```
[root@server named]# chmod 660 ny.project.com.zone
[root@server named]# chown :named ny.project.com.zone
```

```
[root@server named]# ls -l ny.project.com.zone
-rw-rw----. 1 root named 254  3월 16 09:53 ny.project.com.zone
[root@server named]# systemctl restart named.service
```

- **방화벽 설정**
  - 서버를 각각 구축하므로, dns서비스를 방화벽에 설정

```
[root@server named]# firewall-cmd --add-service=dns --permanent
success
[root@server named]# firewall-cmd --reload
```

- **결과 확인**
  - host명령어를 통해 네임서버가 정상적으로 설정되었는지 확인

```
[root@dns named]# host db.ny.project.com
db.ny.project.com has address 192.168.56.107
[root@dns named]# host web.ny.project.com
web.ny.project.com has address 192.168.56.101
```

- **외부에서의 접속 확인**
  - 부에서 접속 시 ❗`** server can't find db.ny.project.com: nxdomain`과 같은 에러 발생
  - web서버의 enp0s3의 주소와 dns 서버 주소가 겹치는 것을 발견
    - enp0s3의 ip주소를 변경해줌으로써 문제를 해결

```
[root@webserver ~]# nmcli con mod static3 ipv4.addresses 10.0.2.8/24 ipv4.method manual
```

- **ip 주소 변경 후 외부접속 다시 확인 : 정상적으로 처리됨**

```
[root@webserver ~]# nslookup
> db.ny.project.com
Server:         10.0.2.10
Address:        10.0.2.10#53

Name:   db.ny.project.com
Address: 192.168.56.107
```

<br>

<br>

<h4>2-9. Web 서버 : dns 주소 등록 및 도메인 등록</h4>

- **enp0s8을 사용하는 웹 서버에 앞서 설정한 dns 주소를 등록**
  - enp0s8(static)

```
[root@webserver ~]# nmcli con mod static ipv4.dns 10.0.2.10
```

- **/var/www/html/wordpress/wp-config.php 수정**
  - DB_HOST의 값을 다음과 같이 DNS 서버에서 설정한 도메인명으로 변경

```
...

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** Database username */
define( 'DB_USER', 'adminuser' );

/** Database password */
define( 'DB_PASSWORD', 'dkagh1.' );

/** Database hostname */
define( 'DB_HOST','db.ny.project.com');

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );
...
```

- **시스템 재시작**
  - 변경사항을 반영시키기 위해 서비스 재시작

```
[root@webserver ~]# systemctl restart httpd
```

- **윈도우에 도메인 등록하기**

  - C:\Windows\System32\drivers 의 hosts 파일 복사
  - 내 PC > 문서에 붙여넣기
  - hosts 파일 메모장으로 열기
  - 도메인 등록

    <img src="https://user-images.githubusercontent.com/64996121/158549921-f986c101-439a-432e-888f-e99c1abb1557.PNG" alt="그림입니다.  원본 그림의 이름: CLP00001ce40004.bmp  원본 그림의 크기: 가로 996pixel, 세로 630pixel" style="zoom: 42%;" />  

  - 복사 후 C:\Windows\System32\drivers에 다시 붙여넣기
  - 관리자 권한으로 덮어씀

<br>

<br>

<h4>2-10. https 설정</h4>

- **편의를 위해 /etc/httpd/conf.d/에 들어가서 진행**

```
[root@server ~]# cd /etc/httpd/conf.d
```

- **SSL/TLS 지원 활성화를 위해 확장 모듈 설치**
  - mod_ssl 패키지 설치

```
[root@server conf.d]#  yum -y install mod_ssl
```

- **https 방화벽 설정**

```
[root@server conf.d]#  firewall-cmd --add-service=https --permanent
success
[root@server conf.d]# firewall-cmd --reload
success
```

- **/etc/httpd/conf.d/ssl.conf 파일 수정**
  - SSLEngine : TLS의 사용 여부
  - SSLCertificateFile : 가상 호스트의 인증서 위치
  - SSLCertificateKeyFile : 가상 호스트의 개인 키 위치

```
[root@server conf.d]#  vi ssl.conf
```

```
...
<VirtualHost _default_:443>

# General setup for the virtual host, inherited from global configuration
DocumentRoot "/var/www/html" #샵(#)을 제거
ServerName web.ny.project.com:443 #샵(#) 제거 후 서버네임 변경
...

SSLCipherSuite HIGH:3DES:!aNULL:!MD5:!SEED:!IDEA #httpd가 사용할 암호화 나열

...

SSLCertificateFile /etc/pki/tls/certs/cert.crt #가상 호스트의 인증서 위치

...

SSLCertificateKeyFile /etc/pki/tls/private/private.key #가상 호스트의 개인 키 위치

...
</VirtualHost>
```

- **openssl 도구를 이용해서 인증서 생성**
  - 개인키 생성

```
[root@server conf.d]# openssl genrsa -out private.key 2048
Generating RSA private key, 2048 bit long modulus
.....................................................................................................................+++
..............................................................................................+++
e is 65537 (0x10001)
```

- **생성된 키로 인증서 생성**

```
[root@webserver conf.d]# openssl req -new -key private.key -out cert.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:kr
State or Province Name (full name) []:Seoul
Locality Name (eg, city) [Default City]:Ilsan
Organization Name (eg, company) [Default Company Ltd]:playdata
Organizational Unit Name (eg, section) []:admin
Common Name (eg, your name or your server's hostname) []:web.ny.project.com
Email Address []:admin@ny.project.com
```

- **인증서 권한 설정 및 경로 지정**
  - /etc/pki/tls/private/keyname.key : 개인 키 600 또는 400 사용 권한 과 cert_t로 유지
  - /etc/pki/tls/certs/certname.csr : 서명 요청할 때만 생성, CA로 보내는 파일(서명용)
  - /etc/pki/tls/cert/certname.crt : 공개 인증서, 자체 서명된 인증서가 요청될 때만 생성

```
[root@server conf.d]#  chmod 600 private.key cert.crt
[root@server conf.d]#  mv private.key /etc/pki/tls/private/
[root@server conf.d]#  mv cert.* /etc/pki/tls/certs/
```

- **변경사항을 반영하기 위해 httpd 서비스 재시작**

```
[root@server ~]# systemcl restart httpd
```

<br>

<br>

<h2>3. 프로젝트 최종 결과</h2>

- DB서버의 ip주소 대신 (DNS 서버에 설정된) **도메인으로 등록된 Web서버**로 접속했을 때, 정상적으로 진행되는 것을 확인함으로써 성공적으로 **DB서버 & Web서버 & DNS 서버가 연동되었음을  확인**할 수 있음

  <img src="https://user-images.githubusercontent.com/64996121/158543485-1aafd6fc-9cf6-472d-859b-cde90dd3802e.PNG" alt="그림입니다.  원본 그림의 이름: CLP00001ce40002.bmp  원본 그림의 크기: 가로 1280pixel, 세로 657pixel" style="zoom:80%;" />

    



 -  **윈도우에 도메인으로 접속하기**

<img src="https://user-images.githubusercontent.com/64996121/158549963-85594584-7d00-46c4-aa55-99ad896f46eb.PNG" alt="그림입니다.  원본 그림의 이름: CLP00001ce40003.bmp  원본 그림의 크기: 가로 1280pixel, 세로 661pixel" style="zoom:81%;" />  

  

- **https로 접속하기**

<img src="https://user-images.githubusercontent.com/64996121/162645383-aee33894-7c21-4835-9aeb-4316b3aa35fb.png" alt="그림입니다.  원본 그림의 이름: https 접속.PNG  원본 그림의 크기: 가로 1902pixel, 세로 814pixel" style="zoom: 80%;" />    

