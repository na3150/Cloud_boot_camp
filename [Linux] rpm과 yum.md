<h1> [Linux] rpm과 yum</h1>



<h3>📌INDEX</h3>

- [RPM Package Manager](#rpm-package-manager)
  - [rpm 명령어](#rpm-명령어)
-  [yum](#yum)
  - [yum 명령어](#yum-명령어)
-  [repository 파일 설정](#repository-파일-설정)

<br>

<br>

<h2>RPM Package Manager</h2>

- **RPM(RedHat Package Manager)** 이란, 레드햇 계열의 리눅스 배포판에서 사용하는 프로그램(패키지) 설치관리 도구이다.
  - **프로그램(패키지)을 쉽게 설치하기 위한 도구**
- 아카이브에서 파일 시스템으로 추출된 소프트웨어로 작업하는 것보다 간단하다
- 설치된 패키지 확인 가능
- 제거된 패키지 파일 잔재 추척
- 설치된 소프트웨어의 지원 패키지 확인
- 시스템 로컬 RPM 데이터 베이스에 패키지 정보 저장
- 패키지 파일 이름 구성
  - 패키지명과 사용되는 서비스명이 다를 수 있음



<img src="https://user-images.githubusercontent.com/64996121/156574717-50d59db4-cda8-424f-a45f-c55ca008a123.png" width=380 height=90 />



<h4>rpm 명령어</h4>

- **rpm [옵션]**

- 옵션

  - -q : 쿼리

  - -a : 시스템에 설치되어 있는 모든 패키지
  - -i : 패키지에 대한 정보
  - -c : 패키지의 설정파일들을 출력
  - -d : 패키지의 문서(document)를 출력
  - -l : 패키지의 모든 파일(list) 출력
  - -f : 파일이나 디렉토리가 어떠한 패키로 인해서 파생(생성)되었는지 알려줌
    - 경로를 볼 수 있음



**사용 예**

- 패키지 정보 확인

```shell
[root@localhost ~]# rpm -qi openssh
Name        : openssh
Version     : 7.4p1
Release     : 16.el7
Architecture: x86_64
Install Date: 2022년 02월 21일 (월) 오후 02시 53분 07초
Group       : Applications/Internet
...
```

- 설정 파일 확인

```shell
[root@localhost ~]# rpm -qc openssh
/etc/ssh/moduli
```

- 패키지의 문서(document)확인

```shell
[root@localhost ~]# rpm -qd openssh
/usr/share/doc/openssh-7.4p1/CREDITS
/usr/share/doc/openssh-7.4p1/ChangeLog
/usr/share/doc/openssh-7.4p1/INSTALL
...
```

- 패키지를 구성하는 모든 파일(list) 확인

```shell
[root@localhost ~]# rpm -ql openssh
/etc/ssh
/etc/ssh/moduli
/usr/bin/ssh-keygen
/usr/libexec/openssh
/usr/libexec/openssh/ctr-cavstest
...
```





- **rpm 패키지 설치 및 업데이트**
  - **rpm -Uvh [패키지 파일 경로]**

```shell
[root@localhost ~]# rpm -Uvh /media/cdrom/Packages/ksh-20120801-137.el7.x86_64.rpm
경고: /media/cdrom/Packages/ksh-20120801-137.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
준비 중...                         ################################# [100%]
Updating / installing...
   1:ksh-20120801-137.el7             ################################# [100%]
```



- **rpm 패키지 삭제**
  - **rpm -e [패키지명]**

```shell
[root@localhost ~]# rpm -e ksh
```



- **rpm 설치 패키지 확인**
  - **rpm -qa** : 설치되어있는 모든 패키지 확인
  - grep 명령어를 통해, 특정 패키지 설치 여부 확인 가능

```shell
[root@localhost ~]# rpm -qa
NetworkManager-libnm-1.10.2-13.el7.x86_64
dejavu-sans-mono-fonts-2.33-6.el7.noarch
perl-Font-AFM-1.20-13.el7.noarch
libchamplain-gtk-0.12.15-1.el7.x86_64
crash-7.2.0-6.el7.x86_64
gsound-1.0.2-2.el7.x86_64
poppler-data-0.4.6-3.el7.noarch
...
```

```shell
[root@localhost ~]# rpm -qa | grep ksh
ksh-20120801-137.el7.x86_64
```



- ⭐**rpm의 단점** : rpm은 저수준 도구
  - 패키지 설치를 위해 반드시 **rpm 파일이 있어야함**
  - **종속성(의존성)을 해결할 수 없음**

예시

```shell
[root@localhost ~]# rpm -Uvh /media/cdrom/Packages/mysql-connector-odbc-5.2.5-7.el7.x86_64.rpm
경고: /media/cdrom/Packages/mysql-connector-odbc-5.2.5-7.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
오류: Failed dependencies:
        libodbc.so.2()(64bit) is needed by mysql-connector-odbc-5.2.5-7.el7.x86_64        libodbcinst.so.2()(64bit) is needed by mysql-connector-odbc-5.2.5-7.el7.x86_64
```

- 다른 패키지 설치가 우선이라는 경고 메세지가 뜬다

  - 즉, 종속성(의존성) 문제를 해결하지 못함

  - 오류: Failed dependencies 부분을 보면, 설치해야하는 모듈·라이브러리명을 알려줌
  - 또한 설치가 필요한 패키지를, 패키지명이 아닌 라이브러리명으로 명시하기 때문에 정확히 설치해야하는 패키지를 찾는 것 조차 쉽지 않음 

- 이러한 이유들로, rpm은 패키지의 설치보다는 정보를 보거나 관리할 때 많이 사용한다

<br>

<br>



<h2>yum</h2>

- YUM(Yellowdog Updater Modified) : **인터넷을 통하여 필요한 파일을 저장소(Repository)에서 자동으로 모두 다운로드해서 설치하는 방식**
  - rpm 명령은 해당 파일을 갖고 있어야하나, yum 명령은 없어도 된다

- 패키지 종속성 완화
  - rpm은 종속성(의존성) 해결 안됨 - 모든 패키지 나열
  - ⭐**yum은** 패키지의 여러 레포지토리 및 **종속성(의존성) 해결 가능**
    - 의존성이 필요한 패키지를 자동으로 설치
    - 단, **인터넷에 연결되어있어야함**

- **yum은 항상 최신 버전을 설치**



<h4>yum 명령어</h4>

- **yum [sub-command] [패키지명]**
- sub-command(명령어)
  - install : 설치
  - remove : 삭제
  - update : 업데이트
  - info : 정보확인
  - list : repository의 패키지 리스트 출력(저장소에 존재하는 모든 패키지)
  - provides file/dir : 해당 파일이나 디렉토리가 어떠한 패키지로 인해서 파생되었는지 알려줌
    - rpm -qf 와 동일
  - repolist : repository 점검, 현재 시스템에 설정되어있는 저장소 확인
    - all 과 함께 사용 시 활성화 상태까지 확인 가능
- group (패키지를 모아둔 그룹 패키지)
  - groups list : 그룹 패키지 리스트 출력
  - groups install [그룹 패키지명] : 그룹 패키지 설치
  - groups remove [그룹 패키지명] : 그룹 패키지 삭제
  - groups update [그룹 패키지명] : 그룹 패키지 업데이트
  - groups info [그룹 패키지명] : 그룹 패키지 정보

- localinstall [패키지 파일명] : 패키지 파일을 yum으로 설치
  - rpm파일을 yum으로 설치할 수 있음
  - 내가 가지고 있는 파일(꼭 최신이 아닌 **원하는 버전)을 설치하고 의존성(종속성)은 yum으로 해결할 수 있음**
- yum 명령어를 통해 설치·삭제할 때, yes/no를 확인한다.
  - **-y 옵션과 함께 사용하면, yes/no를 물어보지  않고 바로 진행**한다

- yum list 명령을 미리 실행해두면, 이후에 명령을 작성할 때 자동완성하기에 편리

```shell
[root@localhost ~]# yum list
```



사용 예

- yum으로 패키지 설치

```shell
[root@localhost ~]# yum install ksh -y
```

- yum으로 패키지 정보 확인

```shell
[root@localhost ~]# yum info ksh
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: ftp.kaist.ac.kr
 * extras: ftp.kaist.ac.kr
 * updates: ftp.kaist.ac.kr
Installed Packages
Name        : ksh
Arch        : x86_64
Version     : 20120801
Release     : 143.el7_9
Size        : 3.1 M
Repo        : installed
From repo   : updates
Summary     : The Original ATT Korn Shell
URL         : http://www.kornshell.com/
License     : EPL
Description : KSH-93 is the most recent version of the KornShell by David Korn of
            : AT&T Bell Laboratories.
            : KornShell is a shell programming language, which is upward
            : compatible with "sh" (the Bourne Shell).
```

- yum으로 패키지 삭제

```shell
[root@localhost ~]# yum remove ksh -y
Loaded plugins: fastestmirror, langpacks
Resolving Dependencies
--> Running transaction check
---> Package ksh.x86_64 0:20120801-143.el7_9 will be erased
--> Finished Dependency Resolution

....

Complete!
```

- yum으로 삭제 후, rpm명령으로의 정보확인과 yum 명령으로의 정보확인을 비교해보자
  - **rpm은 현재 내 시스템에 설치된 것만 확인가능하기 때문에 정보확인이 불가능**
  - **yum은 저장소에서 확인하는 것이기 때문에 삭제후에도 정보확인 가능**

```shell
[root@localhost ~]# rpm -qa | grep ksh
[root@localhost ~]# yum info ksh
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: ftp.kaist.ac.kr
 * extras: ftp.kaist.ac.kr
 * updates: ftp.kaist.ac.kr
Available Packages
Name        : ksh
Arch        : x86_64
Version     : 20120801
Release     : 143.el7_9
Size        : 885 k
Repo        : updates/7/x86_64
Summary     : The Original ATT Korn Shell
URL         : http://www.kornshell.com/
License     : EPL
Description : KSH-93 is the most recent version of the KornShell by David Korn of
            : AT&T Bell Laboratories.
            : KornShell is a shell programming language, which is upward
            : compatible with "sh" (the Bourne Shell).
```

- 의존성(종속성) 문제가 포함된 패키지를 yum localinstall로 설치해보자
  - rpm명령어로는 해결하지 못했지만(위의 rpm예시 참조), **yum 명령어는 의존성을 해결**한 것을 확인할 수 있음

```shell
[root@localhost ~]# yum localinstall /media/cdrom/Packages/mysql-connector-odbc-5.2.5-7.el7.x86_64.rpm -y

...

Dependencies Resolved

==================================================================================
 Package       Arch   Version      Repository                                Size
==================================================================================
...

Complete!
```

- yum으로 패키지들의 정보와 활성화상태까지 확인해보자

```shell
[root@localhost ~]# yum repolist all
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
...
C7.4.1708-extras/x86_64          CentOS-7.4.1708 - Extras          disabled
C7.4.1708-fasttrack/x86_64       CentOS-7.4.1708 - CentOSPlus      disabled
C7.4.1708-updates/x86_64         CentOS-7.4.1708 - Updates         disabled
base/7/x86_64                    CentOS-7 - Base                   enabled: 10,072
...

```

- yum으로 "보안 툴" 그룹의 정보를 확인해보자

```shell
[root@localhost ~]# yum groups info "보안 툴"
Loaded plugins: fastestmirror, langpacks
There is no installed groups file.
Maybe run: yum groups mark convert (see man yum)
Loading mirror speeds from cached hostfile
 * base: ftp.kaist.ac.kr
 * extras: ftp.kaist.ac.kr
 * updates: ftp.kaist.ac.kr

Group: 보안 툴
 Group-Id: security-tools
 Description: 통합과 신뢰 검증을 위한 보안 툴
 Default Packages:
   +scap-security-guide
...
```



<br>

<br>



<h2>repository 파일 설정</h2>

- **/etc/yum.repos.d/** 에 설정
- **확장자가 반드시 .repo** 이어햐 함
- **repo 파일 설정 후 `yum repolist` 명령을 실행하면 설정된 이름과 주소를 통해 다운로드** 시작

- 내용 구성

```shell
[ID명]
name=repo명
baseurl=http://주소
        file://절대경로
enabled=1/0 (1이면 활성화, 0이면 비활성화)
gpgcheck=1/0 (1이면 라이센스 키가 있을 경우, 0이면 라이센크 키가 없는 경우)
gpgkey=file//경로(gpgcheck=1 일 경우에만 작성)
```



예시

- 먼저 **cd 명령을 통해 /etc/yum.repos.d/로 이동 후 .repo확장자 파일 작성**

```
[root@localhost ~]# cd /etc/yum.repos.d/
[root@localhost yum.repos.d]# vi test.repo
```

```shell
[net]
name=network
baseurl=http://mirror.centos.org/centos/7/os/x86_64
enabled=1
gpgcheck=0
```

```shell
[dvd]
name=dvd repo
baseurl=file:///media/cdrom
enabled=1
gpgcheck=0
```



**yum-config-manager를 이용하여 repo 만들기**

- 복잡해서 자주 사용되는 방법은 아님

```
yum -y install yum-utils
yum -config-manager --add-repo=http://주소
해당 파일에 gpgcheck 항목 추가
```





