<h1> [AWS] Amazon RDS(Relational Database Services)란?</h1>



<h3>📌INDEX</h3>

- [Amazon RDS란?](#amazon-rds란)
- [Amazon RDS의 주요 특징](#amazon-rds의-주요-특징)
- [AWS에서 클라우드 데이터베이스 서비스 선택](#aws에서-클라우드-데이터베이스-서비스-선택) 

<br>

<br>

<h2>Amazon RDS란?</h2>

- Amazon RDS는 Relational Database Services의 약자로, **클라우드에서 관계형 데이터베이스를 더욱 간편하게 설정, 운영 및 확장할 수 있는 서비스**이다
- 주로 사용되는 6개의 데이터베이스 엔진 중에서 선택할 수 있는 아마존 관계형 데이터베이스 서비스
- 하드웨어 프로비저닝, 데이터베이스 설정, 패치 및 백업과 같은 시간 소모적인 관리 작업을 자동화
- 비용 효율적이고 크기 조정 가능한 데이터베이스 서비스 제공

- 특징
  - 관리 용이성 : 인프라의 프로비저닝/DB 설치 및 유지 관리 불필요
  - 뛰어난 확장성 : 서비스 중단 없이 서버 및 스토리지 확장 기능
  - 가용성 및 내구성 : 안정성이 뛰어난 인프라 제공(멀티 AZ)
  - 빠른 속도 : SSD 지원 스토리지 옵션 및 고성능 OLTP에 최적화된 옵션과  비용 효울적 범용 사례에서 옵션 선택 가능
  - 보안 : 데이터베이스와 네트워크에 대한 액세스를 손쉽게 제어
- 프리티어(Free Tier)
  - MySQL, PostgreSQL, MariaDB, Oracle BYOL, SQL Server 지원
  - RDS 단일 AZ db.t2.micro 인스턴스를 750시간 무료 사용
  - 가입 후 12개월 이후에 종료됨
- 공식문서 : [Amazon RDS란?](https://docs.aws.amazon.com/ko_kr/AmazonRDS/latest/UserGuide/Welcome.html)

<br>

<br>

<h2>Amazon RDS의 주요 특징</h2>

**유연한 인스턴스 및 스토리지 확장**

- RDS는 다양한 CPU/메모리 옵션을 제공
- CloudWatch와 연계를 통해 트래픽에 따른 증설 및 사양의 축소가 가능
- DB의 저장공간인 스토리지를 필요에 따라 유연하게 확장 가능
- 접속이 빈번하지 않은 작은 워크로드의 경우 Magnetic을 사용하여 저렴한 비용으로 서비스 가능



**손쉽게 사용 가능한 백업 및 복원 기능**

- RDS는 자동 백업 설정을 통해 손쉽게 백업이 가능
- 특정 시점으로 손쉽게 복구 할 수 있는 기능 제공
- 데이터베이스는 최대 35일까지 데이터를 보존 가능
- 백업된 스냅샷(Snapshot)을 통해 Database 생성 가능



**멀티 AZ(Availability Zone)을 통한 고가용성 확보**

- RDS는 멀티 AZ 기능을 활용하여 Region 내 AX 간 데이터베이스 동기화(Synchronization) 구성 가능
- 주요 장애 상황 발생 시 자동으로 데이터베이스 Failover를 구생할 수 있도록 고가용성을 지원하며, 리플리케이션을 통한 가용성 지원 가능
- MySQL은 읽기 트래픽을 자동 관리하는 Read Replica로 분산 서비스를 제공할 수 있음
  - 이를 통해 워크로드로 발생되는 읽기 서비스(Database Select)에 대한 부하를 분산처리 가능
- 리전 간 데이터 이전 손쉽게 가능



**RDS 암호화(Encryption) 옵션을 통한 보안성 강화**

- 모든 RDS는 옵션을 통한 One-Click을 통해 데이터에 대한 암호화 기능을 제공
  - 데이터 백업, 스냅샷, Read Replica에도 적용됨
- KMS를 통해 사용자가 생성하고 관리하는 키(Key)의 사용이 가능
  - 다만, RDS DB 생성 시 암호화 Enable 이후 암호화 Disable은 불가능하며, 암호화 DB에서만 암호화 Read Replica를 생성할 수 있음
- 암호화되지 않은 백업을 암호화된 DB로의 데이터 복구는 불가능



**Database Migration 서비스**

- RDS는 AWS Database Migration Services를 통해 동종 혹은 다른 DB엔진으로부터 RDS로 데이터에 대한 Migration을 지원
- EC2 또는 RDS 간의 데이터 리플리케이션을 통해 원하는 시점에 비용 효율적인 데이터베이스에 대한 데이터 이전을 지원

<br>

<br>

<h2>AWS에서 클라우드 데이터베이스 서비스 선택</h2>

**Amazon EC2 인스턴스에서 직접 DB 설치**

- 기존 On-Premise에 사용하던 데이터베이스를 그대로 사용
- 라이선스에 주의(별도로 클라우드용 라이선스를 운영하는 경우가 있음)



**AWS에서 제공되는 관리형 데이터베이스 사용**

- Amazon RDS : 관계형 데이터베이스
- Amazon DynamoDB : NoSQL 기반의 중단 없는 확장성을 제공하는 데이터베이스
- AmazonRedShift : 대용량 병렬 페타바이트급 데이터웨어하우스(DataWarehouse 서비스)
- Amazon Aurora : [Amazon Aurora란?](https://docs.aws.amazon.com/ko_kr/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html)

<br>
<br>

**📋 실습**

[자습서: 웹 서버 및 Amazon RDS DB 인스턴스 생성 - Amazon Relational Database Service](https://docs.aws.amazon.com/ko_kr/AmazonRDS/latest/UserGuide/TUT_WebAppWithRDS.html)

*주의 : public subnet의 instance는 퍼블릭 IP 할당 활성화, private subnet의 인스턴스는 퍼블릭 IP 할당 비활성화

![             단일 VPC 시나리오         ](https://docs.aws.amazon.com/ko_kr/AmazonRDS/latest/UserGuide/images/con-VPC-sec-grp.png)
