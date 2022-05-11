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

![2](https://user-images.githubusercontent.com/64996121/160634720-44c93e52-568c-4cb6-bf04-5f47e7ada165.png)


4)버킷 이름 작성 및 리전(서울) 선택

![3](https://user-images.githubusercontent.com/64996121/160634744-5c7fc8e7-fd82-4156-8c61-82e2ce2df2f0.png)


5)이외에는 별도의 수정 없이 버킷 만들기 클릭

![4](https://user-images.githubusercontent.com/64996121/160634754-b6d9d071-ffb4-4841-af1e-67126df77fd4.png)

6)버킷이 생성된 것을 확인할 수 있음

![5](https://user-images.githubusercontent.com/64996121/160634769-9236b224-4660-4ece-ad5f-5399c4656fde.jpg)

7)버킷에 들어가서 업로드 클릭

![6](https://user-images.githubusercontent.com/64996121/160635657-306c4a11-e0d3-4f1c-8ed3-b21bb49eb85f.png)

8)파일 추가 후 업로드 클릭 (글쓴이는 평소 좋아하는 영화 고양이의 보은 이미지 업로드)

![7](https://user-images.githubusercontent.com/64996121/160635618-4ec87050-aafe-4995-9ffe-35957a602dba.png)

9)버킷에 파일이 업로드 된 것을 확인할 수 있음

![8](https://user-images.githubusercontent.com/64996121/160635551-142ab282-237a-477f-82a3-c0863c155c15.png)

10)파일 클릭 후 객체 URL 확인

![9](https://user-images.githubusercontent.com/64996121/160635464-ce6b50a2-ae58-4bdf-ae89-a6832ce0715d.jpg)

11)객체 URL 로 접속시도 - 실패(AccessDenied)

![10](https://user-images.githubusercontent.com/64996121/160635386-1f55678d-b6ba-4062-ad49-fb1d6d9d7110.png)

- 버킷 액세스가 **퍼블릭이 아니기 때문**
  - **S3는 default로 사용자가 S3버킷에 접근 불가능하도록 설정**되어있음(비공개)
  - 퍼블릭으로 설정해주어야함


![image-20220329230932091](https://user-images.githubusercontent.com/64996121/160635331-0f24095a-aae7-45b8-a495-d30377289e2f.png)

12)버킷 권한 설정하기

- 모든 퍼블릭 액세스 차단 설정을 해제

![13](https://user-images.githubusercontent.com/64996121/160634911-39601f29-cb14-4725-8652-c659541daaac.png)


13)버킷 정책 편집

![14](https://user-images.githubusercontent.com/64996121/160635086-267af463-11fc-47f8-afaf-ea6656c1f09a.png)

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

![15](https://user-images.githubusercontent.com/64996121/160635055-dfbd5648-eed1-4b81-86c2-5fa9246b7943.png)

14)변경 사항 저장 후 다시 객체 URL 로 접속

- 정상적으로 접근되는 것을 확인할 수 있음

![16](https://user-images.githubusercontent.com/64996121/160634987-a9976f15-10ea-4181-beb3-937a22380c12.png)

<br>

<br>

<h2>파일 삭제</h2>

1)삭제를 원하는 파일 선택 후 "삭제" 클릭

![삭제1](https://user-images.githubusercontent.com/64996121/160635980-b16a4767-443a-475b-b313-3bc720ed702a.png)

2)지정된 객체 확인 후 객체 삭제

![삭제2](https://user-images.githubusercontent.com/64996121/160635991-764761d4-4cc2-4ae9-a36d-ab7cee102ffc.png)

3)정상적으로 삭제된 것을 확인

![삭제3](https://user-images.githubusercontent.com/64996121/160636002-bc55c0d5-1cbb-405a-a723-d6895d4ea971.png)



❕ 버킷을 삭제할 때는 먼저 오브젝트를 삭제해야함
