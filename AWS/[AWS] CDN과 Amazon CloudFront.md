<h1> [AWS] CDN과 Amazon CloudFront</h1>



<h3>📌INDEX</h3> 

- [CDN이란?](#cdn이란)
- [Amazon CloudFront](amazon-cloudfront)
- [S3를 이용한 정적 웹 호스팅](#s3를-이용한-정적-웹-호스팅)
- [S3와 CloudFront 연동하기](#s3와-cloudfront-연동하기)

<br>

<br>

<h2>CDN이란?</h2>

CDN은 Contenst Delivery Network 또는 Content Distribution Network의 약자로  콘텐츠를 효율적으로 전달하기 위해 여러 노드를 가진 네트워크에 데이터를 저장하여 제공하는 시스템

- 주요 ISP(Internet Services Provider)의 CDN 서버에 콘텐츠를 분산시키고 **유저의 네트워크 경로 상 가장 가까운 곳의 서버로부터 콘텐츠를 전송받도록** 하여 트래픽이 특정 서버에 집중되지 않고 각 지역 서버로 분산되도록 하는 기술
- 동작 원리
  - 콘텐츠에 대한 요청이 발생하게 되면 사용자(End-User)와 가장 가까운 위치에 배치된 CDN서버로 사용자를 접속시키게 됨
  - **CDN 서버는 요청된 파일의 캐싱된(사전 저장된) 콘텐츠를 사용자에게 전달**
  - 서버가 파일을 찾는데 실패했거나 콘텐츠가 너무 오래된 경우에는 오리진(원본) 서버에서 파일을 조회하여 사용자에게 전달하며, 이후 동일한 콘텐츠를 요청받게 되면 캐싱된 데이터에서 콘텐츠를 전송하므로 보다 빠르게 전달할 수 있음
- CDN 캐싱 방식
  - Static Caching : 사용자의 요청이 없어도 Origin Server에 있는 Contents를 운영자가 미리 Cache Services에 복사함
  - Dynamic Caching : 최초에는 Cache 서버에 콘텐츠가 없고, 사용자가 콘텐츠를 요청하여 Cache 서버에 콘텐츠가 있는지 여부를 확인

<br>

<br>

<h2>Amazon CloudFront</h2>

Amazon CloudFront는 짧은 지연 시간과 빠른 전송 속도롤 최종 사용자에게 데이터, 동영상, 애플리케이션 및 API를 안전하게 전송하는 **클로벌 콘텐츠 전송 네트워크(CDN) 서비스**

- 고도로 프로그래밍 가능하고 안전한 콘텐츠 전송 네트워크(CDN)

- API, AWS Management Console, AWS CloudFormation, CLI 및 SDK 를 사용하여 CloudFront 시작 가능
- 주요 특징
  - 정적/동적 콘텐츠 가속 서비스
  - HTTP/HTTPS 서비스, Custon SSL 지원
  - 커스텀 오류 응답
  - 쿠키/헤어 오리진 서버 전달
  - 다양한 통계 보고서
  - 콘텐츠 보안 : Signed URL, Signed Cookie
  - API 호출 감사 : CloudTrail 연계
  - 업로드 가속
- Amazon CloudFront 연결 가능한 오리진(Origins) 서비스
  - Amazon S3 버킷(Bucket)
  - Amazon EC2 Instance
  - Elastic Load Balancer
  - 사용자 지정 오리진(다른 위치에서 서비스 중인 HTTP 웹 서버 등)
- 주요 기능 
  - 정적 콘텐츠에 대한 캐싱 서비스와 비디오 스트리밍 서비스
  - 동적 콘텐츠에 대한 캐싱 서비스
  - 다양한 보안 서비스
  - 비용 최적화를 통한 비용 절감
- 프리 티어(Free Tier)
  - 데이터 송신 50GB와 HTTP/S 요청 2백만건

<br>

<br>

<h2>S3를 이용한 정적 웹 호스팅</h2>

- 실습 주제 : S3 버킷을 통해 부트스트랩을 이용한 반응형 페이지 생성 
  - CloudFront를 통한 속도 향상을 확인하기 위해 이용할 예정
- [여기](https://startbootstrap.com/)에서 부트스트랩(bootstrap) 템플릿 다운



**1) S3 버킷 만들기**

- 버킷 이름 및 리전 설정

![a](https://user-images.githubusercontent.com/64996121/161940916-cd144609-b685-47d0-b7f6-25baa59ccbc5.png)



- 모든 퍼블릭 액세스 차단 해제 및 퍼블릭 상태가 될 수 있음을 확인 

![3](https://user-images.githubusercontent.com/64996121/161940990-ee6b3010-1d54-4143-add0-7867e46c83c2.png)

- 업로드



**2) 버킷 정책 수정**

- [생성한 버킷 클릭] - [권한] - [버킷 정책] - [편집] - [정책 생성기]
-  Type of Policy : S3 
- Principal : *
- Actions : GetObject 선택
- 버킷 ARN 붙여넣기

![정책 생성기](https://user-images.githubusercontent.com/64996121/161941096-5d3ea721-8197-4ed0-b97c-fa2791d9bc47.png)

- [Add Statement] - [JSON Document 복사]

![정책생성기2](https://user-images.githubusercontent.com/64996121/161941110-3e73bb50-5961-42a4-82a1-9732245a533e.png)

- 복사한 JSON 을 정책에 붙여넣기

![정책생성기3](https://user-images.githubusercontent.com/64996121/161941126-35aee301-b3f4-49d5-b007-a9c12dfdfded.png)


**3) 버킷에 파일 업로드**

- 글쓴이는 clean-blog 템플릿 사용함

- 다운 받은 파일 압축 해제 후 업로드

![4](https://user-images.githubusercontent.com/64996121/161941163-2cc393f9-8a21-4690-b71b-d1ace00b8d2f.png)



**4) 정적 웹 호스팅 활성화**

- 정적 웹 사이트 호스팅은 S3버킷을 홈페이지처럼 사용할 수 있는 기능
- [속성] - [정적 웹 호스팅] - [편집]
- 정적 웹 사이트 활성화
- 호스팅 유형 : 정적 웹 사이트 호스팅
- 인덱스 문서 : index.html

![6](https://user-images.githubusercontent.com/64996121/161941197-03385974-a1a2-4315-b7b7-ca8ff53c00b4.png)



**5) 정적 웹 호스트 엔트포인트로 접속**

![ㄴㅇㅎㅁㄴ](https://user-images.githubusercontent.com/64996121/161941294-201d42fc-d229-45d6-b8df-29e1c86b79e2.png)

- CloudFront와의 비교를 위해 속도확인(개발자 모드 F12)
  - 속도 : 632ms

![부트스트랩 완성(f12)](https://user-images.githubusercontent.com/64996121/161941390-3af35350-ad9a-45e9-b2f6-dfc75488cc33.png)

<br>

<br>

<h2>S3와 CloudFront 연동하기</h2>

- 좀 전에 생성한 반응형 웹페이지를 CloudFront에 배포하기



**1) CloudFront 배포**

- [CloudFront] - [배포] - [배포 생성]

![ㄹㄹㄹ](https://user-images.githubusercontent.com/64996121/161941425-c2143fcf-ebd2-4516-a26a-2eaad25e525f.png)

![ㄹㄹㄹ](https://user-images.githubusercontent.com/64996121/161941482-292670b3-d267-4213-aa01-e8aa3863e82a.png)



**2) CloudFront 배포 도메인으로 접속하기**

![8](https://user-images.githubusercontent.com/64996121/161941593-635af020-7b56-4241-b8d4-bb187bb56ac1.png)

- S3 버킷에 파일을 드래그하여(하나의 폴더가 묶이지 않은 상태로) 업로드했다면 경로 뒤에 index.html 붙여주기!

![9](https://user-images.githubusercontent.com/64996121/161941555-8d73ec53-6780-4d5e-90ba-33289327401e.png)



**3) 속도 확인하기**

- 속도 : 337 ms
- 632ms -> 337ms 로, CloudFront로 배포함으로써 속도가 훨씬 빨라진 것을 확인할 수 있음

![10](https://user-images.githubusercontent.com/64996121/161941704-afb2ea26-29f4-405f-80da-ffb082f918a8.png)

