<h1>[Linux] CentOs7 : DB서버, Web서버 각각 구축하여 wordpress 구현하기</h1>



<h3>📌INDEX</h3>

- [DB서버 패키지 설치 및 네트워크 설정](#db서버-패키지-설치-및-네트워크-설정)
- [Web 서버 패키지 설치 및 네트워크 설정](#web-서버-패키지-설치-및-네트워크-설정)
- [DB 서버: wordpress 데이터베이스 설정](#db-서버-wordpress-데이터베이스-설정)
- [Web 서버: wordpress 설치](#web-서버-wordpress-설치)
- [Web 서버: wordpress 구성](#web-서버-wordpress-구성)
- [Web 서버: apache 설정](#web-서버-apache-설정)
- [DB서버 & 웹 서버 연결완료](#db서버--웹-서버-연결완료)

<br>
<br>


<h2>DB서버 패키지 설치 및 네트워크 설정</h2>

- 릴리즈 버전 확인

```shell
[root@localhost ~]# cat /etc/redhat-release
CentOS Linux release 7.5.1804 (Core)
```

- yum 업데이트

```shell
[root@localhost ~]# yum -y update
...
```

- MariaDB.repo 파일 생성
  - vi에디터를 통해 해당 내용 저장

```shell
[root@localhost ~]# cat /etc/yum.repos.d/MariaDB.repo
#MariaDB 10.2 CentOS repository list - created 2022-03-09 15:37 UTC
# https://mariadb.org/download/
[mariadb]
name = MariaDB
baseurl = https://mirror.yongbok.net/mariadb/yum/10.2/centos7-amd64
gpgkey=https://mirror.yongbok.net/mariadb/yum/RPM-GPG-KEY-MariaDB
gpgcheck=1
```

- Mariadb-server 버전확인
  - 버전 10.2.43 임을 확인

```shell
[root@localhost ~]# yum info Mariadb-server
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirror.kakao.com
 * extras: mirror.kakao.com
 * updates: mirror.kakao.com
mariadb                                              | 3.4 kB     00:00
(1/2): mariadb/updateinfo                              | 5.8 kB   00:00
(2/2): mariadb/primary_db                              |  59 kB   00:00
Available Packages
Name        : MariaDB-server
Arch        : x86_64
Version     : 10.2.43
Release     : 1.el7.centos
Size        : 24 M
Repo        : mariadb
Summary     : MariaDB database server binaries
URL         : http://mariadb.org
License     : GPLv2
Description : MariaDB: a very fast and robust SQL database server
            :
            : It is GPL v2 licensed, which means you can use the it free of
            : charge under the conditions of the GNU General Public License
            : Version 2 (http://www.gnu.org/licenses/).
            :
            : MariaDB documentation can be found at https://mariadb.com/kb
            : MariaDB bug reports should be submitted through
            : https://jira.mariadb.org

Name        : mariadb-server
Arch        : x86_64
Epoch       : 1
Version     : 5.5.68
Release     : 1.el7
Size        : 11 M
Repo        : base/7/x86_64
Summary     : The MariaDB server and related files
URL         : http://mariadb.org
License     : GPLv2 with exceptions and LGPLv2 and BSD
Description : MariaDB is a multi-user, multi-threaded SQL database server.
            : It is a client/server implementation consisting of a server
            : daemon (mysqld) and many different client programs and
            : libraries. This package contains the MariaDB server and some
            : accompanying files and directories. MariaDB is a community
            : developed branch of MySQL.
```

- yum을 이용하여 mariaDB 설치

```shell
[root@localhost ~]# yum install -y MariaDB-server MariaDB-client
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirror.kakao.com
 * extras: mirror.kakao.com
 * updates: mirror.kakao.com
Resolving Dependencies
--> Running transaction check
---> Package MariaDB-client.x86_64 0:10.2.43-1.el7.centos will be installed
--> Processing Dependency: MariaDB-common for package: MariaDB-client-10.2.43-1.el7.centos.x86_64
---> Package MariaDB-server.x86_64 0:10.2.43-1.el7.centos will be installed
--> Processing Dependency: galera for package: MariaDB-server-10.2.43-1.el7.centos.x86_64
--> Running transaction check
---> Package MariaDB-common.x86_64 0:10.2.43-1.el7.centos will be installed
--> Processing Dependency: MariaDB-compat for package: MariaDB-common-10.2.43-1.el7.centos.x86_64
---> Package galera.x86_64 0:25.3.35-1.el7.centos will be installed
--> Processing Dependency: libboost_program_options-mt.so.1.53.0()(64bit) for package: galera-25.3.35-1.el7.centos.x86_64
--> Running transaction check
---> Package MariaDB-compat.x86_64 0:10.2.43-1.el7.centos will be obsoleting
---> Package boost-program-options.x86_64 0:1.53.0-28.el7 will be installed
---> Package mariadb-libs.x86_64 1:5.5.68-1.el7 will be obsoleted
--> Finished Dependency Resolution

Dependencies Resolved

============================================================================
 Package                 Arch     Version                   Repository
                                                                       Size
============================================================================
Installing:
 MariaDB-client          x86_64   10.2.43-1.el7.centos      mariadb    11 M
 MariaDB-compat          x86_64   10.2.43-1.el7.centos      mariadb   2.2 M
     replacing  mariadb-libs.x86_64 1:5.5.68-1.el7
 MariaDB-server          x86_64   10.2.43-1.el7.centos      mariadb    24 M
Installing for dependencies:
 MariaDB-common          x86_64   10.2.43-1.el7.centos      mariadb    81 k
 boost-program-options   x86_64   1.53.0-28.el7             base      156 k
 galera                  x86_64   25.3.35-1.el7.centos      mariadb   8.1 M

Transaction Summary
============================================================================
Install  3 Packages (+3 Dependent packages)

Total download size: 45 M
Downloading packages:
경고: /var/cache/yum/x86_64/7/mariadb/packages/MariaDB-common-10.2.43-1.el7.centos.x86_64.rpm: Header V4 DSA/SHA1 Signature, key ID 1bb943db: NOKEY
Public key for MariaDB-common-10.2.43-1.el7.centos.x86_64.rpm is not installed
(1/6): MariaDB-common-10.2.43-1.el7.centos.x86_64.rpm  |  81 kB   00:01
(2/6): MariaDB-compat-10.2.43-1.el7.centos.x86_64.rpm  | 2.2 MB   00:00
(3/6): boost-program-options-1.53.0-28.el7.x86_64.rpm  | 156 kB   00:00
(4/6): MariaDB-client-10.2.43-1.el7.centos.x86_64.rpm  |  11 MB   00:04
(5/6): galera-25.3.35-1.el7.centos.x86_64.rpm          | 8.1 MB   00:02
(6/6): MariaDB-server-10.2.43-1.el7.centos.x86_64.rpm  |  24 MB   00:08
----------------------------------------------------------------------------
...
```

- MariaDB 패키지 이름 확인

```shel;
[root@localhost ~]# rpm -qa MariaDB*
MariaDB-server-10.2.43-1.el7.centos.x86_64
MariaDB-client-10.2.43-1.el7.centos.x86_64
MariaDB-common-10.2.43-1.el7.centos.x86_64
MariaDB-compat-10.2.43-1.el7.centos.x86_64
```

- MariaDB-server 실행파일, 데몬명 확인
  - grep 명령어를 함께 사용하여 빠르게 확인

```shell
[root@localhost ~]# rpm -ql MariaDB-server | grep mariadb.service
/usr/bin/mariadb-service-convert
/usr/lib/systemd/system/mariadb.service
/usr/share/man/man1/mariadb-service-convert.1.gz
/usr/share/mysql/systemd/mariadb.service
```

```shell
[root@localhost ~]# rpm -ql MariaDB-server | grep mysql_secure_installation
/usr/bin/mysql_secure_installation
/usr/share/man/man1/mysql_secure_installation.1.gz
```

- mariadb.service 시작 및 활성화

```shell
[root@localhost ~]# systemctl start mariadb.service
[root@localhost ~]# systemctl enable mariadb.service
Created symlink from /etc/systemd/system/mysql.service to /usr/lib/systemd/system/mariadb.service.
Created symlink from /etc/systemd/system/mysqld.service to /usr/lib/systemd/system/mariadb.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/mariadb.service to /usr/lib/systemd/system/mariadb.service.
```

- mysql_secure_installtion 보안 설정
  - root 암호 설정
  - anonymous 접속 차단
  - 원격 접속 허용 X 
    - 웹서버와 DB서버를 따로 구현할 예정이므로
  - test 데이터베이스 삭제 
  - 저장

```shell
[root@localhost ~]# mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none):
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

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

- 방화벽에 mariadb (3306포트 추가)
  - 웹서버와 DB를 별도로 할 예정이므로
  - 설정 후 --list-all 옵션을 통해 추가된 것 확인

```shell
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

- 고정 ip 설정

```shell
[root@localhost ~]# nmcli con add con-name static_db ifname enp0s8 type ethernet ip4 192.168.56.107/24 gw4 192.168.56.1
[root@localhost ~]# nmcli con up static_db
```

- 호스트명 변경

```shell
[root@localhost ~]# hostnamectl set-hostname dbserver
[root@localhost ~]# hostname
dbserver
```




<br>
<br>
<h2>Web 서버 패키지 설치 및 네트워크 설정</h2>

- DB서버와 동일하게 yum update 완료
- 웹서버 설치 및 확인

```shell
[root@localhost ~]# yum install httpd
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirror.kakao.com
 * extras: mirror.kakao.com
 * updates: mirror.kakao.com
base                                                 | 3.6 kB     00:00
extras                                               | 2.9 kB     00:00
mariadb                                              | 3.4 kB     00:00
updates                                              | 2.9 kB     00:00
Package httpd-2.4.6-97.el7.centos.4.x86_64 already installed and latest version
Nothing to do
[root@localhost ~]# rpm -qa httpd
httpd-2.4.6-97.el7.centos.4.x86_64
```

```shell
[root@localhost ~]# yum install httpd
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirror.anigil.com
 * extras: mirror.anigil.com
 * updates: ftp.riken.jp
Package httpd-2.4.6-97.el7.centos.4.x86_64 already installed and latest version
Nothing to do
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

- 방화벽 설정

```shell
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

- PHP 설치 과정

```
[root@localhost ~]# yum install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
Loaded plugins: fastestmirror, langpacks
remi-release-7.rpm                                   |  23 kB     00:00
Examining /var/tmp/yum-root-iF3Njp/remi-release-7.rpm: remi-release-7.9-3.el7.remi.noarch
Marking /var/tmp/yum-root-iF3Njp/remi-release-7.rpm to be installed
Resolving Dependencies
--> Running transaction check
---> Package remi-release.noarch 0:7.9-3.el7.remi will be installed
--> Processing Dependency: epel-release = 7 for package: remi-release-7.9-3.el7.remi.noarch
Loading mirror speeds from cached hostfile
 * base: mirror.anigil.com
 * extras: mirror.anigil.com
 * updates: ftp.riken.jp
--> Running transaction check
---> Package epel-release.noarch 0:7-11 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

============================================================================
 Package          Arch       Version              Repository           Size
============================================================================
Installing:
 remi-release     noarch     7.9-3.el7.remi       /remi-release-7      35 k
Installing for dependencies:
 epel-release     noarch     7-11                 extras               15 k

Transaction Summary
============================================================================
Install  1 Package (+1 Dependent package)

Total size: 50 k
Total download size: 15 k
Installed size: 59 k
Is this ok [y/d/N]: y
Downloading packages:
epel-release-7-11.noarch.rpm                           |  15 kB   00:00
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : epel-release-7-11.noarch                                 1/2
  Installing : remi-release-7.9-3.el7.remi.noarch                       2/2
  Verifying  : remi-release-7.9-3.el7.remi.noarch                       1/2
  Verifying  : epel-release-7-11.noarch                                 2/2

Installed:
  remi-release.noarch 0:7.9-3.el7.remi

Dependency Installed:
  epel-release.noarch 0:7-11

Complete!
```

```shell
[root@localhost ~]# yum -y install yum-utils
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
epel/x86_64/metalink                                 | 8.1 kB     00:00
 * base: mirror.anigil.com
 * epel: ftp.riken.jp
 * extras: mirror.anigil.com
 * remi-safe: ftp.riken.jp
 * updates: ftp.riken.jp
epel                                                 | 4.7 kB     00:00
remi-safe                                            | 3.0 kB     00:00
(1/4): epel/x86_64/group_gz                            |  96 kB   00:01
(2/4): epel/x86_64/updateinfo                          | 1.0 MB   00:02
(3/4): remi-safe/primary_db                            | 2.1 MB   00:05
(4/4): epel/x86_64/primary_db                          | 7.0 MB   00:07
Package yum-utils-1.1.31-54.el7_8.noarch already installed and latest version
Nothing to do
```

```shell
[root@localhost ~]# yum-config-manager --disable remi-php54 (php5.4버전 끄기)
[root@localhost ~]# yum-config-manager --enable remi-php74 (php7.4버전 켜기)
```

- php 설치

```shell
[root@localhost ~]# yum install php74
[root@localhost ~]# yum install -y php74-php php-cli php74-scldevel
```

- 웹 데몬 재시작

```shell
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

- php 및 httpd 버전 확인

```shell
[root@localhost ~]# rpm -qa php74
php74-1.0-3.el7.remi.x86_64
[root@localhost ~]# rpm -qa httpd
httpd-2.4.6-97.el7.centos.4.x86_64
```

- 고정 ip 설정

```shell
[root@localhost ~]# nmcli con add con-name static_web ifname enp0s8 type ethernet ip4 192.168.56.101/24 gw4 192.168.56.2
연결 'static_web' (d8a09917-af58-4986-9942-33e2f7cc1ba4)이 성공적으로 추가되었습니다.
[root@localhost ~]# nmcli con up static_web
연결이 성공적으로 활성화되었습니다 (D-Bus 활성 경로: /org/freedesktop/NetworkManager/ActiveConnection/5)
```

- 호스트명 설정

```shell
[root@localhost ~]# hostnamectl set-hostname webserver
[root@localhost ~]# hostname
webserver
```

- php의 MySQL을 확장패키지 설치

```shell
[root@localhost ~]# yum install php php-mysql
```

- apache를 위한 80번 포트 열어주기

```shell
[root@dbserver ~]# firewall-cmd --add-port=80/tcp --permanent
success
[root@dbserver ~]# firewall-cmd --reload
success
```


<br>
<br>
<h2>DB 서버: wordpress 데이터베이스 설정</h2>

```shell
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
<h2>Web 서버: wordpress 설치</h2>

- URL로 설치하기 위한 wget 패키지 설치

```shell
[root@webserver ~]# yum -y install wget
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirror.anigil.com
 * epel: ftp.riken.jp
 * extras: mirror.anigil.com
 * remi-php74: ftp.riken.jp
 * remi-safe: ftp.riken.jp
 * updates: ftp.riken.jp
Package wget-1.14-18.el7_6.1.x86_64 already installed and latest version
Nothing to do
```

- URL로 wordpress 설치
  - URL:  https://wordpress.org/latest.tar.gz

```shell
[root@webserver ~]# wget https://wordpress.org/latest.tar.gz
--2022-03-15 10:51:31--  https://wordpress.org/latest.tar.gz
Resolving wordpress.org (wordpress.org)... 198.143.164.252
Connecting to wordpress.org (wordpress.org)|198.143.164.252|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 18722604 (18M) [application/octet-stream]
Saving to: ‘latest.tar.gz’

28% [=========>                         ] 5,418,601   14.9KB/s   in 1m 47s

2022-03-15 11:08:18 (49.4 KB/s) - Read error at byte 5418601/18722604 (성공). Retrying.

--2022-03-15 11:08:19--  (try: 2)  https://wordpress.org/latest.tar.gz
Connecting to wordpress.org (wordpress.org)|198.143.164.252|:443... connected.
HTTP request sent, awaiting response... 206 Partial Content
Length: 18722604 (18M), 13304003 (13M) remaining [application/octet-stream]
Saving to: ‘latest.tar.gz’

100%[++++++++++========================>] 18,722,604  1.86MB/s   in 24s

2022-03-15 11:08:45 (530 KB/s) - ‘latest.tar.gz’ saved [18722604/18722604]

[root@webserver ~]# file latest.tar.gz
latest.tar.gz: gzip compressed data, from Unix, last modified: Fri Mar 11 09:39:52 2022
```

- -C 옵션을 통해 위치 지정하여 아카이브 해제
  - 해제할 디렉토리: /var/www/html

```shell
[root@webserver ~]# tar -xvzf latest.tar.gz -C /var/www/html
wordpress/
wordpress/xmlrpc.php
wordpress/wp-blog-header.php
wordpress/readme.html
wordpress/wp-signup.php
wordpress/index.php
wordpress/wp-cron.php
wordpress/wp-config-sample.php
wordpress/wp-login.php
wordpress/wp-settings.php
wordpress/license.txt
wordpress/wp-content/
....
```

```shell
[root@webserver ~]# ls /var/www/html/wordpress
index.php        wp-blog-header.php    wp-includes        wp-settings.php
license.txt      wp-comments-post.php  wp-links-opml.php  wp-signup.php
readme.html      wp-config-sample.php  wp-load.php        wp-trackback.php
wp-activate.php  wp-content            wp-login.php       xmlrpc.php
wp-admin         wp-cron.php           wp-mail.php
```



-  게시판에 업로드되는 파일을 저장하기 위한 디렉토리 생성

```shell
[root@webserver ~]# mkdir /var/www/html/wordpress/uploads
```



<br>

<br>

<h2>Web 서버: wordpress 구성</h2>

- wordpress 샘플 파일 확인

```shell
[root@webserver ~]# ls -l /var/www/html/wordpress/wp-config-sample.php
-rw-r--r--. 1 nobody nfsnobody 3001 12월 14 17:44 /var/www/html/wordpress/wp-config-sample.php
```

- /var/www/html/wordpress/ 로 이동

```shell
[root@webserver ~]# cd /var/www/html/wordpress/
[root@webserver wordpress]#
```

- wp-config-sample.php 파일을 복사하여 사용

```shell
[root@webserver wordpress]# cp wp-config-sample.php wp-config.php
```

- 압축해제된 wordpress 디렉토리와 그 하위 디렉토리의 소유자,소유그룹을 apache로 변경

```shell
[root@webserver wordpress]# chown -R apache:apache /var/www/html/wordpress
```

```shell
[root@webserver wordpress]# ls -l /var/www/html/wordpress/
합계 216
-rw-r--r--.  1 apache apache   405  2월  6  2020 index.php
-rw-r--r--.  1 apache apache 19915  1월  1 09:15 license.txt
-rw-r--r--.  1 apache apache  7437 12월 29 02:38 readme.html
drwxr-xr-x.  2 apache apache     6  3월 15 11:28 uploads
-rw-r--r--.  1 apache apache  7165  1월 21  2021 wp-activate.php
drwxr-xr-x.  9 apache apache  4096  3월 11 09:39 wp-admin
-rw-r--r--.  1 apache apache   351  2월  6  2020 wp-blog-header.php
-rw-r--r--.  1 apache apache  2338 11월 10 08:07 wp-comments-post.php
-rw-r--r--.  1 apache apache  3001 12월 14 17:44 wp-config-sample.php
-rw-r--r--.  1 apache apache  3001  3월 15 11:37 wp-config.php
drwxr-xr-x.  4 apache apache    52  3월 11 09:39 wp-content
-rw-r--r--.  1 apache apache  3939  8월  4  2021 wp-cron.php
drwxr-xr-x. 26 apache apache 12288  3월 11 09:39 wp-includes
-rw-r--r--.  1 apache apache  2496  2월  6  2020 wp-links-opml.php
-rw-r--r--.  1 apache apache  3900  5월 16  2021 wp-load.php
-rw-r--r--.  1 apache apache 47916  1월  4 17:30 wp-login.php
-rw-r--r--.  1 apache apache  8582  9월 23 06:01 wp-mail.php
-rw-r--r--.  1 apache apache 23025 12월  1 02:32 wp-settings.php
-rw-r--r--.  1 apache apache 31959 10월 25 09:23 wp-signup.php
-rw-r--r--.  1 apache apache  4747 10월  9  2020 wp-trackback.php
-rw-r--r--.  1 apache apache  3236  6월  9  2020 xmlrpc.php
```

- vim 에디터를 통해 wp-config.php 파일 수정

```shell
[root@webserver wordpress]# cat wp-config.php
<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', '[데이터베이스 이름]' );

/** Database username */
define( 'DB_USER', '[사용자]' );

/** Database password */
define( 'DB_PASSWORD', '[사용자 암호]' );

/** Database hostname */
define( 'DB_HOST', '[데이터베이스 서버 ip주소]' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );
```



<br>

<br>

<h2>Web 서버: apache 설정</h2>

- /etc/httpd/conf/httpd.conf 파일 수정
  - DocumentRoot 수정 -> /var/www/html/wordpress
  - IfModule 수정 : index.html -> index.php

```shell
[root@webserver ~]# vim /etc/httpd/conf.d/httpd.conf
[root@webserver ~]# cat /etc/httpd/conf.d/httpd.conf
...
DocumentRoot "/var/www/html/wordpress"
...
<IfModule dir_module>
    DirectoryIndex index.php
</IfModule>
```

- SELinux 설정

```shell
[root@webserver ~]# setenforce 0
```

- 'Your PHP installation appears to be missing the MySQL extension which is required by WordPress.' 오류 해결방법
   - 해당 오류로 상당히 애를 먹었는데, 다음 명령어 실행을 통해서 해결할 수 있었다

```shell
yum -y install php php-mysql
```


<br>
<br>

<h2>DB서버 & 웹 서버 연결완료</h2>

- http://[ip주소] 접근
  - DocumentRoot : /var/www/html/wordpress



<img src="https://user-images.githubusercontent.com/64996121/158532228-b7d6c8e5-759a-4a79-964f-b9dc30232081.PNG" style="zoom:60%;" />



<img src="https://user-images.githubusercontent.com/64996121/158532261-d614e7f2-a73a-4d30-8afa-d5ede28080c5.jpg" style="zoom:57%;" />



<img src="https://user-images.githubusercontent.com/64996121/158532330-3f312d41-5d8a-48ca-be17-356fa3e5f7eb.PNG" style="zoom:60%;" />



<img src="https://user-images.githubusercontent.com/64996121/158532384-08a39c60-8afd-407b-880d-0dc50ac21d7c.PNG" style="zoom:60%;" />



- DB서버에서 wordpress 테이블 확인
  - 정상적으로 반영된 것을 확인할 수 있다

```shell
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



