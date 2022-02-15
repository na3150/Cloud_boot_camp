<h1>Linux 기본명령어 모음 (2)</h1>




<h3>📌INDEX</h3>

- [mkdir와 rmdir](#mkdir와-rmdir)
-  [cp](#cp)
-  [ln과 파일링크](#ln)
-  [mv](#mv)
- [rm](#rm) 

<br>

<br>



<h2>mkdir와 rmdir</h2>

- <h3>mkdir</h3>

  - Make Directory의 약자로, 새로운 **디렉토리를 생성**한다. 
  - 생성된 디렉토리는 명령을 실행한 사용자의 소유가 된다. 

  ```shell
  [root@localhost ~]# mkdir kbs
  [root@localhost ~]# ls -id kbs
  101583645 kbs
  ```

  - 옵션 :  -p, -m, -v
  - **-m :** 디렉토리를 생성할 때 권한을 설정 (defualt : 755)
  - **-v :** 디렉토리를 생성하고 생성된 디렉토리에 대한 메시지를 출력
  - **-p** : 지정된 디렉토리에서 중간의 디렉토리도 같이 생성

```shell
[root@localhost ~]# mkdir -p kbs/mbc/sbs
[root@localhost ~]# ls -R kbs
kbs:
mbc

kbs/mbc:
sbs

kbs/mbc/sbs:
```

- <h3>rmdir</h3>

  - Remove Directory의 약자로, 디렉토리를 삭제한다.
  - 해당 디렉토리의 삭제 권한이 있어야하며, 디렉토리는 비어있어야한다.  (링크카운트로 예측 가능)
  - 파일이 들어있는 디렉토리를 삭제하려면 rm -r 명령을 실행해야한다.

```shell
[root@localhost ~]# ls -lR kbs
kbs:
합계 0
-rw-r--r--. 1 root root  0  2월 15 03:07 aaa
drwxr-xr-x. 3 root root 17  2월 15 02:58 mbc

kbs/mbc:
합계 0
drwxr-xr-x. 2 root root 6  2월 15 02:58 sbs

kbs/mbc/sbs:
합계 0
[root@localhost ~]# rmdir kbs/mbc/sbs
합계 0
[root@localhost ~]# ls -lR kbs
kbs:
합계 0
-rw-r--r--. 1 root root 0  2월 15 03:07 aaa
drwxr-xr-x. 2 root root 6  2월 15 03:22 mbc

kbs/mbc:
합계 0
```





<br>

<br>

<h2>cp</h2>

- CoPy의 약자로, **파일이나 디렉토리를 복사**한다. 
  - 복사하면 inode도 변경된다.
- 새로 복사한 파일은 복사한 사용자의 소유가 된다.
- 명령을 실행하는 사용자는 해당 파일의 읽기 권한이 필요한다. 

```shell
[root@localhost ~]# cp /etc/passwd aaa
[root@localhost ~]# ls -il /etc/passwd aaa
35114700 -rw-r--r--. 1 root root 2658  2월 14 07:13 /etc/passwd
68392070 -rw-r--r--. 2 root root 2658  2월 15 03:36 aaa
```

- **-r** : 디렉토리 복사

```shell
[root@localhost ~]# mkdir one
[root@localhost ~]# mkdir two
[root@localhost ~]# cp -r two one
[root@localhost ~]# ls -lR one
one:
합계 0
drwxr-xr-x. 2 root root 6  2월 15 05:15 two    -> one에 two 복사

one/two:
합계 0
```

- **-i**: 복사될 파일이 이름이 이미 존재할 경우, 사용자에게 덮어 쓰기 여부를 묻는다.
- **-b :** 복사될 파일이 이름이 이미 존재할 경우, 백업파일을 생성
- **-f :** 복사 될 파일이 이름이 이미 존재 할 경우, 강제로 덮어쓰기
- **-r :** 하위 디렉토리 까지 모두 복사
- **-a :** 원본 파일의 속성, 링크 정보까지 모두 복사
- **-p :** 원본 파일의 소유자, 그룹, 권한 등의 정보까지 모두 복사
- **-v :** 복사 진행 상태를 출력

<br>

<br>

<h2>ln</h2>

- <h3>파일 링크란?</h3>

  - 예를 들어, A에 저장되어있는 실행파일이 하나 있을 때, 이를 실행시키려면 꼭 A까지 가지 않더라도 B에서 실행시킬 수 있게 하는 것
  - '**바로가기**' 라고 생각하기
  - 원리: inode 번호를 기준으로 관리
  - 심볼릭(=소프트) 링크와 하드링크 2가지가 있다.
  - **심볼릭 링크**: 바로가기처럼 가리키도록 주소 링크만 시켜둔 것
  - **하드 링크**: 원본 데이터와 직접적으로 연결시킨 것(한쪽만 변경해도 양쪽 다 반영)
    - 디렉토리는 하드 링크 불가능( -d 옵션 사용 시 가능, 아래 설명 참조)

```
[root@localhost ~]# ln one two
ln: one: 디렉토리는 하드링크할 수 없습니다
```

<details><summary>파일 링크는 왜 사용할까</summary>
<div markdown="1">
<h4>▪️ 경로 단축</h4> 
예를 들어 실제로, 리눅스에서는 부팅과 관련된 디렉토리는 /etc/rc.d 이지만 /etc의 바로 하위로 심볼릭 링크가 설정되어 있어서 절대경로 입력 시에 rc.d라는 디렉터리 명을 생략해서 사용할 수 있다. <br>   
<h4>▪️ 데이터를 안전하게 보관하고 싶은 경우</h4> 
하나의 파일을 사람들과 공유하는데, 만약 그 파일을 다른 누군가가 삭제해 버렸다고하자. 그렇다면 데이터는 더 이상 확인할 수 없을 것이다. 그러나 원본 파일은 내 개인적인 홈 디렉토리에 놔두고, 사람들과 공유하기 위해 하드링크를 걸어 파일을 생성하면, 파일이 삭제되어도 파일은 남아있게 된다.
</div></details>

- <h3>ln 명령어 사용법</h3>

  - $ ln [option] 원본파일 대상명
  - option : -s, -S, -v, -b , -f, -i

```shell
[root@localhost ~]# ln aaa bbb
```

```shell
[root@localhost ~]# ln aaa bbb
ln: failed to create hard link 'bbb': 파일이 있습니다
[root@localhost ~]# rm -f bbb
[root@localhost ~]# ln aaa bbb
[root@localhost ~]# ls -il aaa bbb /etc/passwd
35173065 -rw-r--r--. 1 root root 2658  2월 14 07:13 /etc/passwd
67934757 -rw-r--r--. 2 root root 2658  2월 14 19:53 aaa
67934757 -rw-r--r--. 2 root root 2658  2월 14 19:53 bbb
[root@localhost ~]# ln aaa /tmp/bbb
[root@localhost ~]# ls -il aaa bbb /tmp/bbb
67934757 -rw-r--r--. 3 root root 2658  2월 14 19:53 /tmp/bbb
67934757 -rw-r--r--. 3 root root 2658  2월 14 19:53 aaa
67934757 -rw-r--r--. 3 root root 2658  2월 14 19:53 bbb
```

   - > **링크 카운트가 증가**한 것을 확인할 수 있다.
     >
     > 디렉토리 링크카운트는 default가 2이고, **디렉토리가 보유한 디렉토리의 개수**가 영향을 준다. **심볼릭 링크는 링크 카운트를 증가시키지 않는다.**

- **ln -s : 심볼릭 링크파일을 생성한다**

```shell
[root@localhost ~]# ln -s aaa ccc
[root@localhost ~]# ls -il aaa ccc
68392070 -rw-r--r--. 1 root root 2658  2월 15 03:36 aaa
69239119 lrwxrwxrwx. 1 root root    3  2월 15 05:49 ccc -> aaa
```

- **-b**: 링크 파일 생성 시에 대상파일이 이미 존재하면 백업 파일을 만든 후에 링크 파일 생성
- **-f**: 대상 파일이 존재할 경우 대상 파일을 지우고 링크 파일 생성
- **-d**: 디렉토리에 대한 하드 링크 파일 생성을 가능하게 한다. (단, root 권한으로 수행하더라도 시스템의 권한 제한으로 인하여 실패할 가능성이 높음)



<br>

<br>

<h2>mv</h2>

- MoVe의 약자로, 파일이나 디렉토리의 **이름을 변경**하거나 **다른 디렉토리로 옮길 때 사용**한다.

- 사용법: $ mv [옵션] [파일명1] [파일명2]

```shell
[root@localhost ~]# mv aaa kbs/mbc/
[root@localhost ~]# ls -l kbs/mbc/aaa
-rw-r--r--. 1 root root 2658  2월 15 03:36 kbs/mbc/aaa
```

- **같은 디렉토리에서의 mv는 결과적으로 이름 변경**과 같다. (앞의 설명 참조)
- 예시 : aaa, bbb, ccc 파일을 /ddd 디렉토리로 이동

```shell
[root@localhost ~]# aaa bbb ccc dddd
```

- **-b** : 이동될 파일이 존재하면 백업파일을 만든다.
- **-i**: 이동될 파일의 이름이 이미 조재할 경우, 사용자에게 덮어쓰기 여부를 묻는다.
- **-f** : 이동 될 파일의 이름이 이미 존재할 경우, **강제로 덮어쓰기**한다.
- **-n**: 이동 될 파일의 이름이 이미 존재할 경우, 덮어쓰기 하지 않는다.
- **-r** : 하위 디렉토리까지 모두 이동한다.
- **-v**: 이동 진행 상태를 출력

<br>

<br>

<h2>rm</h2>

- ReMove의 약자로, **파일이나 디렉토리를 삭제**한다.
- 파일이나 디렉토리를 삭제할 권한이 있어야 한다. 
  - root 사용자는 모든 권한이 있으므로 이 명령에 제약 X
- 실수로 모두 삭제될 수 있으므로, 주의해서 사용해야한다.
- **-i 옵션이 default** 옵션이다. : rm만 쳐도 rm -i가 된다.

```shell
[root@localhost ~]# ls
ab.tar           ccc    initial-setup-ks.cfg  kbs  two
anaconda-ks.cfg  ilsan  jjj                   one
[root@localhost ~]# rm ccc
rm: remove 심볼릭 링크 'ccc'? y
[root@localhost ~]# ls
ab.tar           ilsan                 jjj  one
anaconda-ks.cfg  initial-setup-ks.cfg  kbs  two
[root@localhost ~]#
```

- **-f** : 한번 더 묻지 않고(경고 없이) 강제(force)로 삭제

```shell
[root@localhost ~]# ls
ab.tar           ccc    initial-setup-ks.cfg  kbs  two
anaconda-ks.cfg  ilsan  jjj                   one
[root@localhost ~]# rm -f ccc
[root@localhost ~]# ls
ab.tar           ilsan                 jjj  one
anaconda-ks.cfg  initial-setup-ks.cfg  kbs  two
[root@localhost ~]#
```

- **-rf** : 경고 없이 **모두 강제로 삭제** -> 아주 위험한 명령이지 **조심**해서 사용해야한다.

- 링크 카운트와 함께 확인하기

```shell
[root@localhost ~]# ls -il ddd
68430434 -rw-r--r--. 1 root root 0  2월 14 12:19 ddd
[root@localhost ~]# ln ddd aaa
[root@localhost ~]# ls -il ddd  aaa
68430434 -rw-r--r--. 2 root root 0  2월 14 12:19 aaa
68430434 -rw-r--r--. 2 root root 0  2월 14 12:19 ddd    <--- 링크카운트 증가
[root@localhost ~]# rm -f ddd
[root@localhost ~]# ls -il ddd  aaa
ls: cannot access 'ddd': 그런 파일이나 디렉터리가 없습니다
68430434 -rw-r--r--. 1 root root 0  2월 14 12:19 aaa     <--- 삭제 후 링크카운트 감소
```

