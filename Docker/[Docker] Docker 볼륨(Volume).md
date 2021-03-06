# [Docker] Docker ๋ณผ๋ฅจ(Volume)

<br>

### ๐Index

- [Volume์ด๋?](#volume์ด๋)
- [๋ณผ๋ฅจ ๋ฐฉ์ ๋ง์ดํธ](#๋ณผ๋ฅจ-๋ฐฉ์-๋ง์ดํธ)
- [๋ฐ์ธ๋ ๋ฐฉ์ ๋ง์ดํธ](#๋ณผ๋ฅจ-๋ฐฉ์-๋ง์ดํธ)
- [์ฌ์ฉ ์ฉ๋](#์ฌ์ฉ-์ฉ๋)

<br>

<br>

## โ๏ธ Volume์ด๋?

Docker ์ปจํ์ด๋(container)์ ์ฐ์ฌ์ง ๋ฐ์ดํฐ(์๋ก ์ถ๊ฐํ rw layer)๋ ๊ธฐ๋ณธ์ ์ผ๋ก ์ปจํ์ด๋๊ฐ ์ญ์ ๋  ๋ ํจ๊ป ์ฌ๋ผ์ง๊ฒ ๋๋ค.

Docker์์ ๋์๊ฐ๋ ๋ง์ ์ ํ๋ฆฌ์ผ์ด์(ํนํ `MySQL`๊ณผ ๊ฐ์ DB)์ ์ปจํ์ด๋์ ์๋ช ์ฃผ๊ธฐ์ ๊ด๊ณ์์ด ๋ฐ์ดํฐ๋ฅผ ์์์ ์ผ๋ก ์ ์ฅํด์ผํ๊ณ , ๋ง์ ๊ฒฝ์ฐ ์ฌ๋ฌ ๊ฐ์ Docker ์ปจํ์ด๋๊ฐ ํ๋์ ์ ์ฅ ๊ณต๊ฐ์ ๊ณต์ ํด์ ๋ฐ์ดํฐ๋ฅผ ์ฝ๊ฑฐ๋ ์จ์ผํ๋ค. 

์ด๋ ๊ฒ Docker ์ปจํ์ด๋์ ์๋ช ์ฃผ๊ธฐ์ ๊ด๊ณ์์ด ๋ฐ์ดํฐ๋ฅผ ์์์ ์ผ๋ก ์ ์ฅํ  ์ ์๋๋ก ๋ณ๊ฐ์ ๊ณต๊ฐ์ธ, `Volume`์ด ํ์ํ๋ค.

<br>

์ด๋ฏธ์ง์ `Config.Volumes` ์ ์ธ๋์ด ์์ผ๋ฉด, ์๋์ผ๋ก Docker ๋ณผ๋ฅจ์ด ์์ฑ๋๊ณ  ๋ง์ดํธ๋๋ฉฐ, ์๋์ผ๋ก ๋ง์ดํธํ๋ ๊ฒ๋ ๊ฐ๋ฅํ๋ค.

`/var/lib/docker/volumes/[volume๋ช]/_data`๊ฐ ์ค์  ์ฌ์ฉํ๋, ๋ง์ดํธ๋ ๋๋ ํ ๋ฆฌ์ด๋ค

<br>

<br>

## โ๏ธ ๋ณผ๋ฅจ ๋ฐฉ์ ๋ง์ดํธ
๋ณผ๋ฅจ์ ์ฝ๊ธฐ-์ฐ๊ธฐ๊ฐ ๊ฐ๋ฅํ ๋น ์ ์ฅ์๋ฅผ ์์ฑํ๋ ๊ฒ์ด ๊ธฐ๋ณธ์ด๊ณ , ๋ณผ๋ฅจ์ ๋์ปค ๋ฐ๋ชฌ์ด ๊ด๋ฆฌํ๋ค. 

<br>

#### ๋น ๋ณผ๋ฅจ ์์ฑํ๊ธฐ

```
docker volume create <NAME>
```

์์

```shell
$ docker volume create test-vol 
```

```shell
$ docker volume ls             
DRIVER    VOLUME NAME
local     test-vol
```

๋น ๋ณผ๋ฅจ์ด๋ฏ๋ก `/var/lib/docker/volumes/test-vol/_data`๋ฅผ ํ์ธํด๋ ์์ง์ ์๋ฌด๊ฒ๋ ์๋ค.

```shell
$ docker inspect test-vol           
[
    {
        "CreatedAt": "2022-05-15T12:52:47Z",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/test-vol/_data",
        "Name": "test-vol",
        "Options": {},
        "Scope": "local"
    }
]
```

<br>

#### ๋ณผ๋ฅจ ๋ชฉ๋ก ํ์ธํ๊ธฐ

```shell
$ docker volume ls
```

<br>

#### ๋ณผ๋ฅจ ์ญ์ ํ๊ธฐ

```shell
$ docker volume rm <NAME>
```

<br>

#### ์ฌ์ฉํ์ง ์๋ ๋ณผ๋ฅจ ์ญ์ ํ๊ธฐ

์ฌ์ฉ๋์ง ์๋๋ค๋ ๊ฒ์ ์ปจํ์ด๋์ ๋ง์ดํธ๋์ง ์์๋ค๋ ๋ป์ด๋ค.

```shell
$ docker volume prune
```

<br>

#### ๋ณผ๋ฅจ์ ์ฌ์ฉํ ์ปจํ์ด๋

`docker run`์ `-v`์ต์์ ํตํด ๋ณผ๋ฅจ์ ์ฐ๊ฒฐํ  ์ ์๋ค.

`ro` : `Read-Only` ์ค์ , default๋ `rw` ์ด๋ค.

`<MOUNTPOINT>`๋ ์ปจํ์ด๋ ๋ด๋ถ์ ๋ง์ดํธํ  ์์น๋ก, **๋๋ ํ ๋ฆฌ๊ฐ ๋ง๋ค์ด์ ธ์์ง ์๋๋ผ๋ ์์์ ๋ง๋ค๊ฒ ๋๋ค.**

```shell
$ docker run -v <VOL-NAME>:<MOUNTPOINT>[:ro] <IMAGE>
```

**์์1**

```shell
$ docker run -itd -v test-vol:/test-vol ubuntu
```

์์ฑ๋ ์ปจํ์ด๋๋ฅผ ํ์ธํด๋ณด๋ฉด `Mounts`์์ `Destination`์ด `/test-vol`์ผ๋ก ์ค์ ๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค.

```shell
$ docker inspect 5c 
...
 "Mounts": [
            {
                "Type": "volume",
                "Name": "test-vol",
                "Source": "/var/lib/docker/volumes/test-vol/_data",
                "Destination": "/test-vol",
                "Driver": "local",
                "Mode": "z",
                "RW": true,
                "Propagation": ""
            }
        ],
        ...
```

์ปจํ์ด๋์ ์ ์ํด์ `/test-vol` ๋๋ ํ ๋ฆฌ์ `hello.txt` ํ์ผ์ ์์ฑํด๋ณด์.

```shell
$ docker exec -it 5c bash          
root@5c80ed5ed7c5:/# ls
bin   dev  home  lib32  libx32  mnt  proc  run   srv  test-vol  usr
boot  etc  lib   lib64  media   opt  root  sbin  sys  tmp       var
root@5c80ed5ed7c5:/# cd test-vol/
root@5c80ed5ed7c5:/test-vol# ls
root@5c80ed5ed7c5:/test-vol# echo "hello volume" > hello.txt
root@5c80ed5ed7c5:/test-vol# exit
```

`/var/lib/docker/volumes/test-vol/_data ` ์ `hello.txt`๊ฐ ์์ฑ๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค.

```shell
$ sudo ls /var/lib/docker/volumes/test-vol/_data 
hello.txt
```

์ด๋, **์ปจํ์ด๋๋ฅผ ์ง์ด๋ค๊ณ ํด์ ๋ณผ๋ฅจ์ด ์ง์์ง๋ ๊ฒ์ ์๋๋ค.**

์ฆ, **์ปจํ์ด๋์ ๋ผ์ดํ ์ฌ์ดํด๊ณผ ๋ณผ๋ฅจ์ ๋ผ์ดํ ์ฌ์ดํด์ ๋ณ๊ฐ**์ด๋ค.

<br>

**์์2**

๋ณผ๋ฅจ์ ๋ค์๊ณผ ๊ฐ์ด ์ฌ๋ฌ๊ฐ๋ฅผ ์ง์ ํ๋ ๊ฒ๋ ๊ฐ๋ฅํ๋ค. (**๋ณผ๋ฅจ์ ์ฌ๋ฌ๊ฐ ์์ ์ ์๋ค**)

```shell
$ docker run -itd -v abc:/abc -v xyz:/xyz: ubuntu
```

```shell
$ docker volume ls                               
DRIVER    VOLUME NAME
local     abc
local     xyz
```

```shell
$ docker inspect <container>
...
"Mounts": [
            {
                "Type": "volume",
                "Name": "abc",
                "Source": "/var/lib/docker/volumes/abc/_data",
                "Destination": "/abc",
                "Driver": "local",
                "Mode": "z",
                "RW": true,
                "Propagation": ""
            },
            {
                "Type": "volume",
                "Name": "xyz",
                "Source": "/var/lib/docker/volumes/xyz/_data",
                "Destination": "/xyz",
                "Driver": "local",
                "Mode": "z",
                "RW": true,
                "Propagation": ""
            }
        ],
...
```

<br>

**์์3**

์๋์ ๋ช๋ น์ ์คํํด๋ณด์

```shell
$ docker run --name wp-db -d -v wp-db-vol:/var/lib/mysql mysql:5.7
b63565b20242657ef8ca4a91f346754fbbf1a8a9c1237db48fd37ce270d0ba9c
```

`mysql` ์ปจํ์ด๋์ ํ๊ฒฝ๋ณ์๋ฅผ ์ค์ ํ์ง ์์์ง๋ง, ์ ์์ ์ผ๋ก ์คํ๋์๋ค.

์ ํ๊ฒฝ ๋ณ์ ์ค์ ์์ด๋ ์ ์คํ๋๋ ๊ฒ์ผ๊นโ

```shell
$ docker ps

CONTAINER ID   IMAGE       COMMAND                  CREATED         STATUS         PORTS                 NAMES
b63565b20242   mysql:5.7   "docker-entrypoint.sโฆ"   4 seconds ago   Up 3 seconds   3306/tcp, 33060/tcp   wp-db
```

```shell
$ docker exec b6 env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=95348375c379
GOSU_VERSION=1.14
MYSQL_MAJOR=5.7
MYSQL_VERSION=5.7.38-1debian10
HOME=/root
```

`wp-db`๋ฅผ ์ดํด๋ณด๋ฉด ํ๊ฒฝ๋ณ์๊ฐ ์๋ ๊ฒ์ ํ์ธํ  ์ ์๋๋ฐ, 

์๋ `mysql` ๋๋ `mariadb` ์ปจํ์ด๋๋ฅผ ์คํํ๊ธฐ ์ํด์๋ `root` ํจ์ค์๋ ์ค์ ์ด ์ค์ํ๊ณ , ์ด๋ฏธ์ง ๋ด์๋ `root` ํจ์ค์๋๊ฐ ์๊ธฐ ๋๋ฌธ์ ํ๊ฒฝ๋ณ์๋ก `root` ํจ์ค์๋๋ฅผ ์ ๊ณตํด์ค์ผํ๋ค.

๊ทธ๋ฌ๋ ์ฌ๊ธฐ์๋ ์ปจํ์ด๋๋ฅผ ๋์ธ ๋ volume ์ฆ ๋ฐ์ดํฐ๋ฒ ์ด์ค๋ฅผ ์ ๊ณตํ๊ธฐ ๋๋ฌธ์ ๊ทธ ๋ด๋ถ์ `root` ํจ์ค์๋๊ฐ ์์ด ๋ณ๋๋ก ๋ฃจํธ ํจ์ค์๋๋ฅผ ์ค์ ํ  ํ์ ์์ด ์ปจํ์ด๋๊ฐ ์คํ๋ ๊ฒ์ด๋ค. 

<br>
๋ค์๊ณผ ๊ฐ์ด ๊ธฐ์กด ํจ์ค์๋๋ก๋ ์ ์์ ์ผ๋ก ์ ์ํ  ์ ์์ง๋ง

```shell
$ docker exec -it b6 mysql -u wpadm -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.38 MySQL Community Server (GPL)

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

ํจ์ค์๋๋ฅผ ๋ณ๊ฒฝํ ๋ค, ๋ณ๊ฒฝํ ํจ์ค์๋๋ฅผ ํตํด ๋ก๊ทธ์ธํ๋ คํ๋ฉด ์ ๊ทผ์ด ๋ถ๊ฐ๋ฅํ๋ค.

`-e`๋ก ์ง์ ํ ํ๊ฒฝ ๋ณ์๋ ๋ฌด์๋๊ณ , ๋ณผ๋ฅจ์ ์๋ ๋ด์ฉ์  ์ฐธ์กฐํ๊ณ  ์๊ธฐ ๋๋ฌธ์ด๋ค. 

```shell
$ docker run --name wp-db2 -d -e MYSQL_ROOT_PASSWORD=qwer1234 -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wpadm -e MYSQL_PASSWORD=qwer1234 --restart always --cpus 0.5 --memory 1000m -v wp-db-vol:/var/lib/mysql mysql:5.7
WARNING: Your kernel does not support swap limit capabilities or the cgroup is not mounted. Memory limited without swap.
389245782e838f364604f3dab72790b772046eb93e2d967de58f534db140857e
$ docker ps
CONTAINER ID   IMAGE       COMMAND                  CREATED         STATUS         PORTS                 NAMES
37887g412411   mysql:5.7   "docker-entrypoint.sโฆ"   3 seconds ago   Up 3 seconds   3306/tcp, 33060/tcp   wp-db2
b63565b20242   mysql:5.7   "docker-entrypoint.sโฆ"   5 minutes ago   Up 5 minutes   3306/tcp, 33060/tcp   wp-db
```

์ฌ์ง์ด ๋ค์ ๋ณ๊ฒฝ ์ ์ ๋น๋ฐ๋ฒํธ๋ก ์ ์ํ๋ ค๊ณ ํด๋ ์ ์์ด ๋ถ๊ฐ๋ฅํ๋ค. 

```shell
$ docker exec -it 37 mysql -u wpadm -p
Enter password:
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)
```

๊ฒฐ๋ก : ์ด๋ฏธ ๋ฐ์ดํฐ๋ฒ ์ด์ค(๋ณผ๋ฅจ)์ด ์๋ ์ํ์์ ๋ฐ์ดํฐ๋ฒ ์ด์ค ํ๊ฒฝ๋ณ์๋ฅผ ์ค์ ํด์ฃผ๋ฉด ์ค๋ฅ๊ฐ ๋ฐ์ํ๋ค.

๋ํ ์ฌ๊ธฐ์ ์ ์ ์๋ ํ๊ฐ์ง ์ฌ์ค์ด ๋ ์๋ค.

**ํ๋์ ๋ณผ๋ฅจ์ ์๋ก ๋ค๋ฅธ ์ปจํ์ด๋๊ฐ ๋์์ ๋ง์ดํธํด์ ์ฌ์ฉํ  ์ ์๋ค**๋ ๊ฒ์ด๋ค. (์ฌ๊ธฐ์๋ `wp-db`, `wp-db2`)

`VM`์ ์ฌ์ฉํ  ๋๋ ์ด๋ฐ ๊ตฌ์ฑ์ ํ๊ธฐ ์ํด NFS๋ฅผ ์ฌ์ฉํ์ด์ผํ๋ค.

๊ทธ๋ฆฌ๊ณ  NFS๋ ๋์์ ์ฝ๊ธฐ๋ ๊ฐ๋ฅํ๋, `lock` ๊ธฐ๋ฅ์ผ๋ก ์ธํด ๋์์ ์ฐ๊ธฐ๋ ๋ถ๊ฐ๋ฅ ํ๋ค.

๊ทธ๋ฌ๋ ์ด๋ฌํ ๋ฐฉ์(์ปจํ์ด๋๊ฐ ๋ง์ดํธ ๊ณต์ )์ `lock` ๊ธฐ๋ฅ์ด ์๊ณ , ๋์์ ํ์ผ์ ์ฐ๊ธฐ ์์๋ ๊ฐ๋ฅํ๋ค.

๋ค๋ง ๋ฐ์ดํฐ๊ฐ ๊นจ์ง๊ฑฐ๋, ๋ฌธ์ ๊ฐ ๋ฐ์ํ๊ฑฐ๋ ์ด๋ ํ ๊ฒฐ๊ณผ๋ฅผ ์ด๋ํ  ์ง๋ ๋ชจ๋ฅธ๋ค.

<br>

**์์4**

์๋์ ๋ช๋ น์ ์คํํด๋ณด์. `ro`๋ `Read-Only` ์ต์์ด๋ค.

```shell
$ docker run -itd -v abc:/abc --name u1 ubuntu
$ docker run -itd -v abc:/abc:ro --name u2 ubuntu
```

`ro` ์ต์์ ์ฃผ์ง ์์ `u1`์ `RW : true`๋ก ์ค์ ๋์ด์๊ณ ,

```shell
$ docker inspect u1
"Mounts": [
            {
                "Type": "volume",
                "Name": "abc",
                "Source": "/var/lib/docker/volumes/abc/_data",
                "Destination": "/abc",
                "Driver": "local",
                "Mode": "z",
                "RW": true,
                "Propagation": ""
            }
        ],
```

`ro` ์ต์์ ์ค `u2` ๋ `RW : false` ๋ก ์ค์ ๋์ด์๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค. 

์ฆ, ์ฐ๊ธฐ๊ฐ ๋ถ๊ฐ๋ฅํ๋ค. 

```shell
$ docker inspect u2
"Mounts": [
            {
                "Type": "volume",
                "Name": "abc",
                "Source": "/var/lib/docker/volumes/abc/_data",
                "Destination": "/abc",
                "Driver": "local",
                "Mode": "ro",
                "RW": false,
                "Propagation": ""
            }
        ],
```

<br>

<br>

## โ๏ธ ๋ฐ์ธ๋ ๋ฐฉ์ ๋ง์ดํธ

๋ฐ์ธ๋ ๋ฐฉ์์ **์ปจํ์ด๋์๊ฒ ์ ๊ณตํ  ๋ณผ๋ฅจ์ ํธ์คํธ์ ํน์  ๋๋ ํ ๋ฆฌ๋ฅผ ์ง์ **ํ๋ ๋ฐฉ์์ด๋ค. 
**ํธ์คํธ์ ๋๋ ํ ๋ฆฌ๋ฅผ ์ปจํ์ด๋์๊ฒ ์ ๊ณต**ํ๋ ๊ฒ์ผ๋ก, ๋ฏธ๋ฆฌ ๋ฐ์ดํฐ๋ฅผ ์ฑ์์ ์ ๊ณต์ด ๊ฐ๋ฅํ๋ค.

๋ฐ์ธ๋ ๋ณผ๋ฅจ์ ๋์ปค ๋ฐ๋ชฌ์ด ๊ด๋ฆฌํ์ง ์๊ณ , ์ฌ์ฉ์๊ฐ ์ง์  ๊ด๋ฆฌํ๋ค. 

`bind` ๋ฐฉ์์ ๋ณผ๋ฅจ์ `.Mounts`์ `Type`์ด `bind`๋ก ๋์ด์๋ค.

<br>

` <ABSOLUTE_PATH>` : ๊ฒฝ๋ก๋ฅผ ๋ฐ๋์ ์ ๋๊ฒฝ๋ก๋ก ์์ฑํด์ผํ๋ค

```shell
$ docker run -v <ABSOLUTE_PATH>:<MOUNTPOINT>[:ro] <IMAGE>
```

๋ง์ดํธ ๋ฐฉ์๊ณผ์ ์ฐจ์ด๋ ์ ๋๊ฒฝ๋ก๋ฅผ ์ ๋๊ฐ, ๋ณผ๋ฅจ ์ด๋ฆ์ ์ ๋๊ฐ์ ์ฐจ์ด์ด๋ค.

<br>

**์์**

๋จผ์  ์ค์ต์ ์ํ  `contents` ๋๋ ํ ๋ฆฌ๋ฅผ ๋ง๋ค๊ณ  ๋ณธ ๋๋ ํ ๋ฆฌ์ `hello.html` ํ์ผ์ ์์ฑํด๋ณด์

```shell
$ mkdir contents
$ cd contents
$ echo "hello bind volume" > hello.html
```

๊ทธ๋ฆฌ๊ณ  ๋ค์๊ณผ ๊ฐ์ด ์ ๋๊ฒฝ๋ก๋ก ๋ฐ์ธ๋ ๋ง์ดํธ ํ ๋ค,

```shell
$ docker run -itd -v /home/vagrant/contents:/abc ubuntu
```

`/abc` ๋๋ ํ ๋ฆฌ๋ฅผ ํ์ธํด๋ณด๋ฉด `hello.html` ์ด ์๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค.

```shell
$ docker exec -it d3e bash              
root@d3e21b276e15:/# ls abc
hello.html
```

๋ํ,  `.Mounts`์ `Type`์ด `bind`๋ก ๋์ด์๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค. 

๋ณผ๋ฅจ ๋ฐ์ธ๋ ๋ฐฉ์์ `volume`์ผ๋ก ์ค์ ๋์ด์๋ค. 

```shell
$ docker inspect <container>
...
  "Mounts": [
            {
                "Type": "bind",
                "Source": "/home/vagrant/contents",
                "Destination": "/abc",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            }
        ],
...
```

<br>

**๋๋ ํ ๋ฆฌ ์ ์ฒด ๋ง์ดํธํ๊ธฐ**

`httpd`๋ ๊ธฐ๋ณธ์ ์ผ๋ก `/usr/local/apache2/` ๊ฐ `working directory`์ด๊ณ  `/usr/local/apache2/htdocs`๊ฐ `httpd`์ `DocumentRoot` directory์ด๋ค. 

```shell
$ docker run -d -v /home/vagrant/contents:/usr/local/apache2/htdocs httpd
```

<br>

**โญ ํ์ผ ๋ง์ดํธํ๊ธฐ**

ํ์ผ์ ํ์ผ๋ก ๋ง์ดํธ ํ๋ ๊ฒ์ด๋ค. `file mounting`

```shell
$ docker run -d -v /home/vagrant/contents/hello.html:/usr/local/apache2/htdocs/hello.html httpd
```

๋๋ ํ ๋ฆฌ์ ๊ธฐ์กด์ ๊ฒ์ ์ ์ง๋๊ณ , ํ์ผ๋ง ๋ง์ดํธ ๋๋ค.

```shell
$ docker exec -it 664 bash
root@664e1253a597:/usr/local/apache2# ls htdocs/
hello.html  index.html
```

๋๋ ํ ๋ฆฌ๋ฅผ ๋ง์ดํธํ๋ฉด ๋๋ ํ ๋ฆฌ ์ ์ฒด๊ฐ ๋ง์ดํธ ๋๊ธฐ ๋๋ฌธ์ ๊ธฐ์กด์ ํ์ผ์ด ๊ฐ๋ ค์ง๋ค.

๊ธฐ์กด์ ํ์ผ๋ค์ด ์์ง๋ง ์ ๊ทผ๋ถ๊ฐ(์๋ณด์ด๋) ๊ฒ์ผ๋ก, ๋ง์ดํธ๋ฅผ ํด์ ํ๋ฉด ๋ค์ ์ ๊ทผํ  ์ ์๋ค.

<br>๊ทธ๋ฌ๋ **ํ์ผ์ ๋ง์ดํธํ๋ฉด ํน์  ํ์ผ๋ง ๋ง์ดํธ๋๊ธฐ ๋๋ฌธ์ ๊ธฐ์กด์ ์กด์ฌํ๋ ํ์ผ์ด ๊ฐ๋ ค์ง์ง ์๋๋ค.**

๋ฐ๋ผ์ ๊ธฐ์กด์ ์ด๋ค ๋๋ ํ ๋ฆฌ์ index.html ํ์ผ์ด ์๊ณ  ์ถ๊ฐ์ ์ผ๋ก ๋ค๋ฅธ ํ์ผ์ ๋ง์ดํ ์ํค๊ณ  ์ถ๋ค๋ฉด ํ์ผ๋ช์ ์ง์ ํด์ ๋ง์ดํํ  ์ ์๋ค.

์ค์ ๋ก `file mounting`์ ์ค์  ํ์ผ์ ์ ๊ณตํ  ๋ ๋ง์ด ์ฌ์ฉํ๋ค.

ํ์ผ๋ง์ ์ถ๊ฐํ๋ ๊ฒ์ด ๋ชฉ์ ์ด๋ผ๋ฉด ํ์ผ ๋ง์ดํ ๋ฐฉ์์ ์ฌ์ฉํด์ผํ๋ค.

์ฐธ๊ณ ๋ก ๋ณผ๋ฅจ ๋ฐฉ์์ ํ์ผ ๋ง์ดํ์ด ๋ถ๊ฐ๋ฅํ๋ค. 

<br>

<br>

## โ๏ธ ์ฌ์ฉ ์ฉ๋

**๋ฐ์ธ๋ ๋ฐฉ์**: ์ค์ ํ์ผ, ๊ธฐํ ํ์ผ์ ์ ๊ณตํ๊ธฐ ์ํ ๋ชฉ์ 

- ์ด๋ฏธ ์กด์ฌํ๋ ํ์ผ์ ์ ๊ณตํ  ๋ ์ฌ์ฉํ๋ค.

**๋ณผ๋ฅจ ๋ฐฉ์** : ๋ฐ์ดํฐ๋ฅผ ์ ์ฅํ๊ธฐ ์ํ ๋น ๋๋ ํ ๋ฆฌ ์ ๊ณตํ๊ธฐ ์ํ ๋ชฉ์ 

- ๋น ๋ณผ๋ฅจ์ ์ ๊ณตํ  ๋ ์ฌ์ฉํ๋ค. 












