<h1>[Linux] 파일 아카이브(Archive)</h1>



<h3>📌INDEX</h3>

- [아카이브(archive)란?](#아카이브archive란)
- [tar](#tar) 
- [아카이브 실습(문제)](#아카이브-실습문제)



<br>

<br>

<h2>아카이브(Archive)란?</h2>

- 리눅스에서 **여러 파일을 한 파일로 묶는 것**을 아카이브(archive)라 한다.
  - ''보따리''라고 생각하기
- 다른 시스템과 파일 주고 받기, 기존 아카이브에서 파일의 추출, 백업 등을 위해 사용
- 파일의 메타 데이터가 포함되기 때문에, 파일의 용량이 없더라도 아카이브에는 용량 존재
- **.tar 확장자** 사용
- 일반 아카이브는 묶어만 주기 때문에, 압축률은 0이다.

<br>

<br>

<h2>tar</h2>

- 파일 **아카이브 및 압축에 사용하는 명령어**
- 특정: 아카이브 생성 시 **피드백 없이** 덮어쓴다.
  - 이전 파일로 돌아갈 수 있으므로 주의해야한다.
  - 묶인 파일이 풀릴 때에도 이전으로 돌아가면서 덮어씌워지기 때문에 주의
- 파일의 소유권 및 권한을 저장
- 여러 파일을 묶어서 한 번에 압축 가능
- 추출 시 현재 작업 디렉토리로 추출된다.
- 옵션 
  - c : create, 새로운 묶음 생성
  - x : extract, 묶인 파일 풀기
  - t : list, 묶음을 풀기 전에 목록 출력
  - f : file, 묶음 파일명 지정
  - v : visual, 파일이 묶이거나 풀리는 과정 출력
  - z : tar + gzip
  - j : tar + bzip2
  - J : Tar + xz
  - -C : 압축을 해제할 때, 해제할 디렉토리 지정
  - 많이 사용하는 조합 : cvf(생성), tvf(확인), xvf(해제)

- 아카이브 **생성 :  tar cvf  [생성될 아카이블 파일명]  [아카이브할 파일·디렉토리]**
- 아카이브 **추출(해체) :  tar -xvf [대상tar]**
- 압축
  - **gzip : tar -zcvf [이름] [대상파일]**
  - **bzip2 : tar -jcvf [이름] [대상파일]**
  - **xz : tar -Jcvf [이름] [대상파일]**



사용 예

+ 아카이브 생성 : tar cvf

```shell
[root@localhost ~]# tar cvf xinetd.tar /etc/xinetd.d/
```

- 아카이브 생성 + gzip 압축 : tar zcvf

```shell
[root@localhost ~]# tar cvzf xinetd.tar.gz /etc/xinetd.d/
```

- 아카이브 생성 + bzip2 압축 : tar jcvf 

```shell
[root@localhost ~]# tar cvjf xinetd.tar.bz2 /etc/xinetd.d/
```

- 아카이브 생성 + xz 압축 : tar Jcvf

```shell
[root@localhost ~]# tar cvJf xinetd.tar.xz /etc/xinetd.d/
```

- 확인 : tar tvf

```shell
[root@localhost ~]# tar tvf xinetd.tar
```

- 풀기 : tar xvf

```shell
[root@localhost ~]# tar xvf xinetd.tar
```

- gzip 압축 해제 + tar 풀기 : tar xvzf

```shell
[root@localhost ~]# tar xvzf xinetd.tar.gz
```

<br>

<br>

<h2>아카이브 실습(문제)</h2>

1.  /usr/bin 디렉토리를 아카이브 및 압축 (gzip, bzip2, xz) 해보자

```shell
[root@localhost ~]# tar -cvf bin.tar /usr/bin
[root@localhost ~]# tar -zcvf bin.tar.gz /usr/bin
[root@localhost ~]# tar -jcvf bin.tar.bz2 /usr/bin
[root@localhost ~]# tar -Jcvf bin.tar.xz /usr/bin
```

2. 1번에서 압축한 파일 중 xz 파일을 /tmp 에 압축해제해보자

```shell
[root@localhost ~]# tar -Jxvf bin.tar.xz -C /tmp
```

3. centos 홈 디렉토리의 모든 파일을 아카이브해서 gzip 방식으로 압축해보자.

```shell
[root@localhost ~]# tar -zcvf centos.tar.gzip ~centos/
```

4.  3번에서 압축한 파일을 /tmp/dir01 디렉토리에 해제해보자

```shell
[root@localhost ~]# tar -zxvf centos.tar.gzip -C /tmp/dir01
```

5. 아카이브 된 파일의 내용을 보고 싶을 때 사용하는 명령어와 옵션을 작성해보자

```shell
[root@localhost ~]# tar -tvf [아카이브된 파일명]
```

