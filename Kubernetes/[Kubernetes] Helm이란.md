# [Kubernetes] Helm์ด๋?

<br>

### ๐Index

- [Helm์ด๋?](#helm์ด๋)
- [Helm ์ค์นํ๊ธฐ](#helm-์ค์นํ๊ธฐ)

- [Helm ์ฌ์ฉ๋ฒ](#helm-์ฌ์ฉ๋ฒ)

<br>

<br>

## Helm์ด๋?

[Helm](https://helm.sh/)์ด๋, **Kubernetes ํจํค์ง ๊ด๋ฆฌ๋ฅผ ๋์์ฃผ๋ ๊ฒ**์ผ๋ก, yaml ํ์ผ์ ๋ชจ์์ด๋ผ๊ณ  ํ  ์ ์๋ค.

<br>

Helm์ ๋ํ ๋ง์ ๋ฌธ์๋ ์ฑ์์ 2๋ฒ์ ์ ๋ค๋ฃจ๊ณ  ์๋๋ฐ, 2๋ฒ์ ์ ๋ ์ด์ ๊ฐ๋ฐ๋์ง ์๋๋ค.

2๋ฒ์ ์ 3๋ฒ์ ๊ณผ ๋ช๋ น์ด๋ ๋ค๋ฅด๊ณ , ์ํคํ์ฒ ๊ตฌ์กฐ๋ ๋ค๋ฅด๋ค. 

์๋์ ๊ทธ๋ฆผ์ด ๋ฒ์ 2์ ์ํคํ์ฒ๋ก,



<img src="https://miro.medium.com/max/1200/1*mClrYLFakC6B6f62vVnhcA.png" alt="img" style="zoom: 50%;" />



ํนํ ๊ฐ์ฅ ํฐ ์ฐจ์ด์ ์ Helm Tiller์ ์ฌ๋ถ์ด๋ค.

Helm Tiller๋ Pod๋ก, ๋ฒ์ 2์์ ์ฌ์ฉ๋์๋ค๊ฐ 

์ฌ๋ฌ๊ฐ์ง ๋ณด์ ๋ฌธ์ ๋ก ๋ฒ์ 3์์๋ถํฐ๋ ๋ ์ด์ ์ฌ์ฉ๋์ง ์๋๋ค.

Tiller์ Client๋ ์๋ก gRPC๋ก ํต์ ์ ํ์ผ๋, **๋ฒ์ 3๋ถํฐ๋ Client์์ ๋ฐ๋ก API Server๋ก ์์ฒญ**ํ๋ค.

์๋์ ๊ทธ๋ฆผ์ด Helm ๋ฒ์ 3์ ์ํคํ์ฒ์ด๋ค.

<img src="https://developer.ibm.com/developer/default/blogs/kubernetes-helm-3/images/helm3-arch.png" alt="What's in Helm 3? - IBM Developer" style="zoom:50%;" />

์ถ์ฒ: https://developer.ibm.com/blogs/kubernetes-helm-3/

<br>

`/kubespray/inventory/mycluster/group_vars/k8s_cluster/addon.yml` ํ์ผ์ ๋ณด๋ฉด,

```shell
# Helm deployment
helm_enabled: false
```

`helm_enable : false` ๋ผ๊ณ  ์ค์ ๋์ด์๋๋ฐ, true๋ผ๊ณ  ์ค์ ํ๋ฉด helm ๋ฒ์ 2๋ฅผ ์ฌ์ฉํ๊ฒ ๋๋ค.

๋ฒ์ 2๋ ์ฌ์ฉํ์ง ์์ ๊ฒ์ด๊ธฐ ๋๋ฌธ์, ์์ผ๋ก tiller๋ผ๋ ์ฉ์ด๊ฐ ๋์ค๋ฉด ๋๊ธฐ๋ฉด ๋๋ค.

<br>

Helm์ ์ฌ์ฉํ๊ธฐ์ ์์, **3๊ฐ์ง ์ฃผ์ ๊ฐ๋**์ ๊ผญ ์์์ผํ๋ค.

<br>

#### 1. Chart

Chart๋ **helm์ ๋ฆฌ์์ค ํจํค์ง**๋ก, 

k8s cluster์์ ์ ํ๋ฆฌ์ผ์ด์์ด ๊ธฐ๋๋๊ธฐ ์ํด ํ์ํ ๋ชจ๋  ๋ฆฌ์์ค๋ค์ด ํฌํจ๋์ด ์๋ค.

<br>

**chart ๊ตฌ์กฐ**

```null
<Chart Name>/
  Chart.yaml 
  values.yaml
  templates/ 
```

- Chart.yaml: ์ฐจํธ์ ๋ฉํ๋ฐ์ดํฐ(์ฐจํธ์ ์ด๋ฆ, ๋ฒ์ , ๋ง๋  ์ฌ๋ ๋ฑ)
- values.yaml: ํจํค์ง๋ฅผ ์ปค์คํฐ๋ง์ด์ฆ/์ฌ์ฉ์ํ(value)
- templates: ์ค์  YAML ์ค๋ธ์ ํธ ํ์ผ๋ค์ด ์๋ ๋๋ ํ ๋ฆฌ

<br>

Helm ์ฐจํธ๋ฅผ ๊ฒ์ํ๋ ์ฌ์ดํธ : https://artifacthub.io/ 

- ๋จ, ํจํค์ง๋ฅผ ๊ฐ์ง๊ณ  ์์ง๋ ์๋ค(์ ์ฅ์๊ฐ ์๋)
- ์์ : [bitnami/charts: Bitnami Helm Charts (github.com)](https://github.com/bitnami/charts)

<br>

#### 2. Repository(์ ์ฅ์)

์ฐจํธ ์ ์ฅ์๋ก, ์ฐจํธ๋ฅผ ๋ชจ์๋๊ณ  ๊ณต์ ํ๋ ์ฅ์์ด๋ค.

<br>

#### 3. Release(๋ฆด๋ฆฌ์ฆ)

๋ฆด๋ฆฌ์ฆ๋ k8s cluster์์ ๊ตฌ๋๋๋ **์ฐจํธ ์ธ์คํด์ค**์ด๋ค. 

์ผ๋ฐ์ ์ผ๋ก ๋์ผํ Chart๋ฅผ ์ฌ๋ฌ ๋ฒ ์ค์นํ  ์ ์๊ณ  ์ด๋ ์๋ก์ด Release๋ก ๊ด๋ฆฌ๋๊ฒ ๋๋ค. 

Release๋  ๋ ํจํค์ง๋ ์ฐจํธ์ Config๊ฐ ๊ฒฐํฉ๋์ด ์ ์ ์คํ๋๊ฒ ๋๋ค.

 <br>

์๋ ์์์ ๊ฐ์ด ์ฐ๊ณ๋๋ค๊ณ  ๋ณด๋ฉด ๋๋ค.

k8s cluster ๋ด๋ถ์ **Helm Chart**๋ฅผ ์ํ๋ **Repository์์ ๊ฒ์ ํ ์ค์น** โถ ๊ฐ ์ค์น์ ๋ฐ๋ฅธ **์๋ก์ด Release ์์ฑ**

 <br>

<br>

## Helm ์ค์นํ๊ธฐ

Helm์ ์ค์นํ๊ธฐ์ ์์, ๋ช๊ฐ์ง ์ฌ์  ์๊ตฌ์ฌํญ์ด ์๋ค.

- k8s cluster๊ฐ ์์ด์ผํ๋ค.
- kubeconfig๊ฐ ์์ด์ผํ๋ค. ์์ผ๋ฉด apiserver๋ฅผ ์ฐพ์๊ฐ ์ ์๊ธฐ ๋๋ฌธ์ด๋ค.
- helm์ด ์ค์น๋๊ณ  ๊ตฌ์ฑ๋์ด์ผํ๋ค.

<br>

์ด์  [Helm | Installing Helm](https://helm.sh/docs/intro/install/)์ ๋ฐ๋ผ Helm์ ์ค์นํด๋ณด์.

๋จผ์  ๋ค์์ ๋ช๋ น์ด๋ค์ ์คํํ๋ค.

```shell
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

๋ค์์ผ๋ก helm ๋ช๋ น์ด ์๋์์ฑ์ ์ํด zsh ํ๋ฌ๊ทธ์ธ์ helm ์ถ๊ฐํ๋ค.

`~/.zshrc`

```shell
plugins=(
...
	helm
)
```

์์  ํ ๋ณ๊ฒฝ ์ฌํญ์ ์ ์ฉํ  ์ ์๋๋ก ๋ค์ ๋ช๋ น์ด๋ฅผ ์คํํ๋ค.

```shell
$ source ~/.zshrc
```

์ค์น ํ์ธ

```shell
$ helm version
```

<br>

<br>

## Heml ์ฌ์ฉ๋ฒ

[Helm | Using Helm](https://helm.sh/docs/intro/using_helm/)

<br>

#### Artifact hub ๊ฒ์

```shell
$ helm search hub wordpress
```

<br>

#### Repository ์ถ๊ฐ

```shell
$ helm repo add [๋ ํฌ์งํ ๋ฆฌ ์ด๋ฆ] [๋ ํฌ์งํ ๋ฆฌ ์ฃผ์]
```

์ฌ๊ธฐ์ ๋ ํฌ์งํ ๋ฆฌ ์ด๋ฆ์ ์ด๋ป๊ฒ ์ง์ ํ๋๋์ ๋ฐ๋ผ ํจํค์ง๋ช์ด ๋ฌ๋ผ์ง๋ค. 

ํจํค์ง ์ด๋ฆ ์์ ` ๋ ํฌ์งํ ๋ฆฌ์ด๋ฆ/` ์ด ๋ถ๊ฒ ๋๋ค.

<br>

์์

```shell
$ helm repo add bitnami https://charts.bitnami.com/bitnami
```

--> wordpress ํจํค์ง ์ด๋ฆ  : `bitnami/wordpress`

<br>

#### Repository ๊ฒ์

Chart ๋ฆฌ์คํธ๋ฅผ ๊ฒ์ํ์ฌ ์ถ๋ ฅํ๋ค.

```shell
$ helm search repo <์ ์ฅ์> <PATTERN>
```

์์ : bitnami ๋ ํฌ์งํ ๋ฆฌ์ ์ ์ฅ๋ Chart ๋ชฉ๋ก์ ์ถ๋ ฅํ๋ค.

```shell
$ helm search repo bitnami
```

<br>

#### Repository ๋ฆฌ์คํธ ์ถ๋ ฅ

๋ฑ๋ก๋ ๋ ํฌ์งํ ๋ฆฌ(์ ์ฅ์) ๋ชฉ๋ก์ ์ถ๋ ฅํ๋ค.

```shell
$ helm repo list
```

<br>

#### Chart ์๋ฐ์ด๋

```shell
$ helm repo update
```

`apt update` ํ๋ฏ์ด, ์ถ๊ฐํ ๋ฆฌํ์งํ ๋ฆฌ์ ์ธ๋ฑ์ค ์ ๋ณด๋ฅผ ์ต์ ์ผ๋ก ์๋ฐ์ดํธ ํ๋๊ฒ์ด ํ์ํ๊ธฐ ๋๋ฌธ์

๋ค์๊ณผ ๊ฐ์ด helm ์ฐจํธ์ ์ ๋ณด๋ฅผ ์๋ฐ์ดํธํ๋ค.

<br>

#### Chart ์ค์น

```shell
$ helm install [NAME] [CHART] [flags]
```

`NAME` ์ ๋ฆด๋ฆฌ์ฆ ์ด๋ฆ์ด๋ค.

์ค์น ์๋ฃ์ ๋์ค๋ text๋ ๋ ํฌ์งํ ๋ฆฌ์ `NOTES.txt`์ด๋ค. (์๋ ๊ฒฝ์ฐ๋ ์์)

`NOTES.txt`๋ ๊ฐ๋ตํ๊ฒ ์ฌ์ฉ ๋ฐฉ๋ฒ์ด ์ค๋ช๋์ด์๋ค.

```shell
$ helm install mywordpress bitnami/wordpress
```

<br>

๋ค์๊ณผ ๊ฐ์ด `--set` ์ต์์ ์ฌ์ฉํ์ฌ value๋ฅผ ์ธํํ  ์ ์๋ค. 

์ฆ, ์ฐจํธ๋ฅผ ์ฌ์ฉ์ํ ํ  ์ ์๋ค.

```shell
$ helm install mywordpress bitnami/wordpress --set replicaCount=2
```

```shell
$ helm install mywordpess bitnami/wordpress --set replicaCount=2 --set service.type=NodePort
```

๊ทธ๋ฌ๋ ์์  ์ฌํญ์ด ๋ง์ ๋์๋ `--set` ์ต์์ ์ฌ๋ฌ๋ฒ ๋ถ์ด๋ ๊ฒ์ด ๋ฒ๊ฑฐ๋ก์ฐ๋ฏ๋ก, 

์ผ๋ฐ์ ์ผ๋ก yaml ํ์ผ๋ก ์ค์ ํ๋ค. yaml ํ์ผ๋ก ์ฌ์ฉ์ํํ๋ ๊ฒ์ ๋ค์์ ํ์ธํ  ์ ์๋ค.

<br>

#### Chart ์ ๋ณด ํ์ธ

`values.yaml ` ํ์ธ

```shell
$ helm show values bitnami/wordpress
```

ํ์ผ๋ก ๊ฐ์ ธ์ค๊ธฐ

```shell
$ helm show values bitnami/wordpress > wp-value.yaml
```

`chart.yaml `ํ์ธ

```shell
$ helm show chart bitnami/wordpress
```

<br>

#### Chart ๋ง๋ค๊ธฐ

```shell
$ helm create [PACKAGE NAME]
```

ํจํค์ง ์ด๋ฆ์ผ๋ก ๋๋ ํ ๋ฆฌ๊ฐ ๋ง๋ค์ด์ง๋ฉฐ, ๋๋ ํ ๋ฆฌ ๋ด๋ถ์ ๊ธฐ๋ณธ ๋ผ๋๊ฐ ๋ง๋ค์ด์ง๋ค.

<br>

์์

```shell
$ helm create mypkg
$ cd mypkg
```

```shell
$ ls
Chart.yaml  charts  templates  values.yaml
```

```shell
$ ls templates 
NOTES.txt     deployment.yaml  ingress.yaml  serviceaccount.yaml
_helpers.tpl  hpa.yaml         service.yaml  tests
```

<br>

#### History ํ์ธํ๊ธฐ

```shell
$ helm history [NAME]
```

<br>

#### Rollbackํ๊ธฐ

```shell
$ helm rollback [NAME] [REVISION]
```

<br>

#### ๋ฆด๋ฆฌ์ฆ ๋ชฉ๋ก ํ์ธ

```shell
$ helm list                                    
```

<br>

#### ๋ฆด๋ฆฌ์ฆ ์ญ์ 

```shell
$ helm uninstall [NAME]
```

๋๋

```shell
$ helm delete [NAME]
```



์ค์  ๋ฆฌ์์ค(ํ๋, ์ปจํธ๋กค๋ฌ ๋ฑ)๋ ํจ๊ป ์ง์์ง๋ค.

<br>

#### ๋ฆด๋ฆฌ์ฆ ์๊ทธ๋ ์ด๋

```shell
$ helm upgrade [NAME] [CHART] [FIAG]
```

ํ์ผ์ ๋ด์ฉ(ํ๋ผ๋ฏธํฐ)์ ์์ ํ ๊ฒฝ์ฐ ์๊ทธ๋ ์ด๋๋ฅผ ํ๋ค.

<br>

์์

๋ณ๊ฒฝํด์ผํ  ํ๋ผ๋ฏธํฐ๊ฐ ์ฌ๋ฌ๊ฐ์ธ ๊ฒฝ์ฐ, ์ฐจํธ install ์ `--set` ์ต์์ผ๋ก ์ผ์ผ์ด ์ง์ ํ๋ ๊ฒ์ ๋ฒ๊ฑฐ๋กญ๊ธฐ ๋๋ฌธ์ 

์ผ๋ฐ์ ์ผ๋ก yaml ํ์ผ๋ก ๋ง๋ค์ด์ค๋ค.

```shell
$ helm show value bitnami/wordpress > wp-value.yaml
```

- `-f` : `yaml` ํ์ผ ์ง์ 

์์ ๊ฐ์ด `helm show` ๋ช๋ น์ ํตํด ํ์ผ ์ ์ฒด๋ฅผ ๋ฐ์์ ์์ ํ๋ ๊ฒ๋ ๊ฐ๋ฅํ๊ณ ,

๋ค์๊ณผ ๊ฐ์ด ํ์ํ ๋ถ๋ถ๋ง ์ง์ ํ์ฌ ํ์ผ๋ก ์์ฑํ๋ ๊ฒ๋ ๊ฐ๋ฅํ๋ค.

`wp-value.yaml`

```yaml
replicaCount: 2
service:
  type: LoadBalancer
```

```shell
$ helm upgrade mywordpress bitnami/wordpress -f wp-value.yaml
```

<br>

#### ๋ฆด๋ฆฌ์ฆ ์๊ทธ๋ ์ด๋ ํ์คํ ๋ฆฌ

๋ฆด๋ฆฌ์ฆ๊ฐ ์๊ทธ๋ ์ด๋๋ ํ์คํ ๋ฆฌ๋ค์ ํ์ธํ  ์ ์๋ค.

```shell
$ helm history [NAME]
```

<br>

#### ๋ฆด๋ฆฌ์ฆ ๋กค๋ฐฑ

์ง์ ํ REVISION์ผ๋ก ๋กค๋ฐฑํ๋ค.

```shell
$ helm rollback [NAME] [REVISION]
```

<br>

<br>

## Helm ์ค์ต

๐ป ์ค์ต : Helm Chart๋ก Wordpress ๋ฐฐํฌํ๊ธฐ

<br>

bitnami ๋ ํฌ์งํ ๋ฆฌ๋ฅผ ์ถ๊ฐํ๋ค.

```shell
$ helm repo add bitnami https://charts.bitnami.com/bitnami
```

๋ ํฌ์งํ ๋ฆฌ๊ฐ ์ถ๊ฐ๋ ๊ฒ์ ํ์ธํ๋ค.

```shell
$ helm repo list
NAME    URL                               
bitnami https://charts.bitnami.com/bitnami
```

๋ ํฌ์งํ ๋ฆฌ์์ wordpress ์ฐจํธ๋ฅผ ๊ฒ์ํ๋ค.

```shell
$ helm search repo wordpress 
NAME                    CHART VERSION   APP VERSION     DESCRIPTION                                       
bitnami/wordpress       14.2.7          5.9.3           WordPress is the world's most popular blogging ...
bitnami/wordpress-intel 1.3.0           5.9.3           WordPress for Intel is the most popular bloggin...
```

`bitnami/wordpress` ์ฐจํธ๋ฅผ ์ค์นํ๋ค.

```shell
$ helm install mywordpress bitnami/wordpress
```

์ค์นํ๋ฉด ์ฌ์ฉ๋ฐฉ๋ฒ์ด ์ถ๋ ฅ๋๋๋ฐ, ๋ค์๊ณผ ๊ฐ์ด ๋ก๊ทธ์ธ ์ ๋ณด๋ฅผ ํ์ธํ  ์ ์๋ค.

```shell
3. Login with the following credentials below to see your blog:

echo Username: user
echo Password: $(kubectl get secret --namespace monitor mywordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
```

์ค๋ช์ ๋ฐ๋ผ ๋ค์๊ณผ ๊ฐ์ด ํจ์ค์๋๋ฅผ ํ์ธํ  ์ ์๋ค.

```shell
$ echo Password: $(kubectl get secret --namespace monitor mywordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
Password: lIyCXapQF9
```

ํ์ฌ ๊ธฐ๋ณธ replicas๋ 1์ด๊ณ , ํ๋๋ฅผ 2๊ฐ ์์ฑํ๊ธฐ ์ํด replicas๋ฅผ 2๋ก ์์ ํด๋ณด์.

๋ฐฉ๋ฒ์ 2๊ฐ์ง๊ฐ ์๋ค.

- `--set` ์ต์ ์ฌ์ฉํ๊ธฐ

```shell
$ helm upgrade mywordpress bitnami/wordpress --set replicaCount=2
```

- yaml ํ์ผ์ ์์ฑํ์ฌ `-f` ์ต์์ผ๋ก ์ง์ ํ๊ธฐ

`wp-value.yaml`

```shell
replicaCount: 2
```

```shell
$ helm upgrade mywordpress bitnami/wordpress -f wp-value.yaml
```

<br>

2๊ฐ์ง ๋ฐฉ๋ฒ ์ค ํ๊ฐ์ง ๋ฐฉ๋ฒ์ ์ ํํ์ฌ ์๊ทธ๋ ์ด๋๋ฅผ ์งํํ๋ฉด,

๋ค์๊ณผ ๊ฐ์ด history๋ฅผ ํตํด ํ์ธํ  ์ ์๊ณ ,

```shell
$ helm history mywordpress 
REVISION        UPDATED                         STATUS          CHART                   APP VERSION    DESCRIPTION     
1               Fri May 27 16:10:56 2022        superseded      wordpress-14.3.1        5.9.3          Install complete
2               Fri May 27 16:15:13 2022        deployed        wordpress-14.3.1        5.9.3          Upgrade complete
```

ํ๋๋ 2๊ฐ ์์ฑ๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค.

```shell
$ kubectl get all
NAME                              READY   STATUS             RESTARTS      AGE
pod/mywordpress-ff494df9c-djpfg   0/1     Running            0             3m30s
pod/mywordpress-ff494df9c-h4qrk   0/1     Running            0             3m30s
pod/mywordpress-mariadb-0         0/1     Running            0             3m40s

NAME                          TYPE           CLUSTER-IP     EXTERNAL-IP       PORT(S)                      AGE
service/mywordpress           LoadBalancer   10.233.7.247   192.168.100.240   80:30803/TCP,443:30166/TCP   7m47s
service/mywordpress-mariadb   ClusterIP      10.233.23.89   <none>            3306/TCP                     7m47s

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mywordpress    /2     2                0      7m47s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/mywordpress-ff494df9c   2         2          2      7m47s

NAME                                   READY   AGE
statefulset.apps/mywordpress-mariadb   1/1     7m47s
```

๋ก๋๋ฐธ๋ฐ์์ `EXTERNAL-IP`๋ก ์ ์ํด์ ํ์ธํด๋ณด์.

<br>

![image-20220527114201905](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220527114201905.png) 

<br>

์ ์์ ์ผ๋ก ์ ์ ๋๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค.

<br>

๋ง์ง๋ง์ผ๋ก ์ค์น๋ ๋ฆด๋ฆฌ์ฆ๋ฅผ ์ญ์ ํ๋ฉด, ๋ฆฌ์์ค๊น์ง ํจ๊ป ์ง์์ง๋ค.

```shell
$ helm uninstall mywordpress
```

<br>

<br>

<br>

<br>

์ฐธ๊ณ 

https://tech.ktcloud.com/51
