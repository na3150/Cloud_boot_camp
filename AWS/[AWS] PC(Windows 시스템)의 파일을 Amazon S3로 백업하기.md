<h1> [AWS] PC(Windows 시스템)의 파일을 Amazon S3로 백업하기</h1>



1)AWS 로그인

2)S3 접속

3)backup을 위한 버킷 생성

![image-20220330095016234](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220330095016234.png)

4)AWS CLI 사용을 위해 IAM 계정 생성

- IAM - [사용자] - [사용자 추가]

![image-20220330095039028](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220330095039028.png)

5)[사용자 이름] - [프로그래밍 방식 액세스]

![image-20220330095120246](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220330095120246.png)

6)[그룹 이름] - [AdministratorAccess]

![image-20220330095144971](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220330095144971.png)

7)그룹 생성 후 사용자 추가

- 사용자 만들기 및 .csv 파일 다운로드

![image-20220330095211502](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220330095211502.png)

![image-20220330095308350](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220330095308350.png)

- csv 파일 구성

```shell
User name	Password	Access key ID	Secret access key	Console login link
```

8)[링크](#https://docs.aws.amazon.com/cli/latest/userguide/getting-started-version.html)에서 aws cli 버전 2 다운로드

![image-20220330095612527](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220330095612527.png)

9)cmd창 열기

- `aws --version'

```shell
:\Users\USER>aws --version
aws-cli/2.0.30 Python/3.7.7 Windows/10 botocore/2.0.0dev34
```

- aws configure
  - csv 파일에서 확인한 인증정보 입력

```shell
C:\Users\USER>aws configure
AWS Access Key ID [****************RJEA]: 
AWS Secret Access Key [****************ugKE]:
Default region name [ap-northeast-2]: ap-northeast-2
Default output format [json]: json
```

- `aws s3 ls` 명령을 통해 버킷 확인

```shell
C:\Users\USER>aws s3 ls
2022-03-30 09:37:42 nayoung-desktop-backup-test
```

- 원하는 경로에 backup 폴더를 생성하기
  - 글쓴이는 awsbackup-test
- `aws s3 sync [백업할 로컬 파일 경로] [s3://버킷명]` 명령 입력

```shell
C:\Users\USER>aws s3 sync C:\Users\USER\awsbackup-test s3://nayoung-desktop-backup-test
upload: awsbackup-test\test.txt to s3://nayoung-desktop-backup-test/test.txt
```

10)s3 backup 버킷 확인

- 정상적으로 sync가 된 것을 확인할 수 있음

![image-20220330100025644](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220330100025644.png)

