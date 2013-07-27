niconico_data_set_tools
=======================

ニコニコデータセットのための適当スクリプト

とりまえず動画のほうをDLするスクリプトとMongoにつっこむスクリプトの２つ。

**ニコニコデータセット**
http://www.nii.ac.jp/cscenter/idr/nico/nico.html

上記サイトから事前に申請して、IDとパスワードを取得しておく必要があります。
ID/PWは別にメールで送られてきたりはしません。
申請後に表示される画面のURLの「メールアドレス」がIDで、その次のセグメントが「パスワード」です。

## ファイルのDL
download.rbの``YOUR_ID``と``YOUR_PW``を書き換えて、
走らせれば同梱の``data_urls.txt``の中身を元にDLします。

``download``ディレクトリ内にgzが保存されてきますよ。たぶん。

## mongoに突っ込む
``insert_to_mongo.rb``を走らせたら適当にmongoにツッコミます。たぶん。

## つかう
普通にmongoにアクセスしてくだちぃ。

```js
//日にちごとの動画ファイルサイズの平均
db.videos.aggregate([{$project: {date:{$dayOfMonth: "$upload_time"}, size_high:1}},{$group: {_id: "$date", sizeHighAvg:{$avg:"$size_high"}}}]);
```

うぇーい