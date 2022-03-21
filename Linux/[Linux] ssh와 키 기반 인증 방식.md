<h1> [Linux] ssh와 키 기반 인증 방식</h1>



<h3>📌INDEX</h3>

- [ssh란?](#ssh란)
- [ssh 접속 과정](#ssh-접속-과정)
-  [키 기반 인증 방식](#키-기반-인증-방식)
-  [/etc/ssh/sshd_config](#etcsshsshd_config)

<br>

<br>

<br>

<h2>ssh란?</h2>

- ssh는 secure shell의 줄임말로, 보안적으로 취약했던 기존 telnet을 대체하기위해 설계되었다.
  - telnet : 전통적으로 사용되어 온 원격 접속 서비스로, 암호화하지 않아(평문 전송) 정보 노출의 위험이 크다
- **OpenSSH secure shell(ssh)** 란?
  - **원격 접속  프로토콜**
  - TCP/22번 포트 사용
  - 패킷 전송 시 **암호화**된 패킷 전송
  - IP 및 사용자로 **접속 허용/차단 설정** 가능
  - RSA **공개키 암호화 기법** 사용
  - Client가 Server에 접속 시도 시 공개 키를 전송 받음
  - 전송 받은 공개 키는 **.ssh/know_hosts** 파일에 저장

- ssh는 **비대칭키 암호화 방식과 대칭키 암호화 알고리즘을 동시에 사용**한다
  - 보낼 때 암호화, 받을 때 복호화
- ssh 서버 실행 파일: /etc/sbin/sshd
- ssh 클라이언트 실행 파일: /etc/bin/ssh

- **대칭키 알고리즘** : 데이터 암호화 키와 복호화 키가 동일한 알고리즘
  - 사용되는 키는 비밀키 : 키 1개 사용
- **비대칭키 알고리즘** : 데이터 암호화 키와 복호화 키가 다른 알고리즘
  - 공개키와 개인키 사용 : 키 2개 사용
  - **공개키**: 외부에 공개된 키로 **누구나 공개키를 가지고 있어도 됨**
    - 공개키는 데이터를 암호화하여 전달하며, 공개키와 쌍으로 이루어진 개인키를 이용하여 암호화된 데이터를 복호화
  - **개인키**: **키 생성자만 갖고있는 키**
  - 공개키로 암호화한 것은 개인키로 복호화하고, 개인키로 암호화한 것은 공개키로 복호화
- **ssh 호스트 키** : 통신을 할 때 사용하는 암호 키
  - **/etc/ssh/ 디렉토리에 저장**
  - 키는` ssh_host_키종류_key` 형태로 저장
  - .pub 확장자가 붙어 있으면 공개 키, 붙어있지 않으면 개인 키

```shell
[root@client ~]# ls /etc/ssh
moduli              ssh_host_ecdsa_key.pub    ssh_host_rsa_key
ssh_config          ssh_host_ed25519_key      ssh_host_rsa_key.pub
ssh_host_ecdsa_key  ssh_host_ed25519_key.pub  sshd_config
```



<br>

<br>

<h2>ssh 접속 과정</h2>

- Server(대기) & Client(접속)



1. **client가 server에 접속 요청**
2. **server가 client에게 공개키 전송**
   - 서버의 공개키가 클라이언트에 저장되어있지 않으면 ssh 서버의 공개키를 저장하기 위한 메세지가 출력
3. **client가 비밀키 생성**
   - client는 server로 부터 받은 공개키를 저장한 뒤, 대칭키 알고리즘을 사용하여 암호화를 위한 비밀키를 생성
   - 1쌍(총 2개)의 비밀키를 생성
4. **client가 server의 공개키로 비밀키를 암호화**
   - 총 2개의 비밀키 중 1개의 비밀키를 공개키로 암호화
5. **client가 (공개키로) 암호화된 비밀키를 서버에 전송**
6. **server가 암호화된 비밀키를 서버의 개인키를 통해 복호화**
   - 비밀키를 복호화했을 때, 일치하면 접속 허가
     - 양쪽(client&server)가 동일한 비밀키를 갖게됨



- client가 server에 접속 후, client에 .ssh/known_hosts 파일 생성된 것을 확인할 수 있음
  - **.ssh/known_hosts** : 서버에서 넘겨준 **공개 키 파일**
    - 아래 예시에서 접속 후 client에 파일 생성된 것 확인
  - server에서는 /etc/ssh/ssh_host_ecdsa_key.pub에 저장

```shell
[root@client ~]# ssh root@192.168.56.150
root@192.168.56.150's password:
Last login: Mon Mar  7 17:14:23 2022 from 192.168.56.101
[root@server ~]# exit
logout
Connection to 192.168.56.150 closed.
[root@client ~]# ls -a
.              .bash_profile  .dbus      anaconda-ks.cfg       바탕화면
..             .bashrc        .esd_auth  initial-setup-ks.cfg  비디오
.ICEauthority  .cache         .local     공개                  사진
.bash_history  .config        .ssh       다운로드              서식
.bash_logout   .cshrc         .tcshrc    문서                  음악
[root@client ~]# ls .ssh/
known_hosts
```

<br>

<br>



<h2>키 기반 인증 방식</h2>

- ssh를 사용하여 원격 시스템에 로그인하면, 로그인할 때마다 패스워드 필요
- 키 기반 인증을 이용한 로그인은, **인증된 시스템에서 접근 시도 시 패스워드 인증 없이 로그인 가능**
- 공개 키와 개인 키를 사용하여 인증
  - 통신 시 사용하는 암호화 키와 인증 시 사용하는 키를 구분해야함
- **ssh-keygen** : 키 기반 인증을 위한 공개키와 개인키 생성
- **ssh-copy-id id@server ip address** : client가 생성한 공개키를 서버에 등록
  - **server의 ./ssh에 authorized_keys 가 생성됨**
    - ./ssh/authorized_keys에 키를 등록한 client들이 축적됨
  - **.ssh/authorized_keys(server)의 내용과 .ssh/id_rsa.pub(client)의 내용 동일**
- **.ssh/ 아래에 개인키(is_rsa)와 공개키(id_rsa.pub)**이 생성됨



![키 기반 인증을 이용한 로그인](https://user-images.githubusercontent.com/64996121/157049314-3b8938fb-6b6c-4c5e-836c-98f10cb089e2.PNG)





사용 예

- **키 기반 인증을 위한 개인키와 공개키를 생성**해보자
  - .ssh/ 에 개인키(id_rsa)와 공개키(id_rsa.pub)이 생성된 것을 확인 가능

```shell
[root@client ~]# ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:j7fRuHO3YkUB+kc6A46R/DknperVu3advFBdOQ6BVr4 root@client.encore.class4
The key's randomart image is:
+---[RSA 2048]----+
|            ++   |
|       . . +. o .|
|        + + .o.+.|
|         = * o= +|
|        S B *E.o.|
|         + B +o  |
|        o * oo...|
|       . o.+=.+o.|
|        . o=o=.o.|
+----[SHA256]-----+
[root@client ~]# ls .ssh/
id_rsa  id_rsa.pub  known_hosts
```

- 위에서 **client가 생성한 공개 키를 서버에 등록**해보자

```shell
[root@client ~]# ssh-copy-id root@192.168.56.150
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@192.168.56.150's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'root@192.168.56.150'"
and check to make sure that only the key(s) you wanted were added.
```

- client가 공개 키를 서버에 등록한 뒤, server를 확인해보자
  - **.ssh/authorized_keys가 생성**된 것을 확인할 수 있다

```shell
[root@server ~]# ls .ssh/
authorized_keys
```

- 다시 client에서 서버에 접속해보자
  - **패스워드를 입력하지 않아도 로그인**되는 것을 확인할 수 있다

```shell
[root@client ~]# ssh root@192.168.56.150
Last login: Mon Mar  7 22:09:21 2022 from 192.168.56.101
```







<br>

<br>

<h2>/etc/ssh/sshd_config</h2>

- /etc/ssh/sshd_config : ssh 데몬 설정 파일
  - ssh의 보안 설정이 가능

```shell
[root@client ~]# cat /etc/ssh/sshd_config
#       $OpenBSD: sshd_config,v 1.100 2016/08/15 12:32:04 naddy Exp $

...

# Authentication:

...
#PermitRootLogin yes
...

# To disable tunneled clear text passwords, change to no here!
...
#PasswordAuthentication yes

...
```

- 속성
  - **PermitRootLogin**
    - 비활성화 또는 yes : root 로그인 허용
    - no : root의 로그인 금지
    - without-password : 키 기반 인증으로만 루트 로그인 허용
  - **PasswordAuthentication **
    - yes : 패스워드 인증 방식 사용
    - no : 패스워드 인증 방식 사용하지 않음

- /etc/ssh/sshd_config 파일을 수정한 후에는 sshd를 재시작해주어야 함
  - **systemctl restart sshd**



사용 예

- /etc/ssh/sshd_config에서 PermitRootLogin 속성을 no 로 변경 후 client에서 접속을 시도해보자
  - client에서 서버로의 접속이 거부된 것을 확인할 수 있다

```shell
[root@server ~]# vi /etc/ssh/sshd_config
...
PermitRootLogin no
...
[root@server ~]# systemctl restart sshd
```

```shell
[root@client ~]# ssh root@192.168.56.150
root@192.168.56.150's password:
Permission denied, please try again.
```

- /etc/ssh/sshd_config에서 PermitRootLogin 속성을  without-password로 변경 후 client에서 접속을 시도해보자
  - client가 server에 성공적으로 접속한 것을 확인할 수 있다

```shell
[root@server ~]# vi /etc/ssh/sshd_config
PermitRootLogin without-password
[root@server ~]# systemctl restart sshd.service
```

```shell
[root@client ~]# ssh root@192.168.56.150
Last failed login: Mon Mar  7 23:00:54 KST 2022 from 192.168.56.101 on ssh:notty
There was 1 failed login attempt since the last successful login.
Last login: Mon Mar  7 22:57:54 2022 from 192.168.56.101
[root@server ~]#
```

