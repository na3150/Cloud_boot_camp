<h1> [Linux] rpmκ³Ό yum</h1>



<h3>πINDEX</h3>

- [RPM Package Manager](#rpm-package-manager)
  - [rpm λͺλ Ήμ΄](#rpm-λͺλ Ήμ΄)
-  [yum](#yum)
   - [yum λͺλ Ήμ΄](#yum-λͺλ Ήμ΄)
-  [repository νμΌ μ€μ ](#repository-νμΌ-μ€μ )

<br>

<br>

<h2>RPM Package Manager</h2>

- **RPM(RedHat Package Manager)** μ΄λ, λ λν κ³μ΄μ λ¦¬λμ€ λ°°ν¬νμμ μ¬μ©νλ νλ‘κ·Έλ¨(ν¨ν€μ§) μ€μΉκ΄λ¦¬ λκ΅¬μ΄λ€.
  - **νλ‘κ·Έλ¨(ν¨ν€μ§)μ μ½κ² μ€μΉνκΈ° μν λκ΅¬**
- μμΉ΄μ΄λΈμμ νμΌ μμ€νμΌλ‘ μΆμΆλ μννΈμ¨μ΄λ‘ μμνλ κ²λ³΄λ€ κ°λ¨νλ€
- μ€μΉλ ν¨ν€μ§ νμΈ κ°λ₯
- μ κ±°λ ν¨ν€μ§ νμΌ μμ¬ μΆμ²
- μ€μΉλ μννΈμ¨μ΄μ μ§μ ν¨ν€μ§ νμΈ
- μμ€ν λ‘μ»¬ RPM λ°μ΄ν° λ² μ΄μ€μ ν¨ν€μ§ μ λ³΄ μ μ₯
- ν¨ν€μ§ νμΌ μ΄λ¦ κ΅¬μ±
  - ν¨ν€μ§λͺκ³Ό μ¬μ©λλ μλΉμ€λͺμ΄ λ€λ₯Ό μ μμ



<img src="https://user-images.githubusercontent.com/64996121/156574717-50d59db4-cda8-424f-a45f-c55ca008a123.png" width=380 height=90 />



<h4>rpm λͺλ Ήμ΄</h4>

- **rpm [μ΅μ]**

- μ΅μ

  - -q : μΏΌλ¦¬

  - -a : μμ€νμ μ€μΉλμ΄ μλ λͺ¨λ  ν¨ν€μ§
  - -i : ν¨ν€μ§μ λν μ λ³΄
  - -c : ν¨ν€μ§μ μ€μ νμΌλ€μ μΆλ ₯
  - -d : ν¨ν€μ§μ λ¬Έμ(document)λ₯Ό μΆλ ₯
  - -l : ν¨ν€μ§μ λͺ¨λ  νμΌ(list) μΆλ ₯
  - -f : νμΌμ΄λ λλ ν λ¦¬κ° μ΄λ ν ν¨ν€λ‘ μΈν΄μ νμ(μμ±)λμλμ§ μλ €μ€
    - κ²½λ‘λ₯Ό λ³Ό μ μμ



**μ¬μ© μ**

- ν¨ν€μ§ μ λ³΄ νμΈ

```shell
[root@localhost ~]# rpm -qi openssh
Name        : openssh
Version     : 7.4p1
Release     : 16.el7
Architecture: x86_64
Install Date: 2022λ 02μ 21μΌ (μ) μ€ν 02μ 53λΆ 07μ΄
Group       : Applications/Internet
...
```

- μ€μ  νμΌ νμΈ

```shell
[root@localhost ~]# rpm -qc openssh
/etc/ssh/moduli
```

- ν¨ν€μ§μ λ¬Έμ(document)νμΈ

```shell
[root@localhost ~]# rpm -qd openssh
/usr/share/doc/openssh-7.4p1/CREDITS
/usr/share/doc/openssh-7.4p1/ChangeLog
/usr/share/doc/openssh-7.4p1/INSTALL
...
```

- ν¨ν€μ§λ₯Ό κ΅¬μ±νλ λͺ¨λ  νμΌ(list) νμΈ

```shell
[root@localhost ~]# rpm -ql openssh
/etc/ssh
/etc/ssh/moduli
/usr/bin/ssh-keygen
/usr/libexec/openssh
/usr/libexec/openssh/ctr-cavstest
...
```





- **rpm ν¨ν€μ§ μ€μΉ λ° μλ°μ΄νΈ**
  - **rpm -Uvh [ν¨ν€μ§ νμΌ κ²½λ‘]**

```shell
[root@localhost ~]# rpm -Uvh /media/cdrom/Packages/ksh-20120801-137.el7.x86_64.rpm
κ²½κ³ : /media/cdrom/Packages/ksh-20120801-137.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
μ€λΉ μ€...                         ################################# [100%]
Updating / installing...
   1:ksh-20120801-137.el7             ################################# [100%]
```



- **rpm ν¨ν€μ§ μ­μ **
  - **rpm -e [ν¨ν€μ§λͺ]**

```shell
[root@localhost ~]# rpm -e ksh
```



- **rpm μ€μΉ ν¨ν€μ§ νμΈ**
  - **rpm -qa** : μ€μΉλμ΄μλ λͺ¨λ  ν¨ν€μ§ νμΈ
  - grep λͺλ Ήμ΄λ₯Ό ν΅ν΄, νΉμ  ν¨ν€μ§ μ€μΉ μ¬λΆ νμΈ κ°λ₯

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



- β­**rpmμ λ¨μ ** : rpmμ μ μμ€ λκ΅¬
  - ν¨ν€μ§ μ€μΉλ₯Ό μν΄ λ°λμ **rpm νμΌμ΄ μμ΄μΌν¨**
  - **μ’μμ±(μμ‘΄μ±)μ ν΄κ²°ν  μ μμ**

μμ

```shell
[root@localhost ~]# rpm -Uvh /media/cdrom/Packages/mysql-connector-odbc-5.2.5-7.el7.x86_64.rpm
κ²½κ³ : /media/cdrom/Packages/mysql-connector-odbc-5.2.5-7.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
μ€λ₯: Failed dependencies:
        libodbc.so.2()(64bit) is needed by mysql-connector-odbc-5.2.5-7.el7.x86_64        libodbcinst.so.2()(64bit) is needed by mysql-connector-odbc-5.2.5-7.el7.x86_64
```

- λ€λ₯Έ ν¨ν€μ§ μ€μΉκ° μ°μ μ΄λΌλ κ²½κ³  λ©μΈμ§κ° λ¬λ€

  - μ¦, μ’μμ±(μμ‘΄μ±) λ¬Έμ λ₯Ό ν΄κ²°νμ§ λͺ»ν¨

  - μ€λ₯: Failed dependencies λΆλΆμ λ³΄λ©΄, μ€μΉν΄μΌνλ λͺ¨λΒ·λΌμ΄λΈλ¬λ¦¬λͺμ μλ €μ€
  - λν μ€μΉκ° νμν ν¨ν€μ§λ₯Ό, ν¨ν€μ§λͺμ΄ μλ λΌμ΄λΈλ¬λ¦¬λͺμΌλ‘ λͺμνκΈ° λλ¬Έμ μ νν μ€μΉν΄μΌνλ ν¨ν€μ§λ₯Ό μ°Ύλ κ² μ‘°μ°¨ μ½μ§ μμ 

- μ΄λ¬ν μ΄μ λ€λ‘, rpmμ ν¨ν€μ§μ μ€μΉλ³΄λ€λ μ λ³΄λ₯Ό λ³΄κ±°λ κ΄λ¦¬ν  λ λ§μ΄ μ¬μ©νλ€

<br>

<br>



<h2>yum</h2>

- YUM(Yellowdog Updater Modified) : **μΈν°λ·μ ν΅νμ¬ νμν νμΌμ μ μ₯μ(Repository)μμ μλμΌλ‘ λͺ¨λ λ€μ΄λ‘λν΄μ μ€μΉνλ λ°©μ**
  - rpm λͺλ Ήμ ν΄λΉ νμΌμ κ°κ³  μμ΄μΌνλ, yum λͺλ Ήμ μμ΄λ λλ€

- ν¨ν€μ§ μ’μμ± μν
  - rpmμ μ’μμ±(μμ‘΄μ±) ν΄κ²° μλ¨ - λͺ¨λ  ν¨ν€μ§ λμ΄
  - β­**yumμ** ν¨ν€μ§μ μ¬λ¬ λ ν¬μ§ν λ¦¬ λ° **μ’μμ±(μμ‘΄μ±) ν΄κ²° κ°λ₯**
    - μμ‘΄μ±μ΄ νμν ν¨ν€μ§λ₯Ό μλμΌλ‘ μ€μΉ
    - λ¨, **μΈν°λ·μ μ°κ²°λμ΄μμ΄μΌν¨**

- **yumμ ν­μ μ΅μ  λ²μ μ μ€μΉ**



<h4>yum λͺλ Ήμ΄</h4>

- **yum [sub-command] [ν¨ν€μ§λͺ]**
- sub-command(λͺλ Ήμ΄)
  - install : μ€μΉ
  - remove : μ­μ 
  - update : μλ°μ΄νΈ
  - info : μ λ³΄νμΈ
  - list : repositoryμ ν¨ν€μ§ λ¦¬μ€νΈ μΆλ ₯(μ μ₯μμ μ‘΄μ¬νλ λͺ¨λ  ν¨ν€μ§)
  - provides file/dir : ν΄λΉ νμΌμ΄λ λλ ν λ¦¬κ° μ΄λ ν ν¨ν€μ§λ‘ μΈν΄μ νμλμλμ§ μλ €μ€
    - rpm -qf μ λμΌ
  - repolist : repository μ κ², νμ¬ μμ€νμ μ€μ λμ΄μλ μ μ₯μ νμΈ
    - all κ³Ό ν¨κ» μ¬μ© μ νμ±ν μνκΉμ§ νμΈ κ°λ₯
- group (ν¨ν€μ§λ₯Ό λͺ¨μλ κ·Έλ£Ή ν¨ν€μ§)
  - groups list : κ·Έλ£Ή ν¨ν€μ§ λ¦¬μ€νΈ μΆλ ₯
  - groups install [κ·Έλ£Ή ν¨ν€μ§λͺ] : κ·Έλ£Ή ν¨ν€μ§ μ€μΉ
  - groups remove [κ·Έλ£Ή ν¨ν€μ§λͺ] : κ·Έλ£Ή ν¨ν€μ§ μ­μ 
  - groups update [κ·Έλ£Ή ν¨ν€μ§λͺ] : κ·Έλ£Ή ν¨ν€μ§ μλ°μ΄νΈ
  - groups info [κ·Έλ£Ή ν¨ν€μ§λͺ] : κ·Έλ£Ή ν¨ν€μ§ μ λ³΄

- localinstall [ν¨ν€μ§ νμΌλͺ] : ν¨ν€μ§ νμΌμ yumμΌλ‘ μ€μΉ
  - rpmνμΌμ yumμΌλ‘ μ€μΉν  μ μμ
  - λ΄κ° κ°μ§κ³  μλ νμΌ(κΌ­ μ΅μ μ΄ μλ **μνλ λ²μ )μ μ€μΉνκ³  μμ‘΄μ±(μ’μμ±)μ yumμΌλ‘ ν΄κ²°ν  μ μμ**
- yum λͺλ Ήμ΄λ₯Ό ν΅ν΄ μ€μΉΒ·μ­μ ν  λ, yes/noλ₯Ό νμΈνλ€.
  - **-y μ΅μκ³Ό ν¨κ» μ¬μ©νλ©΄, yes/noλ₯Ό λ¬Όμ΄λ³΄μ§  μκ³  λ°λ‘ μ§ν**νλ€

- yum list λͺλ Ήμ λ―Έλ¦¬ μ€νν΄λλ©΄, μ΄νμ λͺλ Ήμ μμ±ν  λ μλμμ±νκΈ°μ νΈλ¦¬

```shell
[root@localhost ~]# yum list
```



μ¬μ© μ

- yumμΌλ‘ ν¨ν€μ§ μ€μΉ

```shell
[root@localhost ~]# yum install ksh -y
```

- yumμΌλ‘ ν¨ν€μ§ μ λ³΄ νμΈ

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

- yumμΌλ‘ ν¨ν€μ§ μ­μ 

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

- yumμΌλ‘ μ­μ  ν, rpmλͺλ ΉμΌλ‘μ μ λ³΄νμΈκ³Ό yum λͺλ ΉμΌλ‘μ μ λ³΄νμΈμ λΉκ΅ν΄λ³΄μ
  - **rpmμ νμ¬ λ΄ μμ€νμ μ€μΉλ κ²λ§ νμΈκ°λ₯νκΈ° λλ¬Έμ μ λ³΄νμΈμ΄ λΆκ°λ₯**
  - **yumμ μ μ₯μμμ νμΈνλ κ²μ΄κΈ° λλ¬Έμ μ­μ νμλ μ λ³΄νμΈ κ°λ₯**

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

- μμ‘΄μ±(μ’μμ±) λ¬Έμ κ° ν¬ν¨λ ν¨ν€μ§λ₯Ό yum localinstallλ‘ μ€μΉν΄λ³΄μ
  - rpmλͺλ Ήμ΄λ‘λ ν΄κ²°νμ§ λͺ»νμ§λ§(μμ rpmμμ μ°Έμ‘°), **yum λͺλ Ήμ΄λ μμ‘΄μ±μ ν΄κ²°**ν κ²μ νμΈν  μ μμ

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

- yumμΌλ‘ ν¨ν€μ§λ€μ μ λ³΄μ νμ±νμνκΉμ§ νμΈν΄λ³΄μ

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

- yumμΌλ‘ "λ³΄μ ν΄" κ·Έλ£Ήμ μ λ³΄λ₯Ό νμΈν΄λ³΄μ

```shell
[root@localhost ~]# yum groups info "λ³΄μ ν΄"
Loaded plugins: fastestmirror, langpacks
There is no installed groups file.
Maybe run: yum groups mark convert (see man yum)
Loading mirror speeds from cached hostfile
 * base: ftp.kaist.ac.kr
 * extras: ftp.kaist.ac.kr
 * updates: ftp.kaist.ac.kr

Group: λ³΄μ ν΄
 Group-Id: security-tools
 Description: ν΅ν©κ³Ό μ λ’° κ²μ¦μ μν λ³΄μ ν΄
 Default Packages:
   +scap-security-guide
...
```



<br>

<br>



<h2>repository νμΌ μ€μ </h2>

- **/etc/yum.repos.d/** μ μ€μ 
- **νμ₯μκ° λ°λμ .repo** μ΄μ΄ν ν¨
- **repo νμΌ μ€μ  ν `yum repolist` λͺλ Ήμ μ€ννλ©΄ μ€μ λ μ΄λ¦κ³Ό μ£Όμλ₯Ό ν΅ν΄ λ€μ΄λ‘λ** μμ

- λ΄μ© κ΅¬μ±

```shell
[IDλͺ]
name=repoλͺ
baseurl=http://μ£Όμ
        file://μ λκ²½λ‘
enabled=1/0 (1μ΄λ©΄ νμ±ν, 0μ΄λ©΄ λΉνμ±ν)
gpgcheck=1/0 (1μ΄λ©΄ λΌμ΄μΌμ€ ν€κ° μμ κ²½μ°, 0μ΄λ©΄ λΌμ΄μΌν¬ ν€κ° μλ κ²½μ°)
gpgkey=file//κ²½λ‘(gpgcheck=1 μΌ κ²½μ°μλ§ μμ±)
```



μμ

- λ¨Όμ  **cd λͺλ Ήμ ν΅ν΄ /etc/yum.repos.d/λ‘ μ΄λ ν .repoνμ₯μ νμΌ μμ±**

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



**yum-config-managerλ₯Ό μ΄μ©νμ¬ repo λ§λ€κΈ°**

- λ³΅μ‘ν΄μ μμ£Ό μ¬μ©λλ λ°©λ²μ μλ

```
yum -y install yum-utils
yum -config-manager --add-repo=http://μ£Όμ
ν΄λΉ νμΌμ gpgcheck ν­λͺ© μΆκ°
```





