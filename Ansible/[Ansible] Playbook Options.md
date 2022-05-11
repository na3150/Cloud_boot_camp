# [Ansible] Playbook Options

<br>

- **playbook 실행**

```shell
ansible-playbook [yaml 파일]
```

<br>

- **playbook 문법 체크**
  - 문법만 체크하고, 실제 동작을 보장하진 않음
  - 오류된 부분을 완벽하게 가리키지는 못할 수도 있음
  - 파일명만 나온다면 문법적으로 오류가 없는 것
  - 실행하기 전에 한번이라도 체크해주는 것이 좋음

```shell
ansible-playbook [yaml파일] --syntax-check
```

<br>

- **playbook 시뮬레이션**

  - `-C` (--check)

  - **시스템의 실제 변경사항을 만들지는 않음**
  - 패키지가 없어서 시뮬레이션 안될 수도 있음(앞의 명령들이 실제로 실행되지는 않기 때문에)
  - check에서 오류가 난다고해서 실제 작동시 오류가 발생하는 것을 보장하는 것은 아님
  - check에서 오류가 나지않았다고해서 실제 작동시 오류가 발생하지 않는다는 것을 보장하는 것은 아님

````shell
ansible-playbook [yaml파일] --check
````

<br>

- **playbook text 변경사항 확인**

  - `--diff`
  - 텍스트 파일의 변경사항들을 눈으로 직접 확인할 수 있음

  ```
  diff wp-config-sample.php wp-config.php
  ```

  - playbook에서 1개의 파일말 쓰고 진행하면, **playbook 실행 전과 후를 비교**해주는 것
    - `--check` 옵션과 함께 사용하는 경우가 많음

```
ansible-playbook wordpress.yaml -diff -b
```

<br>

- 참고)그룹에 여러개의 호스트?
  - 순차적으로 TASK를 호스트 개수만큼 실행
  - 호스트 2개라면 -> TASK1작업 동시에 2번 , TASK2 동시에 2번, TASK3 동시에 2번...
    - TASK의 모든 호스트의 작업이 끝나야 다음 TASK로 넘어감
    - 한개가 먼저끝난다고해서 다음걸로 먼저 넘어가는 것이 아님
  - 모두 끝나야하기 때문에 시간이 오래 걸리는 작업이다?? (영상 다시 확인)

<br>

- **playbook 실행할 시스템 제한**
  - `--limit`
  - 그룹에서 실행할 호스트를 지정할 수 있음

```shell
ansible-playbook wordpress.yaml -b --limit 192.168.100.12
```

<br>

- **playbook 실행이 적용될 호스트 목록**
  - `--list-hosts`
  - yaml 파일이 (적용될) 호스트 목록 확인

```
ansible-playbook wordpress.yaml --list-hosts
```

```shell
[vagrant@controller ~]$ ansible-playbook wordpress.yaml --list-hosts

playbook: wordpress.yaml

  play #1 (wp): wp      TAGS: []
    pattern: [u'wp']
    hosts (1):
      192.168.100.11
```

<br>

- playbook의 작업 목록
  - `--list-tasks`
  - yaml파일의 task 목록 확인

```
ansible-playbook wordpress.yaml --list-tasks
```

```shell
[vagrant@controller ~]$ ansible-playbook wordpress.yaml --list-tasks

playbook: wordpress.yaml

  play #1 (wp): wp      TAGS: []
    tasks:
      yum       TAGS: []
      yum_repository    TAGS: []
      yum_repository    TAGS: []
      yum       TAGS: []
      service   TAGS: []
      service   TAGS: []
      get_url   TAGS: []
      unarchive TAGS: []
      mysql_db  TAGS: []
      mysql_user        TAGS: []
      copy      TAGS: []
      replace   TAGS: []
      replace   TAGS: []
      replace   TAGS: []
```

<br>

<br>