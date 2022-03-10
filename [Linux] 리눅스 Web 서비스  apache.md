<h1> [Linux] 리눅스 Web 서비스 : apache </h1>



<h3>📌INDEX</h3>

- [웹 서버란?](#웹-서버란)
  - [정적 웹 서버 동작 방식](#정적-웹-서버-동작-방식)
  - [동적 웹 서버 동작 방식](#동적-웹-서버-동작-방식)
-  [apache](#apache)
  - [apache 설정](#apache-설정)
  - [apache 구성](#apache-구성)
  - [apache 웹페이지 설정](#apache-웹페이지-설정)
-  [가상 호스트(Virtual Hosts)](#가상-호스트)
-  

<br>

<br>

<h2>웹 서버란?</h2>

- **웹(Web) 서버**
  - 웹 서비스(Web Service)를 제공하는 서버
  - 인터넷만 연결되어 있다면, 어느 곳에서든 웹 서버에 방문 가능
  - 네트워크를 통해 약속된 주소로 요쳥 시 지정된 컨텐츠를 제공
  - 기본적으로 정적인 컨텐츠만 제공
  - 별도의 구성 시 동적인 컨텐츠 제공 가능
    - 모듈을 추가함으로써 ex) python, php 등
- **웹 서버의 기본적인 동작**
  - 웹 브라우저로 Client가 페이지 요청
  - HTTP (Hypertext Transfer Protocol)을 사용하여 웹 브라우저와 웹 서버간 의사소통
  - Client가 페이지 요청 시 웹 서버는 요청 받은 페이지를 보내줌



<h4>정적 웹 서버 동작 방식</h4>

- 정적 웹이란? 
  - 언제나 동일한 값을 표시(static)
  - HTTP 서버(SW)가 있는 컴퓨터(하드웨어)로 구성
  - 서버가 불려진 파일을 클라이언트의 브라우저로 전송

<img src="C:\Users\USER\Desktop\정적 웹 서버 동작 방식.PNG" style="zoom:67%;" />



1. 클라이언트 즉, 웹 브라우저를 통해 80번 포트로 웹 서버에 연결
2. 사용자 문서 (index.html)를 요청
3. 웹 서버가 클라이언트가 요청한 파일을 시스템에서 검색
4. 웹 서버가 요청한 파일을 읽음
5. 웹 서버가 파일을 클라이언트의 웹 브라우저에게 제공





<h4>동적 웹 서버 동작 방식</h4>

- 동적 웹이란?
  - 매번 웹 페이지를 불러올 때마다 새로운 내용을 표시 (dynamic)
  - 정적 웹 서버와 추가적인 소프트웨어로 구성
  - 서버가 HTTP서버를 통해 클라이언트의 브라우저로 전송하기 전에, 서버가 업데이트를 하기 때문에 동적이라 칭함

<img src="C:\Users\USER\Desktop\동적 웹 서버 동작 방식.PNG" style="zoom:67%;" />

1. 클라이언트 즉, 웹 브라우저를 통해 80번 포트로 웹 서버에 연결
2. 사용자 문서에 동적인 페이지를 표현하는 php 프로그램 요청
3. 웹 서버가 php 프로그램을 실행시킨 후 클라이언트가 요청한 매개변수 넘겨줌
4. 웹 서버가 php 프로그램으로부터 생성된 결과를 읽어들임
5. php 프로그램으로부터의 결과를 웹 서버는 클라이언트의 브라우저에 전송



<br>

<br>

<h2>apache</h2>

- **Apache란?** 
  - 월드 와이드 웹(www) 서버용 소프트웨어
  - 일반적으로 리눅스에서는 apache 사용

- **Apache 특징**
  - 매우 뛰어난 성능과 기능을 가지고 있는 공개형 웹 서버 프로그램
  - 다양한 플랫폼에서 동작할 수 있도록 강력하고 유연하게 설계
  - 보조적 프로그램이 다양
  - 공개된 형태로 개발
  - 다양한 상황에 따른 서비스 지원
  - 동적 공유 객체 지원
  - 모듈 사용으로 기능 추가가 용이
    - php, python 등의 모듈 사용 가능
  - 유연한 설정



<h4>apache 설정</h4>

- 패키지 설치

```shell
[root@server ~]# yum -y install httpd
```

- 서비스 시작 및 활성화

```shell
[root@server ~]# systemctl start httpd
[root@server ~]# systemctl enable httpd
```

- 방화벽 설정

```shell
[root@server ~]# firewall-cmd --add-service=http --permanent
[root@server ~]# firewall-cmd --reload
```





<h4>apache 구성</h4>

- 리눅스 아파치 웹 서버의 메인 설정 파일 : **/etc/httpd/conf/httpd.conf**
  - /etc/httpd/conf/httpd.conf에 직접 설정 
  - 또는 /etc/httpd/conf.d/ 에 추가적인 설정파일 생성 후, 서비스를 재시작하면 적용됨
- 키/값 구성 지시문과 HTML과 유사
  -  <Blockname parameter> 블록 2부분으로 구성
- **블록 외부**의 키/값 구성은 **전체 서버 구성에 영향**
- **블록 내부**의 지시문은 **지정된 구성이나 설정한 요구 조건이 충족될 때만 적용**

```shell
ServerRoot "/etc/httpd" # 구성 파일이 참조하는 위치의 기준점

Listetn 80 # httpd에 모든 인터페이스의 포트 80/TCP에서 수신 대기(중복 사용 금지)

Include conf.modules.d/*.conf # 모듈을 로드할 구성파일

User apache # httpd 데몬이 시작되면 실행되는사용자 및 그룹 지정
Group apache

ServerAdmin root@localhost # httpd에서 오류가 발생했을 때 문제를 보고 하는 곳

 # 지정된 디렉토리및 모든 하위 디렉토리에 대한 구성 지시문 설정
 # 블록 내부 지시문 : 세부 설정
<Directory />
AllowOverride none
Require all denied
</Directory>
```

- **ServerRoot** : apache의 기본 root 경로이며, 절대 경로로 설정해주어야함
- **Listen** [ip주소] [포트번호] : 사용할 포트 지정
  - ip주소를 적지 않는 경우, 모든 주소에 대해서 허용
- **ServerAdmin** [이메일 또는 호스트] : 서버 관리자 이메일(주소) 입력
  - 오류가 발생했을 때 문제 보고하는 곳
- **<Directory [위치] >** ~ </Directory> : [위치]에 대한 접근 제어

```shell
DocumentRoot "/var/www/html" # httpd가 요청된 파일을 검색할 위치 결정
<Directory "/var/www/">
AllowOverride None
Require all granted
</Directory>
<Directory "/var/www/html">
Options Indexes FollowSymLinks
AllowOverride None
Require all granted
</Directory>
<IfModule dir_module> # 지정된 디렉토리가 요청될 때 사용할 파일을 지정
DirectoryIndex index.html
</IfModule>
```

- **DocumentRoot** : 웹 문서가 위치하는 디렉토리를 지정
  - httpd가 요청된 파일을 검색할 위치
  - **/var/www/html 이 default**

- **<IfModule dir_module>** [파일] </IfModule> : 지정된 디렉토리가 요청될 때 사용할 파일을 지정
- **ServerName** : 서버 네임 지정
  - DNS에 등록 해둬야함

<br>

<br>

<h4>apache 웹페이지 설정</h4>

- /var/www/html/에 사용하고자하는 웹 페이지를 저장

```shell
[root@server ~]# echo "test page" > /var/www/html/index.html
[root@server ~]# cat /var/www/html/index.html
test page
[root@server ~]# curl [서버 IP]
test page
```

- 직접 브라우저에 검색해보기
  - 방화벽 설정 : 80번 포트 열어주기
  - 방화벽 설정 후 브라우저에 "http://[ip주소]" 입력하면 정상적으로 출력

```shell
[root@server ~]# firewall-cmd --add-port=80/tcp --permanent
success
[root@server ~]# firewall-cmd --reload
success
```

 <img src="C:\Users\USER\Desktop\http 출력.PNG" style="zoom:60%;" />

<br>

<br>

<h2>가상 호스트</h2>

- **가상 호스트**
  - **한 시스템에서 여러개의 도메인과 호스트 이름을 구분하여 웹 서비스** 가능
  - 연결된 서버의 IP주소와 클라이언트가 요청한 호스트 이름의 조합에 따라 다양한 구성 설정 가능
  - 이름 기반의 가상 호스팅
    - 네임 서버가 각 호스트명이 올바른 IP주소로 대응하도록 가상 호스트 설정
    - 하나의 IP 주소를 가지고 여러 호스트에 대해서 웹 서비스 제공
  - IP 기반의 가상 호스팅
    - 하나의 아파치 웹 서버에서 물리적인 네트워크 카드에 여러 개의 IP 할당
    - 각 호스트들이 서로 다른 IP 주소를 이용할 수 있도록 하는 방식

- **가상 호스트 구성**

  - 기본 구성 내에 <VirtualHost> 블록을 사용하여 구성 가능
  - 편리한 관리를 위해 /etc/httpd/conf/httpd.conf 내에 정의하지 않고, **/user/share/doc/httpd-2.4.6/ 디렉토리 내의 템플릿 파일로 구성**

  ```shell
  [root@server ~]# ls /usr/share/doc/httpd-2.4.6/
  ABOUT_APACHE        httpd-info.conf       httpd-multilang-errordoc.conf  proxy-html.conf
  CHANGES             httpd-languages.conf  httpd-vhosts.conf              README
  httpd-dav.conf      httpd-manual.conf     LICENSE                        VERSIONING
  httpd-default.conf  httpd-mpm.conf        NOTICE
  ```

  - 가상 호스트 구성 템플릿 파일인 **/usr/share/doc/httpd-2.4.6/httpd-vhosts.conf 을 이용**

  ```shell
  <VirtualHost *:@@Port@@> # 모든 IP(*)에 대해 해당 포트 열어줌
      ServerAdmin webmaster@dummy-host.example.com #관리자 설정-> 이미 httpd.conf 파일에 설정
      DocumentRoot "@@ServerRoot@@/docs/dummy-host.example.com" #어디에 있는 데이터 사용할 것인지
      ServerName dummy-host.example.com #서버네임 지정
      ServerAlias www.dummy-host.example.com #서버네임 전환
      ErrorLog "/var/log/httpd/dummy-host.example.com-error_log" #에러 로그
      CustomLog "/var/log/httpd/dummy-host.example.com-access_log" common #커스텀 로그
  </VirtualHost>
  ```

  - 해당 파일을 **/etc/httpd/conf.d/ 디렉토리 내에** 이름을 바꾸어 복사
  - **/etc/httpd/conf.d/site1.conf 파일에 정의**

  ```shell
  [root@server ~]# cp /usr/share/doc/httpd-2.4.6/httpd-vhosts.conf /etc/httpd/conf.d/site1.conf
  ```

  ```shell
  <Directory /srv/site1/www> # 아래 정의된 DocumentRoot에 엑세스 가능
  Require all granted # 디렉토리를 따로 생성할 것
  AllowOverride None
  </Directory>
  <VirtualHost 192.168.0.1:80> # 블록의 기본 태그, 해당 IP와 포트 고려
  DocumentRoot /srv/site1/www # DocumentRoot 정의 가상호스트 내에서만 유효
  ServerName site1.example.com # 가상호스트 도메인네임 ServerAlias문이 사용될 수도 있음
  ServerAdmin webmaster@site1.example.com # 가상 호스트 관리자의 이메일 주소
  ErrorLog "logs/site1_error_log" # 가상호스트 오류 메시지 위치
  CustomLog "logs/site1_access_log" combined # 가상 호스트 액세스 메시지
  </VirtualHost>
  ```

  



<h4>실습</h4>

- /etc/httpd/conf.d/00-vhost.conf 파일 생성
  - 모든 주소에 대해서 80포트 열어줌
  - httpd가 요청된 파일을 검색할 위치 : /var/www/html0
  - 서버 이름 : vhost0.test.example.com
  - 또 다른 서버 이름 : vhost0
  - 해당 디렉토리 : /var/www/html0

```shell
[root@server ~]# vim /etc/httpd/conf.d/00-vhost.conf
<VirtualHost *:80>
	DocumentRoot /var/www/html0
	ServerName vhost0.test.example.com
	ServerAlias vhost0
</VirtualHost>

<Directory /var/www/html0>
	AllowOverride none
	Require all granted
</Directory>
```

- /etc/httpd/conf.d/01-vhost.conf 파일 생성
  - 00-vhost.conf 파일 복사해서 사용

```shell
[root@server ~]# cp /etc/httpd/conf.d/00-vhost.conf /etc/httpd/conf.d/01-vhost.conf 
```

```shell
[root@server ~]# cat /etc/httpd/conf.d/01-vhost.conf 
<VirtualHost *:80>
	DocumentRoot /var/www/html1
	ServerName vhost1.test.example.com
	ServerAlias vhost1
</VirtualHost>

<Directory /var/www/html1>
	AllowOverride none
	Require all granted
</Directory>
```

- 파일 생성(웹  페이지 저장)

```shell
[root@server ~]# mkdir /var/www/html{0..1}
[root@server ~]# echo vhost0 test > /var/www/html0/index.html
[root@server ~]# echo vhost1 test > /var/www/html1/index.html
[root@server ~]# cat /var/www/html0/index.html 
vhost0 test
[root@server ~]# cat /var/www/html1/index.html 
vhost1 test

```

- /etc/hosts에 등록

```shell
[root@server ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.238.100 server.test.example.com server vhost1.test.example.com vhost1 vhost0.test.example.com vhost0
```

- httpd 서비스 재시작

```shell
[root@server ~]# systemctl restart httpd
```

- 확인
  - IP 주소로 curl 했을 때에는 0번에 있는 것을 default값 보다 우선 시해서 적용

```shell
[root@server ~]# curl vhost0
vhost0 test
[root@server ~]# curl vhost1
vhost1 test
[root@server ~]# curl 192.168.238.100
vhost0 test
[root@server ~]# curl vhost0.test.example.com
vhost0 test
[root@server ~]# curl vhost1.test.example.com
vhost1 test
```

