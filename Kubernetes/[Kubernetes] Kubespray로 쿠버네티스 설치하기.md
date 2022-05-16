# [Kubernetes] Kubespray로 쿠버네티스 설치하기

[Kubespray로 쿠버네티스 설치하기 | Kubernetes](https://kubernetes.io/ko/docs/setup/production-environment/tools/kubespray/)
[Readme (kubespray.io)](https://kubespray.io/#/)
https://github.com/kubernetes-sigs/kubespray

<br>

<br>

 `kubeadm` 방식은 k8s를 구성할때 수동으로 구성 모듈을 하나 하나 설치한다는 어려움이 있으나, 

전체적인 구성요소를 이해하는데 장점이 있고, 

`kubespray`는 설치가 매우 간단하다는 장점이 있다.

`Kubespray`는 ansible 기반의 배포툴(`Kubeadm` + `Ansible`)로, 클러스터의 구성은 아래의 그림과 유사하다.

<br>

![img](https://blog.kakaocdn.net/dn/mWUEO/btrCjIIXpCy/2EKO51V89ro8uyMuROFDb0/img.png)

https://initmanfs.eu/

<br>

#### Requirements

- **Ansible의 명령어를 실행하기 위해 Ansible v 2.9와 Python netaddr 라이브러리가 머신에 설치되어 있어야 한다**
- **Ansible 플레이북을 실행하기 위해 2.11 (혹은 그 이상) 버전의 Jinja가 필요하다**
- Docker 이미지를 가져오려면 대상 **서버가 인터넷에 액세스**할 수 있어야한다.
- 인벤토리의 모든 서버 부분에 SSH 키를 복사해야한다.
- **방화벽은 kubespray에 의해 관리되지 않는다**. 배포 중 문제를 방지하려면 **방화벽을 비활성화**해야한다. 
- 만약 kubespray가 루트가 아닌 사용자 계정에서 실행되었다면, 타겟 서버에서 알맞은 권한 확대 방법이 설정되어야 하며, `ansible_become` 플래그나 커맨드 파라미터들, `--become` 또는 `-b` 가 명시되어야 한다

<br>

본 실습에서는 다음과 같이 구성할 예정이다.

```
Control Plane 1
Work Node 3(1 Control Plan + 2 Woker Node)
CPU: 2, Memory 3GB

Master : k8s-node1
Worker Node : k8s-node2, k8s-node3
```

<br>

**클러스터 구성 순서**

1. Vagrant로 VM 구축하기
2. SSH 키 생성 및 복사
3. kubespray 소스 다운로드
4. ansible, netaddr, jinja 등 패키지 설치
5. 인벤토리 구성
6. 변수 설정
7. 플레이북 실행
8. 검증

<br>

<br>

## 1. Vagrant로 VM 구축하기

실습 진행을 위한 디렉토리 `k8s`를 생성하고, `Vagrantfile`을 다음과 같이 작성하자.

`~/vagrant/k8s/Vagrantfile`

```ruby
Vagrant.configure("2") do |config|
	# Define VM
	config.vm.define "k8s-node1" do |ubuntu|
		ubuntu.vm.box = "ubuntu/focal64"
		ubuntu.vm.hostname = "k8s-node1"
		ubuntu.vm.network "private_network", ip: "192.168.100.100"
		ubuntu.vm.provider "virtualbox" do |vb|
			vb.name = "k8s-node1"
			vb.cpus = 2
			vb.memory = 3000
		end
	end
	config.vm.define "k8s-node2" do |ubuntu|
		ubuntu.vm.box = "ubuntu/focal64"
		ubuntu.vm.hostname = "k8s-node2"
		ubuntu.vm.network "private_network", ip: "192.168.100.101"
		ubuntu.vm.provider "virtualbox" do |vb|
			vb.name = "k8s-node2"
			vb.cpus = 2
			vb.memory = 3000
		end
	end
	config.vm.define "k8s-node3" do |ubuntu|
		ubuntu.vm.box = "ubuntu/focal64"
		ubuntu.vm.hostname = "k8s-node3"
		ubuntu.vm.network "private_network", ip: "192.168.100.102"
		ubuntu.vm.provider "virtualbox" do |vb|
			vb.name = "k8s-node3"
			vb.cpus = 2
			vb.memory = 3000
		end
	end

	config.vm.provision "shell", inline: <<-SHELL
	  sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
	  sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list
	  sed -i 's/security.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list
	  systemctl restart ssh
	SHELL
end
```

`/etc/ssh/sshd_config`는 서버 설정파일로, 

`vagrant`로 배포한 이미지는 기본적으로 패스워드 인증이 안되어있다. 

따라서 패스워드 인증을 할 수 있도록 `/PasswordAuthentication yes`로 바꿔준다.

**왜 패스워드 인증이 가능하도록 하는가❔**

`Ansible`을 사용하기 위해서는 `ssh` 키를 만들어서 키를 배포해야한다.

이때, **키를 배포하기 위해서는 패스워드 인증이 가능해야하기 때문**이다.

<br>

또한 패키지 업데이트 속도를 향상 시키기 위해 저장소를 `mirro.kakao.com`으로 바꿔준다. 

<br>

<br>

## 2. SSH 키 생성 및 복사

`k8s-node1`에 `ssh` 접속하여 키를 생성하고 복사한다. 

```
ssh-keygen
```

```
ssh-copy-id vagrant@192.168.100.100
ssh-copy-id vagrant@192.168.100.101
ssh-copy-id vagrant@192.168.100.102
```

<br>

<br>

## 3. kubespray 소스 다운로드

```
cd ~
```

```
git clone -b v2.18.1 https://github.com/kubernetes-sigs/kubespray.git
```

```
cd kubespray
```

`requirements.txt`

```shell
$ cat requirements.txt
ansible==3.4.0
ansible-base==2.10.15
cryptography==2.8
jinja2==2.11.3
netaddr==0.7.19
pbr==5.4.4
jmespath==0.9.5
ruamel.yaml==0.16.10
ruamel.yaml.clib==0.2.6
MarkupSafe==1.1.1
```

`pip` 명령어로 `requirements.txt`의 내용들을 설치할 것이다.

`requirements.txt`는 쓰라고 만들어 놓은 것이기 때문에 있다면 사용하자!

<br>

<br>

## 4. ansible, netaddr, jinja 등 패키지 설치

update 후 pip 패키지를 설치한다. 

```
$ sudo apt update
$ sudo apt install python3-pip -y
```

```
$ sudo pip3 install -r requirements.txt
```

가상환경이 아닌 Global하게 설치할 것이므로 ` sudo ` 권한을 사용한다.

<br>

<br>

## 5. 인벤토리 구성

https://github.com/kubernetes-sigs/kubespray/blob/master/inventory/sample/inventory.ini

인벤토리 구조

 ```
 -all
    - k8s_cluster
       - kube_control_plane
       - kube_node
       - etcd
       - calico_rr
 ```

<br>

```
$ cp -rpf inventory/sample/ inventory/mycluster
```

`inventory/mycluster/inventory.ini` 파일을 수정하자.

`inventory/mycluster/inventory.ini` 

```ini
[all]
node1 ansible_host=192.168.100.100 ip=192.168.100.100
node2 ansible_host=192.168.100.101 ip=192.168.100.101
node3 ansible_host=192.168.100.102 ip=192.168.100.102
# node1 ansible_host=95.54.0.12  # ip=10.3.0.1 etcd_member_name=etcd1
# node2 ansible_host=95.54.0.13  # ip=10.3.0.2 etcd_member_name=etcd2
# node3 ansible_host=95.54.0.14  # ip=10.3.0.3 etcd_member_name=etcd3
# node4 ansible_host=95.54.0.15  # ip=10.3.0.4 etcd_member_name=etcd4
# node5 ansible_host=95.54.0.16  # ip=10.3.0.5 etcd_member_name=etcd5
# node6 ansible_host=95.54.0.17  # ip=10.3.0.6 etcd_member_name=etcd6

# ## configure a bastion host if your nodes are not directly reachable
# [bastion]
# bastion ansible_host=x.x.x.x ansible_user=some_user

[kube_control_plane]
node1
# node1
# node2
# node3

[etcd]
node1
# node1
# node2
# node3

[kube_node]
node1
node2
node3
# node2
# node3
# node4
# node5
# node6

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr
```

<br>

<br>

## 6. 변수 설정

https://kubespray.io/#/docs/vars : 변수에 대한 설명확인

`inventory/mycluster/group_vars`

<br>

<br>

## 7. 플레이북 실행

플레이북 실행 전 검증 단계

```
$ ansible all -m ping -i inventory/mycluster/inventory.ini
```

```shell
vagrant@k8s-node1:~/kubespray$ ansible all -m ping -i inventory/mycluster/inventory.ini
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
node3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

`SUCCESS` 로 잘된다면, 이제 실제 플레이북을 실행하자.

```
$ ansible-playbook -i inventory/mycluster/inventory.ini cluster.yml -b 
```

<br>

<br>

## 8. 검증

`systemctl get nodes` 명령을 실행하면 다음과 같이 출력된다.

```shell
$ systemctl get nodes
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

인증 정보가 없어 `api server`와 통신이 되지 않기 때문이다.

따라서 인증정보를 가져와야한다.

```
$ mkdir ~/.kube
$ sudo cp /etc/kubernetes/admin.conf ~/.kube/config
$ sudo chown vagrant:vagrant ~/.kube/config
```

다시 명령을 실행하면

```
$ kubectl get nodes
```

다음과 같이 정상적으로 확인할 수 있다.

```shell
NAME    STATUS   ROLES                  AGE   VERSION
node1   Ready    control-plane,master   13m   v1.22.8
node2   Ready    <none>                 12m   v1.22.8
node3   Ready    <none>                 12m   v1.22.8
```

```
$ kubectl get pods -A
```





```shell
