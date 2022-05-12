# [Docker] Docker에 node.js 배포하기

<br>

### 📌Index

- [간단한 Node.js 작성해보기](#간단한-nodejs-작성해보기)

- [Node.js web app으로 Docker image 만들기](#nodejs-web-app으로-docker-image-만들기)

<br>

 [Node.js](https://nodejs.org/en/)란확장성 있는 네트워크 애플리케이션(특히 서버 사이드) 개발에 사용되는 소프트웨어 플랫폼이다.

<br>

<br>

## 간단한 Node.js 작성해보기

먼저 `node.js` 를 사용하기 위해 저장소를 추가하고 패키지를 설치하자

여기서는 버전16을 사용할 예정이다.

```shell
$ curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

다음으로 실습을 진행할 환경(디렉토리)를 구성하자.

```shell
$ mkdir -p node/web
$ cd node/web
```

<br>

[Getting Started Guide | Node.js (nodejs.org)](https://nodejs.org/en/docs/guides/getting-started-guide/) 을 참조하여 `app.js` 파일을 작성한다.

`app.js`

```shell
const http = require('http');

const hostname = '0.0.0.0';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World');
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
```

변수 `hostname`과 `port` 값을 가져와서 함수 `listen`이 실행되는 간단한 코드이다.

 `require('http')`에서 `http`는 `nodejs`로 웹앱을 만들 수 있는 라이브러리이고, 

외부에서 접속이 가능하도록 `hostname`은 `0.0.0.0` 로 설정한다.

<br>
다음으로 `app.js`을 실행한다.

```shell
$ node app.js
```

**접속 확인**

<br>

![image-20220512141514403](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220512141514403.png)

<br>

## Node.js web app으로 Docker image 만들기

[Dockerizing a Node.js web app](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/#dockerizing-a-node-js-web-app) 을 따라 진행해보자

`Dockerizing` 이란 docker로 이미지를 만드는 것으로, docker화 시킨다, 이미지를 만다는 의미이다.

<br>

먼저 [여기](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/#create-the-node-js-app) 를 참조하여 `package.json`을 작성하자. 파일 이름은 `package.json` 이어야한다. 

`package.json`

```json
{
  "name": "docker_web_app", #app의 이름
  "version": "1.0.0", #app의 버전
  "description": "Node.js on Docker",
  "author": "First Last <first.last@example.com>", #app 만든 사람
  "main": "server.js", #main이 되는 자바스크립트 파일
  "scripts": { #실행하는 방법 기술
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.16.1"
  }
}
```

`dependencies` 는 설치할 외부 패키지로 `express` 는 nodejs의 웹 프레임워크이다.

<br>

다음으로 `server.js` 파일을 작성한다. 

`server.js`

```shell
'use strict';

const express = require('express');

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/', (req, res) => {
  res.send('Hello World');
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);
```

`npm install` 명령은 `package.json` 의 `dependencies` 를 참조하여 패키지를 설치한다. (여기서는 `express`)

`npm install` 명령을 실행하면 패키지들의 목록을 가지고 있는 `package-lock.json` 파일이 생성된다. 

```shell
$ nmp install
```

`node.js` 는 무조건 `node_modules` 라는 디렉토리에 패키지를 설치한다. 따라서`node_modules` 는 반드시 노출되면 안된다.

<br>

다음으로 `.dockerignore` 파일을 작성하자. 이때, `node_modules` 는 반드시 제외되어야한다. 

`.dockerignore`

```shell
node_modules/
Dockerfile
.dockerignorefile
```

다음으로 이미지를 빌드하기 위한 `Dockerfile`을 작성하자.

`Dockerfile`

```shell
FROM node:16
WORKDIR /usr/src/app
COPY . .
RUN npm install
EXPOSE 8080
CMD ["node", "server.js"]
```

이제 이미지를 빌드하자.

```shell
$ docker build -t mynode .      
```

빌드된 이미지 `mynode`로 실행해보자.

```shell
$ docker run -d -p 80:8080 mynode
```

```shell
$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                                   NAMES
a77ee30d0e92   mynode    "docker-entrypoint.s…"   3 seconds ago   Up 2 seconds   0.0.0.0:80->8080/tcp, :::80->8080/tcp   cool_roentgen
```

**접속 확인**

<br>

![image-20220512142711192](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220512142711192.png)



