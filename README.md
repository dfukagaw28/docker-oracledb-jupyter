# Jupyter 経由で Oracle Database に接続するための Dockerfile

## 前提

- [Docker](https://www.docker.com/) をインストール済み
- [Git](https://git-scm.com/) をインストール済み
- インターネットに接続できる
- ディスク容量に十分な空きがある
- Oracle Database サーバに接続できる
  - 必要に応じて VPN 接続などを行っておく

### 動作確認済みの環境

- Microsoft Windows
  - Windows 10 (21H1 19043.1266)
  - WSL2 (Ubuntu-20.04)
  - Docker (20.10.8, build 3967b7d)

## 使い方

### ファイルを取得する

このリポジトリを複製する。
もし Git が無ければ，必要なファイルを zip 形式でダウンロードして展開してもよい。

```
$ cd /path/to/my/workspace
$ git clone https://github.com/dfukagaw28/docker-oracledb-jupyter.git
$ cd docker-oracledb-jupyter
```

### ビルド

Docker イメージを作成する。
上記で作成したディレクトリ docker-oracledb-jupyter にて作業すること。

イメージ名は何でもよい。ここでは `my-oracle-jupyter` としている。

```
$ docker build -t my-oracle-jupyter .
```

### コンテナを起動する

作成した Docker イメージをもとに Docker コンテナを新たに作成し，作成したコンテナを起動する。
コンテナを起動すると自動的に Jupyter Notebook が実行されるようになっている。
デフォルトではアクセス制限を緩くしているため（使い勝手を重視），必要に応じて適切な制限をかけることが望ましい。

```
$ docker run --rm -it -p 8888:8888 -v $(pwd):/work my-oracle-jupyter
```

Jupyter Notebook サーバにアクセスするには，Web ブラウザを開いて http://localhost:8888/ を開けばよい。

### Oracle Database サーバへの接続テストをおこなう

まず，Oracle Database サーバ（以下 DB サーバ）への接続情報をサーバ管理者等に尋ねておく。

サーバへの接続情報は漏洩のないよう厳重に管理すること。

次に，Jupyter Notebook にて以下のコードを実行する。
ただし，パラメータ `DBUSER`, `DBDSN` は適宜変更すること。

```py
import cx_Oracle
import pandas as pd
import getpass

ORACLE_USER = 'XXXXXXXX'
ORACLE_HOST = 'XXXXXXXX'
ORACLE_PORT = '1521'
ORACLE_SID = 'XXXXXXXX'

ORACLE_PASSWORD = getpass.getpass('DBPASS: ')

def make_connection():
    dsn = cx_Oracle.makedsn(ORACLE_HOST, ORACLE_PORT, ORACLE_SID)
    connection = cx_Oracle.connect(
        user=ORACLE_USER,
        password=ORACLE_PASSWORD,
        dsn=dsn,
        encoding='UTF8',
        nencoding='UTF8',
    )
    return connection
```

パラメータの値は，たとえば以下のようにする（実際の値は，サーバ管理者から提供された情報を用いる）。

```py
ORACLE_USER = 'salesadmin'
ORACLE_HOST = 'dbhost.example.com'
ORACLE_PORT = '1521'
ORACLE_SID = 'orcl'
```

パスワード `DBPASS` の値は，上のコードを実行する際に入力を促される。
`DBPASS` の値もコードに埋め込むことは可能であり，そちらの方が便利ではあるが，ノートブック（ipynb）に平文のまま保存されるためノートブックの管理を厳重におこなう必要がある。

最後に，コードセルに以下を入力する。

```py
conn = make_connection()
```

エラーが発生しなければ，接続に成功しているはずである。

### SQL 文を実行する

次に，SQL 文を実行し，その結果を出力させる。
Jupyter のコードセルに以下を入力し，実行すれば結果が表示される。
これは，ユーザーがアクセス可能なテーブルの一覧を表示する例である。

```py
sql = '''\
SELECT owner, table_name
FROM all_tables
ORDER BY owner, table_name
'''
df = pd.read_sql_query(sql, make_connection())
df
```
