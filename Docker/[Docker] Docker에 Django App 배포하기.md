# [Docker] Docker에 Django App 배포하기

<br>

### 📌Index

- [환경 구성](#환경-구성)
- [Django Testing Page 띄워보기](#django-testing-page-띄워보기) 
- [Polls app 배포하기](#polls-app-배포하기)

<br>

<br>

[ 장고(Django)](https://www.djangoproject.com/)란 파이썬으로 만들어진 무료 오픈소스 웹 애플리케이션 프레임워크(web application framework)이다.

풀 스택 프레임워크이며, `Python`을 통해 작성한다.

<br>

## 환경 구성

[tutorial](https://docs.djangoproject.com/en/4.0/intro/tutorial01/)에 따라 진행해보자

**가상 환경 만들기**

가상 환경을 사용하는 이유와 설명에 대해서는 [여기](https://nayoungs.tistory.com/167#%EA%B-%--%EC%--%--%--%ED%--%--%EA%B-%BD)에서 확인할 수 있다.

```shell
$ mkdir ~/python/hello-django
$ cd ~/python/hello-django
```

<br>

**가상프로젝트/프로젝트를 생성**

```shell
$ python3 -m venv venv
```

<br>

**가상 환경 활성화**

```shell
$ . venv/bin/activate
```

<br>

**Django 설치**

```shell
$ pip3 install Django
```

<br>

**상태 보존해두기**

freeze에 대한 설명은 [여기](https://nayoungs.tistory.com/167#c13)에서 확인할 수 있다.

```shell
$ pip3 freeze > requirments.txt
```

<br>

<br>

## Django Testing Page 띄워보기

**Django 프로젝트 만들기**

여기서는 `mysite`가 프로젝트 이름이다.

```shell
$ django-admin startproject mysite
```

`tree` 확인

```shell
$ tree mysite
mysite
├── manage.py
└── mysite
    ├── __init__.py
    ├── asgi.py
    ├── settings.py
    ├── urls.py
    └── wsgi.py
```

<br>

**프로젝트 실행**

```shell
python manage.py runserver 0.0.0.0:3000
```

- flask에서 `flask run`과 동일한 것으로 보면됨

<br>

**접속 확인**

`Django`는 default 포트가 8000번이고, 기본적으로 외부 접속은 허용하지 않는다 :  `curl`로는 확인 가능하다

```shell
curl localhost:8080

<!doctype html>

<html lang="en-us" dir="ltr">
    <head>
        <meta charset="utf-8">
        <title>The install worked successfully! Congratulations!</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" type="text/css" href="/static/admin/css/fonts.css">
        ...
```

외부에서 접속하려하면 아래와 같이 차단되어 `Invalid HTTP_HOST` 화면이 나타나는 것을 확인할 수 있다.

![image-20220512001310444](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220512001310444.png)

<br>

그렇다면 **외부에서 접속을 허용**(외부에 노출)하도록 해보자!

`mysite` 장고 프로젝트 안에, 동일한 이름 `mysite` 디렉토리를 확인할 수 있는데, 이것은 `Django App`이다. 

기본적으로 프로젝트를 만들면, 프로젝트 이름과 동일한 App이 1개 생성되며 하나의 프로젝트 안에 여러개의 App을 만들 수 있다

`mysite/settings.py`

해당 파일에서 `ALLOWD_HOSTS`를 모든 호스트(*)로 설정하자

```shell
...
ALLOWED_HOSTS = ['*']
...
```

```shell
$ python3 manage.py runserver 0.0.0.0:8000
```

<br>

**접속 확인**

다음과 같이 docker testing page를 확인할 수 있다

![image-20220512001845659](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220512001845659.png)





<br>

<br>
## Polls app 배포하기

[polls tutorial](https://docs.djangoproject.com/ko/4.0/intro/tutorial01/)에 따라 진행해보자

**polls app 생성하기**

```shell
$ python manage.py startapp polls
```

```shell
$ tree polls
polls
├── __init__.py
├── admin.py
├── apps.py
├── migrations
│   └── __init__.py
├── models.py
├── tests.py
└── views.py
```

<br>

[여기](https://docs.djangoproject.com/ko/4.0/intro/tutorial01/#write-your-first-view)를 참조하여 비어있는 `polls/view.py` 파일을 아래와 같이 작성한다.

`polls/view.py`

```shell
from django.shortcuts import render

# Create your views here.
from django.http import HttpResponse


def index(request):
    return HttpResponse("Hello, world. You're at the polls index.")
```

<br>

`polls/urls.py` 는 **라우팅 파일**로 [여기](https://docs.djangoproject.com/ko/4.0/intro/tutorial01/#write-your-first-view)를 참조하여 생성 및 작성하자.

`polls/urls.py`

```shell
from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
]
```

- path 경로(여기서는 root)로 들어오면 `index` 함수를 실행하라는 뜻

<br>최상위 URLconf 에서 `polls.urls` 모듈을 바라보게 설정하자

`mysite/urls.py`

주의: `mysite` 프로젝트 안의 `mysite` app 내부의 `urls.py`이다.

```
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('polls/', include('polls.urls')),
    path('admin/', admin.site.urls),
]
```

```shell
$ python3 manage.py runserver 0.0.0.0:4000
```

<br>

**접속 확인**

 “*Hello, world. You’re at the polls index.*” 문구를 확인할 수 있다!



![image-20220512005558392](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220512005558392.png)

<br>
