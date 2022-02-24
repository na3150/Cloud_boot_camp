<h1> [Linux] 파티셔닝, 파일 시스템 및 마운트 정리 </h1>



<h3>📌INDEX</h3>

- [시스템 디스크 사용 절차](#시스템 디스크 사용 절차)
- [디바이스 정보 확인: lsblk, blkid, df-Th](#디바이스-정보-확인)
  - [lsblk](#lsblk)
  - [blkid](#blkid)
- [파티셔닝](#파티셔닝)
  - [fdisk](#fdisk)
  - [gdisk](#gdisk)
  - [partprobe](#partprobe)
-  [파일 시스템](#파일-시스템)
  - [mkfs](#mkfs)
- [실습](#실습)

<br>

<br>

<br>

<h2>시스템 디스크 사용 절차</h2>

1. **디스크 삽입**
2. **파티션** 생성
   - fdisk 명령어 사용
3. 파일 시스템 **포맷**
   - ex) mkfs.ext4
4. **마운트**
   - mount를 사용하여 특정 디렉토리와 마운트 한다

- 참고) 리눅스에서 사용되는 모든 장치는 /dev 디렉토리에 저장된다

<br>

<br>

<h2>디바이스 정보 확인</h2>



<h4>lsblk</h4>

- **리눅스 디바이스 정보를 출력하는 명령어**

- 옵션 없이 사용하면 **트리형식으로 모든 스토리지 디바이스를 출력**

- **`df -Th`**명령을 통해서도 **마운트 및 파일 시스템 확인 가능**

- 옵션

  - -a : 모든 장치들을 출력
  - -f : 파일 시스템 정보까지 출력
  - -t : topology 정보까지 출력
  - -l : 포맷한 디스크 목록 출력

  

  사용 예

  ```shell
  [root@localhost ~]# lsblk
  NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
  sda      8:0    0   60G  0 disk
  ├─sda1   8:1    0    4G  0 part [SWAP]
  └─sda2   8:2    0   56G  0 part /
  sdb      8:16   0   20G  0 disk
  sr0     11:0    1 1024M  0 rom
  ```

  ```shell
  [root@localhost ~]# lsblk -f
  NAME   FSTYPE LABEL UUID                                 MOUNTPOINT
  sda
  ├─sda1 swap         88f82736-89b0-49e6-88c5-165c88bcc5bf [SWAP]
  └─sda2 xfs          231c776b-3197-4e9f-a142-6b80be0ca930 /
  sdb
  sr0
  ```

  ```shell
  [root@localhost ~]# df -Th
  Filesystem     Type      Size  Used Avail Use% Mounted on
  /dev/sda2      xfs        56G  4.4G   52G   8% /
  devtmpfs       devtmpfs  985M     0  985M   0% /dev
  tmpfs          tmpfs    1000M     0 1000M   0% /dev/shm
  tmpfs          tmpfs    1000M  9.2M  991M   1% /run
  tmpfs          tmpfs    1000M     0 1000M   0% /sys/fs/cgroup
  tmpfs          tmpfs     200M   12K  200M   1% /run/user/42
  tmpfs          tmpfs     200M     0  200M   0% /run/user/0
  ```



- <h4>blkid</h4>

  - 파일 시스템 관련 파티션을 확인하는 명령어
    - 파일 시스템 유형이나 속성(label, uuid 등)을 출력
    - **UUID 정보를 얻을 때 많이 사용**
  - /etc/blkid/blkid.tab에 캐싱된 정보 데이터 저장
  - 마운트 전에도 정보 확인 가능
  - blkid [디바이스명] : 특정 디바이스의 정보만 출력

```shell
[root@localhost ~]# blkid
/dev/sda1: UUID="88f82736-89b0-49e6-88c5-165c88bcc5bf" TYPE="swap"
/dev/sda2: UUID="231c776b-3197-4e9f-a142-6b80be0ca930" TYPE="xfs"
```

```shell
[root@localhost ~]# blkid /dev/sda1
/dev/sda1: UUID="88f82736-89b0-49e6-88c5-165c88bcc5bf" TYPE="swap"
```



<br>

<br>

<h2>파티셔닝</h2>

- 파티셔닝: **하나의 물리 저장장치를 시스템 내부에서 여러 디스크 공간으로 나누는 작업**
- 공간을 물리적 혹은 논리적으로 나눌 수 있음
  - 물리적으로 나뉜 공간: **프라이머리(Primary)**
    - 주 파티션(Primary Partition)
    - **최대 4개의 공간**으로 나눌 수 있음
    - 부팅이 가능한 파티션
    - 많은 파티셔닝이 필요한 경우, 익스텐디드 공간으로 논리적으로 확장
  - 논리적으로 나뉜 공간: **익스텐디드(Extended)**
    - **확장(extended) 파티션 안에서 논리적인 파티션(logical) 파티션을 나누어 사용**

- 이렇게 나뉜 각각의 저장공간을 **파티션(Partition)**이라고 부른다

- 파티셔닝 작업은 단순히 디스크 공간을 나누는 작업 뿐만 아니라, 나뉜 공간의 파일 시스템을 지정하는 것도 포함된다
  - 파일 시스템: 물리적 혹은 논리적으로 나뉜 공간의 파일(data)를 어떻게 배치하고 관리할 것인가를 정의한 시스템

- 기본적으로 한 디스크에는 하나의 파티션(한 종류)만 가능
- 주의) **확장 파티션을 삭제하면 내부의 로지컬 파티션이 모두 날라가므로(삭제되므로)** 주의해야한다.



<h4>fdisk</h4>

- fdisk(fixed disk) :  **MBR 파티션을 생성**하는 명령어
  - MBR : Master Boot Record의 약자로, 부팅을 하기 위한 정보를 담고있으며 일반적으로 0번 섹터에 저장되어있음
- 사용법: fdisk [옵션] [파일명]
- **`fdisk -l`** : 현재 디스크 및 파티션 보기

```shell
[root@localhost ~]# fdisk -l

Disk /dev/sda: 64.4 GB, 64424509440 bytes, 125829120 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000b54a5

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1            2048     8390655     4194304   82  Linux swap / Solaris
/dev/sda2   *     8390656   125829119    58719232   83  Linux

Disk /dev/sdb: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

- 옵션을 사용하면 fdisk 모드로 들어가지지 않고, 옵션 없이 파일(디스크)를 지목하면 fdisk 모드로 들어가지게 된다

- Command (fdisk 모드) 명령어

  - m : menu, 도움말
  - p : 파티션 테이블 확인
  - n : 파티션 추가
  - d : 파티션 삭제
  - t : 파티션의 시스템 ID 변경(속성 변경)
  - w : 저장 후 종료
  - q : 저장하지 않고 종료 

  

  **사용 예**

  - fdisk /dev/sda 
    - 위에서 fdisk -l 명령어를 통해 정보를 확인했을 때, /dev/sdb로 20GB가 추가되어있는 것을 확인할 수 있다
    - fdisk 모드 명령을 사용할 수 있게 됨
    - p 를 눌러, 파티션 테이블을 확인

  ```shell
  [root@localhost ~]# fdisk /dev/sdb
  Welcome to fdisk (util-linux 2.23.2).
  
  Changes will remain in memory only, until you decide to write them.
  Be careful before using the write command.
  
  Device does not contain a recognized partition table
  Building a new DOS disklabel with disk identifier 0x76e57f7c.
  
  Command (m for help): p
  
  Disk /dev/sdb: 21.5 GB, 21474836480 bytes, 41943040 sectors
  Units = sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes
  Disk label type: dos
  Disk identifier: 0x76e57f7c
  
     Device Boot      Start         End      Blocks   Id  System
  ```

  - /dev/sdb를 대상으로 2G 크기의 주(Primary)파티션을 3개로 생성(파티셔닝)해보자

    1. command에 n 입력
    2.  Enter (defuault p)
    3.  Enter (파티션 번호 default)
    4.  Enter(first sector default)
    5. +2G 입력

    - 파티션 테이블을 확인했을 때 주 파티션 3개가 생성된 것을 확인할 수 있다

  ```shell
  [root@localhost ~]# fdisk /dev/sdb
  Welcome to fdisk (util-linux 2.23.2).
  
  Changes will remain in memory only, until you decide to write them.
  Be careful before using the write command.
  
  Device does not contain a recognized partition table
  Building a new DOS disklabel with disk identifier 0x7c5a2631.
  
  Command (m for help): n
  Partition type:
     p   primary (0 primary, 0 extended, 4 free)
     e   extended
  Select (default p): p
  Partition number (1-4, default 1): 1
  First sector (2048-41943039, default 2048):
  Using default value 2048
  Last sector, +sectors or +size{K,M,G} (2048-41943039, default 41943039): +2G
  Partition 1 of type Linux and of size 2 GiB is set
  
  ...2번 더 반복
  
  Command (m for help): p
  
  Disk /dev/sdb: 21.5 GB, 21474836480 bytes, 41943040 sectors
  Units = sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes
  Disk label type: dos
  Disk identifier: 0x7c5a2631
  
     Device Boot      Start         End      Blocks   Id  System
  /dev/sdb1            2048     4196351     2097152   83  Linux
  /dev/sdb2         4196352     8390655     2097152   83  Linux
  /dev/sdb3         8390656    12584959     2097152   83  Linux
  ```

  - 이어서 확장(Extended) 파티션의 2G 4개를 생성(파티셔닝)해보자

  ```shell
  Command (m for help): n
  Partition type:
     p   primary (3 primary, 0 extended, 1 free)
     e   extended
  Select (default e): e
  Selected partition 4
  First sector (12584960-41943039, default 12584960):
  Using default value 12584960
  Last sector, +sectors or +size{K,M,G} (12584960-41943039, default 41943039):
  Using default value 41943039
  Partition 4 of type Extended and of size 14 GiB is set
  
  Command (m for help): n
  All primary partitions are in use
  Adding logical partition 5
  First sector (12587008-41943039, default 12587008):
  Using default value 12587008
  Last sector, +sectors or +size{K,M,G} (12587008-41943039, default 41943039): +2G
  Partition 5 of type Linux and of size 2 GiB is set
  
  ....
  
  Command (m for help): p
  
  Disk /dev/sdb: 21.5 GB, 21474836480 bytes, 41943040 sectors
  Units = sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes
  Disk label type: dos
  Disk identifier: 0xc70a726d
  
     Device Boot      Start         End      Blocks   Id  System
  /dev/sdb1            2048     4196351     2097152   83  Linux
  /dev/sdb2         4196352     8390655     2097152   83  Linux
  /dev/sdb3         8390656    12584959     2097152   83  Linux
  /dev/sdb4        12584960    41943039    14679040    5  Extended
  /dev/sdb5        12587008    16781311     2097152   83  Linux
  /dev/sdb6        16783360    20977663     2097152   83  Linux
  /dev/sdb7        20979712    25174015     2097152   83  Linux
  /dev/sdb8        25176064    29370367     2097152   83  Linux
  ```

   

<h4>gdisk</h4>

- **GPT 파티션을 생성**하는 명령어
  - GPT : GUID Partition Table
  - 주파티션 128개까지 가능하며, 리눅스 2TB이상 디스크 사용가능
- 사용법 : gdisk [디스크명]



<img src="C:\Users\USER\Desktop\파티션 방식.PNG" style="zoom:80%;" />



<h4>partprobe</h4>

- **디스크 정보를 시스템에 등록하는 명령어**
- 재부팅 없이 파티션을 인식할 수 있다.
  - /proc/partitions에서 확인 가능
- **파티셔닝 한 이후**, 변경사항에 대해 시스템에게 알려주어야하기 때문에 **반드시 partprobe 해주어야 한다.**



<br>

<br>

<h2>파일 시스템 포맷</h2>

- **파일시스템(File system)**이란 파일(data)을 사용자가 쉽게 접근 및 발견할 수 있도록 운영체제가 시스템의 디스크 상에서 일정한 규칙을 가지고 보관하는 방식
- 리눅스에서는 파티션을 나누고 정리하는데 주로 사용
- 리눅스 파일 시스템 예시: ext3, ext4, swap, nfs, xfs 등

- **포맷(format) : 파일 시스템을 구축하는 작업**
  - 일반적으로 포맷을 하면 데이터가 지워지고(기존 구조에 새로운 구조를 덮어씌우기 때문) 새로운 파일시스템이 적용되나, 운영체제에 따라 데이터를 보존하고 파일 시스템만 변환시킬 수 있다.
- ext4 : 리눅스의 저널링 파일 시스템으로 ext3 파일 시스템의 향상된 버전
- xfs :  XFS는 1993년 실리콘 그래픽스(SGI)가 만든 고성능 64비트 저널링 파일 시스템



<h4>mkfs</h4>

- mkfs(make file system)은 파티션한 하드디스크를 **포맷할 때 사용하는 명령어**이다

- **mkfs -t [파일시스템] [옵션] [파티션명]** 

- **mkfs.[파일시스템] [옵션] [파티션명]**

- 옵션 

  - -t : type, 파일 시스템의 형식을 지정한다
  - -f : force, 포맷하려는 디스크에 다른 파일 시스템이 포맷되어 있으면 강제로 덮어씌운다

  

  **사용 예**

  - 파티션 1~2를 xfs로 포맷

  ```shell
  [root@localhost ~]# mkfs -t xfs /dev/sdb1
  meta-data=/dev/sdb1                    isize=256     agcount=4, 
  agsize=65536 blks
           =                             sectsz=512    attr=2, projid32bit=1
           =                             crc=0
  data     =                             bsize=4096    blocks=262144, 
  imaxpct=25
           =                             sunit=0       swidth=0 blks
  naming   =version 2                    bsize=4096    ascii-ci=0 ftype=0
  log      =internal log                 bsize=4096    blocks=2560, 
  version=2
           =                             sectsz=512    sunit=0 blks, lazy- 
  count=1   
  realtime =none                         extsz=4096    blocks=0, rtextents=0
  ```

  ```shell
  [root@localhost ~]# mkfs.xfs /dev/sdb2
  meta-data=/dev/sdb2                    isize=256    agcount=4, 
  agsize=65536 blks
           =                             sectsz=512   attr=2, 
  projid32bit=1
           =                             crc=0
  data     =                             bsize=4096   blocks=262144, 
  imaxpct=25
           =                             sunit=0      swidth=0 blks
  naming   =version 2                    bsize=4096   ascii-ci=0 ftype=0
  log      =internal log                 bsize=4096   blocks=2560, 
  version=2
           =                             sectsz=512   sunit=0 blks, 
  lazy-count=1
  realtime =none                         extsz=4096   blocks=0, 
  rtextents=0
  
  ```



<br>

<br>

<h2>mount</h2>

- **물리적인 장치를 특정한 위치(일반적으로 디렉토리)에 연결시켜주는 과정**을 마운트(mount)라고 한다.

  - 하드웨어 장치들을 리눅스 운영체제에 인식시키는 것

- /etc/mtab : 현재 리눅스 시스템의 마운트된 정보를 보관하고 있는 파일

- **mount [옵션] [장치명] [마운트포인트(path)]**

- 옵션

  - **-a : /etc/fstab 에 명시된 파일 시스템을 마운트**할 때 쓰이는 옵션(**자동마운트**)
  - -o [항목] : 마운트 시, 추가적인 설정을 적용할 때 사용하는 옵션
  - 옵션 없이 사용했을 경우, 현재 시스템에 마운트된 정보 확인가능

  

- <h4>umount</h4>

  - **마운트를 해제하는 명령어**

  - **umount [옵션] [장치면] [마운트포인트(path)]**

  - 옵션

    - -a : 사용중인 마운트를 제외한 모든 마운트 해제

    

- 시스템을 껐다가 키면 마운트가 사라진다.

  - **영구로 하려면, /etc/fstab에 저장**해야한다.

  

- **자동마운트 : /etc/fstab 파일에 작성**

- **/etc/fstab** 파일 구성

```shell
장치명(UUID)   마운트포인트   파일시스템   옵션      덤프유무     파일시스템체크순서
/dev/sdb1     /mnt/disk1    ext4    defaults  0(만들땐1)           1 
/dev/sdb2     /mnt/disk2     xfs    defaults     0                1
```

```shell
[root@localhost ~]# cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Mon Feb 21 14:50:32 2022
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=231c776b-3197-4e9f-a142-6b80be0ca930 /                       xfs     defaults        0 0
UUID=88f82736-89b0-49e6-88c5-165c88bcc5bf swap                    swap    defaults        0 0
```

- UUID란? 장치가 갖는 고유한 ID로 변경되지 않는다



<br>

<br>

<h2>실습</h2>

1. 파티션 생성

   - 대상 : /dev/sdb

   - 주 파티션 : 2G 2G 2G
   - 확장 파티션 : 2G 2G 2G 2G
   - 과정은 위의 fdisk 사용 예시와 동일(생략)

```shell
Command (m for help): p

Disk /dev/sdb: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x3d321701

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048     4196351     2097152   83  Linux
/dev/sdb2         4196352     8390655     2097152   83  Linux
/dev/sdb3         8390656    12584959     2097152   83  Linux
/dev/sdb4        12584960    41943039    14679040    5  Extended
/dev/sdb5        12587008    16781311     2097152   83  Linux
/dev/sdb6        16783360    20977663     2097152   83  Linux
/dev/sdb7        20979712    25174015     2097152   83  Linux
/dev/sdb8        25176064    29370367     2097152   83  Linux
```

2. command w로 저장 후 partprobe 명령(디스크 정보를 시스템에 등록)

```

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
[root@localhost ~]# partprobe /dev/sdb
```

3. 파티션 1~3번을 ex4로 포맷

```shell
[root@localhost ~]# mkfs -t ext4 /dev/sdb2
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
131072 inodes, 524288 blocks
26214 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=536870912
16 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

[root@localhost ~]# mkfs -t ext4 /dev/sdb3
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
131072 inodes, 524288 blocks
26214 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=536870912
16 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```

4. 파티션 5~8을 xfs로 포맷

```shell
[root@localhost ~]# mkfs.xfs /dev/sdb5
meta-data=/dev/sdb5              isize=512    agcount=4, agsize=131072 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=524288, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

...6,7,8동일
```

5. /mnt/disk1~3 에 파티션 1~3을 각각 수동 마운트

```shell
[root@localhost ~]# mkdir /mnt/disk{1..3}
[root@localhost ~]# mount /dev/sdb1 /mnt/disk1
[root@localhost ~]# mount /dev/sdb2 /mnt/disk2
[root@localhost ~]# mount /dev/sdb3 /mnt/disk3
```

6. 마운트 및 파일 시스템 확인
   - lsblk 또는 df -Th

```
[root@localhost ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   60G  0 disk
├─sda1   8:1    0    4G  0 part [SWAP]
└─sda2   8:2    0   56G  0 part /
sdb      8:16   0   20G  0 disk
├─sdb1   8:17   0    2G  0 part /mnt/disk1
├─sdb2   8:18   0    2G  0 part /mnt/disk2
├─sdb3   8:19   0    2G  0 part /mnt/disk3
├─sdb4   8:20   0    1K  0 part
├─sdb5   8:21   0    2G  0 part
├─sdb6   8:22   0    2G  0 part
├─sdb7   8:23   0    2G  0 part
└─sdb8   8:24   0    2G  0 part
sr0     11:0    1 1024M  0 rom
```

7. 한꺼번에 모든 마운트 해제
   - 사용중인 마운트를 제외하고 모든 마운트를 제외한다

```shell
[root@localhost ~]# umount -a
umount: /run/user/42: target is busy.
        (In some cases useful info about processes that use
         the device is found by lsof(8) or fuser(1))
umount: /: target is busy.
        (In some cases useful info about processes that use
         the device is found by lsof(8) or fuser(1))
umount: /sys/fs/cgroup/systemd: target is busy.
        (In some cases useful info about processes that use
         the device is found by lsof(8) or fuser(1))
umount: /sys/fs/cgroup: target is busy.
        (In some cases useful info about processes that use
         the device is found by lsof(8) or fuser(1))
umount: /run: target is busy.
        (In some cases useful info about processes that use
         the device is found by lsof(8) or fuser(1))
umount: /dev: target is busy.
        (In some cases useful info about processes that use
         the device is found by lsof(8) or fuser(1))
```

8. 파티션 1~3을 xfs로 재 포맷

```shell
[root@localhost ~]# mkfs.xfs -f /dev/sdb1
...
[root@localhost ~]# mkfs -t xfs -f /dev/sdb2
...
[root@localhost ~]# mkfs.xfs -f /dev/sdb3
```

9. 자동 마운트
   - blkid 명령어를 통해 uuid 값 확인
   - vi 에디터로 /etc/fstab 내용 수정

```
[root@localhost ~]# blkid
/dev/sda1: UUID="88f82736-89b0-49e6-88c5-165c88bcc5bf" TYPE="swap"
/dev/sda2: UUID="231c776b-3197-4e9f-a142-6b80be0ca930" TYPE="xfs"
/dev/sdb1: UUID="670e7e84-fe47-4981-b743-ff38b83617b9" TYPE="xfs"
/dev/sdb2: UUID="06d34523-1c6e-4c81-9130-b48251d6f9a1" TYPE="xfs"
/dev/sdb3: UUID="a19f7479-5864-4cf2-a32c-49dc4560b3ef" TYPE="xfs"
/dev/sdb5: UUID="f1f3f291-bbfd-4ba5-aa55-a933617ab32a" TYPE="xfs"
/dev/sdb6: UUID="b8d62c60-b8b2-4448-b07b-8f987a5691c8" TYPE="xfs"
/dev/sdb7: UUID="e127e9c3-ce52-404d-af2c-277aa05cdb3e" TYPE="xfs"
/dev/sdb8: UUID="ab6b910a-1739-498c-a3cb-aa72f37d1622" TYPE="xfs"
```

```
[root@localhost ~]# cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Mon Feb 21 14:50:32 2022
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=231c776b-3197-4e9f-a142-6b80be0ca930 /                       xfs     defaults        0 0
UUID=88f82736-89b0-49e6-88c5-165c88bcc5bf swap                    swap    defaults        0 0
UUID="670e7e84-fe47-4981-b743-ff38b83617b9" /mnt/disk1 xfs defaults 1 1
UUID="06d34523-1c6e-4c81-9130-b48251d6f9a1" /mnt/disk2 xfs defaults 1 1
UUID="a19f7479-5864-4cf2-a32c-49dc4560b3ef" /mnt/disk2 xfs defaults 1 1
```

10. 재부팅하지 않고, 자동마운트 설정된 마운트들을 모두 mount

```
[root@localhost ~]# mount -a
```

11. 마운트 확인

```shell
[root@localhost ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   60G  0 disk
├─sda1   8:1    0    4G  0 part [SWAP]
└─sda2   8:2    0   56G  0 part /
sdb      8:16   0   20G  0 disk
├─sdb1   8:17   0    2G  0 part /mnt/disk1
├─sdb2   8:18   0    2G  0 part /mnt/disk2
├─sdb3   8:19   0    2G  0 part /mnt/disk2
├─sdb4   8:20   0    1K  0 part
├─sdb5   8:21   0    2G  0 part
├─sdb6   8:22   0    2G  0 part
├─sdb7   8:23   0    2G  0 part
└─sdb8   8:24   0    2G  0 part
sr0     11:0    1 1024M  0 rom
```

11. /dev/sdb의 모든 파티션 삭제

```shell
[root@localhost ~]# umount -a
```

12. fdisk 모드에 command d로 4번 파티션 삭제

- extend 파티션을 삭제하여 logical 파티션이 모두 삭제된 것을 확인 가능

```
[root@localhost ~]# fdisk /dev/sdb
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): d
Partition number (1-8, default 8): 4
Partition 4 is deleted

Command (m for help): p

Disk /dev/sdb: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x3d321701

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048     4196351     2097152   83  Linux
/dev/sdb2         4196352     8390655     2097152   83  Linux
/dev/sdb3         8390656    12584959     2097152   83  Linux
```

13. fdisk모드 상태에서 d를 입력하여 파티션 모두 삭제 후 w로 저장

```shell
Command (m for help): d
Partition number (1-3, default 3):
Partition 3 is deleted

Command (m for help): d
Partition number (1,2, default 2):
Partition 2 is deleted

Command (m for help): d
Selected partition 1
Partition 1 is deleted

Command (m for help): d
No partition is defined yet!

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
```

14. partprobe 명령어로 시스템에 디스크 정보를 등록

```shell
[root@localhost ~]# partprobe /dev/sdb
```

15. /etc/fstab에서 /dev/sdb(1~3) 정보 삭제

```shell
[root@localhost ~]# vi /etc/fstab
[root@localhost ~]# cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Mon Feb 21 14:50:32 2022
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=231c776b-3197-4e9f-a142-6b80be0ca930 /                       xfs     defaults        0 0
UUID=88f82736-89b0-49e6-88c5-165c88bcc5bf swap                    swap    defaults        0 0
```







참조

- [[Linux Storage\] 리눅스 시스템 디스크 파티션 및 관련 개념 정리 (tistory.com)](https://itguava.tistory.com/100)
- [[Linux\] 마운트 파티션 나누기 & fdisk명령어 ③ (tistory.com)](https://it-serial.tistory.com/50)

- [파일시스템의 이해1 (imsosimin.com)](https://imsosimin.com/43)

- [마운트(mount) 뜻, 관련 명령어 & 문제 (fdisk, df, mkfs,디스크마운트) (tistory.com)](https://jhnyang.tistory.com/12)