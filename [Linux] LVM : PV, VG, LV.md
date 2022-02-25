<h2> [Linux] LVM: PV, VG, LV </h2>



<h3>📌INDEX</h3>

- [LVM이란?](#lvm이란)
-  [물리 볼륨 PV(Pysical Volume)](#물리-볼륨physical-volume)
-  [볼륨 그룹 VG(Volume Group)](#볼륨-그룹volume-group)
- [논리 볼륨 LV(Logical Volume)](#논리-볼륨logical-volume)

<br>

<br>

<br>

<h2>LVM이란?</h2>

- LVM(Logical Volume Manager)은 **Logical Volume(논리 볼륨)을 효율적이고 유연하게 관리**하기 위한 커널의 한 부분이자 프로그램이다
- **여러 개의 하드디스크를 합쳐서 한 개의 파일 시스템으로 사용**하는 것으로, 필요에 따라서 다시 나눌 수 있다

- 추상적 레이어를 생성해서 논리적 스토리지(가상의 블록 장치)를 생성할 수 있게 해줌
  - 직접적으로 물리적 스토리지를 사용하는 것보다 다양한 측면에서 유연성 제공

- RAID를 적용한 볼륨 생성 가능



- **논리 볼륨의 구조**



<img src="https://user-images.githubusercontent.com/64996121/155739930-ecbc5d8d-5a94-4e46-9468-1f197a923d21.PNG" width=250 heigth=200 />



- **PV(Physical Volume)** : 물리 장치와 직접 매핑, 다양한 장치로 생성 가능
  -  /dev/sda1, /dev/sda2 등의 **파티션**
- **VG(Volume Group)** : 하나 이상의 PV로 구성, 사용 가능한 PE를 LV에 할당
- **LV(Logical Volume)** : 실질적인 사용 공간, VG 범위 내에서 생성
  - LV는 LE 단위로 구성되므로, 크기도 LE 크기의 배수로 할당된다
- PE(Physical Extent) : PV를 구성하는 기본 단위, 데이터 저장 단위
- LE(Logical Extent) : LV를 이루는 기본 단위, 기본적으로 PE와 1대1매칭



- **논리 볼륨 생성**

  - 물리적 저장 장치를 논리적 장치로 관리한다
  - 공간 활용이 유연하며, 확장성이 좋다
  - 저장 장치의 종류에 무관하다
  - 물리 저장 장치(파티션)의 최소단위는 섹터이지만, 논리 저장 장치(논리볼륨)의 최소 단위는 PE(LE)이다.
  - 사용하는 도중에 명령어로 확장, 축소가 가능하다

  

- **논리 볼륨 생성 과정**
  - **파티션**으로 나누기(fdisk)
  - 파티션을 **PV로 변환 **(초기화)
  - 물리볼륨(PV)으로 볼륨그룹(VG) 생성 : **VG 생성 **
  - 볼륨그룹(VG)에서 논리볼륨(LV) 할당 : **LV 생성**
  - 논리볼륨(LV) 에 파일시스템 생성 : **포맷**
  - **마운트** 후 사용



<br>

<br>

<h2>물리 볼륨(Physical Volume)</h2>

- **PV(Physical Volume)**
  - LVM에서 블록 장치를 사용하려면 PV로 초기화해야함
    - 블록 장치 : 블록 단위로 접근하는 스토리지 ex)하드 디스크
  - **파티션들을 LVM에서 사용할 수 있게 변환한 것**
    - 예를 들어 /dev/sda1, /dev/sda2 는 LVM으로 쓰기 위해 PV라는 형식으로 변환한 것 
  - PV는 일정한 크기의 **PE(Physical Extent)들로 구성**



<h4>pvcreate</h4>

- **physical volume(PV)를 생성**하는 명령어
- **pvcreate [장치명]**
- **pvs** : **pv 목록을 확인**할 때 사용하는 명령어



사용 예 (파티션 되어있다고 가정: 4G, 4G, 6G, 6G)

```shell
[root@localhost ~]# pvcreate /dev/sdb[1-4]
  Physical volume "/dev/sdb1" successfully created.
  Physical volume "/dev/sdb2" successfully created.
  Physical volume "/dev/sdb3" successfully created.
  Physical volume "/dev/sdb4" successfully created.
[root@localhost ~]# pvs
  PV         VG  Fmt  Attr PSize  PFree
  /dev/sdb1  vg0 lvm2 a--  <4.00g <4.00g
  /dev/sdb2      lvm2 ---   4.00g  4.00g
  /dev/sdb3  vg0 lvm2 a--  <6.00g <6.00g
  /dev/sdb4      lvm2 ---  <6.00g <6.00g
```

```
[root@localhost ~]# blkid
/dev/sda1: UUID="88f82736-89b0-49e6-88c5-165c88bcc5bf" TYPE="swap"
/dev/sda2: UUID="231c776b-3197-4e9f-a142-6b80be0ca930" TYPE="xfs"
/dev/sdb1: UUID="NIc8Zl-gSWu-gMvI-2y0c-cWnl-lGL0-tvueV2" TYPE="LVM2_member"
/dev/sdb2: UUID="pG0Wtx-xJrV-3RJY-9zUs-Gbr1-f3WT-9Kcwmc" TYPE="LVM2_member"
/dev/sdb3: UUID="IKBHil-beVd-fxLO-CemL-pa1y-tLYT-w3yt9v" TYPE="LVM2_member"
/dev/sdb4: UUID="b7nt7y-tqA2-hiaR-65mg-Ssb3-IgNw-tKASQH" TYPE="LVM2_member"
```

- blkid 명령어로 확인했을 때, TYPE="LVM2_member"로 생성된 것을 확인할 수 있다.
  - 이게 없으면 PV가 없는 것이다





<h4>pvdisplay</h4>

- Physical Volume(PV)의 속성을 출력하는 명령어
- **pvdisplay [장치명]**



사용 예

```shell
[root@localhost ~]# pvdisplay
  "/dev/sdb1" is a new physical volume of "4.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb1
  VG Name
  PV Size               4.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               NIc8Zl-gSWu-gMvI-2y0c-cWnl-lGL0-tvueV2
```





<h4>pvremove</h4>

- Physical Volume(PV)를 삭제하는 명령어
- **pvremove [pv명]**



사용 예

```shell
[root@localhost ~]# pvremove /dev/sdb[1-4]
  Labels on physical volume "/dev/sdb1" successfully wiped.
  Labels on physical volume "/dev/sdb2" successfully wiped.
  Labels on physical volume "/dev/sdb3" successfully wiped.
  Labels on physical volume "/dev/sdb4" successfully wiped.
```



<br>

<br>

<h2>볼륨 그룹(Volume Group)</h2>

- **VG(Volume Group)**
  - PV들의 집합으로, LV를 할당할 수 있는 공간
  - PV들로 초기화된 장치들은 VG로 통합됨
  - 사용자는 VG안에서 원하는대로 공간을 쪼개서 LV로 만들 수 있음



<h4>vgcreate</h4>

- **VG(Volume Group)을 생성하는 명령어**
- **vgcreate [vg명] [pv명] [옵션]**
- PE 사이즈가 크면 공간 낭비가 심함
- PE 사이즈가 작으면 I/O 시간이 길어짐
- **vgs** : VG 목록을 확인할 때 사용하는 명령어
- **파티션없어도 vgcreate 가능**하다
  - 필요한 pv들을 알아서 만든 다음 자신의 볼륨으로 만들 수 있음
  - 중간 과정 줄일 수 있음
  - 파티션을 굳이 하지 않아도 단순히 디스크 하나를 볼륨으로 나눠서하는 것이 나을 수 있음
- 옵션 
  - -s : PE 사이즈 지정



사용 예

- /dev/sdb1, /dev/sdb3로 볼륨 그룹(VG) vg0 을 생성해보자

```shell
[root@localhost ~]# vgcreate vg0 /dev/sdb[13]
  Volume group "vg0" successfully created
```

- -s 옵션을 사용하여 /dev/sdb[24]로 PE 사이즈가 8M인 볼륨그룹 vg1을 생성해보자

```
[root@localhost ~]# vgcreate vg1 /dev/sdb[24] -s 8M
  Volume group "vg1" successfully created
[root@localhost ~]# vgs
  VG  #PV #LV #SN Attr   VSize  VFree
  vg0   2   0   0 wz--n-  7.99g  7.99g
  vg1   2   0   0 wz--n- 11.98g 11.98g
```



<h4>vgdisplay</h4>

- VG(Volume Group)의 속성을 출력하는 명령어
- **vgdisplay [vg명]**



사용 예

```shell
[root@localhost ~]# vgdisplay vg1
  --- Volume group ---
  VG Name               vg1
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               9.98 GiB
  PE Size               8.00 MiB
  Total PE              1278
  Alloc PE / Size       0 / 0
  Free  PE / Size       1278 / 9.98 GiB
  VG UUID               y6jsxd-OQxS-YrIJ-tzkH-gw4V-eIv0-L1HwLQ
```





<h4>vgremove</h4>

- VG(Volume Group)을 삭제하는 명령어
- **vgremove [vg명]**
- 사용중인 VG는 vgremove 불가능
  - **마운트 해제 후**, vgremove하면 lv가 지워지면서 정상적으로 진행가능



사용 예

```shell
[root@localhost ~]# vgremove vg1
  Volume group "vg1" successfully removed
```

- VG가 사용중인 경우, 에러 발생

```
[root@localhost ~]# vgremove vg0
Do you really want to remove volume group "vg0" containing 2 logical volumes? [y/n]: y
  Logical volume vg0/lv01 contains a filesystem in use.
```

- 마운트 해제 후 LV가 지워지면서 정상적으로 진행

```shell
[root@localhost ~]# umount /mnt/*
umount: /mnt/disk3: not mounted
[root@localhost ~]# vgremove vg0
Do you really want to remove volume group "vg0" containing 2 logical volumes? [y/n]: y
Do you really want to remove active logical volume vg0/lv01? [y/n]: y
  Logical volume "lv01" successfully removed
Do you really want to remove active logical volume vg0/lv02? [y/n]: y
  Logical volume "lv02" successfully removed
  Volume group "vg0" successfully removed
```





<h4>vgextend</h4>

- VG(Volume Group)을 확장하는 명령어
  - **새로운 PV를 VG안에 추가함으로써 확장**
- **vgextend [vg명] [추가할 pv명]**



사용 예 :

- vgdisplay를 통해 확인했을 때, VG size가 증가(확장)한 것을 확인할 수 있음

```shell
[root@localhost ~]# vgextend vg0 /dev/sdb2
  Volume group "vg0" successfully extended
[root@localhost ~]# vgdisplay vg0
  ...
  VG Size               <13.99 GiB
  PE Size               4.00 MiB
  ...
```



<h4>vgreduce</h4>

- VG(Volume Group)을 축소하는 명령어
- VG에서 PV를 제거함으로써 축소
  - 이때, **사용중(LV생성, 데이터 존재)인것이면 안된다**
- **vgreduce [vg명] [제거할 pv명]**



사용 예

- /dev/sdb2는 사용중이지 않기 때문에 오류없이 제거(축소)가 잘 이루어진다

```shell
[root@localhost ~]# vgreduce vg0 /dev/sdb2
  Removed "/dev/sdb2" from volume group "vg0"
```

- /dev/sdb1는 사용중(lv02)이기 때문에 제거(축소)할 때 에러가 발생
  - 이러한 에러가 발생했을 때, pmove 명령어를 통해 해결할 수 있다

```shell
[root@localhost ~]# lsblk
NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda            8:0    0   60G  0 disk
├─sda1         8:1    0    4G  0 part [SWAP]
└─sda2         8:2    0   56G  0 part /
sdb            8:16   0   20G  0 disk
├─sdb1         8:17   0    4G  0 part
│ └─vg0-lv02 253:1    0    3G  0 lvm  /mnt/disk2
├─sdb2         8:18   0    4G  0 part
├─sdb3         8:19   0    6G  0 part
│ └─vg0-lv01 253:0    0    4G  0 lvm  /mnt/disk1
└─sdb4         8:20   0    6G  0 part
sr0           11:0    1 1024M  0 rom
[root@localhost ~]# vgreduce vg0 /dev/sdb1
  Physical volume "/dev/sdb1" still in use
```



<h4>pvmove</h4>

- **PV(물리볼륨)의 내용을 이동시키는 명령어**
- vgreduce 명령어 실행 시 사용중인 PV라 정상적으로 진행되지 못할 때, pvmove를 통해 다른 곳으로 옮긴 후 정상적으로 진행할 수 있다
  - 옮겨지는 곳은 시스템에 남아있는 공간에서 랜덤으로 지정
  - 특정 PV 지정 불가
- **VG(Volume Group)에서 제거 할 PV의 사이즈보다 큰 여유 공간 필요**
  - 부족할 경우 VG 확장 후 데이터 이동 가능
- **pvmove [pv명]**



사용 예

```shell
[root@localhost ~]# vgreduce vg0 /dev/sdb1
Physical volume "/dev/sdb1" still in use
[root@localhost ~]# pvmove /dev/sdb1
/dev/sdb1: Moved: 7.0%
/dev/sdb1: Moved: 100.0%
[root@localhost ~]# vgreduce vg0 /dev/sdb1
Removed "/dev/sdb1" from volume group "vg0"
```

- pvmove 명령 실행 시 PV사이즈보다 용량이 부족한 경우

```shell
[root@localhost ~]# pvmove /dev/sdb3
  Insufficient free space: 768 extents needed, but only 511 available
  Unable to allocate mirror extents for vg0/pvmove0.
  Failed to convert pvmove LV to mirrored.
```





<br>

<br>

<h2>논리 볼륨(Logical Volume)</h2>

- **LV(Logical Volume)**
  -  사용자가 최종적으로 다루게 되는 논리적인 스토리지
  - 생성된 LV는 파일 시스템 및 애플리케이션 등으로 사용
  - LV를 구성하는 LE들은 PV의 PE와 매핑됨



<h4>lvcreate</h4>

- **LV(Logical Volume)을 생성**하는 명령어
- **lvcreate [vg명] [옵션]**
- **lvs** : LV 목록을 확인할 때 사용하는 명령어
- LV의 순서는 시스템에서 랜덤으로 정한다

- 옵션
  - -L : 사이즈를 지정
    - 단위: K(kilobytes), M(megabytes), G(gigabytes), T(terabytes) 이용
  - -l : 사이즈를 지정하는 옵션, PE 개수로 용량을 설정
    - 1 PE = 4MB
  - -n : LV 이름 지정



사용 예

```shell
[root@localhost ~]# lvcreate vg0 -l 256 -n lv01
  Logical volume "lv01" created.
[root@localhost ~]# lvs
  LV   VG  Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv01 vg0 -wi-a----- 1.00g
```

```shell
[root@localhost ~]# lvcreate vg0 -L 2G -n lv02
  Logical volume "lv02" created.
```



- lvcreate 명령어를 통해 LV를 생성했을 때, **용량이 모자란다는 에러가 난다면?**
  - `-l 100%FREE` 옵션을 통해 나머지 용량을 (쏟아부어서) 만들 수 있다

```shell
[root@localhost ~]# lvcreate vg0 -L 7G -n lv03
  Volume group "vg0" has insufficient free space (1790 extents): 1792 required.
[root@localhost ~]# lvcreate vg0 -l 100%FREE -n lv03
  Logical volume "lv03" created.
```

```shell
[root@localhost ~]# lvdisplay /dev/vg0/lv03
  --- Logical volume ---
  LV Path                /dev/vg0/lv03
  LV Name                lv03
  VG Name                vg0
  LV UUID                Gk7hpp-kCPv-1rHk-icKZ-tDEY-EREw-IjyJ92
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2022-02-25 22:59:37 +0900
  LV Status              available
  # open                 0
  LV Size                6.99 GiB
  Current LE             1790
  Segments               2
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2
```

- 7G(1792LE) 용량의 LV를 생성하려했지만, 1790LE 용량만 남아, 용량이 부족하다는 에러 발생 후, `- 100%FREE`옵션을 통해 1790LE(나머지) 용량 만큼의 LV(lv03)을 생성한 것을 확인할 수 있다





<h4>lvdisplay</h4>

- LV(Logical Volume)의 속성을 출력하는 명령어

- **lvdisplay [lv 경로]**

  - 경로를 지정하지 않으면 모두 출력

- **LV 경로의 경로는 3가지 패턴으로 표현**할 수 있다. 

  - `/dev/볼륨그룹명/논리볼륨명` 또는 `/dev/mapper/볼륨그룹명-논리볼륨명`

  - lv01을 예시로
    - **/dev/vg0/lv01**
      - 사용자가 주로 사용
    - /dev/mapper/vg0-lv01
      - 시스템에서 주로 사용
    - /dev/dm-0



사용 예

```shell
[root@localhost ~]# lvdisplay /dev/vg0/lv01
  --- Logical volume ---
  LV Path                /dev/vg0/lv01
  LV Name                lv01
  VG Name                vg0
  LV UUID                t05fdV-8Oyr-1f4z-PiIm-VP4U-Pjzj-F1GiSm
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2022-02-25 22:24:32 +0900
  LV Status              available
  # open                 0
  LV Size                1.00 GiB
  Current LE             256
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:0
```

- 3가지 LV 경로 패턴 확인해보기

```shell
[root@localhost ~]# ls -l /dev/vg0/lv01 /dev/mapper/vg0-lv01 /dev/dm-0
brw-rw----. 1 root disk 253, 0  2월 25 22:24 /dev/dm-0
lrwxrwxrwx. 1 root root      7  2월 25 22:24 /dev/mapper/vg0-lv01 -> ../dm-0
lrwxrwxrwx. 1 root root      7  2월 25 22:24 /dev/vg0/lv01 -> ../dm-0
```



<h4>LV의 포맷</h4>

- 파티션(Partition) 포맷(format)의 명령과 동일
- 포맷의 결과는 blkid 명령어를 통해 확인 가능

```shell
[root@localhost ~]# mkfs -t xfs /dev/vg0/lv02
```

```shell
[root@localhost ~]# mkfs.ext4 /dev/mapper/vg0-lv02
```

```shell
[root@localhost ~]# blkid
....
/dev/mapper/vg0-lv02: UUID="55340cea-e3ea-4f11-a6d7-8b67b99ab2c6" TYPE="ext4"
/dev/mapper/vg0-lv01: UUID="8d2fbd67-342f-4113-8fd6-113b0839809e" TYPE="xfs"
```



<h4>LV의 마운트</h4>

- 파티션(Partition)의 마운트(mount)의 명령과 동일
- 예시) /mnt/disk{1..3} 생성 후 마운트
  - 마운트 후 lsblk 명령어를 통해 확인 가능

```shell
[root@localhost ~]# mkdir /mnt/disk{1..3}
[root@localhost ~]# mount /dev/vg0/lv01 /mnt/disk1
[root@localhost ~]# mount /dev/vg0/lv02 /mnt/disk2
```

```shell
[root@localhost ~]# lsblk
NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda            8:0    0   60G  0 disk
├─sda1         8:1    0    4G  0 part [SWAP]
└─sda2         8:2    0   56G  0 part /
sdb            8:16   0   20G  0 disk
├─sdb1         8:17   0    4G  0 part
│ ├─vg0-lv01 253:0    0    1G  0 lvm  /mnt/disk1
│ └─vg0-lv02 253:1    0    2G  0 lvm  /mnt/disk2
├─sdb2         8:18   0    4G  0 part
├─sdb3         8:19   0    6G  0 part
└─sdb4         8:20   0    6G  0 part
sr0           11:0    1 1024M  0 rom
```





<h4>lvremove</h4>

- **LV(Logical Remove)**을 삭제하는 명령어
- 사용중인(마운트된) LV를 삭제하려하면 에러발생
  - **먼저 마운트를 해제하고 LV를 삭제**해야함
- **lvremove [lv경로]**



사용 예

```shell
[root@localhost ~]# umount /mnt/disk1
[root@localhost ~]# umount /mnt/disk2
[root@localhost ~]# lvremove /dev/vg0/lv01
Do you really want to remove active logical volume vg0/lv01? [y/n]: y
  Logical volume "lv01" successfully removed
[root@localhost ~]# lvremove /dev/vg0/lv02
Do you really want to remove active logical volume vg0/lv02? [y/n]: y
  Logical volume "lv02" successfully removed
```

- 마운트를 해제하지 않고, 삭제를 진행했을 때

```shell
[root@localhost ~]# lvremove /dev/vg0/lv01
  Logical volume vg0/lv01 contains a filesystem in use.
```



<h4>lvextend</h4>

- LV(Logical Volume) 을 확장하는 명령어
- **lvextend [옵션] [lv 경로]** 
- 옵션 
  - **-r : 파일 시스템 확장(확장과 동시에 포맷)**
  - -L : 확장시킬 용량(혹은 최종 용량)
    - ex) +2G, 6G

- **LV 확장 시 주의점**

  - **-r 옵션을 사용해주지 않으면 파일 시스템이 함께 포맷되지 않는다**

  - 용량만 늘어나고, 파일 시스템 자체는 늘어나지 않았기 때문
  - df -Th 명령어의 결과를 확인했을 때 용량이 증가되지 않은 것을 확인할 수 있음

- -r 옵션을 사용하지 않고, 파일 시스템 확장하는 방법
  - xfs 파일 시스템을 논리볼륨에서 확장할 때 :`xfs_growfs [마운트 포인트]`
  - ext4 파일 시스템을 논리볼륨에서 확장할 때 : `resize2fs [lv경로]`



사용 예

- -r 옵션을 사용하지 않았을 때
  - lv01을 6G로 확장시켰지만, df -Th로 확인했을 때, 여전히 4G인 것을 확인할 수 있음

```
[root@localhost ~]# lvextend -L +2G /dev/vg0/lv01
  Size of logical volume vg0/lv01 changed from 4.00 GiB (1024 extents) to 6.00 GiB (1536 extents).
  Logical volume vg0/lv01 successfully resized.
[root@localhost ~]# df -Th
Filesystem           Type      Size  Used Avail Use% Mounted on
/dev/sda2            xfs        56G  4.4G   52G   8% /
devtmpfs             devtmpfs  985M     0  985M   0% /dev
tmpfs                tmpfs    1000M     0 1000M   0% /dev/shm
tmpfs                tmpfs    1000M  9.0M  991M   1% /run
tmpfs                tmpfs    1000M     0 1000M   0% /sys/fs/cgroup
tmpfs                tmpfs     200M     0  200M   0% /run/user/0
/dev/mapper/vg0-lv01 xfs       4.0G   33M  4.0G   1% /mnt/disk1
/dev/mapper/vg0-lv02 ext4      2.9G  9.0M  2.8G   1% /mnt/disk2
```

- -r 옵션을 사용하여, lv01을 +0.5G 확장

```shell
[root@localhost ~]# lvextend -L +0.5G /dev/vg0/lv01 -r
  Size of logical volume vg0/lv01 changed from 6.00 GiB (1536 extents) to 6.50 GiB (1664 extents).
  Logical volume vg0/lv01 successfully resized.
meta-data=/dev/mapper/vg0-lv01   isize=512    agcount=6, agsize=262144 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=1572864, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 1572864 to 1703936
```

- -r 옵션 없이 파일 시스템 확장해보기

```shell
[root@localhost ~]# xfs_growfs /mnt/disk1
[root@localhost ~]# resize2fs /dev/vg0/lv02
```







참조

- [LVM(Logical Volumn Manager)개념과 설정 (tistory.com)](https://kit2013.tistory.com/199)
- [[리눅스\] LVM 구성 ③편 - LVM 명령어 총정리 (tistory.com)](https://lifegoesonme.tistory.com/451) 
