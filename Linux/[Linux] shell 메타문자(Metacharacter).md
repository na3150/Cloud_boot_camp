<h1>[Linux] shell ๋ฉํ๋ฌธ์(Metacharacter)</h1>



<h3>๐INDEX</h3>

- [shell ๋ฉํ ๋ฌธ์๋?](#shell-๋ฉํ-๋ฌธ์๋)
- [๊ฒฝ๋ก ์ด๋ฆ ๋ฉํ ๋ฌธ์](#๊ฒฝ๋ก-์ด๋ฆ-๋ฉํ-๋ฌธ์)
- [ํ์ผ ์ด๋ฆ ๋ฉํ ๋ฌธ์](#ํ์ผ-์ด๋ฆ-๋ฉํ-๋ฌธ์)
- [์ธ์ฉ ๋ถํธ ๋ฉํ ๋ฌธ์(echo์ ์ฌ์ฉ์)](#์ธ์ฉ-๋ถํธ-๋ฉํ-๋ฌธ์echo์-์ฌ์ฉ์)
- [๋ฐฉํฅ ์ฌ์ง์  ๋ฉํ ๋ฌธ์](#๋ฐฉํฅ-์ฌ์ง์ -๋ฉํ-๋ฌธ์)
  - [ํ์ค ์์ถ๋ ฅ](#ํ์ค-์์ถ๋ ฅ)
- [shell ๋ฉํ ๋ฌธ์ ์ค์ต(๋ฌธ์ )](#shell-๋ฉํ-๋ฌธ์-์ค์ต๋ฌธ์ )



<br>

<br>



<h2>shell ๋ฉํ ๋ฌธ์๋?</h2>

- **shell์์ ์ฌ์ฉํ  ๋ ํน์ํ ๊ธฐ๋ฅ์ ๊ฐ์ง๊ณ  ์๋ ๋ฌธ์**
- shell์ ์ด๋ฌํ ํน์ ๊ธฐํธ๋ค์ ํด์(interpret)ํ์ฌ ๋ช๋ น ์คํ
- Bourne Shell์ ๊ฒฝ์ฐ์๋ ๋ฉํ ๋ฌธ์ ์ธ์ ๋ชปํจ
- shell์์ ์ฌ์ฉํ๋ ๋ฉํ๋ฌธ์์ ์ ๊ท ํํ์์์ ์ฌ์ฉํ๋ ๋ฉํ ๋ฌธ์ ํผ๋ ์๋๋ก ์ฃผ์
- ์ข๋ฅ 
  - ๊ฒฝ๋ก ์ด๋ฆ ๋ฉํ๋ฌธ์ : ๋๋ ํ ๋ฆฌ์ ๊ฒฝ๋ก ์ถ์ฝ
  - ํ์ผ ์ด๋ฆ ๋ฉํ๋ฌธ์ : ํ์ผ ์ด๋ฆ ๋์ฒด
  - ์ธ์ฉ๋ถํธ ๋ฉํ๋ฌธ์ : ๋ฉํ ๋ฌธ์์ ์๋ฏธ๋ฅผ ๋ค๋ฅด๊ฒ ํ๊ฑฐ๋ ๋ฌด์
  - ๋ฐฉํฅ ์ฌ์ง์  ๋ฉํ๋ฌธ์ : ํ์ค ์๋ ฅ๊ณผ ์ถ๋ ฅ ๋ฑ์ ์ฌ์ง์ 



<br>

<br>

<h2>๊ฒฝ๋ก ์ด๋ฆ ๋ฉํ ๋ฌธ์</h2>

- ํ์ผ ๊ฒฝ๋ก ์ด๋ฆ ๋งค์นญ ๊ธฐ๋ฅ์ ์ ๊ณต
- ๋ง์ ์์ ํ์ผ์ ๊ด๋ฆฌํ๊ธฐ ์ฌ์



<img src="https://user-images.githubusercontent.com/64996121/154929769-b517a28b-21e9-4e2f-8617-6b05381ae79c.PNG" width=500 heigth=400 />



- ์ฌ์ฉ ์

```shell
[user@localhost ~]$ ~
-bash: /home/user: ๋๋ ํฐ๋ฆฌ์๋๋ค
```

```shell
[user@localhost tmp]$ ~+
-bash: /tmp: ๋๋ ํฐ๋ฆฌ์๋๋ค
```

```shell
[user@localhost tmp]$ ~-
-bash: /home/user: ๋๋ ํฐ๋ฆฌ์๋๋ค
```

```shell
[root@localhost dir01]# ~user
-bash: /home/user: ๋๋ ํฐ๋ฆฌ์๋๋ค
```

<br>

<br>

<h2>ํ์ผ ์ด๋ฆ ๋ฉํ ๋ฌธ์</h2>

- **ํ์ผ ์ด๋ฆ์ ๋์ฒด(ํ์ฅ)ํ๋ ๋ฐ ์ฌ์ฉ**๋๋ ๋ฉํ ๋ฌธ์๋ค์ด๋ค



<img src="https://user-images.githubusercontent.com/64996121/154929903-f001761d-8582-49fc-a555-16a7d0d57590.PNG" width=500 heigth=400 />



- ex) [123] : 1,2,3์ ํ๋์ฉ ๋์
- ex) [a-z] : a๋ถํฐ z๊น์ง ํ ๋ฌธ์์ฉ ๋์
- ex) [!] : ๋๊ดํธ ์์ ์๋ ๋ฌธ์๋ค์ ์ ์ธํ ๋ชจ๋  ๋ฌธ์
- ex) 1133* : 1133์ ํฌํจํด์ 1133์ผ๋ก ์์ํ๋ ๋ชจ๋  ๊ฒ์ ๋ปํ๋ค.
- ex) 13? : ๋น์นธ์ ํฌํจํ ์ต์ ํ ๊ธ์๋ฅผ ๋ํ๋ธ๋ค(space, tab ๋ฑ ํฌํจ)
- ex) [B-Pk-y] : B์์ P๊น์ง ์ฌ์ด ํน์ k ์์ y ๊น์ง ์ฌ์ด ์ค์ ํ ๊ธ์์ ์ผ์น
- ex) [a-z0-9] : ์๋ฌธ์ ํน์ ์ซ์์ ์ผ์น
- ex) [!b-d] : b์์ d ์ฌ์ด์ ๋ฌธ์๋ฅผ ์ ์ธํ ๋ชจ๋  ๋ฌธ์

- <h4>๋ธ๋ ์ด์ค ํ์ฅ</h4>

  - bash ์์๋ง ์ฌ์ฉ ๊ฐ๋ฅ
  - **์ค๊ดํธ ์์ ๋ค์ด๊ฐ ์๋ ๋ฌธ์์ด์ ํ๋์ฉ ๋ฐฐํฌ**
  - {a,b,c} ํ์์ผ๋ก ์ฌ์ฉ 
  - {001..100} : 001๋ถํฐ 100๊น์ง ์ฐจ๋ก๋๋ก ๋ฐฐํฌ
  - ์ฌ์ฉ ์

```shell
[root@localhost dir01]# touch {a,b,c}
[root@localhost dir01]# ls
a  b  c
```

```shell
[root@localhost dir01]# rm -rf {a..c}
```

```shell
[root@localhost dir01]# touch z{a{1..10},b{01..10},c{001..100}}
[root@localhost dir01]# ls
za1   zb01  zc001  zc011  zc021  zc031  zc041  zc051  zc061  zc071  zc081  zc091
za10  zb02  zc002  zc012  zc022  zc032  zc042  zc052  zc062  zc072  zc082  zc092
za2   zb03  zc003  zc013  zc023  zc033  zc043  zc053  zc063  zc073  zc083  zc093
za3   zb04  zc004  zc014  zc024  zc034  zc044  zc054  zc064  zc074  zc084  zc094
za4   zb05  zc005  zc015  zc025  zc035  zc045  zc055  zc065  zc075  zc085  zc095
za5   zb06  zc006  zc016  zc026  zc036  zc046  zc056  zc066  zc076  zc086  zc096
za6   zb07  zc007  zc017  zc027  zc037  zc047  zc057  zc067  zc077  zc087  zc097
za7   zb08  zc008  zc018  zc028  zc038  zc048  zc058  zc068  zc078  zc088  zc098
za8   zb09  zc009  zc019  zc029  zc039  zc049  zc059  zc069  zc079  zc089  zc099
za9   zb10  zc010  zc020  zc030  zc040  zc050  zc060  zc070  zc080  zc090  zc100
```

```shell
[root@localhost dir01]# rm -f z{a?,a10,b??,c*}
```

<br>

<br>

<h2>์ธ์ฉ ๋ถํธ ๋ฉํ ๋ฌธ์(echo์ ์ฌ์ฉ์)</h2>

- echo์ ์ฌ์ฉ ์์ ์ ์ฉ

<img src="https://user-images.githubusercontent.com/64996121/154930022-9fdc8503-f342-4591-9a30-44b5dd067f0f.PNG" width=500 heigth=400 />

- ์ฌ์ฉ ์

```shell
[root@localhost dir01]# echo "date is $(date)"
date is 2022. 02. 21. (์) 03:30:19 EST

[root@localhost dir01]# echo 'date is $(date)'
date is $(date)

[root@localhost dir01]# echo "date is `date`"
date is 2022. 02. 21. (์) 03:31:50 EST

[root@localhost dir01]# echo "\`date\` is `date`"
`date` is 2022. 02. 21. (์) 03:32:11 EST
```

<br>

<br>

<h2>๋ฐฉํฅ ์ฌ์ง์  ๋ฉํ ๋ฌธ์</h2>

- I/O ๊ด๋ จ

<img src="https://user-images.githubusercontent.com/64996121/154930150-6107c6d4-a941-4b0d-bab0-fc15fd73689d.PNG" width=500 heigth=400 />


- <h4>ํ์ค ์์ถ๋ ฅ</h4>

  <img src="https://user-images.githubusercontent.com/64996121/154930173-a1edff5d-d5ff-4766-9556-784d47878c05.PNG" width=500 heigth=400 /><br>

  -  **๋ฆฌ๋๋ ์(redirection) ์ฌ์ฉ๋ฒ**

<br>
  <img src="https://user-images.githubusercontent.com/64996121/154930219-9feb0527-21bf-49b4-95db-e6cbd7035113.PNG" width=500 heigth=400 />
<br>

  -  ์ฌ์ฉ ์

```shell
[root@localhost dir01]# date 1> r01
[root@localhost dir01]# cat r01
2022. 02. 21. (์) 04:15:21 EST
```

```shell
[root@localhost dir01]# find / -perm -2000 > r03 2>&1
[root@localhost dir01]# cat r03
find: โ/proc/5126/task/5126/fd/5โ: ๊ทธ๋ฐ ํ์ผ์ด๋ ๋๋ ํฐ๋ฆฌ๊ฐ ์์ต๋๋ค
find: โ/proc/5126/task/5126/fdinfo/5โ: ๊ทธ๋ฐ ํ์ผ์ด๋ ๋๋ ํฐ๋ฆฌ๊ฐ ์์ต๋๋ค
find: โ/proc/5126/fd/6โ: ๊ทธ๋ฐ ํ์ผ์ด๋ ๋๋ ํฐ๋ฆฌ๊ฐ ์์ต๋๋ค
find: โ/proc/5126/fdinfo/6โ: ๊ทธ๋ฐ ํ์ผ์ด๋ ๋๋ ํฐ๋ฆฌ๊ฐ ์์ต๋๋ค
find: โ/run/user/1000/gvfsโ: ํ๊ฐ ๊ฑฐ๋ถ
/run/log/journal
/run/log/journal/092c802715504b6f8575e745f2daaed4
/usr/bin/write
/usr/bin/locate
/usr/sbin/lockdev
/usr/libexec/utempter/utempter
/usr/libexec/openssh/ssh-keysign
/tmp/usr/bin/write
/tmp/usr/bin/locate
```

```shell
[root@localhost dir01]# echo "hello" > test.txt
[root@localhost dir01]# cat test.txt
hello
[root@localhost dir01]# echo "next hello" >> test.txt
[root@localhost dir01]# cat test.txt
hello
next hello
```

```shell
[root@localhost dir01]# ln aaa bbb
ln: failed to access 'aaa': ๊ทธ๋ฐ ํ์ผ์ด๋ ๋๋ ํฐ๋ฆฌ๊ฐ ์์ต๋๋ค
[root@localhost dir01]# ln aaa bbb 2> errro.txt
[root@localhost dir01]# cat error.txt
cat: error.txt: ๊ทธ๋ฐ ํ์ผ์ด๋ ๋๋ ํฐ๋ฆฌ๊ฐ ์์ต๋๋ค
```

```shell
[root@localhost dir01]# ln aaa bbb 2> /dev/null
```



- **ํ์ดํ(pipe)** : ํ ํ๋ก๊ทธ๋จ์ ์ถ๋ ฅ์ ์ค๊ฐ ํ์ผ ์์ด ๋ค๋ฅธ ํ์ผ์ ์๋ ฅ์ผ๋ก ๋ฐ๋ก ๋ณด๋ด๋ ์ ๋์ค ๋ฉ์ปค๋์ฆ
  - ํ์ดํ๋ ํ์ดํ(|) ๊ธฐํธ ์ผ์ชฝ ๋ช๋ น์ด์ ์ถ๋ ฅ์ ์ค๋ฅธ์ชฝ ๋ช๋ น์ด์ ์๋ ฅ์ผ๋ก  ๋ณด๋ธ๋ค
  - ํ์ดํ๋ผ์ธ์ ํ๋ ์ด์์ ํ์ดํ๋ก ๊ตฌ์ฑ
  - ์ฌ์ฉ ์

```shell
[root@localhost dir01]# cat /etc/profile | more
```

```shell
[root@localhost dir01]# cat /etc/passwd | sort -r | more
```

<br>

<br>

<h2>shell ๋ฉํ ๋ฌธ์ ์ค์ต(๋ฌธ์ )</h2>

1.  /etc/ ๋ก ์ด๋ ํ์ ํธ๋(~) ๋ฌธ์๋ฅผ ์ฌ์ฉํ์ฌ ํ ์ฌ์ฉ์์ ๋๋ ํ ๋ฆฌ๋ก ์ด๋ํ์์ค.

``` shell
[root@localhost dir01]# cd /etc
[root@localhost etc]# cd ~
[root@localhost ~]#
```

2. /etc/sysconfig/network-scripts/๋ก ์ด๋ ํ์ ํ์ผ๋ก ๋ค์ ์ด๋ - ๋ฌธ์๋ฅผ ์ฌ์ฉํด์ ์ด๋ํด ๋ณด์์ค.

```shell
[root@localhost ~]# cd /etc/sysconfig/network-scripts/
[root@localhost network-scripts]# cd -
/root
[root@localhost ~]#
```

3. ์ด์  ๋ฌธ์ ์ ์ด์ด, ์์ ์ ํ ๋๋ ํ ๋ฆฌ๋ก ์ด๋๋ ์ํ์์ /etc/sysconfig/network-scripts ๋๋ ํ ๋ฆฌ์ ๋ด์ฉ์ ํ์ธํด๋ณด์์ค. (ํธ๋ ๋ฌธ์ ~ ์ด์ฉ)

```shell
[root@localhost ~]# ls ~-/
ifcfg-ens160
```

4. /media ๋๋ ํ ๋ฆฌ ์์ superman-season(1~3) ๋๋ ํ ๋ฆฌ๋ฅผ ๊ฐ๊ฐ ๋ง๋ค๊ณ  superman-season(1-3)-drama(01-10).avi ํ์ผ ์์ฑ ํ์ ์ด๋ฆ์ ๋ง์ถ์ด ๊ฐ๊ฐ ๋ฃ์ผ์์ค. (ํ์ผ ์ด๋์ ์ต๋ํ ๊ฐ๋จํ๊ฒ ์์ฑ)

```shell
[root@localhost media]# mkdir /superman-season{1..3}
[root@localhost media]# touch superman-season{1..3}-drama{01..10}.avi
[root@localhost media]# mv *n1*i /*1
[root@localhost media]# mv *n2*i /*2
[root@localhost media]# mv *n3*i /*3
[root@localhost ~]# ls -lR /superman-season{1..3}
/superman-season1:
ํฉ๊ณ 0
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season1-drama01.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season1-drama02.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season1-drama03.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season1-drama04.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season1-drama05.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season1-drama06.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season1-drama07.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season1-drama08.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season1-drama09.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season1-drama10.avi

/superman-season2:
ํฉ๊ณ 0
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season2-drama01.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season2-drama02.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season2-drama03.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season2-drama04.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season2-drama05.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season2-drama06.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season2-drama07.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season2-drama08.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season2-drama09.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season2-drama10.avi

/superman-season3:
ํฉ๊ณ 0
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season3-drama01.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season3-drama02.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season3-drama03.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season3-drama04.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season3-drama05.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season3-drama06.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season3-drama07.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season3-drama08.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season3-drama09.avi
-rw-r--r--. 1 root root 0  2์ 21 04:36 superman-season3-drama10.avi
```

5. ls -lR / ์ ์ ์ ์ถ๋ ฅ ๊ฐ์ ~/r01 ์ ์๋ ฅํ๊ณ , ์๋ฌ๊ฐ์ ~/r02์ ์๋ ฅํ์์ค.

```shell
[root@localhost ~]# ls -lR / 1> ~/r01 2> ~/r02
```

6.  ls -lR / ์ ๋ชจ๋  ์ถ๋ ฅ ๊ฐ์ ~/r03์ ์๋ ฅํ์์ค.

```shell
[root@localhost ~]# ls -lR / &> ~/r03
```

7. yum list ์ ๊ฒฐ๊ณผ๊ฐ ์ค์์ ssh ๋ผ๋ ํจํด์ด ๋ค์ด๊ฐ๋ ๊ฒ์ ์ถ๋ ฅํด๋ณด์์ค.

```shell
[root@localhost ~]# yum list | grep ssh
libssh.x86_64                                          0.9.4-2.el8                                            @anaconda
libssh-config.noarch                                   0.9.4-2.el8                                            @anaconda
openssh.x86_64                                         8.0p1-5.el8                                            @anaconda
openssh-askpass.x86_64                                 8.0p1-5.el8                                            @AppStream
openssh-clients.x86_64                                 8.0p1-5.el8                                            @anaconda
openssh-server.x86_64                                  8.0p1-5.el8   
...
```

8. 7๋ฒ์ ๊ฒฐ๊ณผ๋ฅผ r04์ ์ ์ฅํ์์ค(์ฌ๋ฌ๊ฐ์ง ๊ฐ๋ฅ)

```shell
[root@localhost ~]# yum list | grep ssh > r04
[root@localhost ~]# cat r04
libssh.x86_64                                          0.9.4-2.el8                                            @anaconda
libssh-config.noarch                                   0.9.4-2.el8                                            @anaconda
openssh.x86_64                                         8.0p1-5.el8                                            @anaconda
openssh-askpass.x86_64                                 8.0p1-5.el8                                            @AppStream
openssh-clients.x86_64                                 8.0p1-5.el8                                            @anaconda
openssh-server.x86_64                                  8.0p1-5.el8                                            @anaconda
```

