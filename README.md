# LogGraph.pm Readme (Japanese Only)
### 更新日：2017/2/13
---
## 概要
独自のアクセスログファイルを集計して、GDを使ったグラフを作成するPerlパッケージです。  
本パッケージを利用するpsgiアプリ側で「必要モジュール1」をuseしてください。  
Plack::Builderを使用したマルチアプリケーションフレームから呼び出す前提で作りました。  
CGI::PSGIオブジェクトリファレンスを渡してインスタンスを生成します。

## 必要モジュール1（呼び出し元にてuse）
Plack::Builder  
Encode  
URI::Escape  
CGI::PSGI  
Jcode  

## 必要モジュール2（本パッケージでuse）
GD  
GD::Graph::mixed  
GD::Graph::pie  

## ログ仕様（タブ区切りテキスト）
アクセス秒（time for perl format）  
YYYY年MM月DD日 hh:mm:ss  
ユーザー名（クッキーあれば）  
性別  
REMOTE_HOST  
REMOTE_ADDR  
HTTP_X_FORWARDED_FOR  
HTTP_CACHE_INFO  
HTTP_FROM  
HTTP_CLIENT_IP  
HTTP_SP_HOST  
HTTP_CACHE_CONTROL  
HTTP_X_LOCKING  
HTTP_USER_AGENT  
HTTP_REFERER,HTTP_VIA  
HTTP_FORWARDED  

## クエリー文字
下記のクエリー文字列を全て付加してpsgiにリクエスト送信してください。 キー毎の値について記載します。

1. act  
disp_grp : 横軸に日、縦軸にその日の訪問人数をエージェント別に積み上げた棒グラフ表示  
disp_grp_pie : 指定月の総訪問人数をエージェント別パーセンテージで円グラフ表示

2. page  
ページ番号（半角数値） : lodirで指定されるログ保存ディレクトリ配下のページ番号の名前のディレクトリを探し、この中のログを収集する。

3. year  
西暦年4桁（半角数値）

4. month  
月（半角数値、1または２桁）

5. logdir  
ログ保存ディレクトフルパス（最後の/は不要）

6. kizititle  
グラフタイトル欄に表示させるタイトル文字列。uriescapeされたもの。

## コーディング
下記のようなマルチアプリケーションフレーム用psgiから呼び出す例を紹介します。  
CGI::PSGIのオブジェクトを生成しそのリファレンスをnewに渡してLogGraphオブジェクトを生成します。  
生成したらto_app()を呼び出してください。  
下記では/MTlog_anaというURLでリクエストされるとこのto_app()関数がグラフイメージをhttpヘッダー付きで返します。
<pre>
use Plack::Builder;
use lib qw(/root/webkoza_psgis/lib);
use Encode;
use URI::Escape;
use CGI::PSGI;
use Jcode;
use Sitelog::LogGraph;

my $app1 = sub { #超基本
return [200,['Content-Type'=>'text/plain'],['Hello World 3']];
};

my $MTlog_analizer = sub { # MT用ログ解析グラフ表示
	my $env = shift;
	my $q = CGI::PSGI->new($env);#CGIでなくPSGI環境変数を渡してCGI::PSGIのインスタンス生成
	my $p = Sitelog::LogGraph->new($q);#CGI::PSGIオブジェクトリファ（インスタンス）を渡す
	return $p->to_app();
};

builder{
	enable "StackTrace";
	mount "/a"=>$app1;
	mount "/MTlog_ana"=>$MTlog_analizer;
};
</pre>
