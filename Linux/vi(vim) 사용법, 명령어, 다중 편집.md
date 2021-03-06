<h1>vi(vim) 사용법, 명령어, 다중 편집</h1>



<h3>📌INDEX</h3>

- [vi의 3가지 모드](#vi의-3가지-모드)
-  [vi 명령어](#vi-명령어)
- [vi 다중 편집](#vi-다중-편집)
-  [vi 환경 설정](#vi-환경-설정)

- [번외: alias, unalias](#alias와-unalias)

<br><br>



<h2>vi의 3가지 모드</h2>

- vi는 다른 편집기들과는 다르게, 모드형 편집기라는 특징이 있다.

```shell
[root@localhost ~]# which vi
/usr/bin/vi
```

- 모드
  - **입력 모드(insert mode)** : 메모장처럼 텍스트를 자유롭게 편집하는 모드
    - Insert 키나 **i** 키로 명령 모드에서 입력 모드로 전환 가능
  - **명령 모드(Command mode)** : 말 그대로 다양한 명령을 내리는 모드
    - **ESC**키로 명령 모드로 전환 가능
  - **라인 모드(line mode)**
    - 콜론 모드, 대기 모드라고도 하며, **명령 모드에서 콜론(:)**을 입력하면 화면 맨 아랫줄에 입력 가능한 공간이 출력
    - 여기서 vi를 종료할 수 있다.



<br><br>

<h2>vi 명령어</h2>

- 명령 모드에 **입력 모드로 전환**
  - **i**  : 커서 앞(왼쪽)에 입력
  - a : 커서 다음(오른쪽)에 입력

- 입력 모드에서 **명령 모드로 전환**
  - **ESC **

- **저장과 종료**

  - **명령 모드**에서 작업

  - :q : 종료
  - :q! : 강제로 종료 
    - 일반적으로 수정 후 내용을 저장하지 않고 종료할 때 사용
  - :w [파일이름] : [파일이름]으로 저장
  - :wq : 저장 후 종료
  - :x 저장 후 종료

  - ZZ : 저장 후 종료

- **입력**
  - **명령 모드**에서 작업
  - i : 커서가 있는 위치에서 바로 입력 
  - a : 커서가 있는 문자 한칸 뒤에서 입력
  - s : 커서가 위치한 문자를 하나 삭제하고 입력  
    - [숫자]s : 커서 위치 뒤로 숫자만큼의 문자를 삭제 후 입력
  - o : 커서가 위치한 라인의 아래로 공백 라인을 확보하고 입력
  - I : 커서가 있는 라인의 가장 앞으로 이동 후 입력
  - A : 커서가 있는 라인의 가장 뒤로 이동 후 입력
  - S : 커서가 위치한 라인 하나를 삭제하고 입력
  - O:  커서가 위치한 라인의 위로 공백 라인을 확보하고 입력
- **커서 이동**
  - **명령 모드**에서 작업
  - 기본 이동
    - h, j, k, l : 좌, 하, 상, 우 커서 이동
    - G : 마지막 행으로 가기
    - gg : 파일의 가장 처음 라인(행)으로 이동
  - 단어 단위로 이동
    - w : 다음 단어의 첫 글자로 이동
    - b : 이전 단어의 첫 글자로 이동
    - e : 다음 단어의 마지막 위치로 이동
    - ge : 이전 단어의 마지막 위치로 커서 이동
  - 한 문장 내에서의 이동
    - ^ : 라인의 맨 앞으로 이동
    - $ : 라인의 맨 뒤로 이동
  - 원하는 줄 번호로 한 번에 이동
    - :숫자 : 지정한 숫자 행으로 이동
- **복사**
  - **라인모드(대기모드)** 에서 진행
  - 커서 이동 명령어와 혼합해서 사용
  - **y(yank)**
  - yw : 단어를 복사
  - yb : 커서를 기준으로 앞에 있는 단어 글자 복사
  - yy : 라인을 복사
    - **yw, yb, yy 명령 앞에 복사할 숫자 지정 가능** ex) : 4yw, 3yb, 4yy
  - y^ : 커서가 있는 앞쪽으로 복사
  - y$ : 커서가 있는 뒤쪽으로 복사
  - yH : 커서가 있는 라인 부터 화면에 보이는 윗 부분 까지 복사
  - yL :  커서가 있는 라인 부터 화면에 보이는 아랫 부분 까지 복사
  - ygg : 커서가 있는 라인 부터 파일의 가장 윗 부분 까지 복사
  - yG :커서가 있는 라인 부터 파일의 가장 아랫 부분 까지 복사
  - **n,my : n번재 라인부터 m번재 라인까지 복사 **
    - ex) :10,20y

- **붙여 넣기**
  - **p** : paste의 약자
    - 행 복사: 현재 커서가 위치한 줄 바로 아랫줄에 붙여넣기
    - 단어 복사: 현재 커서가 위치한 바로 다음 위치에 붙여넣기

- **잘라내기**
  - **라인 모드(대기 모드)**에서 작업
  - **c(cut)**
  - 커서 이동 명령어와 혼합해서 사용
  - cw : 단어를 잘라내기
  - cc : 라인을 잘라내기
    - cc, cw 명령 앞에 잘라낼 숫자 지정 가능 ex) 2c3w == 6cw (곱하기로 이루어짐)
  - c^ : 커서가 있는 앞쪽으로 잘라내기
  - c$ : 커서가 있는 뒤쪽으로 잘라내기
  - cH : 커서가 있는 라인 부터 화면에 보이는 윗 부분 까지 잘라내기
  - cL : 커서가 있는 라인 부터 화면에 보이는 아랫 부분 까지 잘라내기
  - cgg :  커서가 있는 라인 부터 파일의 가장 윗 부분 까지 잘라내기
  - cG : 커서가 있는 라인 부터 파일의 가장 아랫 부분 까지 잘라내기
  - **n,mc** : n번째 라인부터 m번째 라인까지 잘라내기
- **삭제**
  - 문자 삭제
    - x : 커서가 위치한 뒤로 문자 삭제
    -  X : 커서가 위치한 앞으로 문자 삭제
  - 단어와 라인(행) 삭제
    - dw : 단어를 삭제
    - dd : 라인을 삭제
    - d^ : 커서가 있는 앞쪽으로 삭제
    - d$ : 커서가 있는 뒤쪽으로 삭제
    - dH : 커서가 있는 라인 부터 화면에 보이는 윗 부분 까지 삭제
    - dL : 커서가 있는 라인 부터 화면에 보이는 아랫 부분 까지 삭제
    - dgg : dgg 커서가 있는 라인 부터 파일의 가장 윗 부분 까지 삭제
    - dG :  커서가 있는 라인 부터 파일의 가장 아랫 부분 까지 삭제
    - :n,md : n번째 라인부터 m번째 라인까지 삭제

- **되돌리기와 다시실행**

  - **되돌리기(Undo), 다시 실행(Redo)**
  - u : 이전으로 되돌리기
  - ctrl + r : 되돌리기한 것을 다시 실행

- **검색**

  - /문자열 : 앞에서 부터 문자열을 찾는다 (정규화 표현식 가능)
  - ?문자열 : 뒤에서 부터 문자열을 찾는다 (정규화 표현식 가능)
  - n : 뒤로 검색
  - N : 앞으로 검색

- **치환(바꾸기)**

  - 각 행의 처음 나오는 old를 찾아 new로 바꾼다.

  ```shell
  :%s/old/new
  ```

  - 모든 old를 찾아 new로 바꾼다.

  ```
  :%s/old/new/g
  ```

  - 모든 old를 찾아 new로 바꾸기 전에 물어본다.
    -  (y/n/a/q/l/^E/^Y)?
      - y : 바꾼다
      - n : 안바꾼다
      - a : 나머지 모두 바꾼다
      - q : 커서 위치의 문자를 바꾸지 않고 종료한다.
      - l : 커서 위치의 문자까지만 바꾸고 종료한다.
      - ^E  ^Y : 변경을 하다가 아래(^E) 위(^Y)로  변경하고자 하는 부분을 찾아볼 때

  ```
  :%s/old/new/gc
  ```

- 이외에 자주 사용하는 기능들

  - :set nu : 행번호 출력
  - :set nonu : 행번호 숨기기
  - :nohl : 하이라이트 없애기
  - :cd : 현재 디렉토리 출력

<br><br>

<h2>vi 다중 편집</h2>

```shell
[root@localhost ~]# vim aaa bbb ccc
```

- 예시로 설명
  - 다중 파일 오픈 시, :n 과 :N 을 이용하여 다음 파일로 이동 가능
  - 오픈하면 aaa파일이 오픈되고 :n 하면 ccc파일이 오픈된다.
  - ccc파일에서 :N 하게 되면 aaa 파일로 이동하게 된다.
- 3개 이상의 파일을 열어서 동시에 작업하는 경우
  - **2개 이상의 파일을 한번에 넘어서 이동** 할 시 
    - :2n , :2N 형태로 명령한다.
    - n : 뒤로
    - N : 앞으로
- 주의: 파일의 수정이 발생한 경우, **저장이 되지 않은 상태로는 이동이 불가능**하다.
  - 반드시 w로 저장을 해주거나 :N! 와 같이 !를 붙여주면 저장하지 않고 이동 가능
- **:ls** : 현재 열린 파일 목록 및 번호 확인

```shell
:ls
	  1      "aaa"                          7 줄
	  2 #    "ccc"                          6 줄
	  3 %a   "eee"                          1 줄
```

- **:b[숫자]** : ls 명령어를 통해 확인된 파일 숫자로 이동
  - ex)b1 -> 첫번째 파일로
  - ex)b2 -> 두번째 파일로

<br><br>

<h2>vi 환경 설정</h2>

- vi의 환경을 설정하기 위해서는 **.vimrc** 파일을 편집해야한다.

```shell
[root@localhost ~]# vi .vimrc
```

- 생성된 .vimrc 파일은 빈 파일이다. 따라서 여기에 **필요한 설정값들을 입력**해주어야한다.

- 설정값은 사용자의 취향에 맞게 넣는다.

```
set nu
set autoindent
set cindent


set number " 라인 넘버를 보여준다
set mouse=a " 마우스를 클릭하는 곳으로 커서를 옮긴다

set autoindent "indent를 다음줄에도 유지한다
set smartindent "문법에 맞게 자동으로 indent를 넣어준다
                "(e.g., 괄호 다음줄에 자동으로 indent 적용

autocmd FileType c,cpp,java :set cindent "지정된 filetype에 대해 cindent를 적용한다
set cinoptions=g0,t0 "switch~case문 등 세부 indent를 정의한다
                    "참고(http://vimdoc.sourceforge.net/htmldoc/indent.html)

set tabstop=4 "Tab의 크기를 결정한다
set shiftwidth=4 "indent의 크기를 결정한다
set expandtab "Tab을 공백(space)으로 자동 전환한다

set ignorecase "검색할 때 대소문자 구분을 하지 않는다
set smartcase "검색할 때 대문자를 섞어 사용하면 대소문자 구분하여 검색하고,
                "소문자로만 쓰면 대소문자 구분을 하지 않는다

set incsearch "검색시 단어 전체를 입력하지 않아도, 입력된 글자까지 순차적으로 검색한다
set hlsearch "검색된 단어를 highlight 한다

set title "상단에 파일 이름을 표시해준다
set ruler "하단에 현재 커서의 위치를 표시해준다

colo default "color set을 결정한다

set textwidth=90
set colorcolumn=+1 "91번째줄 색을 바꾼다(line length 맞추기 위한 guideline)
hi ColorColumn ctermbg=235 "세로줄 색깔

```

<br><br>

<h2>alias와 unalias</h2>

- **alias** 

  - 리눅스의 **기본 명령어와 긴 명령어를 다른 이름으로 간단히 줄여서 사용**할 수 있는 별칭
  - 어떤 명령어 이든지, 명령의 길이가 얼마이든지 상관없이, 사용자가 편한 상태로 바꾸어 사용 가능

  ```
  alias 별명='명령어 정의'
          unalias 별명
  ```

  - 시스템을 재부팅하고 나면 초기화된다.
  - 예시

```
[root@localhost ~]#alias cp='cp -i'
```

- **unalias** 

  - **alias로 지정 된 명령어를 제거**하는 명령어

  - mycommand라는 명령어가 alias로 지정되어 있다고 가정하자.
  - 해당 별칭을 제거하기 위해 다음과 같이 사용

  ```shell
  [root@localhost ~]#unalias mycommand
  ```

  
