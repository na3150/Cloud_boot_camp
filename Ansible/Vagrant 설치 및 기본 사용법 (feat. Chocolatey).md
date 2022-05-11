# Vagrant 설치 및 기본 사용법 (feat. Chocolatey)



### 📌INDEX

- [Vagrant란?](#vagrant란)
- [Vagrantfile](#Vagrantfile)
- [Vagrant 명령어](#vagrant-명령어)





## Vagrant란?

**Vagrant는 가상화 인스턴스를 관리하는 소프트웨어**이다.

- IaC 도구 중의 하나
- Vagrant를 이용하면 가상 인스턴스를 만들고 실행하는 과정이 매우 빠르고 편리

- 지원하는 가상화 기술
  - VirtualBox
  - VMware
  - KVM
  - Linux Container(LXC)
  - Docker



Vagrant를 설치하기 위해 `Chocolatey`를 이용할 예정이다.

- **Chocolatey란?**
  - Windows용 패키지 관리자
  -  [Chocolatey](https://chocolatey.org/)는 Linux에서의 apt(apt-get), yum이나 macOS에서의 Homebrew처럼 패키지를 설치/업데이트/제거 등 관리하는 데에 사용하는 Windows용 프로그램

- **Chocolatey 설치**(Windows Terminal에서 진행)
  - 참고) Windows Terminal에서 choco로 설치할 때는 **관리자 모드**에서 진행해야함(sudo 명령 없음)
  - 아래 명령 복사해서 실행

```shell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

```shell
PS C:\Users\USER> choco
Chocolatey v1.1.0
Please run 'choco -?' or 'choco <command> -?' for help menu.
```

- **Vagrant 설치**
  - 설치 후 재부팅

```shell
PS C:\Users\USER> choco install vagrant
```







## Vagrantfile

- Vagrantfile이란? 
  - **Vagrantfile 은 VM 환경설정 파일**
  - Vagrant 는 프로젝트 당 한 개의 vagrantfile 이 존재
  - Vagrantfile은 `Ruby`로 작성되어있지만, Ruby를 공부할 필요는 X
- Vagrantfile 예시

```shell
Vagrant.configure("2") do |config|  #Vagrant 설정형식 2를 사용한다는 의미
	# Define VM
	config.vm.define "myvm" do |centos|  #Vagrant에서 정의한 가상머신 이름
		centos.vm.box = "centos/7"  #Vagrant Cloud에서 다운로드 및 실행할 이미지 이름
		centos.vm.hostname = "myvm"  #Centos에서 설정될 hostname
		centos.vm.network "private_network", ip: "192.168.56.10"  #Centos에서 설정될 네트워크
		centos.vm.provider "virtualbox" do |vb|  #Virualbox Provider 지정
			vb.name = "myvm"
			vb.cpus = 2
			vb.memory = 2048
		end
		config.vm.provision "shell", inline: <<-SHELL
			#!/bin/bash
			echo "hello world" > /tmp/hello.txt
		SHELL
	end
end
```

- Vagrantfile 설정 후 `vagrant up` 명령을 입력하면 Vagrantfile에서 정의한 내용으로 가상머신 생성됨

- Vagrantfile 파일 생성 방법은 아래에서 확인







## Vagrant 명령어

- Vagrant는 작업하는 **디렉토리의 위치가 매우 중요**함 -> 현재 디렉토리를 체크하는 습관을 들이는 것이 좋음

- 모든 작업을 코드로 했으면 처음 부터 끝까지 코드로 진행할 것 -> 꼬일 수 있음
- 정의된 VM이 2개 이상이라면 명령어 뒤에 [VM 이름] 지정



**Vagrantfile 생성**

- [이미지 공유 사이트](https://app.vagrantup.com/boxes/search)

```shell
vagrant init <IMAGE>
```



**VM 생성 및 부팅**

- 이미 vagrant 파일에 정의되어있는 가상 컴퓨터가 있으면 재부팅

```shell
vagrant up
```



**VM 상태 확인**

```shell
vagrant status
```



**VM 재시작**

```shell
vagrant reload
```



**VM 종료**

```shell
vagrant halt
```



**VM 삭제**

```shell
vagrant destroy
```



**VM SSH 접속**

```shell
vagrant ssh 
```



**VM 일시 정지**

```shell
vagrant suspend
```



**일시 정지된 VM 재시작**

```shell
vagrant resume
```

