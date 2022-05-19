# [kubernetes] Controller: Jobs와 CronJobs

[잡 | Kubernetes](https://kubernetes.io/ko/docs/concepts/workloads/controllers/job/)

`ReplicaSets`, `ReplicaController`, `DaemonSets` 등은 

데몬 형태의 계속적으로 실행되어야하는 애플리케이션들을 실행하는 것이 목적이다. 

`job`에서하나 이상의 파드를 생성하고 지정된 수의 파드가 **성공적으로 종료될 때까지 계속해서 파드의 실행을 재시도**한다.

시작이 있으면 반드시 끝이 있는 애플리케이션이며, **애플리케이션의 종료를 보장**한다.

지정된 수의 성공 완료에 도달하면, 작업(job)이 완료되고, 잡을 삭제하면 잡이 생성한 파드가 정리된다

<br>

`cronjobs`와 `jobs`는 `batch` 그룹에 속해있는 것을 확인할 수 있다.

```shell
$ kubectl api-resources | grep batch     
cronjobs                          cj           batch/v1                               true         CronJob
jobs                                           batch/v1                               true         Job
```

일반적으로 대량의 작업을 `batch` 작업이라고하고, 일련의 순서가 있는 작업을 스크립트로 짜놓고 실행한다. 

<br>

## ✔️ Jobs

**리소스 정의 방법 확인**

```shell
$ kubectl explain job
```

<br>

##### command와 args

`pod.spec.containers.command`는 `EntryPoint`를 변경하는 것이고,

`pod.spec.containers.args `는 `CMD`를 변경하는 것이다.

<br>

##### restartPolicy

`jobs.spec.template.spec.restartPolicy`는 `OnFailuer`, `Never`둘 중 하나의 값을 가져야한다. 

잡과 크론잡은 시작과 끝이 있는, 즉 반드시 종료되는 애플리케이션이기 때문이다.

재시작 정책이 `Always`가 되면, 종료되어도 계속 재시작하기 때문에 의도한 형태가 아니게된다.

따라서 default는 Always로 설정되어있기 때문에 에러가 발생하고, 반드시 별도로 `restartPolicy`를 설정해줘야한다.

 <br>

**💻 실습** : job 생성과 종료 및 셀렉터확인

`mypi.yaml`

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: mypi
spec:
  template:
    spec:
      containers:
        - image: perl #python과 같은 script언어
          name: mypi
          command: ["perl", "-Mbignum=bpi","-wle", "print bpi(2000)"]  #pi의 값을 2000자리까지 계산
      restartPolicy: OnFailure
```

```shell
$ kubectl create -f mypi.yaml
```

```shell
$ kubectl get job,po 
NAME             COMPLETIONS   DURATION   AGE
job.batch/mypi   0/1           54s        54s

NAME                 READY   STATUS              RESTARTS   AGE
pod/mypi--1-qwcgv    0/1     ContainerCreating   0          54s
```

시간이 지난 후 `job`의 애플리케이션이 종료되고, `Completed` 상태가 된 것을 확인할 수 있다.

```shell
$ kubectl get job,po                               

NAME             COMPLETIONS   DURATION   AGE
job.batch/mypi   1/1           3m9s       28m

NAME                 READY   STATUS      RESTARTS   AGE
pod/mypi--1-qwcgv    0/1     Completed   0          28m
```

`pod/mypi--1-qwcgv`는 종료된 파드인데, 종료된 후에도 계속 남아있게 된다.

**`job`은 작업을 완료한 뒤에 지워주지 않으면 계속 쌓이게 된다.** 

물론, 자동으로 지우게 설정할 수도 있지만 표준 출력이 있는 애플리케이션의 경우,

로그도 함께 지워지는 문제가 생길 수 있다. 따라서 쿠버네티스는 작업의 자동 삭제 여부를 사용자에게 넘겼다.

`ELK`를 사용하는 경우와 같이 로그가 따로 저장되는 경우는 지워도 무방하다. 

<br>

이번 실습을 하면서 별도로 셀렉터를 지정하지 않았었다.

다음에서 잡의 셀렉터를 살펴보자.

셀렉터를 지정하지 않았음에도 `controller-uid`가 Key로, `f92f157e-5744-4476-938d-12dd2ee7295d`가 Value로 자동 설정되었다.

파드에도 동일한 레이블이 붙어있는 것을 확인할 수 있다.

```shell
$ kubectl get job,po -o wide --show-labels
NAME             COMPLETIONS   DURATION   AGE   CONTAINERS   IMAGES   SELECTOR                                              LABELS
job.batch/mypi   1/1           3m9s       30m   mypi         perl     controller-uid=f92f157e-5744-4476-938d-12dd2ee7295d   controller-uid=f92f157e-5744-4476-938d-12dd2ee7295d,job-name=mypi

NAME                 READY   STATUS      RESTARTS   AGE   IP             NODE    NOMINATED NODE   READINESS GATES   LABELS
pod/mypi--1-qwcgv    0/1     Completed   0          30m   10.233.92.2    node3   <none>           <none>            controller-uid=f92f157e-5744-4476-938d-12dd2ee7295d,job-name=mypi
```

`jobs.spec.selector` 필드는 선택사항이지만, 대부분의 케이스에서 지정해서는 안된다.

**파드 템플릿의 레이블, 잡 컨트롤러의 레이블 셀렉터는 지정하지 않는 것이 원칙**⭐이다. 

`Job`과 `CronJob`은  시작하면 끝나는 것을 보장하기 때문에, 

기존에 있던 `RC`, `RS`, `DS` 등이 관리하고 있던 파드를 잘못 가리키는 경우가 생길 수도 있다.

이렇게 되면, 잡이나 크론잡은 해당되는 파드를 종료시키는 문제가 발생한다. 

즉, 레이블과 레이블 셀렉터를 지정하지 않는 이유는 **잘못된 매핑으로 기존의 파드를 종료하지 않게하기 위함**이다.

<br>

<br>

#### 파드의 종료 및 삭제

- `activeDeadlineSeconds`
  - `Job`에 있는 파드의 애플리케이션이, 시작된 이후 너무 오랫동안 실행되는 것을 방지하기 위해서 **일정 시간에 종료**시키는 기능
  - default는 세팅되어있지 않다

```shell
kubectl explain job.spec.activeDeadlineSeconds 
KIND:     Job
VERSION:  batch/v1

FIELD:    activeDeadlineSeconds <integer>

DESCRIPTION:
     Specifies the duration in seconds relative to the startTime that the job
     may be continuously active before the system tries to terminate it; value
     must be positive integer. If a Job is suspended (at creation or through an
     update), this timer will effectively be stopped and reset when the Job is
     resumed again.
```

- `backoffLimit` 
  -  잡과 크론잡에만 존재하는 기능이다
  - 허용되는 재시도 횟수이고, default는 6번이다. 

```shell
$ kubectl explain job.spec.backoffLimit                     
KIND:     Job
VERSION:  batch/v1

FIELD:    backoffLimit <integer>

DESCRIPTION:
     Specifies the number of retries before marking this job failed. Defaults to 6
```

- `ttlSecondsAfterFinished`⭐
  - 파드가 종료된 후 특정 시간이 지나면 삭제 및 종료한다
  - 종료돼도 job이 남아있는 문제를 해당 기능을 통해 특정 시간이 지난 후 자동 삭제되도록 설정할 수 있다.
  - `TTL` : Time To Live

```shell
$ kubectl explain jobs.spec.ttlSecondsAfterFinished
KIND:     Job
VERSION:  batch/v1

FIELD:    ttlSecondsAfterFinished <integer>

DESCRIPTION:
     ttlSecondsAfterFinished limits the lifetime of a Job that has finished
     execution (either Complete or Failed). If this field is set,
     ttlSecondsAfterFinished after the Job finishes, it is eligible to be
     automatically deleted. When the Job is being deleted, its lifecycle
     guarantees (e.g. finalizers) will be honored. If this field is unset, the
     Job won't be automatically deleted. If this field is set to zero, the Job
     becomes eligible to be deleted immediately after it finishes. This field is
     alpha-level and is only honored by servers that enable the TTLAfterFinished
     feature.
```

<br>

#### 작업의 병렬 처리

- `parallelism`
  - **작업의 병렬 처리**
  - 병렬로 job을 처리할 파드의 개수 
  - 데이터가 굉장히 많을 때 애플리케이션을 병렬로 처리하여 시간을 단축할 수 있다.

```shell
$ kubectl explain job.spec.parallelism            
KIND:     Job
VERSION:  batch/v1

FIELD:    parallelism <integer>

DESCRIPTION:
     Specifies the maximum desired number of pods the job should run at any
     given time. The actual number of pods running in steady state will be less
     than this number when ((.spec.completions - .status.successful) <
     .spec.parallelism), i.e. when the work left to do is less than max
     parallelism. More info:
     https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/
```

- `completions`
  - **완료 횟수**
  - 생성과 종료를 몇번 반복한 후 작업을 종료할 것인지
  - **complation 개수는 parallelism 값보다 크거나 같아야한다.**

```shell
$ kubectl explain job.spec.completions
KIND:     Job
VERSION:  batch/v1

FIELD:    completions <integer>

DESCRIPTION:
     Specifies the desired number of successfully finished pods the job should
     be run with. Setting to nil means that the success of any pod signals the
     success of all pods, and allows parallelism to have any positive value.
     Setting to 1 means that parallelism is limited to 1 and the success of that
     pod signals the success of the job. More info:
     https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/
```

- `suspend`
  - 작업의 중지 여부
  - default는 false이다.

```shell
$ kubectl explain job.spec.suspend    
KIND:     Job
VERSION:  batch/v1

FIELD:    suspend <boolean>

DESCRIPTION:
     Suspend specifies whether the Job controller should create Pods or not. If
     a Job is created with suspend set to true, no Pods are created by the Job
     controller. If a Job is suspended after creation (i.e. the flag goes from
     false to true), the Job controller will delete all active Pods associated
     with this Job. Users must design their workload to gracefully handle this.
     Suspending a Job will reset the StartTime field of the Job, effectively
     resetting the ActiveDeadlineSeconds timer too. Defaults to false.

     This field is beta-level, gated by SuspendJob feature flag (enabled by
     default).
```

<br>

**💻 실습 1** : ttlSecondsAfterFinished

`mypi.yaml`

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: mypi
spec:
  template:
    spec:
      containers:
        - image: perl
          name: mypi
          command: ["perl", "-Mbignum=bpi","-wle", "print bpi(2000)"]  #pi의 값을 2000자리까지 계산
      restartPolicy: OnFailure
  ttlSecondsAfterFinished: 10
```

```shell
$ kubectl create -f mypi.yaml
```

```shell
NAME                          COMPLETIONS   DURATION   AGE
job.batch/mypi                0/1           6s         6s

NAME                             READY   STATUS      RESTARTS   AGE
pod/mypi--1-jh4qz                1/1     Running     0          6s
```

10초 후에 job이 삭제되는 것을 확인할 수 있다. 

```shell
NAME                          COMPLETIONS   DURATION   AGE
job.batch/mypi                0/1           6s         6s

NAME                             READY   STATUS      RESTARTS   AGE
```

다만 삭제된 후 로그는 남지 않기 때문에 필요한 경우 별도로 저장해야한다.

<br>

**💻 실습 2** : completions

`completions` 횟수는 `parellism`보다 횟수가 작거나 같아야한다. 

`mypi-comp.yaml`

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: mypi-comp
spec:
  completions: 3
  template:
    spec:
      containers:
        - image: perl 
          name: mypi
          command: ["perl", "-Mbignum=bpi","-wle", "print bpi(1500)"] 
      restartPolicy: OnFailure
```

```shell
$ kubectl create -f mypi-comp.yaml
```

3번을 반복한 후 작업이 완전히 완료(COMPLETIONS)되는 것을 확인할 수 있다.

```shell
$ kubectl get job,po                              

NAME                  COMPLETIONS   DURATION   AGE
job.batch/mypi-comp   3/3           25s        79s

NAME                     READY   STATUS      RESTARTS   AGE
pod/mypi-comp--1-b629n   0/1     Completed   0          79s
pod/mypi-comp--1-nd4ql   0/1     Completed   0          63s
pod/mypi-comp--1-t85b9   0/1     Completed   0          71s
```

<br>

**💻 실습 3** : parellel

`mypi-para.yaml`

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: mypi-para
spec:
  completions: 3
  parallelism: 3
  template:
    spec:
      containers:
        - image: perl 
          name: mypi
          command: ["perl", "-Mbignum=bpi","-wle", "print bpi(1500)"] 
      restartPolicy: OnFailure
```

```shell
$ kubectl create -f mypi-para.yaml
```

`parallelism`을 설정함으로써 작업이 병렬로 처리됨을 확인할 수 있다.

```shell
$ kubectl get job,po
NAME                          COMPLETIONS   DURATION   AGE
job.batch/mypi-para           0/3           8s         8s

NAME                             READY   STATUS      RESTARTS   AGE
pod/mypi-para--1-lv6tg           1/1     Running     0          8s
pod/mypi-para--1-qsf9v           1/1     Running     0          8s
pod/mypi-para--1-txvkx           1/1     Running     0          8s
```

<br>

**💻 실습 3** : suspend

실습1에서 생성했던 `mypi.yaml`을 실행시킨다.

```shell
$ kubectl create -f mypi.yaml
```

`kubectl edit`을 통해 `suspend`의 값을 `True`로 변경시킨다.

```shell
$ kubectl edit job mypi
...
suspend: True
...
```

```shell
job.batch/mypi edited
```

잡이 `Terminating`된 것을 확인할 수 있다. 

```shell
$ kubectl get pods           
NAME                         READY   STATUS              RESTARTS   AGE
mypi--1-6x9s2                1/1     Terminating         0          10s
```

<br>

<br>

## ✔️ CronJob

[크론잡 | Kubernetes](https://kubernetes.io/ko/docs/concepts/workloads/controllers/cron-jobs/)

`CronJob`은 쿠버네티스 `v1.21` 부터 stable이 되었다.

***크론잡은* 반복 일정에 따라 [잡](https://kubernetes.io/ko/docs/concepts/workloads/controllers/job/)을 만든다.**

크론잡은 잡을 [크론](https://ko.wikipedia.org/wiki/Cron) 형식(포맷)으로 쓰여진 주어진 일정에 따라 주기적으로 동작시킨다.

<br>

**리소스 정의 방법 확인**

```shell
$ kubectl explain cj.spec                       
```

<br>

**☁️ 참고** : 다른 버전의 explain 확인하기

```shell
$ kubectl explain cj --api-version=batch/v1beta1
```

다음과 같이 `--api-version` 옵션을 사용하여 특정 버전의 정보를 확인할 수 있다

```shell
KIND:     CronJob
VERSION:  batch/v1beta1

DESCRIPTION:
     CronJob represents the configuration of a single cron job.
     ....
```

옵션을 지정하지 않고 `kubectl explain`하게 되면, `stable`버전이 있는 경우 stable 버전의 내용만 나온다.

이런 경우 최신 버전을 사용하지 않는다면,  `--api-version`을 사용할 수 있다.

<br>

#### 크론 스케줄 문법

```
# ┌───────────── 분 (0 - 59)
# │ ┌───────────── 시 (0 - 23)
# │ │ ┌───────────── 일 (1 - 31)
# │ │ │ ┌───────────── 월 (1 - 12)
# │ │ │ │ ┌───────────── 요일 (0 - 6) (일요일부터 토요일까지;
# │ │ │ │ │                                   특정 시스템에서는 7도 일요일)
# │ │ │ │ │
# │ │ │ │ │
# * * * * *
```

| 항목                   | 설명                     | 상응 표현 |
| ---------------------- | ------------------------ | --------- |
| @yearly (or @annually) | 매년 1월 1일 자정에 실행 | 0 0 1 1 * |
| @monthly               | 매월 1일 자정에 실행     | 0 0 1 * * |
| @weekly                | 매주 일요일 자정에 실행  | 0 0 * * 0 |
| @daily (or @midnight)  | 매일 자정에 실행         | 0 0 * * * |
| @hourly                | 매시 0분에 시작          | 0 * * * * |

예를 들면, 다음은 해당 작업이 매주 금요일 자정에 시작되어야 하고, 매월 13일 자정에도 시작되어야 한다는 뜻이다.

```
0 0 13 * 5
```

크론잡 스케줄 표현을 생성하기 위해서 [crontab.guru](https://crontab.guru/)와 같은 웹 도구를 사용할 수도 있다.

<br>

**💻 실습** : 크론잡 생성 및 확인

`mypi-cj.yaml`

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: mypi-cj
spec: 
  schejule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: mypi
              image: perl
              command: ["perl", "-Mbignum=bpi","-wle", "print bpi(1500)"] 
          restartPolicy: OnFailure  
```

`Job`과 마찬가지로, `CronJob`도 컨트롤러 레이블셀렉터, 파드 레이블을 설정하지 않는다.

`watch`로 확인했을 때 1분마다 실행되는 것을 확인할 수 있다.

```shell
 kubectl get cj,pod                           

NAME                    SCHEDULE    SUSPEND   ACTIVE   LAST SCHEDULE   AGE
cronjob.batch/mypi-cj   * * * * *   False     1        9s              3m36s

NAME                            READY   STATUS      RESTARTS      AGE
pod/mypi-cj-27548971--1-qd4tf   0/1     Completed   0             3m9s
pod/mypi-cj-27548972--1-zb8d2   0/1     Completed   0             2m9s
pod/mypi-cj-27548973--1-5ps2v   0/1     Completed   0             69s
pod/mypi-cj-27548974--1-6hfmx   1/1     Running     0             9
```

여기에서 또 한가지 알 수 있는 것은,

**`CronJob`은 기본적으로 4개의 `job`만 가지고 있고, 오래된 것은 지워버린다**는 것이다.

<br>

##### successfulJobsHistoryLimit

- (정상적으로 종료된) pod 정보를 몇개까지 가지고 있을 것인가
- default는 3개이며, 최대는 4개까지 가능하다
- 실행중인 것은 포함되지 않기 때문에, 한번에 여러개 실행되고 있으면 여러개의 정보를 가질 수 있다.

```shell
$ kubectl explain cj.spec.successfulJobsHistoryLimit
KIND:     CronJob
VERSION:  batch/v1

FIELD:    successfulJobsHistoryLimit <integer>

DESCRIPTION:
     The number of successful finished jobs to retain. Value must be
     non-negative integer. Defaults to 3.
```

default가 3개였기 때문에, 바로 윗 실습에서 `Completed` 상태의 크론잡을 3개까지 보관하는 것이었다.

앞서 살펴봤던 잡은 따로 지정해주지 않으면 계속 남아있었는데, 크론잡은 이와같이 히스토리에 제한이있어서 계속 늘어날 일은 없다

<br>

##### failedJobHistoryLimit

- 실패한 파드 정보를 몇개까지 가지고 있을 것인가
- default는 1개이다.

```shell
$ kubectl explain cj.spec.failedJobsHistoryLimit
KIND:     CronJob
VERSION:  batch/v1

FIELD:    failedJobsHistoryLimit <integer>

DESCRIPTION:
     The number of failed finished jobs to retain. Value must be non-negative
     integer. Defaults to 1.
```

<br>

##### concurrencyPolicy

```shell
$ kubectl explain cj.spec.concurrencyPolicy
KIND:     CronJob
VERSION:  batch/v1

FIELD:    concurrencyPolicy <string>

DESCRIPTION:
     Specifies how to treat concurrent executions of a Job. Valid values are: -
     "Allow" (default): allows CronJobs to run concurrently; - "Forbid": forbids
     concurrent runs, skipping next run if previous run hasn't finished yet; -
     "Replace": cancels currently running job and replaces it with a new one
```

- 동시 정책

-  `Allow`(허용) ,`Forbid`(금지), `Replace`(대체) 가 있으며, default는 `Allow`이다.
-  `Forbid` : 동시 작업을 금지하며, 이미 **실행중인 것이 있어서 Forbid된 경우 실패로 간주**한다.
-  `Replace` : 실행을 시도할 때, 이미 실행중인 것이 있으면 실행하던 것을 종료시키고 새로운 것을 실행시킨다~~~~~~~~~~~~~
-  동시 작업이 허용되어있으면 상관없으나, 대부분 그렇지 않고, 동시 작업이 허용되지 않는 데이터, 애플리케이션의 경우 문제가 생길 수 있다
-  애플리케이션의 성격에 따라 적절하게 사용해야한다.

<br>

**💻 실습** : concurrencyPolicy `Forbid`

`sleep-cj.yaml`

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: sleep-cj
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: sleep
              image: ubuntu
              command: ["sleep", "80"]
          restartPolicy: OnFailure
  concurrencyPolicy: Forbid
```

```shell
$ kubectl creat -f sleep-cj.yaml
```

스케쥴링 시간이 지났음에도, `concurrencyPolicy: Forbid`로 설정되어있어서 그냥 넘어가는 것을 확인할 수 있다.

```shell
$ kubectl get cj,po                            k8s-node1: Thu May 19 13:34:03 2022

NAME                     SCHEDULE    SUSPEND   ACTIVE   LAST SCHEDULE   AGE
cronjob.batch/sleep-cj   * * * * *   False     1        63s             86s

NAME                             READY   STATUS    RESTARTS   AGE
pod/sleep-cj-27549453--1-xnkqx   1/1     Running   0          63s
```

실행되고 있던 것이 완료된 후에 다음 것이 실행되는 것을 확인할 수 있다.

```shell
$ kubectl get cj,po                            k8s-node1: Thu May 19 13:35:28 2022

NAME                     SCHEDULE    SUSPEND   ACTIVE   LAST SCHEDULE   AGE
cronjob.batch/sleep-cj   * * * * *   False     1        88s             2m51s

NAME                             READY   STATUS      RESTARTS   AGE
pod/sleep-cj-27549453--1-xnkqx   0/1     Completed   0          2m28s
pod/sleep-cj-27549454--1-rj77m   1/1     Running     0          65s
```

<br>

**💻 실습** : concurrencyPolicy `Replace`

`sleep-cj.yaml`

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: sleep-cj
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: sleep
              image: ubuntu
              command: ["sleep", "80"]
          restartPolicy: OnFailure
  concurrencyPolicy: Replace
```

```shell
$ kubectl create -f sleep-cj.yaml
```

스케쥴링 시간이 되면, 기존의 것을 종료 `Terminating`하고, 새로운 것을 실행하는 것을 확인할 수 있다.

```shell
$ kuubectl get cj,pod                           k8s-node1: Thu May 19 13:43:06 2022

NAME                     SCHEDULE    SUSPEND   ACTIVE   LAST SCHEDULE   AGE
cronjob.batch/sleep-cj   * * * * *   False     1        6s              4m49s

NAME                             READY   STATUS        RESTARTS   AGE
pod/sleep-cj-27549462--1-rwx57   1/1     Terminating   0          66s
pod/sleep-cj-27549463--1-st54s   1/1     Running       0          6s
```

<br>

앞서 설명했듯이, **포비드 상태에서 잡을 실행하지못하는 것은 실패로 간주**한다.

모든 크론잡에 대해 크론잡 컨트롤러는 마지막 일정부터 일정부터 지금까지 얼마나 많은 일정이 누락되었는지 확인하며,

**크론잡은 100회 이상의 일정이 누락되면, 중단된다.** 그리고 아래와 같은 에러 로그를 남긴다.

```shell
Cannot determine if job needs to be started. Too many missed start time (> 100). Set or decrease .spe
```

<br>

##### startingDeadlineSeconds

- 스케쥴링되는 시점으로부터 과거에 얼마(시간)동안 실패한 작업이 있는 지 없는지 체킹
- 예: 스케쥴링 시점으로부터 과거의 100초 동안 실패한 작업이 있는지 확인

```shell
$ kubectl explain cj.spec.startingDeadlineSeconds
KIND:     CronJob
VERSION:  batch/v1

FIELD:    startingDeadlineSeconds <integer>

DESCRIPTION:
     Optional deadline in seconds for starting the job if it misses scheduled
     time for any reason. Missed jobs executions will be counted as failed ones.
```

