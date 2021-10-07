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

まず，Jupyter Notebook にて以下のコードを実行する。

```
import cx_Oracle
import pandas as pd

DBUSER = 'XXXXXXXX'
DBDSN = 'XXXXXXXX'
DBPASS = input('DBPASS: ')

def make_connection():
    connection = cx_Oracle.connect(
        user=DBUSER,
        password=DBPASS,
        dsn=DBDSN,
        encoding='UTF8',
        nencoding='UTF8',
    )
    return connection

def list_tables():
    sql = '''\
SELECT owner, table_name
FROM all_tables
ORDER BY owner, table_name
'''
    df = pd.read_sql_query(sql, make_connection())
    return df
```

ただし，パラメータ `DBUSER`, `DBDSN` は適宜変更すること。

たとえば以下のようにする（実際の値は，サーバ管理者から提供された情報を用いる）。

```
DBUSER = 'salesadmin'
DBDSN = 'dbhost.example.com:1522/sales.example.com'
```

パスワード `DBPASS` の値は，上のコードを実行する際に入力を促される。
`DBPASS` の値もコードに埋め込むことは可能であり，そちらの方が便利ではあるが，ノートブック（ipynb）に平文のまま保存されるためノートブックの管理を厳重におこなう必要がある。
