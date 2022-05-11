# [Docker] Docker에 Flask App 배포하기

<br>

### 📌Index

- [환경 구성](#환경-구성)
-  [Application 만들기](#application-만들기)
-  [Freeze](#freeze)

<br>

<br>

[Flask](https://flask.palletsprojects.com/en/2.1.x/)란 **마이크로 서비스 웹 프레임워크**로 간단한 웹 사이트, 혹은 간단한 API 서버를 만드는 데에 특화되어있다. 

(python 3.7 이상 필요)

<br>

<br>

## 환경 구성

`Flask` 환경 구성을 위해 아래의 3가지를 설치하자

- python3
- python3-pip
- python3-venv

`pip` 는 파이썬 패키지를 설치하고 관리하는 도구이다. 

- `pip` 는 `python2`의 패키지 관리자
- `pip3`는 `python3`의 패키지 관리자

```shell
$ sudo apt install python3-pip python3-venv
```

<br>

#### 가상 환경

가상환경(virtual environment)는 `Python`에만 존재하는 개념으로, 가상환경을 사용하면 **가상 환경에서만 패키지를 설치하고 관리**할 수 있다. `Flask`는 우리가 만드려는 App에만 필요하기 때문에 Global 전체에 설치하는 것이 불필요하고, 해당되는 App에만 사용할 수 있는 가상 환경을 만들고, **가상 환경에서만 사용할 수 있는 패키지를 따로 관리한다(Isolation)**

<br>

**가상환경 만들기**

가상환경을 위한 별도의 디렉토리를 만들어주는 것은 중요하다

```shell
$ mkdir -p /python/hello-flask
$ cd /python/hello-flask
```

<br>

**가상환경/프로젝트를 생성**

```shell
$ python3 -m venv venv
```

- `venv`는 파이썬이 관리하므로, 직접적으로 건들이지 않는 것이 좋음
- `-m venv`에서 `venv`는 모듈명(패키지명)이고, 뒤의 `venv`는 가상환경의 이름
- 가상환경의 이름을 꼭 `venv`로 설정할 필요는 없으나 일반적으로 `venv`로 지정
- **가상 환경에 패키지를 설치하면 `/venv/lib/site-packages/`에 설치됨(isolation)**

<br>

**가상환경 활성화**

```shell
$ . venv/bin/activate
```

- 가상환경 비활성화(가상환경에서 벗어나기) : `deactivate`

- 관리하는 패키지 목록 확인하기 : `pip3 list`
- **`(venv)` 를 통해 가상 환경에 들어온 것을 확인**
- 작업 디렉토리에서 가상환경을 활성화를 시켜줘야함
- 참고) 가상환경에서 디렉토리를 빠져나와도 가상환경은 유지됨
- 터미널을 닫았다가 다시 열면 가상환경에서 나와지기 때문에 꼭 promt를 통해 본인이 가상환경인지 확인해야함

<br>

**Flask 설치**

```shell
$ pip3 install Flask
```

<br>

<br>

## Application 만들기

#### Minimal Application

[a minimal application](https://flask.palletsprojects.com/en/2.1.x/quickstart/#a-minimal-application)을 참조하여, 아래와 같이 `hello.py` 파일을 작성하자.

`hello.py`

```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"
```

파일 내용 설명

- `from flask import Flask` : Flask 패키지를 가져옴
- `@app.route("/")` : `app.route` `decorator`로, root(/) 경로로 오면 아래의 함수를 실행하도록 설정 
  - Linux의 `DocumentRoot`라고 생각하면 이해하기 쉬울 것 같다
- `def hello_world()` : 함수정의, return 값만 있음

<br>

**Flask 실행**

```shell
$ export FLASK_APP=hello
$ flask run
 * Serving Flask app 'hello' (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: off
 * Running on http://127.0.0.1:5000 (Press CTRL+C to quit)
127.0.0.1 - - [11/May/2022 05:16:16] "GET / HTTP/1.1" 200 -
```

- `flask run` == `python3 -m flask run`

<br>

**접속 확인**

단, 개발중에 외부에 노출되면 위험하기 때문에, 

기본적으로 외부에서는 접속이 불가능하고 내부에서만 접속 가능하도록 구성되어있다.

```shell
$ curl localhost:5000
<p>Hello, World!</p>%                   
```

다음 명령을 통해 외부에서의 접속을 허용할 수 있다. 

```shell
$ flask run --host='0.0.0.0' [--port='8080']
```

![hello world](https://raw.githubusercontent.com/na3150/typora-img/main/img/hello%20world.PNG)

<br>

#### Rendering Templates

[rendering-templates](https://flask.palletsprojects.com/en/2.1.x/quickstart/#rendering-templates)을 참조하여 `hello.py` 를 작성해보자

`hello.py`

```shell
from flask import Flask
from flask import render_template

app = Flask(__name__)

@app.route('/')
def hello_world():
    return "<p>Hello, World!</p>"

@app.route('/hello/')
@app.route('/hello/<name>')
def hello(name=None):
    return render_template('hello.html', name=name)
```

파일 내용 설명

- root(/)로 접근하면 `Hello, World`가 출력
- `/hello/` 뒤에 변수(name)을 적으면 함수(hello)의 매개변수로 전달됨

`/template/hello.html`을 다음과 같이 작성해보자

```shell
<!doctype html>
<title>Hello from Flask</title>
{% if name %}
  <h1>Hello {{ name }}!</h1>
{% else %}
  <h1>Hello, World!</h1>
{% endif %}
```

파일 내용 설명

- `{% if name %}` 조건문: `name`이라는 변수가 있으면 `Hello {{ name }}!`을 출력
- `{% else %}`: 없으면 ` Hello, World!`을 출력 

<br>

**Flask 실행**

```shell
$ flask run --host='0.0.0.0'
```

<br>

**접속 확인**

`/hello/`뒤의 변수 `/encore`가 들어가서 출력된 것을 확인할 수 있다.



![image-20220511225802771](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220511225802771.png)

<br>

<br>

## Freeze

현재 **설치된 패키지들을 보존하여 저장**할 수 있다.

```
pip3 freeze > requirements.txt
```

```shell
$ cat requirements.txt 
click==8.1.3
Flask==2.1.2
importlib-metadata==4.11.3
itsdangerous==2.1.2
Jinja2==3.1.2
MarkupSafe==2.1.1
Werkzeug==2.1.2
zipp==3.8.0
```

매번 애플리케이션을 개발할 때마다 필요한 패키지들을 설치하는 것은 매우 번거럽고 어렵다.

따라서 필요한 패키지들을 `requirements.txt` 파일로 만들어 놓고, 이 파일을 읽어서 패키지 목록을 설치할 수 있다.

```shell
$ pip3 install -r requirements.txt
```

파이썬 소스코드는 항상 `reauirements.txt` 파일을 제공한다. 

개발 완료 후, 코드를 배포하기 전에 `freeze` 해서 `requirements.txt` 파일을 생성해야, 

이후 사용하는 사람이 어떤 패키지의 어떤 버전을 사용했는지 알고 대응할 수 있다.

 
