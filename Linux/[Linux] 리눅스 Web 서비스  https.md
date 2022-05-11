<h2> [Linux] 리눅스 웹 서비스 : https </h2>



👉[미리 보고 와야할 글](https://nayoungs.tistory.com/92)



<h3>📌INDEX</h3>

-  [HTTPS란?](#https란)
-  [HTTPS 구성 및 실습](#https-구성-및-실습)

<br>
<br>
<br>

<h2>HTTPS란?</h2>

- **HTTPS(HTTP Secure)**
  - HTTP protocol 의 암호화된 버전
  - 클라이언트와 서버 간의 모든 커뮤니케이션을 암호화하기 위하여 SSL이나 TLS을 사용
    - SSL (Secure Socket Layer) : 넷스케이프사에서 개발한 인터넷 보안 프로토콜
    - TLS (Transport Layer Security) : SSL이 표준화되면서 바뀐 이름

- **HTTPS 암호화 방식**

<img src="https://user-images.githubusercontent.com/64996121/157842672-d8f5ca82-3844-47ce-bb36-0f472c90648f.PNG" width=800 height=500 />
<br>

1. 클라이언트 -> 서버로 랜덤 데이터와 사용 가능한 암호화 방식을 보낸다.
   - 클라이언트가 생성한 랜덤 데이터(32 byte)
2. 서버 -> 클라이언트로 랜덤 데이터, 사용할 암호화 방식과 SSL 인증서를 보낸다
3. 클라이언트는 서버에게 받은 인증서의 CA가 자신이 들고 있는 CA 리스트에 있는지 확인하고, 있다면 CA의 공개키로 복호화한다. 
   - 이는 곧 CA 비밀키에 의해 암호화됐다는 것이므로 인증서의 신원을 보증해준다. (공개키 암호화 방식)
4. 클라이언트는 자기가 보낸 랜덤 데이터와 서버로부터 받은 랜덤 데이터를 조합하여 임시 키(pre master secret key)를 만든다.
5. 만들어진 임시 키를 인증서의 공개키로 암호화하여 서버에게 보낸다
   - 서버가 준 공개키로 암호화
6. 서버는 자신이 들고있던 비밀키로 임시 키를 복호화한다.
   - 서버가 자신의 개인키로 복호화
7. 이로써 클라이언트와 서버는 동일한 임시 키를 공유하게 되는데, 일련의 과정을 거쳐 master secret 값을 만들고 세션 키를 생성한다.
   - 대칭키 생성
8. 이렇게 만들어진 세션 키로 암호화된 데이터를 주고 받는다(대칭키 암호화 방식)
9. 세션이 종료되면 클라이언트와 서버 모두 세션 키를 폐기한다.

<br>

<br>



<h2>HTTPS 구성 및 실습</h2>

- HTTPS 방화벽 설정
  - https 서비스 설정
  - 443/tcp, 443/udp 포트 열어주기



- 편의를 위해 /etc/httpd/conf.d/에 들어가서 진행

```shell
[root@server ~]# cd /etc/httpd/conf.d 
```



- **SSL/TLS 지원 활성화를 위해 확장 모듈 설치**
  - mod_ssl 패키지 설치

```shell
[root@server conf.d]#  yum -y install mod_ssl
```



- **443/TCP에서 대기하는 기본 가상 호스트에 대해 httpd를 활성화**

```shell
[root@server conf.d]#  systemctl start httpd
[root@server conf.d]#  systemctl enable httpd
[root@server conf.d]#  firewall-cmd --add-service=https --permanent
success
[root@server conf.d]# firewall-cmd --reload
success
```



- **https 구성**
  - **/etc/httpd/conf.d/ssl.conf 에 구성**
  - **SSLEngine** : TLS의 사용 여부
    - on : 사용 하겠다
    - off : 사용하지 않겠다
  - **SSLProtocol** : httpd가 클라이언트와 통신할 프로토콜 목록
    - all : 모든 프로토콜과 통신
    - -[프토토콜] : 해당 프로토콜 제외
  - **SSLCipherSuite** : httpd가 사용할 암호화 나열
  - **SSLCertificateFile** : 가상 호스트의 인증서 위치
  - **SSLCertificateKeyFile** : 가상 호스트의 개인 키 위치

```shell
[root@server conf.d]#  vi ssl.conf
```

```shell
...
<VirtualHost _default_:443>

# General setup for the virtual host, inherited from global configuration
DocumentRoot "/var/www/html" #샵(#)을 제거
ServerName server.test.example.com:443 #샵(#) 제거 후 서버네임 변경

...

SSLEngine on #TLS의 사용 여부

...

SSLProtocol all -SSLv2 -SSLv3 #httpd가 클라이언트와 통신할 프로토콜 목록 (-:제외)

...

SSLCipherSuite HIGH:3DES:!aNULL:!MD5:!SEED:!IDEA #httpd가 사용할 암호화 나열

...

SSLCertificateFile /etc/pki/tls/certs/cert.crt #가상 호스트의 인증서 위치

...

SSLCertificateKeyFile /etc/pki/tls/private/private.key #가상 호스트의 개인 키 위치

...
</VirtualHost>                                  
```



- **인증서 생성**

  - 자체 서명된 인증서를 만들거나(명령어를 통해), CA에 요청해서 서명을 받아 만드는 방법이 있음

  - openssl도구를 이용해서 인증서 생성

    - 개인 키 생성

    ```shell
    [root@server conf.d]#  openssl genrsa -out private.key 2048
    [root@server conf.d]# openssl genrsa -out private.key 2048
    Generating RSA private key, 2048 bit long modulus
    .....................................................................................................................+++
    ..............................................................................................+++
    e is 65537 (0x10001)
    ```

    - 생성된 키로 인증서 생성
      - 정해진 문법임

    ```shell
    [root@server conf.d]# openssl req -new -key private.key -out cert.csr
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) [XX]:kr
    State or Province Name (full name) []:admin
    Locality Name (eg, city) [Default City]:Seoul
    Organization Name (eg, company) [Default Company Ltd]:Seoul
    Organizational Unit Name (eg, section) []:adm
    Common Name (eg, your name or your server's hostname) []:server.test.example.com
    Email Address []:admin@test.example.com
    
    Please enter the following 'extra' attributes
    to be sent with your certificate request
    A challenge password []:
    An optional company name []:
    [root@server conf.d]# openssl x509 -req -signkey private.key -in cert.csr -out cert.crt
    Signature ok
    subject=/C=kr/ST=admin/L=Seoul/O=Seoul/OU=adm/CN=server.test.example.com/emailAddress=admin@test.example.com
    Getting Private key
    ```

    



- **인증서 권한 설정 및 경로 지정**
  - key 파일, csr 파일, crt 파일 모두 지정된 경로에 저장해둘 것
  - /etc/pki/tls/private/keyname.key : 개인 키 600 또는 400 사용 권한 과 cert_t로 유지
  - /etc/pki/tls/certs/certname.csr : 서명 요청할 때만 생성, CA로 보내는 파일(서명용)
  - /etc/pki/tls/cert/certname.crt : 공개 인증서, 자체 서명된 인증서가 요청될 때만 생성
    - 서명 요청이 있고, CA로 전송될 때 CA에서 반환되는 파일 644 cert_t로 유지

```shell
[root@server conf.d]#  chmod 600 private.key cert.crt
[root@server conf.d]#  mv private.key /etc/pki/tls/private/
[root@server conf.d]#  mv cert.* /etc/pki/tls/certs/
```





- **가상 호스트 파일 수정(/etc/httpd/conf.d/[가상 호스트 파일])**
  - /etc/httpd/conf.d/00-vhost.conf
  - /etc/httpd/conf.d/01-vhost.conf

```shell
[root@server conf.d]# vi /etc/httpd/conf.d/00-vhost.conf
```

```shell
<VirtualHost *:80>
    DocumentRoot /var/www/html0
    ServerName vhost0.test.example.com
    ServerAlias vhost0 
    RewriteEngine On                                                   => 추가
    RewriteCond %{HTTPS} off                                           => 추가
    RewriteRule ^(.*)$https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]     => 추가
</VirtualHost>

<Directory /var/www/html0>
    AllowOverride None
    Require all granted
</Directory>
```

```shell
[root@server ~]# vi /etc/httpd/conf.d/01-vhost.conf
```

```shell
<VirtualHost *:80>
    DocumentRoot /var/www/html1
    ServerName vhost1.test.example.com
    ServerAlias vhost1
    RewriteEngine On                                                   => 추가
    RewriteCond %{HTTPS} off                                           => 추가
    RewriteRule ^(.*)$https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]     => 추가
</VirtualHost>

<Directory /var/www/html1>
    AllowOverride None
    Require all granted
</Directory>
```



- **httpd 서비스 재시작**

```shell
[root@server ~]# systemcl restart httpd
```
