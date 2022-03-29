<h1> [AWS] Amazon S3에 파일 업로드 및 삭제하기</h1>

<h3>📌INDEX</h3>

- [파일 업로드](#파일-업로드)
- [파일 삭제](#파일-삭제)

<br>

<br>

<h2>파일 업로드</h2>

1)AWS 계정에 로그인

2)AWS S3에 접속

3)버킷 만들기 클릭

![image-20220329230809977](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329230809977.png)

4)버킷 이름 작성 및 리전(서울) 선택

![image-20220329230844978](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329230844978.png)

5)이외에는 별도의 수정 없이 버킷 만들기 클릭

![image-20220329230906350](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329230906350.png)

6)버킷이 생성된 것을 확인할 수 있음

![image-20220329230932091](C:\Users\USER\Desktop\image-20220329230932091.png)

7)버킷에 들어가서 업로드 클릭

![image-20220329230954574](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329230954574.png)

8)파일 추가 후 업로드 클릭 (글쓴이는 평소 좋아하는 영화 고양이의 보은 이미지 업로드)

![image-20220329231015665](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329231015665.png)

9)버킷에 파일이 업로드 된 것을 확인할 수 있음

![image-20220329231058952](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329231058952.png)

10)파일 클릭 후 객체 URL 확인

![image-20220329231116316](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329231116316.png)

11)객체 URL 로 접속시도 - 실패(AccessDenied)

![image-20220329231155086](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329231155086.png)

- 버킷 액세스가 **퍼블릭이 아니기 때문**
  - **S3는 default로 사용자가 S3버킷에 접근 불가능하도록 설정**되어있음(비공개)
  - 퍼블릭으로 설정해주어야함

![image-20220329231404038](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329231404038.png)

12)버킷 권한 설정하기

- 모든 퍼블릭 액세스 차단 설정을 해제

![image-20220329231539066](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329231539066.png)

![image-20220329231547990](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329231547990.png)

13)버킷 정책 편집

![image-20220329231613086](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329231613086.png)

- 정책 변경 : https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteAccessPermissionsReqd.html 에서 복사해서 사용

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::Bucket-Name/*"
            ]
        }
    ]
}
```

![image-20220329231620803](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329231620803.png)

14)변경 사항 저장 후 다시 객체 URL 로 접속

- 정상적으로 접근되는 것을 확인할 수 있음

![image-20220329231725698](C:\Users\USER\AppData\Roaming\Typora\typora-user-images\image-20220329231725698.png)

<br>

<br>

<h2>파일 삭제</h2>

1)삭제를 원하는 파일 선택 후 "삭제" 클릭

![삭제1](C:\Users\USER\Desktop\삭제1.png)

2)지정된 객체 확인 후 객체 삭제

![삭제2](C:\Users\USER\Desktop\삭제2.png)

3)정상적으로 삭제된 것을 확인

![삭제3](C:\Users\USER\Desktop\삭제3.png)



❕ 버킷을 삭제할 때는 먼저 오브젝트를 삭제해야함