# 環境構築資料

- [環境構築資料](#環境構築資料)
  - [Laravelのライブラリ導入とコマンド一覧](#laravelのライブラリ導入とコマンド一覧)
  - [Docker開発環境構築手順](#docker開発環境構築手順)
    - [Dockerファイル全体構成](#dockerファイル全体構成)
    - [必要条件とツールの導入](#必要条件とツールの導入)
    - [wsl上での構築手順(任意)](#wsl上での構築手順任意)
    - [Dockerインフラ構築](#dockerインフラ構築)
    - [コンテナ内での作業](#コンテナ内での作業)
    - [プロジェクトの作成とLaravel環境設定](#プロジェクトの作成とlaravel環境設定)
  - [Vite設定](#vite設定)
  - [テスト開発環境設定とDB設定](#テスト開発環境設定とdb設定)
  - [開発環境URLアクセス法](#開発環境urlアクセス法)
  - [Dockerコマンド](#dockerコマンド)

## 置くところ
volumeをCドライブとかとやり取りするとめちゃくちゃ重いのでwslのlinuxの中の、homeとかに置くといいらしい。<br>
なので `\\wsl.localhost\Ubuntu\home\●linuxのユーザ名●\` の下にprojectのファイル置き場みたいのを作って置いたらいいと思う。<br>
例 `\\wsl.localhost\Ubuntu\home\●linuxのユーザ名●\projects\someproject` の中に、下記構造物を入れる。<br>
上のパスの someproject が下記例で言うところの ｢/projectフォルダ｣。

## 構造
```
/projectフォルダ
    .devcontainer/
        db/
            Dockerfile
            my.cnf
        php/
            Dockerfile
            php.ini
        phpMyAdmin/
            Dockerfile
            php.ini
        proxy/
            Dockerfile
            default.conf.template
        .env
        docker-compose.yml
    docker_volumes/
        db/
            (何も置かない)
        php/
            laravel/
                (何も置かない)
            log/
                (何も置かない)
        proxy/
            ssl/
                (ホスト側で生成した秘密鍵を置く。 localhost-key.pem と localhost.pem 、 など)
```

## dockerでSSLをつかう(windowsの方法)
参考 https://shimota.app/windows環境にhttps-localhost-環境を作成する/
- https://chocolatey.org/install でコマンドをコピー
- powershellを管理者で実行、貼り付け、 `choco list -l` で確認
- powershellを一旦閉じて再度開けて、 `choco install mkcert` やって `mkcert --install`
- localhost-key.pem と localhost.pem が実行したディレクトリに落ちてるので保存して使い回す。


## Laravelのライブラリ導入とコマンド一覧
`laravel/README.md`にライブラリ導入手順や`artisan`コマンドの一覧が記述されています。

## Docker開発環境構築手順

### Dockerファイル全体構成

- .devcontainer/
    - 開発環境で利用する`docker-compse`のリソースが格納。
- .devcontainer/db/
    - `docker-compse build`で利用するMySQLの設定が格納。
- .devcontainer/php/
    - `docker-compose build`で利用するphpの設定が格納。
- .devcontainer/proxy/
    - `docker-compose build`で利用するnginxの設定が格納。

### 必要条件とツールの導入

[Docker の公式サイト](https://www.docker.com/)から手順に従って導入し`docker-compose`コマンドを利用できるようにします。
[docker-composeの詳細](https://docs.docker.com/compose/compose-file/)はリファレンスを参考にしてください。
[docerk-composeコマンド](https://matsuand.github.io/docs.docker.jp.onthefly/engine/reference/commandline/compose/)はリファレンスを参考にしてください。
[Dockerプラグイン](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)を導入してください。

### wsl上での構築手順(任意)

wsl上上では [Dockerインフラ構築](#dockerインフラ構築)前に下記手順を実施(任意)。

この手順を踏まなくても[Dockerインフラ構築](#dockerインフラ構築)に移行しても構築は可能。

1〜3までの手順を実行すると以下が変更または追加される。
- `.devcontainer`フォルダが.envrcに設定されている`.${PROJECT_NAME}`にリネームされる。
- `.${PROJECT_NAME}/db/init/init.sql`が生成。
このファイルは内容は`${PROJECT_NAME}_db`とテスト用DBが定義されたファイルを作成する。
sqlファイルは.docker-compose.ymlで利用される。
- `.${PROJECT_NAME}/.env`ファイルを作成する。ファイル内容は`.envrc`で定義したポートなど設定ファイルとして作成される。


1. プロジェクト直下に存在する.envrc.expamleファイルを.envrcにリネーム
2. .envrcファイル内の環境変数のポート番号などを設定する。このファイルは後述3のシェルスクリプトが参照する。
3. `bash ./bin/gene_docker_compose_env`を実行
    実行するとプロジェクト直下の.devcontainerフォルダが.envrcで定義されている`.${PROJECT_NAME}`名に置き換わる。
    このスクリプトは`.${PROJECT_NAME}/.env`が新たに生成し`.envrc`で定義した環境変数が設定される。

### Dockerインフラ構築
1. `.devcontainer`ディレクトリ下で`.env`ファイルを作成し`env.example`の内容をコピーします。
1. 作成した`.env`ファイルを作成するアプリケーションに応じて編集します。
    ```
    #### .devcontainer/.envファイル ###
    #プロジェクト名
    PROJECT_NAME=●●●プロジェクト名●●●

    # nodejsのバージョン https://github.com/nodesource/distributions/blob/master/README.md からOSごとの設定を確認
    # 書き方は NODEJS_VERSION=20.x など
    NODEJS_VERSION=●●●nodejsのバージョン●●●

    # laravelのバージョン 書き方は LARAVEL_VERSION=10.* など
    LARAVEL_VERSION=●●●laravelのバージョン●●●

    # アプリ名: この名前がdockerコンテナのプレフィックス名になる
    APP_NAME=●●●プロジェクト名●●●

    # linux環境のユーザー名
    USER=user

    # linux環境のユーザー(上記 USER で設定したもの)のパスワード
    PASSWORD=password

    # db名
    DB_DATABASE=●●●プロジェクト名●●●

    # dbユーザー名…laravelの.envはこれに合わせる
    DB_USER=db_user

    # dbパスワード…laravelの.envはこれに合わせる
    DB_PASSWORD=db_password

    # webサーバー: webブラウザからアクセスするポート番号。非ssl。
    PROXY_PUBLIC_PORT=8080

    # webサーバー: ssl接続するポート番号
    PROXY_SSL_PORT=8443

    # Viteのポート番号
    VITE_PORT=5173

    # PhpMyAdmin: webブラウザからアクセスするポート番号
    PHP_MYADMIN_PUBLIC_PORT=83306

    # sqlファイルのPhpMyAdminファイルのアップロードサイズ
    MEMORY_LIMIT=128M

    # sqlファイルPhpMyAdminアップロードサイズ
    UPLOAD_LIMIT=64M
    ```

    ● 補足
    proxy/default.conf.template のrootパスとlaravelプロジェクトを作成するコンテナのパスが一致することを確認してください。
    ```
    # proxy/default.conf.templateのルートパス定義
    root /var/www/html/public;
    # phpコンテナ内のlaravelプロジェクトのパス
    /var/www/html/public;
    ```

1. `/.devcontainer`ディレクトリに移動し`docker-compose up -d --build`を実行。
### 上記手順で`ERROR: for proxy Cannot start service proxy: Mounts denied:`が出力された場合
- DockerアプリのPreferences > Resources > File sharing設定にプロジェクトディレクトリのパスを追加。
- Apply & Restartボタンで再起動。


### 複数コンテナを稼働させる場合
1. ルートディレクトリ下の`.devcontainer`ディレクトリ名を任意の名前変更。
    上記のディレクトリ名がcomposeのコンテナ名になるので複数立ち上げる場合は重複させないようにディレクトリ名を変更する。
**コンテナを複数立ち上げる場合はブラウザからアクセスするポート番号を重複しないように変更する。**

### 起動しなくなった場合
- 起動しない
    1. `.devcontainer/`下で `docker-compose down --rmi all --volumes`を実行。
    2. `.devcontainer/db/data`ディレクトリ(存在する場合は)削除
    3. `docker rmi $(docker images -f "dangling=true" -q)`でnone(不明)dockerイメージ削除
    4. `.devcontainer/`下で`docker-compose build --no-cache`
    5. `.devcontainer/`下で`docker-compose up -d`を実行。
- Windowsでエラー docker-credential-desktop.exe": executable file not found in $PATH, out: の場合
    1. `~/.docker/config.json`ファイル内
    ```
    {
        "credsStore": "desktop.exe"
    }
    ```
    ```
    {
        "credStore": "desktop.exe"
    }
    ```

    上記`"credsStore"`のsを除外し`docker-compose build --no-cache`を実行

### コンテナ立ち上げ後に`.devcotainer/.env`を編集した場合

1. 画面左の[Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)パネルをクリック。
2. 対象のコンテナをクリックしCompose Downを実行。
3. `docker-compose up -d --build`を実行。

### コンテナ内での作業
[Dockerプラグイン](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) 導入。

- エディタ画面左側にDocdkrのアイコンが表示されます。
アイコンをクリックし最上段にある`CONTAINERS`をクリックします。
コンテナリストが表示されサフィックスに`-php`が表示されている箇所をクリックします。
    - Attach Shellと表示されている箇所をクリックしたとき
    →VSCodeにコンテナのターミナル画面が表示されます。
    - Attach Visual Studio Code と表示されている箇所をクリックしたとき
    →VSCodeの新しいウィンドウがコンテナ内に開きます。

### プロジェクトの作成とLaravel環境設定

1. “$APP_NAME名”(.devcontainer/.envファイルに記載)-php コンテナに入る。
1. 新規プロジェクトの場合は/var/wwwディレクトリで以下コマンドを実行
`composer create-project laravel/laravel "html" "${LARAVEL_VERSION}" --prefer-dist`

- 警告: バージョンが不一致警告が出力された場合
    - `php --version`でバージョンを確認し`composer config platform.php バージョン番号`でバージョンを合わせる。
    - `composer install`を実行する。
    - `php artisan key:generate`を実行する。
1. 作成したプロジェクトに移動し`.env`ファイル内を`.devcontainer/.env`に基づいて下記値に変更する。

    ```
    APP_NAME=`.devcontainer/.env`に記載されているアプリ名
    ...
    DB_CONNECTION=mysql
    DB_HOST=db
    DB_PORT=3306
    DB_DATABASE=`.devcontainer/.env`に記載されている接続先データベース
    DB_USERNAME=`.devcotainer/.env`に記載されているDBユーザー
    DB_PASSWORD=`.devcotainer/.env`に記載されているパスワード

    ```

2. `http://127.0.0.1:{.devcontainer/.env記載のPHP_MYADMIN_PUBLIC_PORT}`でPhpMyAdminにアクセスできるか確認します。
3. Gitからクローンした場合(プロジェクト新規作成の場合は不要)
プロジェクトディレクトリ内で`composer install`を実行。
4. 下記コマンドを実行しマイグレーション・データを作成
`php artisan migrate --seed`

## Vite設定

1. .devcontainer/.envファイル下記変数に任意のポートを設定する

```
VITE_PORT= # php artisan serveで動かす場合にviteで構築されたファイルを読み込むために必要
PHP_SERVE_PORT= 
```

2. docker-compose.ymlファイル内: phpサービスの下記コメントアウトを外す。

```
# ports:
      # - ${PHP_SERVE_PORT}:8000
      # - ${VITE_PORT}:${VITE_PORT}
 args:
     # VITE_PORT: ${VITE_PORT}
```

3. .devcontainer/php/Dockerfileの以下Vite/php artisan serve部分のコメントアウトを外す
```
# 引数を受け取ってコンテナ内で環境変数を定義
# ARG VITE_PORT

# ENV VITE_PORT=${VITE_PORT}

# Vite開発環境用のポート
# EXPOSE ${VITE_PORT}
# php artisan serveポート
# EXPOSE 8000
```


4. `welcome.blade.php`に以下を追加
```
<!DOCTYPE html>
<html ...>
    <head>
        {{-- ... --}}
        # 下記を追加する
        @vite(['resources/css/app.css', 'resources/js/app.js'])
    </head>
```

5. vite.config.jsまたはvite.config.tsをを以下を参考に編集する。
```
## vite.config.jsの設定
import { defineConfig } from "vite";
import laravel from "laravel-vite-plugin";

export default defineConfig({
    plugins: [
        laravel({
            // パス設定
            input: ["resources/css/app.css", "resources/js/app.js"],
            refresh: true,
        }),
    ],
    server: {
         //　docker-composeの.envで定義した${VITE_PORT}を指定。
        port: ${VITE_PORT},
        host: true, // trueにすると host 0.0.0.0
        // ホットリロードHMRとlocalhost: マッピング
        hmr: {
            host: "localhost",
        },
        // ポーリングモードで動作 wsl2の場合これを有効しないとホットリロード反映しない
        watch: {
            usePolling: true,
        },
    },
});
```
6. 下記2点のコマンドを実行状態する。
この両者コマンドを実行状態にしないとvite・laravelの開発環境が正常に動作しない。

```
npm run dev -- --host
php artisan serve --host 0.0.0.0
```

**Vite開発設定時の注意点**

welcome.blade.phpを読み込時にvite.config.jsで定義されているserver: { port: 番号}で指定されたURLにアクセスしようとする。
外部ポートとコンテナ内でviteを起動してアクセスするポートを一致させないとアクセスできない。

docker-compse.ymlで下記定義されている場合の例に説明すると、

```
ports:
    15173:5173
```
welcome.blade.php返却->localhost:5173に存在するリソースにアクセスしようとする。
このポートは外部公開されてないので、読み込む事ができないためエラーになり画面が真っ白になる。
```

server: {
         //　docker-composeの.envで定義した${VITE_PORT}を指定。
        port: 
@vite(['resources/css/app.css', 'resources/js/app.js'])
```

## テスト開発環境設定とDB設定
***.env_testingを作成***
 `cp .env .env_testing`
  .env_testingファイル下記内容を変更
 `cp .env .env_testing`ファイルを作成
 .env_testingの下記を変更または追加
    ```php
    APP_ENV=test
    # dbは追加
    DB_TESTING_CONNECTION=mysql_testing
    DB_TESTING_HOST=ahr_db_testing
    DB_TESTING_PORT=3306
    DB_TESTING_DATABASE=test_ahr_db
    DB_TESTING_USERNAME=user
    DB_TESTING_PASSWORD=password
    ```

***database.phpを編集***

    ```php
    // mysqlの配列をコピーして貼り付け下記部分を変更
    'mysql_testing' => [　　　　名前変更
       'database' => 'test_db名',             変更点
    ],
    ```

****phpunitファイルの編集****

    phpunitを実行する際に使用するデータベースを設定。

    ```xml
    <php>
    <server name="APP_ENV" value="testing"/>
    <server name="BCRYPT_ROUNDS" value="4"/>
    <server name="CACHE_DRIVER" value="array"/>
    <server name="MAIL_MAILER" value="array"/>
    <server name="QUEUE_CONNECTION" value="sync"/>
    <server name="SESSION_DRIVER" value="array"/>
    <server name="TELESCOPE_ENABLED" value="false"/>
    <server name="DB_CONNECTION" value="mysql_testing"/>      変更点
    <server name="DB_DATABASE" value="test_db名"/>       変更点
    <server name="DB_HOST" value="127.0.0.1"/>
    </php>
    ```

***テスト用データベースを正しく使用できるか確認***
`php artisan migrate --env=testing`

    aravelにはデフォルトでuserのfactoryが用意されていて、seederも実行できる状態。

    テスト用dbにseederを実行して値が反映されているか確認。

****テストファイルの編集****

データベースと繋がっているのか確認。

```php
<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

use App\User;
use App\Item;

class ExampleTest extends TestCase
{
	use RefreshDatabase;

	public function setUp(): void
	{
		dd(env('APP_ENV'), env('DB_DATABASE'), env('DB_CONNECTION'));
	}
}
```

下記のコマンドを実行します。

```php
php artisan config:clear　　キャッシュ消してから

vendor/bin/phpunit

ファイル指定で実行したい場合は下記のコマンドで出来ます。

vendor/bin/phpunit tests/Feature/ExampleTest.php
```

## 開発環境URLアクセス法

1. コンテナが起動していない場合はコマンド `cd .devcontainer`で移動し`docker-compose up -d`を実行。
2. コンテナ立ち上げ後に下記URLでアクセス。
- ドメイン
    - URL: [http://127.0.0.1](http://127.0.0.1/):PROXY_PUBLIC_PORT/
- PhpMyAdmin
    - URL: [http://127.0.0.1](http://127.0.0.1/):.PHP_MYADMIN_PUBLIC_PORT/
- URLアクセス時画面に`No application encryption key has been specified.`が出力された場合
    1. `php artisan key:generate`を実行。
    2. サーバーを再起動。
    3. 起動後に`cd プロジェクト名`を実行。
    4. `php artisan config:clear`を実行。

## Dockerコマンド

コンテナ削除などのコマンド

- docker-compseのダウン
    - `cd .devcontainer`でディレクトリに移動し`docker-compose down`
- docker-compseのコンテナ、イメージ、ボリューム、ネットワークの一括削除。
    - docker-compse.ymlが配置されているディレクトリで`docker-compose down --rmi all --volumes --remove-orphans`
- Dockerで作成したコンテナを全削除
    - `docker rm $(docker ps -a -q)`
- Dockerのnoneイメージのみ全削除
    - `docker rmi $(docker images -f "dangling=true" -q)`
- Dockerのイメージを全削除
