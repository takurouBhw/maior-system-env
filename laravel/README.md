- [PHPとLaravel環境設定](#phpとlaravel環境設定)
  - [Xdebug設定](#xdebug設定)
  - [各ライブラリの導入手順](#各ライブラリの導入手順)
    - [Laravel Sanctum](#laravel-sanctum)
    - [Laraval Breeze](#laraval-breeze)
    - [AdminLTE3](#adminlte3)
    - [Jetstream](#jetstream)
    - [Jetstreamの設定](#jetstreamの設定)
  - [artisanコマンド等](#artisanコマンド等)
  - [その他注意事項](#その他注意事項)

# PHPとLaravel環境設定

## Xdebug設定
1. LaravelプロジェクトディレクトリをVSCodeで開く。
2. `web.php`のルートに以下を追加する。
    ```
      Route::get('/phpinfo', function(){
          phpinfo();
    });
    ```
3. 以下コマンドを実行し `GET|HEAD  | phpinfo`が追加されているか確認。
    ```
    php artisan route:clear
    php artisan route:list | grep phpinfo
    ```

4. 上記のルートで設定した[URL](`http://127.0.0.1/phpinfo`)にアクセスする。
   `xdebug.client_port`を検索。ポート番号をコピーする。
5. 画面右側のデバッグアイコンをクリック、実行とデバッグ`.vscode/launch.json`を作成する。
6. `.vscode/launch.json`の設定を下記項目に変更する。
```
  "configurations": [
        {
          "name": "Listen for Xdebug",
          "type": "php",
          "request": "launch",
          "port": コピーしたポート番号,
          "pathMappings": {
              "nginxで設定されているドメインルート": "${workspaceRoot}"
          }
      },
```
**注意点**
`.vscode/launch.json`
上記ファイルの配置場所はEnvLaravel直下に配置する。

## 各ライブラリの導入手順
下記を参考に実施する。

### Laravel Sanctum
1. 以下のコマンドを実行する。
```
  composer require laravel/sanctum
  php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
  php artisan migrate:fresh
```

2. `Kernel.php`ファイルの以下の記載部分を変更する。
```
'api' => [
    \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
    \Illuminate\Session\Middleware\StartSession::class,
    // 'throttle:api',
    // \Illuminate\Routing\Middleware\SubstituteBindings::class,
],
```

3. `config/sanctum.php`ファイルの以下を自身の環境に合わせ変更する。
```
  'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
      '%s%s',
      'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
      env('APP_URL') ? ','.parse_url(env('APP_URL'), PHP_URL_HOST) : ''
  ))),
```

4. 任意のコントローラーを作成して以下の内容を追加する。
```
namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

// ↓コントローラー・メソッドなどは任意の名前
class AuthController extends Controller
{

  /**
  * @param  Request  $request
  * @return \Illuminate\Http\JsonResponse
  */
  public function login(Request $request)
  {
      $credentials = $request->validate([
          'email' => ['required', 'email'],
          'password' => ['required'],
      ]);

      if (Auth::attempt($credentials)) {
          $request->session()->regenerate();

          return response()->json(Auth::user());
      }
      return response()->json([], 401);
  }

  /**
  * @param  Request  $request
  * @return \Illuminate\Http\JsonResponse
  */
  public function logout(Request $request)
  {
      Auth::logout();

      $request->session()->invalidate();

      $request->session()->regenerateToken();

      return response()->json(true);
  }


  public function register(Request $request)
  {
      $validatedData = $request->validate([
          'name' => 'required|string|max:255',
          'email' => 'required|string|email|max:255|unique:users',
          'password' => 'required|string|min:8',
      ]);

      $user = User::create([
          'name' => $validatedData['name'],
          'email' => $validatedData['email'],
          'password' => Hash::make($validatedData['password']),
      ]);

      $token = $user->createToken('auth_token')->plainTextToken;

      return response()->json([
          'access_token' => $token,
          'token_type' => 'Bearer',
      ]);
  }
}
```

5. api.phpに以下を追記する

```
// routes/api.php
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout']);
// 下はテスト用
Route::get('/test', function(){
return response()->json([
    'test' => 'ok',
],200);
});

Route::middleware('auth:sanctum')->get('/user', function () {
return User::all();
});
```

6. `php artisan route:clear`を実行


以下参考URL
- [Sanctum](https://laravel.com/docs/9.x/sanctum)
- [認証](https://laravel.com/docs/9.x/authentication)

- **ログイン時にステータスコード500が送出される場合は以下の記事を参考にする**。
  [ログイン認証エラー ステータスコード(500)の対処](https://laracasts.com/discuss/channels/laravel/sanctum-throws-session-store-not-set-on-request)

### Laraval Breeze
- [参考1](https://reffect.co.jp/laravel/laravel8-breeze#Laravel_Breeze)
1. `composer require laravel/breeze --dev`
2. `php artisan breeze:install`
3. `npm install && npm run dev`

### AdminLTE3
- [参考](https://chigusa-web.com/blog/laravel-crud/)
1. ```composer require jeroennoten/laravel-adminlte```
2. ```php artisan adminlte:install```

### Jetstream
```
composer require laravel/jetstream
composer require laravel/sanctum
php artisan jetstream:install livewire
npm install && npm run dev
# viewsリソースを作成
php artisan vendor:publish --tag=jetstream-views
```

`npm install`時のエラー対処
  1. `webpack-cli] Error: Unknown option '--hide-modules'`が発生した場合
  `package.json`ファイル内で`--hide-modules`を検索し該当するオプションを削除する。

  2. ```run `npm audit fix` to fix them, or `npm audit` for details```が発生した場合
    `npm audit`を実行。セキュリティエラーメッセージの警告に従い解決する。

  3. 一旦キャッシュをクリーンにして下記コマンドを実行する
    ```
      npm cache clean --force
      rm -rf ~/.npm
      rm -rf node_modules
      install && nmp run dev
    ```

### Jetstreamの設定
- プロフィール画像の表示方法
1. `config/jetstream.php`ファイルの`Features::profilePhotos()`変数のコメントアウトを外す。
2. ```
    # ストレージリンクを貼る
    php artisan storage:link
    ```
5. `.env`ファイルの項目を`APP_URL=http://localhost:{サーバーのポート}`に変更する。
7. ```php artisan config:clear```でキャッシュをクリア。
8. `php artisan migrate:fresh`でDBに反映させる。

## artisanコマンド等
- Middlewareの作成
  ```
    php artisan make:middleware Cors 
  ```

- カスタムバリデーション
  ```
    php artisan make:rule {ルール名}
  ```

- キャッシュをクリア 
  ```
  php artisan cache:clear
  php artisan config:clear
  php artisan route:clear
  php artisan view:clear
  ```
- ストレージリンク
  ```
  php artisan storage:link
  ```
- リクエスト一覧
  ```
  php artisan route:list
  ```
- シーダー作成
  [参照](https://readouble.com/laravel/8.x/ja/seeding.html)
  1. 下記コマンド実行
      ```
      php artisan make:seeder ProductSeeder
      ```
  2. `database/seeders/ProductSeeder.php`に追記
      ```
      use Illuminate\Support\Facades\DB;
      use Illuminate\Support\Facades\Hash;
      ...

      public function run() {
          DB::table('products')->insert([
            'name' => 'test',
            'price' => 1000,
            'password' => Hash::make('p@ssw0rd'),
            'created_ad => '2020/12/12 12:12:12',
          ]);
      }
      ```
  3. `database/seeders/DatabaseSeeder.php`に追記
      ```
        public function run()
        {
            // \App\Models\User::factory(10)->create();
            $this->call([
                ProductSeeder::class
            ]);
        }
      ```
  4. `php artisan migrate:fresh --seed`を実行。

- ダミーデータ作成
  - [ダミーデータ一覧参照](https://qiita.com/tosite0345/items/1d47961947a6770053af)
    ```
    php artisan make:factory ProductFactory --model=Product
    ```
- コントローラー作成
  [参照](https://readouble.com/laravel/8.x/ja/controllers.html)
  [同時作成参照(ver8.7.0以降)](https://zenn.dev/nshiro/articles/204ce98cf088b9)
  ```
  php artisan make:controller ProductsController -r
  ```

- ルーティング作成
  `web.php`に追記
  ```
  use App\Http\Controllers\ProductsController;
  ...

  // ルーティング一覧(showを使用しない場合の例)
  Route::resource('product', ProductsController::class, ['except' => ['show']]);
  ```
- テーブル作成
  ```
  php artisan make:migration create_products_table
  php artisan migrate:fresh
  ```
- モデル作成
  [同時作成の参照(ver 8.7.0以降)](https://zenn.dev/nshiro/articles/204ce98cf088b9)
  (ver 8.7.0以降)

  ```
  php artisan make:controller ProductController -R --model=Product

  Model created successfully.
  Request created successfully.
  Request created successfully.
  Controller created successfully.
  ```
  (ver 8.7.0以前)
  ```
  php artisan make:model Product
  // フォームリクエスト等も同時に作成する場合
  php artisan make:model Product -rR

  Model created successfully.
  Request created successfully.
  Request created successfully.
  Controller created successfully.
  ```

- フォームリクエスト作成
  ```
  php artisan make:request ProductStoreRequest
  ```

- ダミーデータの作成方法
  1. `composer.json`内に"fakerphp/faker": "^1.9.1"が存在するか確認する。
  2. `config/app.php`内の`faker_locale => 'ja_JP'`に変更する。
  3. `php artisan config:clear`を実行。
  4. `php artisan make:factory モデルFactory --model=モデル名`で`モデルFactory.php`が生成される。
  5. 上記で生成されたファイルを[URL](https://qiita.com/tosite0345/items/1d47961947a6770053af)を参考に修正する。


 ## その他注意事項
 **フォーム画面注意点**
    画面を作成する際は`@csrf, @method('DELETE')`を追記する

  ```
  <form method="POST" action="{{ route('owner.products.update', ['product' => $product->id]) }}">
    @csrf
    @method('PUT')
  ```
