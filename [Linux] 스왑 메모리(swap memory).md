<h1> [Linux] 스왑 메모리(swap memory) </h1>



<h3>📌INDEX</h3>

- [스왑 메모리란?](#스왑-메모리란)
- [swap 관련 명령어](#swap-관련-명령어)
  - [free](#free)
  - [mkswap](#mkswap)
  - [swapon](#swapon)
  - [swapoff](#swapoff)
  - [자동 swap 마운트(mount)](#자동-swap-마운트)

<br>

<br>



<h2>스왑 메모리란?</h2>

- 스왑 메모리(swap memory)란 **물리적 디스크 공간을 메모리 공간처럼 사용하는 방식**이다
  - 디스크 영역을 메모리 영역화
  - 메모리 처럼 사용
- 가상 메모리 = 시스템 RAM(물리 메모리) + swap 공간

- RAM이 부족한 상태가 되었을 때, 메모리의 일부분을 저장 장치에 저장하여 빈 공간을 만들어 낸다.
  - 이때 메모리의 내용이 저장된 영역을 SWAP영역이라 한다

- 기존 프로세스 중에서 **가장 오래되고, 가장 중요도가 적은 프로세스를 SWAP 영역으로 전환**

- 원리 
  - 프로그램 실행 시 메모리에 로드
  - 메모리 공간 부족 시
  - 오래된 프로세스, 중요도가 낮은 프로세스 swap 공간으로 이동
  - 새로운 프로세스 로드

<br>

<br>

<h2>swap 관련 명령어</h2>



<h4>free</h4>

- **swap 공간을 확인하는 명령어**
- 옵션
  - -h : 사람이 읽기 쉬운 단위로 출력
  - -b, -k, -m, -g : 바이트, 키로바이트, 메가바이트, 기가바이트 단위로 출력
  - -w : 와이드 모드로 cache와 buffers를 따로 출력

- **필드**
  - total : 설치된 총 메모리 크기 / 설정된 스왑 총 크기
  - used : total에서 free, buff/cache를 뺀 사용중인 메모리. / 사용중인 스왑 크기
  - free : total에서 used와 buff/cahce를 뺀 실제 사용 가능한 여유 있는 메모리량 / 사용되지 않은 스왑 크기
  - shared :  tmpfs(메모리 파일 시스템), ramfs 등으로 사용되는 메모리. 여러 프로세스에서 사용할 수 있는 공유 메모리
  - buffers : 커널 버퍼로 사용중인 메모리
  - cache : 페이지 캐시와 slab으로 사용중인 메모리
  - buff/cache : 버퍼와 캐시를 더한 사용중인 메모리
  - available : swapping 없이 새로운 프로세스에서 할당 가능한 메모리의 예상 크기. (예전의 -/+ buffers/cache이 사라지고 새로 생긴 컬럼)



사용 예

```shell
[root@localhost ~]# free -h
              total        used        free      shared  buff/cache   available
Mem:           2.0G        407M        1.1G        9.3M        451M        1.4G
Swap:          4.0G          0B        4.0G
```



<h4>mkswap</h4>

- 새로 만든 **파티션/파일을 swap 영역으로 지정**하기 위해 사용하는 명령어
- swap 파일 시스템 생성
- **mkswap [옵션] [swap파일/파티션]**
- 옵션
  - -c : swap 파티션으로 만들기 전에 배드블록을 검사해주는 옵션



사용 예

```shell
[root@localhost ~]# mkswap /dev/sdb1
Setting up swapspace version 1, size = 3145724 KiB
no label, UUID=670e7e84-fe47-4981-b743-ff38b83617b9
```



<h4>swapon</h4>

- 만들어진 **swap 영역을 사용하기 위해 활성화(on) 시켜주는 명령어**
  - 파티션을 swap 영역으로 지정했더라도 바로 사용 가능한 것이 아니다
- **수동 swap 마운트(mount)**
- **swapon [옵션] [파티션명]**
- 옵션 
  - -s : swap 상태일 때, 사용중인 파티션 확인
  - -a : /etc/fstab 에 설정된 swap 마운트(mount) 실행



사용 예

```shell
[root@localhost ~]# swapon -s
Filename                                Type            Size    UsePriority
/dev/sda1                               partition       4194300 0  -1
```

```shell
[root@localhost ~]# swapon /dev/sdb3
[root@localhost ~]# free
        total used free shared buffers cached
Mem: 4033908 1256324 2777584 10256 1304 292284
-/+ buffers/cache: 962736 3071172
Swap: 2621432 0 2621432
```



<h4>swapoff</h4>

- **활성화시킨 swap 파티션을 비활성화(off) 시켜주는 명령어**
- **수동 swap 마운트 해제**
- **swapoff [옵션] [파티션명]**
- 옵션
  - -a : 모든 swap 마운트 해제



사용 예

```shell
[root@localhost ~]# swapoff /dev/sdb3
[root@localhost ~]# free
        total used free shared buffers cached
Mem: 4033908 1255768 2778140 10256 1300 292264
-/+ buffers/cache: 962204 3071704
Swap: 2097148 0 2097148
```



<h4>자동 swap 마운트</h4>

- **/etc/fstab 파일 수정**
- /etc/fstab에 문장을 추가하면, **재부팅시에도 자동으로 swap 메모리가 활성화**된다
- swap은 디렉토리 구조로 접근하지 않기 때문에 마운트 포인트를 swap으로 지정한다
- swap 공간은 백업 및 파일 시스템 점검이 필요없다

- /etc/fstab 파일 구성
  - uuid는 blkid 명령을 통해 확인

```shell
장치명(UUID)   마운트포인트   파일시스템   옵션      덤프유무     파일시스템체크순서
예시) UUID        swap        swap   defaults      0               0
```



예시 

```shell
#
# /etc/fstab
# Created by anaconda on Wed Mar 23 04:53:16 2016
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/rhel-root / xfs defaults 1 1
UUID=739dc405-a245-4014-913a-9a8afc6cdeef /boot xfs defaults 1 2
/dev/mapper/rhel-swap swap swap defaults 0 0
UUID="e242d743-4b22-491c-b1f4-0609a8cb4c54" /mnt/xfs xfs defaults 0 0
UUID="3b25bb12-5149-4cea-8858-3cca575d1129" swap swap defaults 0 0
```







참조

- [리눅스 free 명령어로 메모리 상태 확인하기 | 와탭 블로그 (whatap.io)](https://www.whatap.io/ko/blog/37/)

- [[리눅스\] swap 생성 및 관리 (mkswap / dd) (tistory.com)](https://wiseworld.tistory.com/62)

  