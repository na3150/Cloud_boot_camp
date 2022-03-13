<h1> [Linux] 데이터베이스 SQL DML(Data Manipulation Language)</h1>



<h3>📌INDEX</h3>

- [데이터베이스란?](#데이터베이스란)
- [데이터 베이스 설치 및 설정](#데이터-베이스-설치-및-설정)
-  [SQL 문법](#sql-문법)
  - [SQL 문법의 분류](#sql-문법의-분류)
  - [WHERE 조건](#where-조건)
  - [LIKE와 함께 사용하는 와일드 문자](#like와-함께-사용하는-와일드-문자)
-  [DML 구문](#dml-구문)
  - [SELECT](#select)
  - [INSERT](#insert)
  - [UPDATE](#update)
  - [DELETE](#delete)

<br>

<br>

<br>

<h2>데이터베이스란?</h2>

- **데이터를 효율적으로 저장/관리**하기 위해 사용
- 1950년대에 미국에서 처음 사용(용어)
- **데이터베이스 종류**
  - 계층형 DB
  - 관계형 DB
    - 가장 광범위 하게 사용
    - ex) 오라클 DB, MariaDB 등
  - NoSQL
    - ex) AWS DynamoDB 등
- **데이터 베이스의 특징**
  - 실시간 접근성
  - 지속적인 변화
  - 동시 공유
  - 내용에 대한 참조
  - 데이터 논리적 독립성

- **용어 설명**
  - DB : 데이터베이스
  - DBMS : 데이터베이스 관리 시스템
  - DBA : 데이터 베이스 관리자
  - 테이블 : 데이터가 저장된 객체
  - 컬럼(Column) : 테이블에서 데이터들의 속성이 같은 값
  - 행(Row) : 특정 테이블에서 의미 있는 하나의 데이터 집합
  - 필드 : 각가의 데이터 하나를 의미
  - 레코드 :  여러 필드의 조합을 의미

<br>

<br>

<h2>데이터 베이스 설치 및 설정</h2>



<h4>패키지 설치</h4>

- mariadb-server 혹은 mariadb, mariadb-client
- 오류가 날 때는 `nmcli con up ens33`

````shell
t@server ~]# yum -y install mariadb-server
````



<h4>서비스 활성화</h4>

```shell
[root@server ~]# systemctl start mariadb
```



<h4>방화벽 설정</h4>

```shell
[root@server ~]# firewall-cmd --add-service=mysql 
success
```



<h4>기본 보안 설정</h4>

```shell
[root@server ~]# mysql_secure_installation

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

Set root password? [Y/n] 
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

Disallow root login remotely? [Y/n] y
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] n
 ... skipping.

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```



<h4>설정파일</h4>

- /etc/my.cnf

```shell
[root@server ~]# cat /etc/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
# Settings user and group are ignored when systemd is used.
# If you need to run mysqld under a different user or group,
# customize your systemd unit file for mariadb according to the
# instructions in http://fedoraproject.org/wiki/Systemd

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid

#
# include all files from the config directory
#
!includedir /etc/my.cnf.d
```



<h4>사용 시작</h4>

- mysqul -u [계정] -p

```shell
[root@server ~]# mysql -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 9
Server version: 5.5.68-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> 
```



<br>

<br>

<h2>SQL 문법</h2>

- 데이터 베이스에서 데이터 관리를 위해 사용하는 약속된 언어
- 검색/추가/제거 등 다양한 구문이 존재



<h4>SQL 문법의 분류</h4>

- DDL
  - CREATE : 객체 생성
  - ALTER : 객체 수정
  - DROP : 객체 삭제/제거
  - TRUNCATE : 객체 내용 삭제
- DML
  - SELECT : 데이터 조회
  - INSERT : 데이터 추가
  - UPDATE : 데이터 수정
  - DELETE : 데이터 삭제
- DCL
  - GRANT : 권한 부여
  - REVOKE : 권한 제거
- TCL
  - COMMIT : 수정 사항 적용
  - ROLLBACK : 수정 사항 반영 안함



<h4>WHERE 조건</h4>

- WHERE 조건 절에서는 비교, 범위, 집합, 패턴, NULL, 복합 조건 등을 다룬다.
- **비교 연산자**
  - = , <>, < , <= , > , >=
    - <> 는 다름을 의미, != 와 동일
    - 문자열을 비교할 때는 ' = '사용 권장 X
- **범위**
  - BETWEEN
    - BETWEEN A AND B : A이상 B 이하
- **집합**
  - IN, NOT IN
    - PRICE IN (100,200,300) : PRICE(가격)이 100 또는 200 또는 300
- **패턴**
  - LIKE
    - NAME LIKE '기술%' : NAME(이름)이 '기술'로 시작되는 문자열
- **NULL**
  - IS NULL, IS NOT NULL
    - PRICE IS NULL : PRICE(가격)이 NULL 값인 경우
- **복합 조건**
  - AND, OR, NOT
    - (PRICE < 300) AND (NAME LIKE '기술%') : PRICE(가격)이 300미만이고, NAME(이름)이 '기술'로 시작하는 문자열





<h4>LIKE와 함께 사용하는 와일드 문자</h4>

- +, % , [] , [^], _ 가 있다
- `+` : 문자열을 연결
  - 예시: '축구'+'감독' => '축구감독'
- `%` : 0개 이상의 문자열과 일치
  - 예시: LIKE '키워드%' => '키워드'로 시작하는 문자열을 검색
- `[]` : 1개의 문자와 일치
  - 예시: '[0-8]%' => 0-8 사이 숫자로 시작하는 문자열
- `[^]` : 1개의 문자와 불일치
  - 예시: '`[^0-8]%`' => 0-8 사이 숫자로 시작하지 않는 문자열 

- `_` : 특정 위치의 1개의 문자와 일치
  - 예시 : '_동%' : 두 번째 위치에 '동'이 들어가는 문자열



<br>

<br>

<h2>DML 구문</h2>

- DML (Data Manipulation Language) 는 **데이터베이스에 저장된 자료들을 입력, 수정, 삭제, 조회하는 언어**이다.
- 데이터 조작어(DML)에는 SELECT, INSERT, UPDATE, DELETE 가 있다.
- 세미콜론(;)을 작성하기 전까지는 명령이 끝나지 않음



<h4>SELECT</h4>

- **데이터를 조회**하기 위해 사용
- 특정 테이블 및 컬럼을 지정해서 확인
- 필요에 따라 조건을 부여해 알맞은 데이터 검색
- 사용법

```shell
SELECT 컬럼이름

FROM 테이블 이름

WHERE 조건문

ORDER BY 정렬방식 #ASC(오름차순), DESC(내림차순)
```



사용 예

```shell
MariaDB [mysql]> SELECT host
    -> FROM user;
+-----------+
| host      |
+-----------+
| 127.0.0.1 |
| ::1       |
| localhost |
+-----------+
3 rows in set (0.00 sec)
```

```sh
MariaDB [mysql]> SELECT host,user,password,max_updates
    -> FROM user 
    -> WHERE max_updates=0;
+-----------+------+-------------------------------------------+-------------+
| host      | user | password                                  | max_updates |
+-----------+------+-------------------------------------------+-------------+
| localhost | root | *E6CC90B878B948C35E92B003C792C46C58C4AF40 |           0 |
| 127.0.0.1 | root | *E6CC90B878B948C35E92B003C792C46C58C4AF40 |           0 |
| ::1       | root | *E6CC90B878B948C35E92B003C792C46C58C4AF40 |           0 |
+-----------+------+-------------------------------------------+-------------+
3 rows in set (0.00 sec)
```

```shell
MariaDB [mysql]> SELECT host,user,password,max_updates  FROM user WHERE max_updates BETWEEN -1 AND 1;
+-----------+------+-------------------------------------------+-------------+
| host      | user | password                                  | max_updates |
+-----------+------+-------------------------------------------+-------------+
| localhost | root | *E6CC90B878B948C35E92B003C792C46C58C4AF40 |           0 |
| 127.0.0.1 | root | *E6CC90B878B948C35E92B003C792C46C58C4AF40 |           0 |
| ::1       | root | *E6CC90B878B948C35E92B003C792C46C58C4AF40 |           0 |
+-----------+------+-------------------------------------------+-------------+
3 rows in set (0.01 sec)
```

```shell
MariaDB [mysql]> SELECT host,user FROM user WHERE host LIKE 'localhost';
+-----------+------+
| host      | user |
+-----------+------+
| localhost | root |
+-----------+------+
1 row in set (0.00 sec)

```

```shell
MariaDB [mysql]> SELECT host,user FROM user WHERE host LIKE 'local%';
+-----------+------+
| host      | user |
+-----------+------+
| localhost | root |
+-----------+------+
1 row in set (0.00 sec)
```





<h4>INSERT</h4>

- **데이터의 내용을 삽입**할 때 사용하는 명령어

- 사용법

```sh
INSERT INTO 테이블 명 및 컬럼이름
VALUES 입력할 데이터
```



사용 예

```shell
MariaDB [mysql]> SELECT * FROM test;
Empty set (0.00 sec)

MariaDB [mysql]> INSERT INTO test 
    -> VALUES ('Lee', 1, 'Seoul', 'lee@test.example.com');
Query OK, 1 row affected (0.01 sec)

MariaDB [mysql]> SELECT * FROM test;
+------+------+--------+----------------------+
| name | uid  | locate | email                |
+------+------+--------+----------------------+
| Lee  |    1 | Seoul  | lee@test.example.com |
+------+------+--------+----------------------+
1 row in set (0.00 sec)
```

```shell
MariaDB [mysql]> INSERT INTO test
    -> VALUES ('Kim', 3, 'Busan' ,'kim@example.com');
Query OK, 1 row affected (0.00 sec)

MariaDB [mysql]> SELECT * FROM test;
+------+------+--------+----------------------+
| name | uid  | locate | email                |
+------+------+--------+----------------------+
| Lee  |    1 | Seoul  | lee@test.example.com |
| Kim  |    3 | Busan  | kim@example.com      |
+------+------+--------+----------------------+
2 rows in set (0.00 sec)
```





<h4>UPDATE</h4>

- **데이터의 내용을 변경**할 때 사용하는 명령어
- **조건(WHERE)를 작성해주지 않으면 전체 내용이 모두 변경되므로 주의**
- 사용법

```shell
UPDATE 테이블명 및 컬럼이름
SET 새로 입력할 데이터
WHERE 수정할 위치
```



사용 예

```shell
MariaDB [mysql]> SELECT * FROM test;
+------+------+--------+----------------------+
| name | uid  | locate | email                |
+------+------+--------+----------------------+
| Lee  |    1 | Seoul  | lee@test.example.com |
| Kim  |    3 | Busan  | kim@example.com      |
+------+------+--------+----------------------+
2 rows in set (0.00 sec)

MariaDB [mysql]> UPDATE test
    -> SET name = 'Park'
    -> WHERE uid=3;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

MariaDB [mysql]> SELECT * FROM test;
+------+------+--------+----------------------+
| name | uid  | locate | email                |
+------+------+--------+----------------------+
| Lee  |    1 | Seoul  | lee@test.example.com |
| Park |    3 | Busan  | kim@example.com      |
+------+------+--------+----------------------+
2 rows in set (0.00 sec)
```





<h4>DELETE</h4>

- **데이터의 내용을 삭제**할 때 사용하는 명령어
- **조건(WHERE)을 지정해주지 않으면 전체 내용을 삭제하므로 주의**

- 사용법

```shell
DELETE FROM 테이블이름
WHERE 조건
```



사용 예

```sh
MariaDB [mysql]> SELECT * FROM test;
+------+------+--------+----------------------+
| name | uid  | locate | email                |
+------+------+--------+----------------------+
| Lee  |    1 | Seoul  | lee@test.example.com |
| Park |    3 | Busan  | kim@example.com      |
+------+------+--------+----------------------+
2 rows in set (0.00 sec)

MariaDB [mysql]> DELETE FROM test
    -> WHERE uid=3;
Query OK, 1 row affected (0.00 sec)

MariaDB [mysql]> SELECT * FROM test;
+------+------+--------+----------------------+
| name | uid  | locate | email                |
+------+------+--------+----------------------+
| Le  |    1 | Seoul  | lee@test.example.com |
+------+------+--------+----------------------+
1 row in set (0.00 sec)
```

