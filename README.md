### 非同期処理と同期処理のまとめ

このソースはObjective-Cで書かれています。

**以下コメントの抜粋**

#### [1] リクエストの生成

こちらは**同期通信**も**非同期通信**も同じくリクエストのクラスを生成しています。

まず**NSURLクラス**を**NSStringクラス**から生成しています。

その後、**NSURLRequestクラス**を**NSURLクラス**から生成しています。

それと同じく**NSURLResponseクラス**と**NSErrorクラス**を`nil`で生成しています。

#### [2] バイナリデータの受け取り

**NSURLConnectionクラス**の`-(NSData)sendSynchronousRequest:request returningResponse: &response error: &error`メソッドでHTTP通信をしています。

上記で生成した**NSURLResponseクラス**と**NSErrorクラス**を`nil`で生成したのはこのメソッドで適時、値が代入されるからです。

**NSDataクラス**はHTTP通信で受け取ったバイナリデータになります。

#### [3] エラーチェック

ここはHTTP通信エラーチェックになります。

NSError error = nil と初期化しておけば

	if (!error) {
	}
	
という感じのエラーチェックでも大丈夫です。

**NSErrorクラス**の`-(NSString)localizedDescription`というメソッドはエラーを**NSString**にするメソッドです。

バグチェックなどに使えると思います。

#### [4] NSDataをNSStringに変換する

**NSDataクラス**はバイナリデータのためこのままでは使用できません。

なのでNSStringにするなりして使用出来るデータ型やオブジェクトに変換する必要があります。

ここでは**NSStringクラス**に変換する方法を説明します。

まずはencordの配列を生成します。

こちらは返却された**バイナリデータ**の文字コードがなにか特定できない場合に限ります。

文字コードがわかっている場合は生成しなくて問題ありません。

その後

	int max = sizeof(encArray) / sizeof(encArray[0]);

という処理で`encArray`の要素数を`int max`という変数に代入します。

そして`for`で要素数分だけループを回します。

ループの中では**NSStringクラス**の`-(NSString *)initWithData:data encoding: encord`というメソッドでバイナリデータを**NSStringクラス**に変換しています。

このメソッドは文字コードが正しくない場合は`nil`を返すのでその性質を利用して変換できたかを

	if (dataString != nil) {
	}

で確認しています。

これで**NSStringクラス**に変換されたHTTP通信の結果を得ることが出来ました。

あとはこれをJSONにするなり色々やってください。

**同期通信**はこれで終了です。

#### [5] 非同期通信

**非同期通信**には`delegate`を自分自身に設定してあるメソッドを実装する必要があります。

まずはメソッドの紹介です。

     -(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
     
     -(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
     
     -(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
     
     -(void)connectionDidFinishLoading:(NSURLConnection*)connection

の４つになります。

**非同期通信**をするとユーザーのアクションを受け付けるため**HTTP通信**の結果を一発で受け取れないのでちょびちょび受け取る必要があります。

なのでその処理を自分自身に**delegate(丸投げ)**します。

１つずつ説明していきます。

#### [6] -(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response

こちらのメソッドは**レスポンスを受け取った時点で呼び出されます**。

**バイナリデータの受信はまだ始まっていない**ので、注意してください。

ソースコードでは**ProgressView**の初期化をしています。

#### [7] -(void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data

こちらのメソッドは**データを受け取る度に呼び出される**メソッドです。

受け取るデータは断片的なのでインスタンス変数で宣言してある`NSMutableData *asyncData`に追加しています。


また受け取ったデータの容量をとって**ProgressView**の更新もしています。

#### [8] -(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error

こちらは**通信時にエラーが起きた際に呼ばれるメソッド**です。

#### [9] -(void)connectionDidFinishLoading:(NSURLConnection*)connection

こちらは**データをすべて受け取った時点で呼び出されるメソッド**です。
`-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data`でスタックし続けた**NSMutableData**を使って**[4] NSDataをNSStringに変換する**と同じ処理をしています。