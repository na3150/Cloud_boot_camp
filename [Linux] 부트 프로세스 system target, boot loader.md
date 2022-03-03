<h1> [Linux] 부트 프로세스: system target, boot loader </h1>



<h3>📌INDEX</h3>

- [리눅스 부트 프로세스](#리눅스-부트-프로세스)
-  [system target](#system-target)
   - [target 목록 출력하기](#target-목록-출력하기)
   - [default target 확인](#default-target-확인)
   - [default target 설정](#default-target-설정)
   - [target 전환](#target-전환)
- [root 비밀번호 변경하기](#root-비밀번호-변경하기)
- [부트 로더(boot loader)](#부트-로더boot-loader)
   - [부트로더 커널 이미지 시간](#부트로더-커널-이미지-시간)
   - [부트로더 ID 및 PW 설정](#부트로더-id-및-pw-설정)
   - [설정 내용 부트로더 인식](#설정-내용-부트로더-인식)



<br>

<br>

<br>



<h2>리눅스 부트 프로세스</h2>

1. **시스템 전원 ON(power on)**
   - 모든 운영체제를 부팅하기 위한 첫 단계
2. **BIOS 프로그램의 실행**
   - **POST**(power on self test) : 부팅이 시작되면 컴퓨터는 가장 먼저 **자체진단 기능을 통하여 컴퓨터 이상 유무를 검사**
     - 컴퓨터에 전원이 들어오면 먼저 전류는 CPU로 흘러 들어가게 되며, CPU는 BIOS 프로그램을 불러들이게 됨
     - **BIOS 프로그램은 CPU를 시작으로 CMOS를 검사하고, 메모리 테스트 후 용량을 확인**
     - 그래픽 카드, 키보드, 마우스 등 각종 장치의 이상 유무를 검사하여 초기화

3. **부트 매체의 검색(부트 섹터 로드)**
   - POST 과정에서 하드웨어 **검사가 무사히 완료되면** 검색된 부팅 매체(HDD, ODD, USB, 네트워크 등) 중 **CMOS에 설정되어 있는 순서대로 부팅**시도
   - MBR(Master Boot Record)에 존재하는 부트로더(Boot Loader)인 GRUB를 읽어들이게 되며, **부트로더가 메모리에 적재되고 시스템의 제어권을 부트로더**가 갖게됨
     - GRUB2를 이용하여 부트로더 올림

4. **부트로더의 실행**

   - 부트 로더는 Kernel을 메모리에 올려놓게 됨
   - **부트 로더는 Kernel 이미지를 불러들이고 시스템의 제어권을 넘겨옴**
   - 부트로더 설정파일: /boot/grub2/grub.cfg
   - 커널 위치 : /boot

   

<img src="https://user-images.githubusercontent.com/64996121/156555679-a4298173-196b-4aa0-a31b-f0cbd15d0be1.PNG" width=500 heigth=300 />



5. **커널 부트 이미지 적재**
   - GRUB의 부트 메뉴에서 **Kernel을 선택**하게 되면, Kernel 이미지가 동작
   - Kernel 이미지는 압축되어 있기 때문에 PID 0번인 swapper 프로세스를 호출
   - swapper 프로세스는 Kernel 이미지를 압축해제하고 Kernel이 사용할 각 장치들 (메모리, HDD, 시리얼 장치, 마우스 등 하드웨어)을 초기화하고 자세한 정보를 콘솔에 출력
6. **루트 파일 시스템 마운트**
   - 하드웨어의 컴색 후 커널은 **루트 (/) 파일 시스템을 마운트**
     - 일반적인 루트(/)가 아닌 **테스트용 임시 루트 (/sysroot) 사용**
   - 마운트는 안전하게 점검될 수 있도록 읽기 전용(read-only)으로 마운트
   - 이후에 읽기/쓰기로 마운트가 이루어짐

7. **systemd 프로세스 실행**

   - 모든 프로세스의 부모 역할을 하는 PID 1번인 systemd 프로세스를 실행
   - systemd 프로세스는 사용자가 시스템을 사용할 수 있도록 시스템 초기화 진행
   - systemd 프로세는 기본 시스템 초기화 스크립트인 **local-fs.target을 통해 파일 시스템 점검**
     - tartget: 부팅할 때 사용되는 유닛
   - 이후 **sysinit.target**을 시작으로 필요한 스크립트를 통해서 커널 모듈의 메모리 적재, 스왑 파티션 초기화, 네트워크 초기화, 서비스 프로세스 관리, 가상 콘솔 접속 관리, 실행 레벨 관리를 실행

   

<br>

<br>

<h2>system target</h2>

- 런레벨(run level)이란, init 명령 뒤에 붙는 숫자로, 리눅스는 시스템이 가동되는 방법을 7가지 런레벨로 나눌 수 있다.
- 리눅스 버전이 업그레이드 되면서, init은 systemd로 런레벨(runlevel)은 target으로 변경되었다
- **systemd는 default.target을 실행**시킨다
  - default.tartget은 graphical.target 혹은 multi-user.target 중 하나로 설정되어있음
- runlevel1 (single mode) => rescue.target
- runlevel2,3,4 => multiuser.target
- runlevel5 => graphical.target

```shell
[root@localhost ~]# ls -l /lib/systemd/system/runlevel?.target
lrwxrwxrwx. 1 root root 15  2월 21 14:52 /lib/systemd/system/runlevel0.target -> poweroff.target
lrwxrwxrwx. 1 root root 13  2월 21 14:52 /lib/systemd/system/runlevel1.target -> rescue.target
lrwxrwxrwx. 1 root root 17  2월 21 14:52 /lib/systemd/system/runlevel2.target -> multi-user.target
lrwxrwxrwx. 1 root root 17  2월 21 14:52 /lib/systemd/system/runlevel3.target -> multi-user.target
lrwxrwxrwx. 1 root root 17  2월 21 14:52 /lib/systemd/system/runlevel4.target -> multi-user.target
lrwxrwxrwx. 1 root root 16  2월 21 14:52 /lib/systemd/system/runlevel5.target -> graphical.target
lrwxrwxrwx. 1 root root 13  2월 21 14:52 /lib/systemd/system/runlevel6.target -> reboot.target
```

- **target 종류**

  - graphical.target : GUI 그래픽 기반 사용 환경
  - multi-user.target : CLI 텍스트 기반 사용 환경
  - basic.target : SELINUX, 네트워크 환경
  - sysinit.target : 마운트 한정화
  - local-fs.target : /etc/fstab에 등록된 마운트 작업
  - rescue.target : solugin 프롬프트, 기본 시스템 초기화 완료
    - 싱글(single)모드, /root 비밀번호 필요, 네트워크 불가, /가 read/write 읽기쓰기 모드
  - emergency.target : sulogin 프롬프트, initramfs 피벗 완료 및 시스템 루트 마운트/읽기 전용
    - 싱글(single)모드, /root 비밀번호 불필요, 네트워크 불가,  /(sysroot)가 read-only 읽기전용 모드

- 각각의 **target은 종속성 설정으로 연관**되어있다

  - systemd는 default.target(graphical/multi-user)을 실행시킨다

  - graphical.target이 실행되기 전에 multi-user.target이 실행되어야한다
  - multi-user.target이 실행되기 전에 basic.target이 실행되어야한다
  - basic.target이 실행되기 전에 sysinit.target이 실행되어야한다
  - sysinit.target이 실행되기 전에 local-fs.target이 실행되어야한다

  

<img src="https://user-images.githubusercontent.com/64996121/156555794-6f3d21ac-af23-41b7-9100-8626b2bb8220.PNG" width=500 heigth=350 />



- /etc/fstab 마운트 설정 조건 4가지

  -  4가지 조건 중 하나라도 만족하지 않으면 rescue.target으로 부팅됨

  - 조건 4가지
    - 존재하는 장치
    - 존재하는 마운트 포인트
    - 올바른 파일 시스템명
    - 올바른 옵션



<h4>target 목록 출력하기</h4>

- list-units --type target 사용
- 기본적으로 활성화된 타겟만 출력
  - 모든 타겟을 출력하려면 --all 옵션 추가

```shell
[root@localhost ~]# systemctl list-units --type target
UNIT                   LOAD   ACTIVE SUB    DESCRIPTION
basic.target           loaded active active Basic System
cryptsetup.target      loaded active active Local Encrypted Volumes
getty-pre.target       loaded active active Login Prompts (Pre)
getty.target           loaded active active Login Prompts
local-fs-pre.target    loaded active active Local File Systems (Pre)
local-fs.target        loaded active active Local File Systems
multi-user.target      loaded active active Multi-User System
network-online.target  loaded active active Network is Online
network-pre.target     loaded active active Network (Pre)
network.target         loaded active active Network
nfs-client.target      loaded active active NFS client services
nss-user-lookup.target loaded active active User and Group Name Lookups
paths.target           loaded active active Paths
remote-fs-pre.target   loaded active active Remote File Systems (Pre)
remote-fs.target       loaded active active Remote File Systems
rpc_pipefs.target      loaded active active rpc_pipefs.target
slices.target          loaded active active Slices
sockets.target         loaded active active Sockets
swap.target            loaded active active Swap
sysinit.target         loaded active active System Initialization
timers.target          loaded active active Timers

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.
```





<h4>default target 확인</h4>

- systemctl **get-default**

```shell
[root@localhost ~]# systemctl get-default
multi-user.target
```





<h4>default target 설정</h4>

- systemctl **set-default** [mult-user/graphical.target]
- set-default로 수정하면 **재부팅 시에 반영**

```shell
[root@localhost ~]# systemctl set-default graphical.target
Removed symlink /etc/systemd/system/default.target.
Created symlink from /etc/systemd/system/default.target to /usr/lib/systemd/system/graphical.target.
```





<h4>target 전환</h4>

- 설치되어있다는 전제하에, **재부팅 없이 모드만 전환**(현재 세션에 즉시 반영)
- systemctl **isolate** [mult-user/graphical.target]

```shell
[root@localhost ~]# systemctl isolate multi-user.target
[root@localhost ~]# systemctl isolate graphical.target
```



<br>

<br>

<h2>root 비밀번호 변경하기</h2>

- root의 비밀번호를 변경하기 위해서는 아래의 절차를 따라야한다

1. 커널선택 화면에서 아무키를 눌러 카운트 해제

<img src="https://user-images.githubusercontent.com/64996121/156555943-ad423abe-5e6d-4b19-bddc-fae71c0b54a0.PNG" width=500 heigth=300 />


2. 원하는 커널에서 'e' 키를 눌러서 grub 진입

<img src="https://user-images.githubusercontent.com/64996121/156555982-7ce9fb06-30af-40ff-9d2c-5e02c5bb8a55.PNG" width=500 heigth=300 />


3. linux16 라인 끝에 rd.break 입력 후 ctrl + x 
   - ctrl + x 누르면 프롬프트 창이 나옴

<img src="https://user-images.githubusercontent.com/64996121/156556030-48cd4b5e-2128-41d7-affd-06bd4ab2d59d.PNG" width=500 heigth=300 />


4. mount -o rw,remount /sysroot 입력

5. chroot /sysroot 입력
   - 시스템에 들어간다(shell)

<img src="https://user-images.githubusercontent.com/64996121/156556070-3da97259-7f1e-4859-b426-cac716d0e233.PNG" width=500 heigth=300 />


6. passwd 
   - 패스워드 변경

7. touch /.autorelabel
   - /sysroot에 생긴 변화를 메모리에 초기화하기 전에 본 시스템에 인식시키기 위한 파일
   - /.autorelabel 파일을 생성하지 않으면
     - 최선 : 비밀번호 변경 실패
     - 최악 : 아예 부팅 불가능 

8. ctrl+d 2번

<img src="https://user-images.githubusercontent.com/64996121/156556110-5a5b05fa-d93e-4dd0-a9a2-6f08868a9125.PNG" width=500 heigth=300 />



- 다시 root로 로그인해보면 비밀번호가 정상적으로 변경된 것을 확인할 수 있다

<img src="https://user-images.githubusercontent.com/64996121/156556165-08c6555d-d064-46ab-b41d-4fccef0cac3a.PNG" width=500 heigth=300 />


<br>

<br>

<h2>부트 로더(Boot Loader)</h2>

- **부트로더(Boot Loader)란 부팅 이전에 먼저 실행되는 프로그램**
- 커널이 올바르게 부팅되기 위해 필요한 모든 관련 작업을 마무리하고 최종적으로 운영체제를 부팅 시키기 위한 목적을 가짐

- **GRUB**
  - 파일 시스템과 커널 실행 포맷을 인식하여, 하드디스크 상에서의 커널의 물리적인 위치를 기록하지 않고도 커널의 파일명과 커널이 위치하고 있는 파티의 위치만을 알고있으면 시스템 부팅이 가능
  - #cat /boot/grub2/grub.cfg
  - #cat /etc/default/grub
  - #grub2-deitenv list : 현재 사용하는 커널 확인



<h4>부트로더 커널 이미지 시간</h4>

- 부트로더 커널 이미지 시간이란, 처음 화면이 나오고 자동으로 부팅되는 시간이다
  - 초 단위로 설정한다
  - -1로 설정하면 사용자가 엔트리(커널)를 선택할 때까지 대기
- **/etc/default/grub**에서 확인할 수 있다
  - GRUB_TIMEOUT 속성이 커널 이미지 시간이다
- vi 에디터를 통해 GRUB_TIMEOUT을 변경함으로써, 부트로더 커널 이미지 시간을 변경할 수 있다

```
[root@localhost ~]# vi /etc/default/grub
```

```shell
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rhgb quiet"
GRUB_DISABLE_RECOVERY="true"

...

"/etc/default/grub" 7L, 218C
```





<h4>부트로더 ID 및 PW 설정</h4>

- /etc/grub.d/00_header 설정을 통해 부트로드의 ID 및 PW를 설정·변경할 수 있다.

- 아래의 절차를 따르면 부트로더의 ID 및 PW를 설정할 수 있다.
- 부트로더의 ID,PW를 설정하면, 커널 편집모드(e)로 들어갈 때, 아이디와 비밀번호를 입력해야한다.



1. vi에디터로 /etc/grub.d/00_header 파일 변경
2. G를 눌러 제일 마지막 부분으로 이동
3.  'i' 를 눌러 편집모드로 변환한 뒤, 해당 부분(아래 사진 참고)을 작성
4. ':wq' 를 통해 저장 후 나온다



<img src="https://user-images.githubusercontent.com/64996121/156556269-0a94fb00-058b-4564-aad6-ccad3c80326a.PNG" width=500 heigth=300 />


 

<h4>설정 내용 부트로더 인식</h4>

- 앞서 설명한 '부트로더 커널 이미지 시간' '부트로드 ID 및 PW' 등의 **부트로더 설정을 변경한 후에는 시스템에 적용**시키기 위해서는 **아래의 명령어 입력 후 재부팅(reboot)** 해야한다
- **grub2-mkconfig -o /boot/grub2/grub.cfg**

```shell
[root@localhost ~]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-862.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-862.el7.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-bb9afee5d305ab46b7f34ffc7d08f145
Found initrd image: /boot/initramfs-0-rescue-bb9afee5d305ab46b7f34ffc7d08f145.img
done
[root@localhost ~]# reboot
Connection to 192.168.56.101 closed by remote host.
Connection to 192.168.56.101 closed.
```

