<h2> [Linux] LVM: PV, VG, LV </h2>



<h3>๐INDEX</h3>

- [LVM์ด๋?](#lvm์ด๋)
-  [๋ฌผ๋ฆฌ ๋ณผ๋ฅจ PV(Pysical Volume)](#๋ฌผ๋ฆฌ-๋ณผ๋ฅจphysical-volume)
-  [๋ณผ๋ฅจ ๊ทธ๋ฃน VG(Volume Group)](#๋ณผ๋ฅจ-๊ทธ๋ฃนvolume-group)
- [๋ผ๋ฆฌ ๋ณผ๋ฅจ LV(Logical Volume)](#๋ผ๋ฆฌ-๋ณผ๋ฅจlogical-volume)

<br>

<br>

<br>

<h2>LVM์ด๋?</h2>

- LVM(Logical Volume Manager)์ **Logical Volume(๋ผ๋ฆฌ ๋ณผ๋ฅจ)์ ํจ์จ์ ์ด๊ณ  ์ ์ฐํ๊ฒ ๊ด๋ฆฌ**ํ๊ธฐ ์ํ ์ปค๋์ ํ ๋ถ๋ถ์ด์ ํ๋ก๊ทธ๋จ์ด๋ค
- **์ฌ๋ฌ ๊ฐ์ ํ๋๋์คํฌ๋ฅผ ํฉ์ณ์ ํ ๊ฐ์ ํ์ผ ์์คํ์ผ๋ก ์ฌ์ฉ**ํ๋ ๊ฒ์ผ๋ก, ํ์์ ๋ฐ๋ผ์ ๋ค์ ๋๋ ์ ์๋ค

- ์ถ์์  ๋ ์ด์ด๋ฅผ ์์ฑํด์ ๋ผ๋ฆฌ์  ์คํ ๋ฆฌ์ง(๊ฐ์์ ๋ธ๋ก ์ฅ์น)๋ฅผ ์์ฑํ  ์ ์๊ฒ ํด์ค
  - ์ง์ ์ ์ผ๋ก ๋ฌผ๋ฆฌ์  ์คํ ๋ฆฌ์ง๋ฅผ ์ฌ์ฉํ๋ ๊ฒ๋ณด๋ค ๋ค์ํ ์ธก๋ฉด์์ ์ ์ฐ์ฑ ์ ๊ณต

- RAID๋ฅผ ์ ์ฉํ ๋ณผ๋ฅจ ์์ฑ ๊ฐ๋ฅ



- **๋ผ๋ฆฌ ๋ณผ๋ฅจ์ ๊ตฌ์กฐ**



<img src="https://user-images.githubusercontent.com/64996121/155739930-ecbc5d8d-5a94-4e46-9468-1f197a923d21.PNG" width=250 heigth=200 />



- **PV(Physical Volume)** : ๋ฌผ๋ฆฌ ์ฅ์น์ ์ง์  ๋งคํ, ๋ค์ํ ์ฅ์น๋ก ์์ฑ ๊ฐ๋ฅ
  -  /dev/sda1, /dev/sda2 ๋ฑ์ **ํํฐ์**
- **VG(Volume Group)** : ํ๋ ์ด์์ PV๋ก ๊ตฌ์ฑ, ์ฌ์ฉ ๊ฐ๋ฅํ PE๋ฅผ LV์ ํ ๋น
- **LV(Logical Volume)** : ์ค์ง์ ์ธ ์ฌ์ฉ ๊ณต๊ฐ, VG ๋ฒ์ ๋ด์์ ์์ฑ
  - LV๋ LE ๋จ์๋ก ๊ตฌ์ฑ๋๋ฏ๋ก, ํฌ๊ธฐ๋ LE ํฌ๊ธฐ์ ๋ฐฐ์๋ก ํ ๋น๋๋ค
- PE(Physical Extent) : PV๋ฅผ ๊ตฌ์ฑํ๋ ๊ธฐ๋ณธ ๋จ์, ๋ฐ์ดํฐ ์ ์ฅ ๋จ์
- LE(Logical Extent) : LV๋ฅผ ์ด๋ฃจ๋ ๊ธฐ๋ณธ ๋จ์, ๊ธฐ๋ณธ์ ์ผ๋ก PE์ 1๋1๋งค์นญ



- **๋ผ๋ฆฌ ๋ณผ๋ฅจ ์์ฑ**

  - ๋ฌผ๋ฆฌ์  ์ ์ฅ ์ฅ์น๋ฅผ ๋ผ๋ฆฌ์  ์ฅ์น๋ก ๊ด๋ฆฌํ๋ค
  - ๊ณต๊ฐ ํ์ฉ์ด ์ ์ฐํ๋ฉฐ, ํ์ฅ์ฑ์ด ์ข๋ค
  - ์ ์ฅ ์ฅ์น์ ์ข๋ฅ์ ๋ฌด๊ดํ๋ค
  - ๋ฌผ๋ฆฌ ์ ์ฅ ์ฅ์น(ํํฐ์)์ ์ต์๋จ์๋ ์นํฐ์ด์ง๋ง, ๋ผ๋ฆฌ ์ ์ฅ ์ฅ์น(๋ผ๋ฆฌ๋ณผ๋ฅจ)์ ์ต์ ๋จ์๋ PE(LE)์ด๋ค.
  - ์ฌ์ฉํ๋ ๋์ค์ ๋ช๋ น์ด๋ก ํ์ฅ, ์ถ์๊ฐ ๊ฐ๋ฅํ๋ค

  

- **๋ผ๋ฆฌ ๋ณผ๋ฅจ ์์ฑ ๊ณผ์ **
  - **ํํฐ์**์ผ๋ก ๋๋๊ธฐ(fdisk)
  - ํํฐ์์ **PV๋ก ๋ณํ **(์ด๊ธฐํ)
  - ๋ฌผ๋ฆฌ๋ณผ๋ฅจ(PV)์ผ๋ก ๋ณผ๋ฅจ๊ทธ๋ฃน(VG) ์์ฑ : **VG ์์ฑ **
  - ๋ณผ๋ฅจ๊ทธ๋ฃน(VG)์์ ๋ผ๋ฆฌ๋ณผ๋ฅจ(LV) ํ ๋น : **LV ์์ฑ**
  - ๋ผ๋ฆฌ๋ณผ๋ฅจ(LV) ์ ํ์ผ์์คํ ์์ฑ : **ํฌ๋งท**
  - **๋ง์ดํธ** ํ ์ฌ์ฉ



<br>

<br>

<h2>๋ฌผ๋ฆฌ ๋ณผ๋ฅจ(Physical Volume)</h2>

- **PV(Physical Volume)**
  - LVM์์ ๋ธ๋ก ์ฅ์น๋ฅผ ์ฌ์ฉํ๋ ค๋ฉด PV๋ก ์ด๊ธฐํํด์ผํจ
    - ๋ธ๋ก ์ฅ์น : ๋ธ๋ก ๋จ์๋ก ์ ๊ทผํ๋ ์คํ ๋ฆฌ์ง ex)ํ๋ ๋์คํฌ
  - **ํํฐ์๋ค์ LVM์์ ์ฌ์ฉํ  ์ ์๊ฒ ๋ณํํ ๊ฒ**
    - ์๋ฅผ ๋ค์ด /dev/sda1, /dev/sda2 ๋ LVM์ผ๋ก ์ฐ๊ธฐ ์ํด PV๋ผ๋ ํ์์ผ๋ก ๋ณํํ ๊ฒ 
  - PV๋ ์ผ์ ํ ํฌ๊ธฐ์ **PE(Physical Extent)๋ค๋ก ๊ตฌ์ฑ**



<h4>pvcreate</h4>

- **physical volume(PV)๋ฅผ ์์ฑ**ํ๋ ๋ช๋ น์ด
- **pvcreate [์ฅ์น๋ช]**
- **pvs** : **pv ๋ชฉ๋ก์ ํ์ธ**ํ  ๋ ์ฌ์ฉํ๋ ๋ช๋ น์ด



์ฌ์ฉ ์ (ํํฐ์ ๋์ด์๋ค๊ณ  ๊ฐ์ : 4G, 4G, 6G, 6G)

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

- blkid ๋ช๋ น์ด๋ก ํ์ธํ์ ๋, TYPE="LVM2_member"๋ก ์์ฑ๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค.
  - ์ด๊ฒ ์์ผ๋ฉด PV๊ฐ ์๋ ๊ฒ์ด๋ค





<h4>pvdisplay</h4>

- Physical Volume(PV)์ ์์ฑ์ ์ถ๋ ฅํ๋ ๋ช๋ น์ด
- **pvdisplay [์ฅ์น๋ช]**



์ฌ์ฉ ์

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

- Physical Volume(PV)๋ฅผ ์ญ์ ํ๋ ๋ช๋ น์ด
- **pvremove [pv๋ช]**



์ฌ์ฉ ์

```shell
[root@localhost ~]# pvremove /dev/sdb[1-4]
  Labels on physical volume "/dev/sdb1" successfully wiped.
  Labels on physical volume "/dev/sdb2" successfully wiped.
  Labels on physical volume "/dev/sdb3" successfully wiped.
  Labels on physical volume "/dev/sdb4" successfully wiped.
```



<br>

<br>

<h2>๋ณผ๋ฅจ ๊ทธ๋ฃน(Volume Group)</h2>

- **VG(Volume Group)**
  - PV๋ค์ ์งํฉ์ผ๋ก, LV๋ฅผ ํ ๋นํ  ์ ์๋ ๊ณต๊ฐ
  - PV๋ค๋ก ์ด๊ธฐํ๋ ์ฅ์น๋ค์ VG๋ก ํตํฉ๋จ
  - ์ฌ์ฉ์๋ VG์์์ ์ํ๋๋๋ก ๊ณต๊ฐ์ ์ชผ๊ฐ์ LV๋ก ๋ง๋ค ์ ์์



<h4>vgcreate</h4>

- **VG(Volume Group)์ ์์ฑํ๋ ๋ช๋ น์ด**
- **vgcreate [vg๋ช] [pv๋ช] [์ต์]**
- PE ์ฌ์ด์ฆ๊ฐ ํฌ๋ฉด ๊ณต๊ฐ ๋ญ๋น๊ฐ ์ฌํจ
- PE ์ฌ์ด์ฆ๊ฐ ์์ผ๋ฉด I/O ์๊ฐ์ด ๊ธธ์ด์ง
- **vgs** : VG ๋ชฉ๋ก์ ํ์ธํ  ๋ ์ฌ์ฉํ๋ ๋ช๋ น์ด
- **ํํฐ์์์ด๋ vgcreate ๊ฐ๋ฅ**ํ๋ค
  - ํ์ํ pv๋ค์ ์์์ ๋ง๋  ๋ค์ ์์ ์ ๋ณผ๋ฅจ์ผ๋ก ๋ง๋ค ์ ์์
  - ์ค๊ฐ ๊ณผ์  ์ค์ผ ์ ์์
  - ํํฐ์์ ๊ตณ์ด ํ์ง ์์๋ ๋จ์ํ ๋์คํฌ ํ๋๋ฅผ ๋ณผ๋ฅจ์ผ๋ก ๋๋ ์ํ๋ ๊ฒ์ด ๋์ ์ ์์
- ์ต์ 
  - -s : PE ์ฌ์ด์ฆ ์ง์ 



์ฌ์ฉ ์

- /dev/sdb1, /dev/sdb3๋ก ๋ณผ๋ฅจ ๊ทธ๋ฃน(VG) vg0 ์ ์์ฑํด๋ณด์

```shell
[root@localhost ~]# vgcreate vg0 /dev/sdb[13]
  Volume group "vg0" successfully created
```

- -s ์ต์์ ์ฌ์ฉํ์ฌ /dev/sdb[24]๋ก PE ์ฌ์ด์ฆ๊ฐ 8M์ธ ๋ณผ๋ฅจ๊ทธ๋ฃน vg1์ ์์ฑํด๋ณด์

```
[root@localhost ~]# vgcreate vg1 /dev/sdb[24] -s 8M
  Volume group "vg1" successfully created
[root@localhost ~]# vgs
  VG  #PV #LV #SN Attr   VSize  VFree
  vg0   2   0   0 wz--n-  7.99g  7.99g
  vg1   2   0   0 wz--n- 11.98g 11.98g
```



<h4>vgdisplay</h4>

- VG(Volume Group)์ ์์ฑ์ ์ถ๋ ฅํ๋ ๋ช๋ น์ด
- **vgdisplay [vg๋ช]**



์ฌ์ฉ ์

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

- VG(Volume Group)์ ์ญ์ ํ๋ ๋ช๋ น์ด
- **vgremove [vg๋ช]**
- ์ฌ์ฉ์ค์ธ VG๋ vgremove ๋ถ๊ฐ๋ฅ
  - **๋ง์ดํธ ํด์  ํ**, vgremoveํ๋ฉด lv๊ฐ ์ง์์ง๋ฉด์ ์ ์์ ์ผ๋ก ์งํ๊ฐ๋ฅ



์ฌ์ฉ ์

```shell
[root@localhost ~]# vgremove vg1
  Volume group "vg1" successfully removed
```

- VG๊ฐ ์ฌ์ฉ์ค์ธ ๊ฒฝ์ฐ, ์๋ฌ ๋ฐ์

```
[root@localhost ~]# vgremove vg0
Do you really want to remove volume group "vg0" containing 2 logical volumes? [y/n]: y
  Logical volume vg0/lv01 contains a filesystem in use.
```

- ๋ง์ดํธ ํด์  ํ LV๊ฐ ์ง์์ง๋ฉด์ ์ ์์ ์ผ๋ก ์งํ

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

- VG(Volume Group)์ ํ์ฅํ๋ ๋ช๋ น์ด
  - **์๋ก์ด PV๋ฅผ VG์์ ์ถ๊ฐํจ์ผ๋ก์จ ํ์ฅ**
- **vgextend [vg๋ช] [์ถ๊ฐํ  pv๋ช]**



์ฌ์ฉ ์ :

- vgdisplay๋ฅผ ํตํด ํ์ธํ์ ๋, VG size๊ฐ ์ฆ๊ฐ(ํ์ฅ)ํ ๊ฒ์ ํ์ธํ  ์ ์์

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

- VG(Volume Group)์ ์ถ์ํ๋ ๋ช๋ น์ด
- VG์์ PV๋ฅผ ์ ๊ฑฐํจ์ผ๋ก์จ ์ถ์
  - ์ด๋, **์ฌ์ฉ์ค(LV์์ฑ, ๋ฐ์ดํฐ ์กด์ฌ)์ธ๊ฒ์ด๋ฉด ์๋๋ค**
- **vgreduce [vg๋ช] [์ ๊ฑฐํ  pv๋ช]**



์ฌ์ฉ ์

- /dev/sdb2๋ ์ฌ์ฉ์ค์ด์ง ์๊ธฐ ๋๋ฌธ์ ์ค๋ฅ์์ด ์ ๊ฑฐ(์ถ์)๊ฐ ์ ์ด๋ฃจ์ด์ง๋ค

```shell
[root@localhost ~]# vgreduce vg0 /dev/sdb2
  Removed "/dev/sdb2" from volume group "vg0"
```

- /dev/sdb1๋ ์ฌ์ฉ์ค(lv02)์ด๊ธฐ ๋๋ฌธ์ ์ ๊ฑฐ(์ถ์)ํ  ๋ ์๋ฌ๊ฐ ๋ฐ์
  - ์ด๋ฌํ ์๋ฌ๊ฐ ๋ฐ์ํ์ ๋, pmove ๋ช๋ น์ด๋ฅผ ํตํด ํด๊ฒฐํ  ์ ์๋ค

```shell
[root@localhost ~]# lsblk
NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda            8:0    0   60G  0 disk
โโsda1         8:1    0    4G  0 part [SWAP]
โโsda2         8:2    0   56G  0 part /
sdb            8:16   0   20G  0 disk
โโsdb1         8:17   0    4G  0 part
โ โโvg0-lv02 253:1    0    3G  0 lvm  /mnt/disk2
โโsdb2         8:18   0    4G  0 part
โโsdb3         8:19   0    6G  0 part
โ โโvg0-lv01 253:0    0    4G  0 lvm  /mnt/disk1
โโsdb4         8:20   0    6G  0 part
sr0           11:0    1 1024M  0 rom
[root@localhost ~]# vgreduce vg0 /dev/sdb1
  Physical volume "/dev/sdb1" still in use
```



<h4>pvmove</h4>

- **PV(๋ฌผ๋ฆฌ๋ณผ๋ฅจ)์ ๋ด์ฉ์ ์ด๋์ํค๋ ๋ช๋ น์ด**
- vgreduce ๋ช๋ น์ด ์คํ ์ ์ฌ์ฉ์ค์ธ PV๋ผ ์ ์์ ์ผ๋ก ์งํ๋์ง ๋ชปํ  ๋, pvmove๋ฅผ ํตํด ๋ค๋ฅธ ๊ณณ์ผ๋ก ์ฎ๊ธด ํ ์ ์์ ์ผ๋ก ์งํํ  ์ ์๋ค
  - ์ฎ๊ฒจ์ง๋ ๊ณณ์ ์์คํ์ ๋จ์์๋ ๊ณต๊ฐ์์ ๋๋ค์ผ๋ก ์ง์ 
  - ํน์  PV ์ง์  ๋ถ๊ฐ
- **VG(Volume Group)์์ ์ ๊ฑฐ ํ  PV์ ์ฌ์ด์ฆ๋ณด๋ค ํฐ ์ฌ์  ๊ณต๊ฐ ํ์**
  - ๋ถ์กฑํ  ๊ฒฝ์ฐ VG ํ์ฅ ํ ๋ฐ์ดํฐ ์ด๋ ๊ฐ๋ฅ
- **pvmove [pv๋ช]**



์ฌ์ฉ ์

```shell
[root@localhost ~]# vgreduce vg0 /dev/sdb1
Physical volume "/dev/sdb1" still in use
[root@localhost ~]# pvmove /dev/sdb1
/dev/sdb1: Moved: 7.0%
/dev/sdb1: Moved: 100.0%
[root@localhost ~]# vgreduce vg0 /dev/sdb1
Removed "/dev/sdb1" from volume group "vg0"
```

- pvmove ๋ช๋ น ์คํ ์ PV์ฌ์ด์ฆ๋ณด๋ค ์ฉ๋์ด ๋ถ์กฑํ ๊ฒฝ์ฐ

```shell
[root@localhost ~]# pvmove /dev/sdb3
  Insufficient free space: 768 extents needed, but only 511 available
  Unable to allocate mirror extents for vg0/pvmove0.
  Failed to convert pvmove LV to mirrored.
```





<br>

<br>

<h2>๋ผ๋ฆฌ ๋ณผ๋ฅจ(Logical Volume)</h2>

- **LV(Logical Volume)**
  -  ์ฌ์ฉ์๊ฐ ์ต์ข์ ์ผ๋ก ๋ค๋ฃจ๊ฒ ๋๋ ๋ผ๋ฆฌ์ ์ธ ์คํ ๋ฆฌ์ง
  - ์์ฑ๋ LV๋ ํ์ผ ์์คํ ๋ฐ ์ ํ๋ฆฌ์ผ์ด์ ๋ฑ์ผ๋ก ์ฌ์ฉ
  - LV๋ฅผ ๊ตฌ์ฑํ๋ LE๋ค์ PV์ PE์ ๋งคํ๋จ



<h4>lvcreate</h4>

- **LV(Logical Volume)์ ์์ฑ**ํ๋ ๋ช๋ น์ด
- **lvcreate [vg๋ช] [์ต์]**
- **lvs** : LV ๋ชฉ๋ก์ ํ์ธํ  ๋ ์ฌ์ฉํ๋ ๋ช๋ น์ด
- LV์ ์์๋ ์์คํ์์ ๋๋ค์ผ๋ก ์ ํ๋ค

- ์ต์
  - -L : ์ฌ์ด์ฆ๋ฅผ ์ง์ 
    - ๋จ์: K(kilobytes), M(megabytes), G(gigabytes), T(terabytes) ์ด์ฉ
  - -l : ์ฌ์ด์ฆ๋ฅผ ์ง์ ํ๋ ์ต์, PE ๊ฐ์๋ก ์ฉ๋์ ์ค์ 
    - 1 PE = 4MB
  - -n : LV ์ด๋ฆ ์ง์ 



์ฌ์ฉ ์

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



- lvcreate ๋ช๋ น์ด๋ฅผ ํตํด LV๋ฅผ ์์ฑํ์ ๋, **์ฉ๋์ด ๋ชจ์๋๋ค๋ ์๋ฌ๊ฐ ๋๋ค๋ฉด?**
  - `-l 100%FREE` ์ต์์ ํตํด ๋๋จธ์ง ์ฉ๋์ (์์๋ถ์ด์) ๋ง๋ค ์ ์๋ค

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

- 7G(1792LE) ์ฉ๋์ LV๋ฅผ ์์ฑํ๋ คํ์ง๋ง, 1790LE ์ฉ๋๋ง ๋จ์, ์ฉ๋์ด ๋ถ์กฑํ๋ค๋ ์๋ฌ ๋ฐ์ ํ, `- 100%FREE`์ต์์ ํตํด 1790LE(๋๋จธ์ง) ์ฉ๋ ๋งํผ์ LV(lv03)์ ์์ฑํ ๊ฒ์ ํ์ธํ  ์ ์๋ค





<h4>lvdisplay</h4>

- LV(Logical Volume)์ ์์ฑ์ ์ถ๋ ฅํ๋ ๋ช๋ น์ด

- **lvdisplay [lv ๊ฒฝ๋ก]**

  - ๊ฒฝ๋ก๋ฅผ ์ง์ ํ์ง ์์ผ๋ฉด ๋ชจ๋ ์ถ๋ ฅ

- **LV ๊ฒฝ๋ก์ ๊ฒฝ๋ก๋ 3๊ฐ์ง ํจํด์ผ๋ก ํํ**ํ  ์ ์๋ค. 

  - `/dev/๋ณผ๋ฅจ๊ทธ๋ฃน๋ช/๋ผ๋ฆฌ๋ณผ๋ฅจ๋ช` ๋๋ `/dev/mapper/๋ณผ๋ฅจ๊ทธ๋ฃน๋ช-๋ผ๋ฆฌ๋ณผ๋ฅจ๋ช`

  - lv01์ ์์๋ก
    - **/dev/vg0/lv01**
      - ์ฌ์ฉ์๊ฐ ์ฃผ๋ก ์ฌ์ฉ
    - /dev/mapper/vg0-lv01
      - ์์คํ์์ ์ฃผ๋ก ์ฌ์ฉ
    - /dev/dm-0



์ฌ์ฉ ์

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

- 3๊ฐ์ง LV ๊ฒฝ๋ก ํจํด ํ์ธํด๋ณด๊ธฐ

```shell
[root@localhost ~]# ls -l /dev/vg0/lv01 /dev/mapper/vg0-lv01 /dev/dm-0
brw-rw----. 1 root disk 253, 0  2์ 25 22:24 /dev/dm-0
lrwxrwxrwx. 1 root root      7  2์ 25 22:24 /dev/mapper/vg0-lv01 -> ../dm-0
lrwxrwxrwx. 1 root root      7  2์ 25 22:24 /dev/vg0/lv01 -> ../dm-0
```



<h4>LV์ ํฌ๋งท</h4>

- ํํฐ์(Partition) ํฌ๋งท(format)์ ๋ช๋ น๊ณผ ๋์ผ
- ํฌ๋งท์ ๊ฒฐ๊ณผ๋ blkid ๋ช๋ น์ด๋ฅผ ํตํด ํ์ธ ๊ฐ๋ฅ

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



<h4>LV์ ๋ง์ดํธ</h4>

- ํํฐ์(Partition)์ ๋ง์ดํธ(mount)์ ๋ช๋ น๊ณผ ๋์ผ
- ์์) /mnt/disk{1..3} ์์ฑ ํ ๋ง์ดํธ
  - ๋ง์ดํธ ํ lsblk ๋ช๋ น์ด๋ฅผ ํตํด ํ์ธ ๊ฐ๋ฅ

```shell
[root@localhost ~]# mkdir /mnt/disk{1..3}
[root@localhost ~]# mount /dev/vg0/lv01 /mnt/disk1
[root@localhost ~]# mount /dev/vg0/lv02 /mnt/disk2
```

```shell
[root@localhost ~]# lsblk
NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda            8:0    0   60G  0 disk
โโsda1         8:1    0    4G  0 part [SWAP]
โโsda2         8:2    0   56G  0 part /
sdb            8:16   0   20G  0 disk
โโsdb1         8:17   0    4G  0 part
โ โโvg0-lv01 253:0    0    1G  0 lvm  /mnt/disk1
โ โโvg0-lv02 253:1    0    2G  0 lvm  /mnt/disk2
โโsdb2         8:18   0    4G  0 part
โโsdb3         8:19   0    6G  0 part
โโsdb4         8:20   0    6G  0 part
sr0           11:0    1 1024M  0 rom
```





<h4>lvremove</h4>

- **LV(Logical Remove)**์ ์ญ์ ํ๋ ๋ช๋ น์ด
- ์ฌ์ฉ์ค์ธ(๋ง์ดํธ๋) LV๋ฅผ ์ญ์ ํ๋ คํ๋ฉด ์๋ฌ๋ฐ์
  - **๋จผ์  ๋ง์ดํธ๋ฅผ ํด์ ํ๊ณ  LV๋ฅผ ์ญ์ **ํด์ผํจ
- **lvremove [lv๊ฒฝ๋ก]**



์ฌ์ฉ ์

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

- ๋ง์ดํธ๋ฅผ ํด์ ํ์ง ์๊ณ , ์ญ์ ๋ฅผ ์งํํ์ ๋

```shell
[root@localhost ~]# lvremove /dev/vg0/lv01
  Logical volume vg0/lv01 contains a filesystem in use.
```



<h4>lvextend</h4>

- LV(Logical Volume) ์ ํ์ฅํ๋ ๋ช๋ น์ด
- **lvextend [์ต์] [lv ๊ฒฝ๋ก]** 
- ์ต์ 
  - **-r : ํ์ผ ์์คํ ํ์ฅ(ํ์ฅ๊ณผ ๋์์ ํฌ๋งท)**
  - -L : ํ์ฅ์ํฌ ์ฉ๋(ํน์ ์ต์ข ์ฉ๋)
    - ex) +2G, 6G

- **LV ํ์ฅ ์ ์ฃผ์์ **

  - **-r ์ต์์ ์ฌ์ฉํด์ฃผ์ง ์์ผ๋ฉด ํ์ผ ์์คํ์ด ํจ๊ป ํฌ๋งท๋์ง ์๋๋ค**

  - ์ฉ๋๋ง ๋์ด๋๊ณ , ํ์ผ ์์คํ ์์ฒด๋ ๋์ด๋์ง ์์๊ธฐ ๋๋ฌธ
  - df -Th ๋ช๋ น์ด์ ๊ฒฐ๊ณผ๋ฅผ ํ์ธํ์ ๋ ์ฉ๋์ด ์ฆ๊ฐ๋์ง ์์ ๊ฒ์ ํ์ธํ  ์ ์์

- -r ์ต์์ ์ฌ์ฉํ์ง ์๊ณ , ํ์ผ ์์คํ ํ์ฅํ๋ ๋ฐฉ๋ฒ
  - xfs ํ์ผ ์์คํ์ ๋ผ๋ฆฌ๋ณผ๋ฅจ์์ ํ์ฅํ  ๋ :`xfs_growfs [๋ง์ดํธ ํฌ์ธํธ]`
  - ext4 ํ์ผ ์์คํ์ ๋ผ๋ฆฌ๋ณผ๋ฅจ์์ ํ์ฅํ  ๋ : `resize2fs [lv๊ฒฝ๋ก]`



์ฌ์ฉ ์

- -r ์ต์์ ์ฌ์ฉํ์ง ์์์ ๋
  - lv01์ 6G๋ก ํ์ฅ์์ผฐ์ง๋ง, df -Th๋ก ํ์ธํ์ ๋, ์ฌ์ ํ 4G์ธ ๊ฒ์ ํ์ธํ  ์ ์์

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

- -r ์ต์์ ์ฌ์ฉํ์ฌ, lv01์ +0.5G ํ์ฅ

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

- -r ์ต์ ์์ด ํ์ผ ์์คํ ํ์ฅํด๋ณด๊ธฐ

```shell
[root@localhost ~]# xfs_growfs /mnt/disk1
[root@localhost ~]# resize2fs /dev/vg0/lv02
```







์ฐธ์กฐ

- [LVM(Logical Volumn Manager)๊ฐ๋๊ณผ ์ค์  (tistory.com)](https://kit2013.tistory.com/199)
- [[๋ฆฌ๋์ค\] LVM ๊ตฌ์ฑ โขํธ - LVM ๋ช๋ น์ด ์ด์ ๋ฆฌ (tistory.com)](https://lifegoesonme.tistory.com/451) 
