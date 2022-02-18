<h1>[Linux] 파일 입출력 관련 명령어</h1>





<h3>📌INDEX</h3>

- [cut](#cut)
- [paste](#paste)
- [diff](#diff)
- [grep](#grep)

- [sort](#sort)
- [sed](#sed)
- [awk](#awk)



<br>

<br>

<h2>cut</h2>

- 리눅스에서 **파일 내용을 각 필드로 구분**하고, 필드별로 **내용을 추출**하며, 각 필드들을 **구분자로 구분**할 수 있는 명령어
- 사용법:  cut [옵션] [파일명]
- 옵션 
  - -c : 잘라낼 곳의 글자 위치를 지정
    - 콤마나 하이픈을 사용하여 범위를 정할 수 있고, 혼합하여 사용 가능
  - -s : 필드 구분자를 사용. 
    - 필드 구분자를 포함할 수 없다면 그 행은 하지 않는다.
  - -d : 지정한 문자를 구분자로 사용
    - default 구분자는 공백 ' '
  - -f : 지정한 필드를 출력한다. 

- 예시

  - 아래의 sample을 이용하여 cat을 활용해보자

  ```shell
  [root@localhost ~]# cat sample
  sung 23 010-1234-5678
  park 28 011-8765-4321
  yoon 46 010-4321-5678
  kin 33 016-1122-3344
  la 15 010-5555-5555
  ```

  -  공백을 기준으로 필드 1,3을 출력하라
    - 3과 1을 바꾸어도 출력되는 순서는 동일하다

  ```shell
  [root@localhost ~]# cut -d ' ' -f 1,3 sample
  sung 010-1234-5678
  park 011-8765-4321
  yoon 010-4321-5678
  kin 016-1122-3344
  la 010-5555-5555
  ```

  - 이번에는 /etc/passwd 파일에서 첫번째 필드와, 세번째부터 여섯번째 필드를 : 구분자를 기준으로 나누어 마지막 5줄만 출력하라

  ```shell
  [root@localhost ~]# cut -d ':' -f 1,3-6 /etc/passwd | tail -5
  sshd:74:74:Privilege-separated SSH:/var/empty/sshd
  rngd:975:974:Random Number Generator Daemon:/var/lib/rngd
  tcpdump:72:72::/
  user:1000:1000:user:/home/user
  test1:1001:1001::/home/test1
  ```



<br><br>

<h2>paste</h2>

- 하나 이상의 파일에서 **행을 합치는 명령어(파일의 내용을 결헙)**
- 사용법: paste [옵션] [파일이름] [파일이름]
- 옵션 
  - -s : 한 파일의 내용을 한 줄로 보여준 후 다른 파일의 내용을 한 줄로 덧붙인다.
    - 수평으로 붙인다.
  - -d : 출력되는 내용의 구분자를 지정한다.

- 예시

  ```shell
  [root@localhost ~]# cat sample1
  seoul
  ilsan
  busan
  [root@localhost ~]# cat sample2
  namhae
  seoul
  ```

  -  위와 같은 2개의 파일 sample1, sample2를 paste 해보자

  ```shell
  [root@localhost ~]# paste sample1 sample2
  seoul   namhae
  ilsan   seoul
  busan
  ```

  - - 새로운 필드로 각각 붙여서 새로운 data field로 만들어진 것을 확인할 수 있다.
    - 그러나 paste한 파일은 글자수가 다를 때 간격이 일정하지 않아 cut 하기 힘들다. 

  - ' : '구분자를 이용하여 sample1, sample2를 paste해보자

  ```shell
  [root@localhost ~]# paste -d : sample1 sample2
  seoul:namhae
  ilsan:seoul
  busan:
  ```

  - ' | ' 구분자를 이용하여 sample1, sample2를 수평으로 (한 행에 한 파일의 내용) paste해보자

  ```shell
  [root@localhost ~]# paste -d '|' -s sample1 sample2
  seoul|ilsan|busan
  namhae|seoul
  ```

  

<br>

<br>



<h2>diff</h2>

- differences의 약자로, **두 파일 사이의 내용을 비교**하는 명령어이다.
- 사용법: diff [옵션] [파일명] [파일명]
- 옵션 
  - -b : space를 무시하고 비교
  - -i : 대소문자를 구분하지 않는다
  - -d : 세세한 차이까지 검색
  - -s : 두 파일이 같은지 확인
  - -u : undirectional new fiel 옵션으로 비교하는 파일/디렉토리가 빠져있을 경우, dummy로 처리해서 출력을 통일시킴

- 예시

  - sample1은 앞선 paste예시에 나와있음
  - sample3

  ```shell
  [root@localhost ~]# cat sample3
  seoul
  ilsan
  ```

  - sample1과 sample3의 내용이 다른지 확인해보자.

  ```shell
  [root@localhost ~]# diff sample1 sample3
  3d2
  < busan
  \ No newline at end of file
  ```

  - ' > ' 는 뒤에 입력한 파일(sample3)을 의미하고, ' < ' 앞에 입력한 파일(sample1)을 의미한다.
  - -u 옵션을 추가해보자

  ```
  [root@localhost ~]# diff -u sample1 sample3
  --- sample1     2022-02-18 06:36:47.423422200 -0500
  +++ sample3     2022-02-18 06:57:03.567559438 -0500
  @@ -1,3 +1,2 @@
   seoul
   ilsan
  -busan
  \ No newline at end of file
  ```

  - sample1이 sample3가 되기 위해서는 busan을 빠져야된다고 알려줌

<br>

<br>

<h2>grep</h2>

- 파일에서 **원하는 문자열이 들어간 행을 찾아 출력**하는 명령어
- 주로 log파일에서 특정 날짜, 문자로 기록된 **error 메시지를 찾는데 유용**하게 사용
- 사용법 : grep [옵션] [패턴] [파일명]
- 옵션
  - -v : 패턴을 포함하지 않은 행을 출력
  - -i : 대소문자를 구분하지 않는다.
  - -n : 줄 번호를 함께 출력
  - -l : 파일명을 출력
  - -c : 일치하는 라인의 개수를 출력

- grep에서 자주 사용하는 형식
  - grep ^[문자열] : 문자열로 행이 시작되는 경우 출력
  - grep [문자열]$ : 문자열로 행이 끝나는 경우 출력
  - grep -v [문자열] : 해당 문자열을 제외한 행 출력
  - grep [문자열] * : 현재 위치의 모든 파일 (*) 에서 특정 문자열 출력
  - grep ^[0-9] : 숫자로 시작되는 경우 출력
  - grep ^[a-z]: 소문자 영문자로 시작되는 경우 출력
  - grep ^[A-Z] : 대문자 영문자로 시작되는 경우 출력

- 예시

  - /etc/passwd 에서 root 문자열이 들어간 파일을 출력해보자.

  ```shell
  [root@localhost ~]# grep root /etc/passwd
  root:x:0:0:root:/root:/bin/bash
  operator:x:11:0:operator:/root:/sbin/nologin
  ```

  - /etc/passwwd에서 root 문자열이 들어간 파일을 제외하고 5번째 줄 까지 출력해보자.

  ```shell
  [root@localhost ~]# grep -v root /etc/passwd | head -5
  bin:x:1:1:bin:/bin:/sbin/nologin
  daemon:x:2:2:daemon:/sbin:/sbin/nologin
  adm:x:3:4:adm:/var/adm:/sbin/nologin
  lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
  sync:x:5:0:sync:/sbin:/bin/sync
  ```

  - /etc/passwd 에서 root로 시작하는 행을 출력해보자.

  ```shell
  [root@localhost ~]# grep ^root /etc/passwd
  root:x:0:0:root:/root:/bin/bash
  ```

  - /etc/passwd 에서 nologin으로 끝나는 행을 5개만 출력해보자.

  ```shell
  [root@localhost ~]# grep nologin$ /etc/passwd | head -5
  bin:x:1:1:bin:/bin:/sbin/nologin
  daemon:x:2:2:daemon:/sbin:/sbin/nologin
  adm:x:3:4:adm:/var/adm:/sbin/nologin
  lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
  mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
  ```

  - /etc/passwd 에서 root 가 들어간 행을 라인넘버를 붙여 출력해보자.

  ```shell
  [root@localhost ~]# grep -n root /etc/passwd
  1:root:x:0:0:root:/root:/bin/bash
  10:operator:x:11:0:operator:/root:/sbin/nologin
  ```

<br>

<br>

<h2>sort</h2>

-  사용자가 지정한 **파일의 내용을 정렬**하거나 **정렬된 파일의 내용을 병합**할 때 사용한다.

- 사용법: sort [옵션] [파일명]

- default는 오름차순이다.

- default는 첫번째 필드를 기준으로 정렬한다.

- 구분자를 선언하지 않으면 공백 간격을 인지하고 필드를 구분한다.

- 옵션

  - -r : 역순으로 정렬
  - -k : 정해진 필드를 기준으로 정렬
  - -t : 지정한 구분자를 구분자로 사용
  - -u : 정렬 후 중복된 내용을 제거
  - -f : 대소문자를 구분하지 않고 정렬
  - -n: 숫자 순서로 정렬(붙이지않으면 문자열로 인식)
  - -b : space를 무시한다.

- 예시

  ```shell
  [root@localhost ~]# cat sample
  sung 23 010-1234-5678
  park 28 011-8765-4321
  yoon 46 010-4321-5678
  kin 33 016-1122-3344
  la 15 010-5555-5555
  ```

  - sample 파일을 첫번째 필드를 기준으로 오름차순으로 정렬해보자.

  ```shell
  [root@localhost ~]# sort sample
  kin 33 016-1122-3344
  la 15 010-5555-5555
  park 28 011-8765-4321
  sung 23 010-1234-5678
  yoon 46 010-4321-5678
  ```

  - sample 파일을 첫번째 필드를 기준으로 내림차순으로 정렬해보자.

  ``` shell
  [root@localhost ~]# sort -r sample
  yoon 46 010-4321-5678
  sung 23 010-1234-5678
  park 28 011-8765-4321
  la 15 010-5555-5555
  kin 33 016-1122-3344
  ```

  - 3번째 필드를 기준으로 (오름차순)  정렬해보자.

  ```shell
  [root@localhost ~]# sort -k 3 sample
  sung 23 010-1234-5678
  yoon 46 010-4321-5678
  la 15 010-5555-5555
  park 28 011-8765-4321
  kin 33 016-1122-3344
  ```

  - 나이가 많은 순서대로 정렬하여 다른 파일에 저장해보자.

  ```shell
  [root@localhost ~]# sort -k 2 sample > other_sample
  [root@localhost ~]# cat other_sample
  la 15 010-5555-5555
  sung 23 010-1234-5678
  park 28 011-8765-4321
  kin 33 016-1122-3344
  yoon 46 010-4321-5678
  ```

  - /etc/passwd 파일을 : 구분자를 이용하여 세 번째 필드인 uid를 기준으로 숫자 순서대로 내림차순 정렬한 후 위에서 5번째 줄 까지만 출력해보자.

  ```shell
  [root@localhost ~]# sort -t : -k 3 -n -r /etc/passwd | head -5
  nobody:x:65534:65534:Kernel Overflow User:/:/sbin/nologin
  test1:x:1001:1001::/home/test1:/bin/bash
  user:x:1000:1000:user:/home/user:/bin/bash
  systemd-coredump:x:999:997:systemd Core Dumper:/:/sbin/nologin
  polkitd:x:998:996:User for polkitd:/:/sbin/nologin
  ```



<br>

<br>

<h2>sed</h2>

- Stream Editor의 약자로, **텍스트 파일을 편집하는 유용한 명령어**
- 원본을 건드리지 않고 편집하기 때문에, 작업이 완료돼도 원본에는 영향이 없다.
- 사용법: set [옵션] [파일명]
- 옵션
  - p : 행을 출력( -n 옵션과 함께 사용할 경우, 선택된 행만 출력)
  - d : 선택한 행을 삭제
  - s : 문자열을 치환
  -  s/가/나/g : '가' 문자열을 '나' 문자열로 대체한다.
    - n,ms/가/나/g : n번째 줄부터 m번째 줄까지 '가'를 '나'로 대체(치환)
  - -f : 파일 안의 내용을 실행
  - -e : 다중 편집을 가능하게 한다.
  - -n : 출력을 생략
  - -q : sed를 종료

- 예시

  ```shell
  [root@localhost ~]# sed '/010/p' sample
  sung 23 010-1234-5678
  sung 23 010-1234-5678
  park 28 011-8765-4321
  yoon 46 010-4321-5678
  yoon 46 010-4321-5678
  kin 33 016-1122-3344
  la 15 010-5555-5555
  la 15 010-5555-5555
  ```

  - 패턴에 따라 내용이 나오나, 같은 내용이 두번 반복되어 나오는 것을 확인할 수 있다.
  - **패턴에 해당하는 부분만 보려면 -n 옵션을 사용**한다.

  ```shell
  [root@localhost ~]# sed -n '/010/p' sample
  sung 23 010-1234-5678
  yoon 46 010-4321-5678
  la 15 010-5555-5555
  ```

  - sample 파일에서 1번부터 3번라인까지 삭제하고 출력해보자.

  ```shell
  [root@localhost ~]# sed '1,3d' sample
  kin 33 016-1122-3344
  la 15 010-5555-5555
  ```

  - sample 파일의 내용을 4번째라인부터 끝까지 삭제하고 출력해보자.

  ```shell
  [root@localhost ~]# sed '4,$d' sample
  sung 23 010-1234-5678
  park 28 011-8765-4321
  yoon 46 010-4321-5678
  ```

  - sample 파일의 내용을 4번째 줄 까지 출력 후 종료해보자.

  ```shell
  [root@localhost ~]# sed '4q' sample
  sung 23 010-1234-5678
  park 28 011-8765-4321
  yoon 46 010-4321-5678
  kin 33 016-1122-3344
  ```

  - 'sung' 이라는 특정 문자열이 포함된 라인을 제외하고 data 파일을 출력해보자.

  ```shell
  [root@localhost ~]# sed '/sung/d' sample
  park 28 011-8765-4321
  yoon 46 010-4321-5678
  kin 33 016-1122-3344
  la 15 010-5555-5555
  ```

  - 'park' 이라는 특정 문자열을  'song'으로 치환해서 출력해보자.

  ```shell
  [root@localhost ~]# sed 's/park/song/g' sample
  sung 23 010-1234-5678
  song 28 011-8765-4321
  yoon 46 010-4321-5678
  kin 33 016-1122-3344
  la 15 010-5555-5555
  ```

  - **sample에서 'song'이 포함된 라인을 제외하고, 이름과 전화번호로 구성된 내용을 위에서 2번째 라인부터 출력해보자.**

  ```shell
  [root@localhost ~]# sed '/song/d' sample | cut -d ' ' -f 1,3 | tail -n +2
  park 011-8765-4321
  yoon 010-4321-5678
  kin 016-1122-3344
  la 010-5555-5555
  ```

  - sample에서 'kin'을 'kim'으로 대체(치환)하고, 'la'가 포함된 줄을 제외하여 출력해보자.

  ```shell
  [root@localhost ~]# sed -e 's/kin/kim/g' -e '/la/d' sample
  sung 23 010-1234-5678
  park 28 011-8765-4321
  yoon 46 010-4321-5678
  kim 33 016-1122-3344
  ```

  

<br>

<br>

<h2>⭐awk⭐</h2>

- awk란 이름은 awk 유틸리티를 작성한 A.V.Aho, P.J. Weinberger, B. Kernigham 의 머리글자를 따온 것
- awk는 일종의 프로그래밍 언어이나, 일반적인 언어라기보다는 주로 패턴의 검색과 조작을 주 목적으로 만들어졌다.
- awk으로 할 수 있는 일?
  - 다른 프로그램의 입력 형식에 맞게 변환하는 작업에 이용
  - 텍스트 파일의 전체 내용 출력
  - 파일의 특정 필드만 출력
  - 패턴이 포함된 레코드 출력
  - 특정 필드에 연산 수행 결과 출력
  - 필드 값 비교에 따라 레코드 출력
  - 특저 필드에 문자열을 추가하여 출력
- awk 명령 기본 형식: aws [옵션] 'awk 프로그램; [argument]
- awk program은 ' '(single quotation marks) 안에서 작성한다.
- 옵션
  - -F : 구분자 지정
  - -f : awk 프로그램 파일 경로 지정
  - -v : awk 프로그램에서 사용될 특정 variable 값 지정
- 패턴
  - BEGIN : 특정 명령을 실행하기 전에 먼저 실행
  - END : 특정 명령을 실행한 후 제시되는 문장을 실행
  - /정규표현식/ : 정규표현식의 패턴을 포함하는 라인에서 문장을 실행
  - 패턴1 && 패턴2 : 패턴1과 패턴2를 동시에 만족시킬 때 문장을 실행
  - 패턴1 || 패턴2 : 패턴1이나 패턴2 중 하나만 만족시켜도 문장을 실행
  - ! 패턴 : 패턴과 일치하지 않을 경우 문장을 실행
- 연산자 : 다른 프로그래밍 언어의 연산자와 유사
  - 다만, 증감연산자는 -- 가 아닌 +- 이다.

- awk의 내부 변수

  - FILENAME : 현재 처리되고 있는 파일 이름
  - FS : 필드 구분자 
  - RS : 레코드 구분자
  - NF : 현재 레코드에서의 필드 수
  - NR : 현재 파일에서 전체 레코드 수
  - OFS : 출력시의 필드 구분자
  - ORS : 출력시의 레코드 구분자

- 예시

  - awk을 사용하여 1,3 필드를  출력해보자
    - 만약 전체 필드를 출력하려면 &0 인자를 사용한다.

  ```shell
  [root@localhost ~]# awk '{print $1, $3}' data
  hong 011-222-2222
  park 017-333-3333
  im 019-444-4444
  son 016-555-5555
  gil 018-666-6666
  jang 011-7777-7777
  lee 016-8888-8888
  sa 017-9999-9999
  hwang 015-555-5555
  ```

  - 25세 이상인 사람의 이름과 나이를 출력하라

  ```shell
  [root@localhost ~]# awk '$2>25{print $1, $2}' sample
  park 28
  yoon 46
  kin 33
  ```

  - 아래의 sample 파일에서 '세' 글자를 없애고, 문장에 맞춰 출력해보자.

  ```shell
  [root@localhost ~]# cat sample
  sung 23세 010-1234-5678
  park 28세 011-8765-4321
  yoon 46세 010-4321-5678
  kin 33세 016-1122-3344
  la 15세 010-5555-5555
  ```

  ```shell
  [root@localhost ~]# sed 's/세//g' sample | awk '$2>25{print $1"님은 ",$2"세 입니다."}'
  park님은  28세 입니다.
  yoon님은  46세 입니다.
  kin님은  33세 입니다.
  ```

  - sed 프로그램을 sedfile1에, awk 프로그램을 awkfile1 파일에 저장 후 실행해보자.

  ```shell
  [root@localhost ~]# cat > sedfile1
  s/세//g
  [root@localhost ~]# cat > awkfile1
  $2 > 25 {print $1"씨는 ",$2"세 입니다"}
  [root@localhost ~]# sed -f sedfile1 sample | awk -f awkfile1
  park씨는  28세 입니다
  yoon씨는  46세 입니다
  kin씨는  33세 입니다
  ```

  - lastb.txt 의 내용은 다음과 같다.

  ```shell
  [root@localhost ~]# cat lastb.txt
  user     ssh:notty    192.168.110.200  Mon Oct  5 17:25 - 17:25  (00:00)
  user     ssh:notty    192.168.110.200  Mon Oct  5 17:13 - 17:13  (00:00)
  user     ssh:notty    192.168.110.200  Mon Oct  5 17:13 - 17:13  (00:00)
  user     ssh:notty    192.168.110.200  Mon Oct  5 17:13 - 17:13  (00:00)
  user     ssh:notty    192.168.110.200  Mon Oct  5 17:09 - 17:09  (00:00)
  user     ssh:notty    192.168.110.136  Mon Oct  5 17:08 - 17:08  (00:00)
  user     ssh:notty    192.168.110.136  Mon Oct  5 17:07 - 17:07  (00:00)
  userhat  ssh:notty    192.168.110.136  Mon Oct  5 16:27 - 16:27  (00:00)
  userhat  ssh:notty    192.168.110.136  Mon Oct  5 16:27 - 16:27  (00:00)
  userhat  ssh:notty    192.168.110.100  Mon Oct  5 16:27 - 16:27  (00:00)
  userhat  ssh:notty    192.168.110.100  Mon Oct  5 16:26 - 16:26  (00:00)
  userhat  ssh:notty    192.168.110.100  Mon Oct  5 16:26 - 16:26  (00:00)
  user     ssh:notty    192.168.110.110  Mon Oct  5 17:13 - 17:13  (00:00)
  user     ssh:notty    192.168.110.110  Mon Oct  5 17:09 - 17:09  (00:00)
  user     ssh:notty    192.168.110.110  Mon Oct  5 17:08 - 17:08  (00:00)
  user     ssh:notty    192.168.110.110  Mon Oct  5 17:07 - 17:07  (00:00)
  userman  ssh:notty    192.168.110.110  Mon Oct  5 16:26 - 16:26  (00:00)
  userman  ssh:notty    192.168.110.110  Mon Oct  5 16:25 - 16:25  (00:00)
  userman  ssh:notty    192.168.110.110  Mon Oct  5 16:25 - 16:25  (00:00)
  test     ssh:notty    localhost        Mon Oct  5 16:23 - 16:23  (00:00)
  test     ssh:notty    localhost        Mon Oct  5 16:23 - 16:23  (00:00)
  userman  ssh:notty    192.168.110.136  Mon Oct  5 16:25 - 16:25  (00:00)
  userman  ssh:notty    192.168.110.136  Mon Oct  5 16:25 - 16:25  (00:00)
  userman  ssh:notty    192.168.110.136  Mon Oct  5 16:25 - 16:25  (00:00)
  userman  ssh:notty    192.168.110.136  Mon Oct  5 16:25 - 16:25  (00:00)
  userman  ssh:notty    192.168.110.136  Mon Oct  5 16:24 - 16:24  (00:00)
  test     ssh:notty    localhost        Mon Oct  5 16:23 - 16:23  (00:00)
  test     ssh:notty    localhost        Mon Oct  5 16:23 - 16:23  (00:00)
  test     ssh:notty    localhost        Mon Oct  5 16:23 - 16:23  (00:00)
  userhat  ssh:notty    192.168.110.136  Mon Oct  5 16:26 - 16:26  (00:00)
  userhat  ssh:notty    192.168.110.136  Mon Oct  5 16:26 - 16:26  (00:00)
  test     ssh:notty    localhost        Mon Oct  5 16:23 - 16:23  (00:00)
  root     :0           :0               Mon Oct  5 11:02 - 11:02  (00:00)
  
  btmp begins Mon Oct  5 11:02:02 2020
  ```

  - 여기서 10번 이상 접속한 유저를 출력해보자.(심화)
    - **'~' :  특정 필드 조건을 지정**할 때 사용

  ```shell
  [root@localhost ~]# awk '$3 ~ /^[0-9]/{print $3}' lastb.txt | sort | uniq -c | awk '$1>=10{print "10회 이상 접속 시도 ip = "$2}'
  10회 이상 접속 시도 ip = 192.168.110.136
  ```

  - 분리해서 해석해보자.
    - **awk '$3 ~ /^[0-9]/{print $3}' lastb.txt** : 3번째 필드를 숫자로 시작하는 것으로 지정하고 3번째 필드를 출력**(/정규식/)**
    -  sort : 정렬 
    - uniq -c : 카운트 계산, uniq를 사용하기 전에는 반드시 sort해야한다.
    -  **awk '$1>=10{print "10회 이상 접속 시도 ip = "$2}'** : 첫번째 필드(uniq -c를 통해 계산된 카운트 횟수)가 10이상인 것을 출력
  - sample 파일에서 나이의 평균을 구하는 프로그램을 구현해보자.

  ```shell
  [root@localhost ~]# cat sedfile1
  s/세//g
  [root@localhost ~]# cat > awkfile2
  BEGIN {
   sum = 0;
   line = 0;
  }
  {
   sum += $2;
   line ++;
  }
  END {
  average = sum / line;
  print "나이의 평균 : "average"세";
  }
  [root@localhost ~]# sed -f sedfile1 sample | awk -f awkfile2
  나이의 평균 : 29세
  ```

  