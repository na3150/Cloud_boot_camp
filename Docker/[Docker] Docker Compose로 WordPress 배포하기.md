# [Docker] Docker Compose로 WordPress 배포하기

<br>

**환경 구성**

먼저 실습을 진행할 디렉토리를 생성한다. 

```shell
$ mkdir wp
$ cd wp
```

생성 및 구성하는 `docker-compose.yaml`을 작성한다. 

`docker-compose.yaml`

```yaml
version: "3"

services:
  wp-db:
    image: mysql:5.7
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: P@ssw0rd
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpadm
      MYSQL_PASSWORD: P@ssw0rd
    volumes:
      - wp-db-vol:/var/lib/mysql
    networks:
      - wp-net

  wp-web:
    depends_on:
      - wp-db
    image: wordpress:5-apache
    restart: always
    environment:
      WORDPRESS_DB_HOST: wp-db
      WORDPRESS_DB_USER: wpadm
      WORDPRESS_DB_PASSWORD: P@ssw0rd
      WORDPRESS_DB_NAME: wordpress
    ports:
      - "80:80"
    volumes:
      - wp-web-vol:/var/www/html
    networks:
      - wp-net

volumes:
  wp-db-vol:
  wp-web-vol:

networks:
  wp-net:
```

서비스들끼리는 서로 어는 것이 먼저 만들어질지 모르기 때문에 `depends_on` 지시어를 사용한다. 

관련된 내용은 `Docker Hub`의 `WordPress` 이미지 정보에서도 확인할 수 있다. 

<br>

다음으로 docker compose를 실행하자.

```shell
$ docker compose up -d 
$ docker compose ps   
NAME                COMMAND                  SERVICE             STATUS              PORTS
wp-wp-db-1          "docker-entrypoint.s…"   wp-db               running             33060/tcp
wp-wp-web-1         "docker-entrypoint.s…"   wp-web              running             0.0.0.0:80->80/tcp, :::80->80/tcp
```

<br>

**접속 확인**

![image-20220513092318546](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220513092318546.png)

<br>

**삭제**

`-v` 옵션을 사용하여 볼륨까지 함께 삭제한다. 

```shell
$ docker compose down -v
```

<br>

<br>