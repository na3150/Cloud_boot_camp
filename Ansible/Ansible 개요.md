## Ansible 설치 및 개요



### 📌INDEX

- [IaC](#IaC)
- [Ansible 설치](#ansible-설치)
- [Inventory](#inventory)
- [Ansible Architecture](#ansible-architecture)
- [Ansible Module](#ansible-module)
- [Ad-Hoc 명령](#ad-hoc-명령)
- [Playbook](#playbook)

<br>

<br>

## IaC

IaC란 Infrastructure as Code(코드형 인프라)의 약자로, 수동 프로세스가 아닌 **코드를 통해 인프라를 관리하고 프로비저닝하는 것**을 말함

- 장점
  - 비용 절감
  - 빠른 속도
  - 안정성
  - 재사용성
  - 버전 관리
- IaC는 구성 사양을 코드화하고 문서화함으로써 [구성 관리](https://www.redhat.com/ko/topics/automation/what-is-configuration-management)(Configuration Management)를 지원
  - 구성 관리 : 패키지 설치, 설정 파일, 파일 복사 등
  - 배포 : 리소스 새로 생성, 리소스 변경, 삭제 , 관리
- 구성 관리 도구(Tool) 
  - Chef
  - Puppet
  - **Ansible** 
  - Saltstack
  - ...

- 배포(Provisioning)
  - **Terraform**
  - AWS CloudFormation
  - Vagrant

<br>

#### **불변 인프라/가변 인프라**

- 가변(Mutable) : Ansible
  - 여러 관리 대상 인프라가 독립적으로 관리되며 별도의 변경 사항을 가지는 형태
  - 예 : VM, EFS로 공유 
- 불변(Immutable) : Terraform
  - 인프라가 배포된 후 절대로 변하지 않는 인프라
  - 관리가 용이
  - 예 : 컨테이너, 이미지(AMI)화 하는 것

<br>

#### 절차적 / 선언적 

- 절차적 : 순서 O
  - 순서를 지켜서 절차적으로 진행해야함
  - 예 : Ansible -> 코드를 짤 때 순서를 잘 지켜야함
- 선언적 : 순서 X
  - 예 : Terraform, Kubernetes
  - 일반적으로 선언적인 것을 선호

<br>

#### 마스터 및 에이전트 유무

- 마스터 : 전체를 관리할 수 있는 시스템
- 에이전트 : 마스터에 의해 제어되는 시스템
  - (마스터에 의해 제어받을 수 있는) 에이전트 프로그램이 설치되어있어야함
  - 에이전트 프로그램도 관리가 필요함(관리를 위한 관리) -> 번거로울 수 있음
- Master-Agent 예 : Chef, Puppet, SaltStack

<br>

<br>

## Ansible Architecture



![image](https://user-images.githubusercontent.com/64996121/162985981-62d3dd58-c55b-4eab-aa92-1ea366dc2819.png)



**Controller(제어노드)** : 그림의 좌측

- Ansible 시스템이 설치되는 곳
- Ansible's Automation Engine : Ansible 프로그램을 controller에 설치를 하게되는 시스템
- 모듈이 핵심
- 별다른 목적이 아닌 이상 Controller에서 작업
- User가 Ansible을 사용하는 방식
  - **Ad-hoc** : user가 직접 direct로 사용
  - **Playbook** : playbook(설정 파일)을 만들어서 playbook을 실행

<br>

**Managed node(관리노드)** : 그림의 우측

- 아무것도 설치될 필요 없음 -> agent-less : 에이전트가 없는 형태
- `ssh`로 제어노드와 통신
  - ssh 통신이 되는 모든 시스템들은 관리가 가능

<br>

<br>

## Ansible 설치

- 레포지토리 추가

```shell
sudo yum -y install centos-release-ansible-29
```

- ansible 설치

```shell
sudo yum -y install ansible -y
```

- 설치 확인

```shell
ansible --version
```

<br>

<br>

## Inventory

인벤토리(Inventory)란 **Ansible에서 관리할 호스트의 모음을 정의한 것**

- 호스트명만 정의하는 것을 넘어서, 그룹의 정의 등 여러가지 정보를 추가로 넣을 수 있음

- 인벤토리 종류

  - 정적 인벤토리 : 단순하게 사용자가 직접 텍스트 파일로 정의
    - 본적으로 ini 형식을 사용하며, yaml 형식도 사용 가능

  - 동적 인벤토리 : 필요에 따라 외부 정보 provider를 사용해 스크립트나 기타 프로그램으로 인벤토리를 생성

- 사전 설정: ssh 키 기반의 인증이 설정되어있어야함



예시

```shell
vi inventory.ini
```

```shell
# inventory.ini
# 관리 대상(서버)의 IP를 정의
192.168.100.11
192.168.100.12
```



<br>

<br>

## Ansible Module

Ansible Module은 **ansible의 최소 실행 단위**

- [ansible module docs]([Module Index — Ansible Documentation](https://docs.ansible.com/ansible/2.9/modules/modules_by_category.html))
- 모듈의 파라미터를 어떻게 사용할지가 중요 : 모듈 사용법(설명서) 확인하기

<br>

<br>

## Ad-Hoc 명령

- `yum` 모듈로 httpd 서비스 설치
  - [yum 모듈 사용법]([yum – Manages packages with the yum package manager — Ansible Documentation](https://docs.ansible.com/ansible/2.9/modules/yum_module.html#yum-module))
  - yum 모듈의 상태(status)
    - 설치 : installed, latest, present
    - 삭제 : absent, removed

```shell
ansible 192.168.100.11 -i inventory.ini -m yum -a "name=httpd state=present" -b
```

- `ansible` : Ad-Hoc command(명령)
- 관리 대상이 되는 시스템(IP)은 반드시 `inventory.ini` 파일에 정의되어있어야함

| 옵션 | 설명                             |
| ---- | -------------------------------- |
| -i   | 인벤토리 파일 지정               |
| -m   | 모듈 이름 지정                   |
| -a   | 모듈 파라미터                    |
| -b   | 관리자 권한 취득(become -> sudo) |



- `service` 모듈로 httpd 서비스 시작
  - [service 모듈 사용법](https://docs.ansible.com/ansible/2.9/modules/service_module.html#service-module)

```shell
ansible 192.168.100.11 -i inventory.ini -m service -a "name=httpd state=started enabled=yes" -b
```

- 동일한 명령 한번 더 진행해보기
  - SUCCESS : 성공적으로 모듈을 실행했다는 의미
  - changed : false 
    - 시스템에 변경이 없다는 뜻
    - 이미 현재 실행되고 있어서 아무 작업 안함(다시 시작할 필요X) => **`멱등성`**
      - 멱등성이란? 명령을 여러번 실행해도 결과가 변하지 않는다는 것

```shell
[vagrant@controller ~]$  ansible 192.168.100.11 -i inventory.ini -m yum -a "name=httpd state=present" -b
192.168.100.11 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "msg": "",
    "rc": 0,
    "results": [
        "httpd-2.4.6-97.el7.centos.5.x86_64 providing httpd is already installed"
    ]
}
```



이와 같이 **원격 시스템을 관리**

<br>

<br>

## Playbook

-  Ansible Playbook은 작업 메뉴얼과 같은 것
- 멱등성을 보장
- 파일 생성 시 주의 점
  - 띄어쓰기에 매우 민감함
  - 콜론(:) 뒤에 반드시 한칸 띄어져 있어야함
  - 띄어쓰기 시 Tab 키 사용하면 안됨

- `apache_install.yaml` 파일 생성

```shell
vi apache_install.yaml
```

```shell
- hosts: 192.168.100.11
  tasks:
  - yum:
      name: httpd
      state: present
  #ansible 192.168.100.11 -i inventory.ini -m yum -a "name=httpd state=present" -b 와 동일
  - service:
      name: httpd
      enabled: yes
      state: started
  #ansible 192.168.100.11 -i inventory.ini -m service -a "name=httpd state=started enabled=yes" -b 와 동일
```

- **playbook 실행**

```shell
ansible-playbook -i inventory.ini apache_install.yaml -b
```

