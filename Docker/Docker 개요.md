# [Docker] Docker 개요 및 설치

<br>

### 📌Index

- [Docker란?](#docker란)
- [Docker 설치 및 환경 구성](#docker-설치-및-환경-구성)
- [Container Image](#container-image)
  - [관련 docker 명령어](#관련-docker-명령어)
- [Lifecycle](#lifecycle)

<br>

<br>

## Docker란?

[Docker](https://www.docker.com/)는 **애플리케이션을 신속하게 구축, 테스트 및 배포**할 수 있는 소프트웨어 플랫폼

[Docker Docs](https://docs.docker.com/)

Docker를 이해하기 위해서는 Container에 대한 이해가 필요함

#### Container란?

Host OS 상에서 **리소스를 논리적으로 구분(Isolation)하여 마치 별도의 서버인 것 거처럼 사용**할 수 있게 하는 기술

Container와 다르게 **VM은 논리적으로 분리**하는 것 : [VM vs. Container](https://www.docker.com/blog/containers-replacing-virtual-machines/)

Docker를 사용하는 가장 큰 이유는 **Isolation**을 위해서이다.

참고)컨테이너는 가상머신과 다르게 끄고 킨다는 개념이 존재하지 않음(stop, start는 있지만...)

<br>

#### Container 핵심 기술

**Cgroup: Control Group(리소스 양)**

- 프로세스를 그룹핑 시켜놓은 것

- 격리된 공간에 얼마만큼의 리소스를 사용할 수 있는지 리소스의 양을 제어함

  - 리소스의 양이란? 하드웨어,CPU,메모리,네트워크 등과 같은 리소스의 양

  - 기본적으로 양의 제한이 걸려있지는 않음(무제한)

참고) 서비스 상태를 확인할 때 확인할 수 있음

```shell
$ systemctl status docker
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-05-03 03:19:45 UTC; 4h 38min ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 4308 (dockerd)
      Tasks: 10
     Memory: 268.2M
     CGroup: /system.slice/docker.service
             └─4308 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```

**Namespace: Isolation**

NS 종류

- IPC NS: IPC
- PID NS: Process
- Network NS: Network
- UID NS: User/Group
- Mount NS: Mount Point
- UTS NS: Hostname

**Layered Filesystem**

<br>

#### Docker Engine

도커가 곧 컨테이너를 의미하는 것은 아니며, 컨테이너를 구현하도록 돕는 것이 Docker(도커)이다.

일반적으로 Docker는 컨테이너를 제공해주는 **Docker Engine**을 의미

- Docker가 Cgroup과 Namespace를 쉽게 사용하게 해준 최초의 도구이다.

- 컨테이너, 도커 엔진은 **리눅스 시스템에서만 작동**

<br>

#### Docker Architecture

[docker-architecture](https://docs.docker.com/get-started/overview/#docker-architecture)

<img src = "https://docs.docker.com/engine/images/architecture.svg" width = 600>



- `docker client` : docker 명령어
- `docker host` :  Server로, `docker daemon`, `docker engine`이 있음
- `docker registry` : 컨테이너용 이미지를 저장하고 있는 저장소  

docker 명령어가 docker 데몬에게 명령을 내리는 형태

<br>

<br>

## Docker 설치 및 환경 구성
#### Vagrant 환경 구성

`~/vagrant/container/Vagrantfile`

```Vagrantfile
Vagrant.configure("2") do |config|
	# Define VM
	config.vm.define "docker" do |centos|
		centos.vm.box = "ubuntu/focal64"
		centos.vm.hostname = "docker"
		centos.vm.network "private_network", ip: "192.168.100.100"
		centos.vm.provider "virtualbox" do |vb|
			vb.name = "docker"
			vb.cpus = 2
			vb.memory = 4096
		end
	end
end
```

`~/.ssh/config`

```
Host docker
    Hostname 192.168.100.100
    User vagrant
    IdentityFile C:\Users\USER\vagrant\container\.vagrant\machines\docker\virtualbox\private_key    
```

<br>

#### Docker Engine 설치

[Docker Engine 설치](https://docs.docker.com/engine/install/ubuntu/)

리스트 가져오기

```
sudo apt update
```

```
sudo apt install ca-certificates curl gnupg lsb-release
```

전자서명을 위한 GPG키 가져오기

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

`/etc/apt/sources.list.d/docker.list` 파일 구성

```
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

확인

```
vagrant@docker:~$ cat /etc/apt/sources.list.d/docker.list 
deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu   focal stable
```

앞서 새로운 저장소를 추가했기 때문에, 다시 패키지 목록 가져오기

```
sudo apt update
```

```
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```
- docker-ce: Docker Engine
- docker-ce-cli: docker command
- containerd.io: Container Runtime Interface
  - [containerd](https://containerd.io/) : 라이브러리를 표준화시킨 것(libcontainer)
- docker-compose-plugin: Docker Compose

```
sudo usermod -aG docker vagrant
```

docker를설치할 때 기본적으로 docker 그룹 생김

```
vagrant@docker:~$ tail /etc/group
...
docker:x:998:
```

vagrant 사용자를 docker 그룹에 넣기

- docker는 docker그룹에 의해 실행됨
- docker 명령을 실행할 때 마다 `sudo` 를 붙이는 것이 귀찮다면 docker그룹에 사용자 추가할 것

```
vagrant@docker:~$ sudo usermod -aG docker vagrant
```

나갔다가 들어오면(또는 exit) 적용됨

```
vagrant@docker:~$ id
uid=1000(vagrant) gid=1000(vagrant) groups=1000(vagrant),998(docker)
```

<br>

여기서 부터는 선택 사항

#### Terminal 환경 구성

https://ohmyz.sh/ : 오픈소스, zsh의 테마

- bash shell은 기능이 많이 없기 때문에 zsh 사용

```
sudo apt install zsh
```

```
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

`~/.zshrc` : zsh 설정파일

```
...
ZSH_THEME="agnoster"
...
```

- https://github.com/powerline/fonts

설정파일 읽어오게 하기

```
source ~/.zshrc
```

명령어의 자동완성을 도와주는 플러그인(Plugin) 다운

- https://github.com/powerline/fonts/archive/refs/heads/master.zip
- https://github.com/zsh-users/zsh-completions

```
$ git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

```
$ git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
```

`~/.zshrc` 설정파일에 플러그인 추가

```
 73 plugins=(
 74         git
 75         zsh-autosuggestions
 76         zsh-completions
 77 )
```

```
source ~/.zshrc
```

설정을 완료하면, 다음과 같이 확인됨

![zsh](https://raw.githubusercontent.com/na3150/typora-img/main/img/zsh.PNG)

<br>

**vscode에서 적용하는 방법**

<img src="https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220503175450476.png" width=700/>

<br>

<br>

## Container Image

`(registry/)[저장소이름]/[이미지이름]:[태그]`

- 저장소 이름은 Docker Hub의 아이디

- `registry/`는 일반적으로 생략

- 모든 이미지는 태그가 존재해야함
- 태그를 생략해서 명령(run)할 때는, 무조건 `latest`라는 태그를 지정하게됨

<br>

https://hub.docker.com/ : 이미지 검색 및 확인

`official image` : docker에서 만든 이미지

- 이미지를 실행할 때 무엇을 만들지, 어떤 애플리케이션을 실행할 지는 이미 **이미지를 만들때 결정**됨 => 그냥 이미지를 실행하면 끝
- `docker run` 명령어를 실행할 때마다(이미지를 실행할 때마다) 컨테이너가 생성되고,  종료되면 컨테이너가 종료됨

```shell
$ docker run [container image]
```

- **⭐컨테이너는 애플리케이션이 종료되면, 컨테이너가 자동으로 종료됨**

<br>

예시

- `hello-world` 이미지로 docker를 실행

도커가 제대로 실행되는지 체크하기 위해 사용하는 이미지

```shell
$ docker run hello-world
```

```shell
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

=> docker 가 어떻게 실행되는지에 대한 설명

- docker client가 docker daemon에게 접근
- docker daemon은  local에서 이미지가 있는지 찾아보고, 없으면 docker hub(registry)로 부터 hello-world 이미지를 가져옴(pulling)
- 현재 읽고 있는 텍스트를 출력하는 실행파일이 있는 이미지(현재 이미지)로 컨테이너로 만듬
- **docker daemon은 docker client에게 output**(표준출력 stdout, stdin, stderr)을 출력. 그리고 우리 터미널에 전송(출력)

<br>

#### 관련 docker 명령어

**local에 다운로드 받아진(한번이라도 사용된) 이미지 목록 확인하기**

```shell
$ docker images
```

<br>

**현재 실행중인 컨테이너의 목록 확인**

```shell
$ docker ps
```

<br>

**컨테이너 목록 확인**

```shell
$ docker ps -a
CONTAINER ID   IMAGE         COMMAND    CREATED          STATUS                      PORTS     NAMES
81f5723d4d27   hello-world   "/hello"   11 minutes ago   Exited (0) 11 minutes ago             reverent_lehmann
b5eb1ae5fb9e   hello-world   "/hello"   26 minutes ago   Exited (0) 26 minutes ago             stupefied_morse
```

- docker가 컨테이너를 실행할 때 알아서 자동으로 컨테이너 ID 생성
- command: 실행할 애플리케이션 => 이미지 내에 결정되어 있음

<br>

**컨테이너 지우기**

```
docker rm [container ID | Names]
```

- 컨테이너 id의 일부분만 지정해도, 매칭되는 컨테이너 삭제 가능
  - 단, 만약 2자리를 쓴 경우 2자리가 겹치는 컨테이너가 2개 이상 있다면 삭제되지 않음
-  name의 일부분은 불가능

<br>

<br>

## Lifecycle

`docker run` 은 `docker create`와 `docker start`를 합쳐놓은 것

- `docker create` : 컨테이너만 생성
- `docker start` : 컨테이너 실행
- `docker pause` : 중지, 사용하고 있던 리소스는 그대로 가지고 있음
  - pause, unpause는 특별한 일이 있지 않은 이상 사용할 일이 거의 없음
- `docker kill` : 컨테이너 강제 종료

<br>

**docker Lifecycle**

```
create -> start -> (pause) -> (unpause) -> (kill) -> stop -> rm
run ---------------->
```

⭐ 원칙: application이 종료되면 컨테이너도 종료(stop)

**⭐ 옵션**

- `-i`: interactive, STDIN 유지

   **docker client가 docker deamon에게 표준입력을 전송(stream)**할 수 있게 만들어줌

- `-t`: Terminal 할당

- `-d`: Detach, 백그라운드에서 계속 실행, 이미지에따라 붙일 수 있는/없는 경우 다름

<br>

`-it` 옵션은 Shell을 실행하는 이미지에서 사용: centos, ubuntu ...

- bash => 입력이 있어야 출력을 할 수 있는 애플리케이션 => `-i` 사용
- `-i` 만 사용하면 실행되고 있는 것을 확인하기 어려움 => `-t` 사용
- 우리가 일반적으로 알고있는 형태로 shell이 터미널로 실행 + 표준 입력 가능

```shell
$ docker run -it ubuntu
root@82ad12092f1d:/# hostname
82ad12092f1d
root@82ad12092f1d:/# ls
bin  boot  dev  etc  home  lib  lib32  lib64  libx32  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@82ad12092f1d:/# exit
exit
$ docker ps -a
CONTAINER ID   IMAGE         COMMAND       CREATED          STATUS                      PORTS     NAMES
82ad12092f1d   ubuntu        "bash"        13 seconds ago   Exited (0) 5 seconds ago              magical_joliot
659145c1be1d   ubuntu        "bash"        24 seconds ago   Exited (0) 22 seconds ago             stupefied_mclaren
347a3a5b8154   centos:7      "/bin/bash"   4 hours ago      Exited (0) 4 hours ago                condescending_bardeen
81f5723d4d27   hello-world   "/hello"      5 hours ago      Exited (0) 5 hours ago                reverent_lehmann
b5eb1ae5fb9e   hello-world   "/hello"      5 hours ago      Exited (0) 5 hours ago                stupefied_morse
```

- `exit` 으로 터미널 종료 : 컨테이너 종료

```shell
root@82ad12092f1d:/# exit
exit
$ docker ps -a
CONTAINER ID   IMAGE         COMMAND       CREATED          STATUS                      PORTS     NAMES
82ad12092f1d   ubuntu        "bash"        13 seconds ago   Exited (0) 5 seconds ago             
```

<br>

`-d` 옵션 application이 계속적으로 실행되어햐 할 때: httpd ...

`-d` 옵션으로 실행할 지 `-i` 옵션으로 실행할 지 잘생각해봐야함

<br>

참고) 컨테이너 이미지에는 운영체제(os)가 없는데 ubuntu, centos, rocky 등의 이미지는 뭘까?

=> Base image : 다른 이미지를 만들 때 사용

=> 어떤 이미지는 어떻게 써야하는지, 어떻게 실행해야할지 보고  판단해야함

참고) 리눅스 배포판 이름으로된 이미지

- ubuntu
- centos
- rocky
- debian
- alpine
- busybox
- amazonlinux
- oraclelinux
- ...
-> Base Image





