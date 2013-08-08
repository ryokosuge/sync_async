//
//  ViewController.m
//  SampleSyncAsync
//
//  Created by Ryo Kosuge on 2013/08/08.
//  Copyright (c) 2013年 programmatore. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

NSURLConnection *connection;
NSMutableData *asyncData;
float totalBytes;
float loadedBytes;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // progressBarの初期化
    [_progressBar setProgress:0.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 同期通信
// pushSyncBtnが押されたら実行される処理
- (IBAction)pushSyncBtn:(id)sender {
    // [1] リクエストの生成
    /**
     こちらは同期通信も非同期通信も同じくリクエストのクラスを生成しています。
     まずNSURLクラスをNSStringクラスから生成しています。
     その後、NSURLRequestクラスをNSURLクラスから生成しています。
     それと同じくNSURLResponseクラスとNSErrorクラスをnilで生成しています。
     */
    NSURL *url = [NSURL URLWithString:@"http://www.hatena.ne.jp"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    // [2] バイナリデータの受け取り
    /**
     NSURLConnectionクラスの-(NSData)sendSynchronousRequest:request returningResponse: &response error: &errorメソッドでHTTP通信をしています。
     上記で生成したNSURLResponseクラスとNSErrorクラスをnilで生成したのはこのメソッドで適時、値が代入されるからです。
     NSDataクラスはHTTP通信で受け取ったバイナリデータになります。
     */
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // [3] エラーチェック
    /**
     ここはHTTP通信エラーチェックになります。
     NSError error = nil と初期化しておけば
        if (!error) {
        }
     という感じのエラーチェックでも大丈夫です。
     */
    NSString *errorString = [error localizedDescription];
    if (0 < [errorString length]){
        // エラー処理
        // お好きにどうぞ！
        // --- 省略  ---
    }
    
    // [4] NSDataをNSStringに変換する
    /**
     NSDataクラスはバイナリデータのためこのままでは使用できません。
     なのでNSStringにするなりして使用出来るデータ型やオブジェクトに変換する必要があります。
     ここではNSStringクラスに変換する方法を説明します。
     まずはencordの配列を生成します。
     こちらは返却されたバイナリデータの文字コードがなにか特定できない場合に限ります。
     文字コードがわかっている場合は生成しなくて問題ありません。
     その後
        int max = sizeof(encArray) / sizeof(encArray[0]);
     という処理でencArrayの要素数をint maxという変数に代入します。
     そしてforで要素数分だけループを回します。
     ループの中ではNSStringクラスの-(NSString *)initWithData:data encoding: encordというメソッドでバイナリデータをNSStringクラスに変換しています。
     このメソッドは文字コードが正しくない場合はnilを返すのでその性質を利用して変換できたかを
        if (dataString != nil) {
        }
     で確認しています。
     これでNSStringクラスに変換されたHTTP通信の結果を得ることが出来ました。
     あとはこれをJSONにするなり色々やってください。
     */
    int encArray[] = {
        NSUTF8StringEncoding,           // UTF-8
        NSShiftJISStringEncoding,       // Shift-JIS
        NSJapaneseEUCStringEncoding,    // EUC-JP
        NSISO2022JPStringEncoding,      // JIS
        NSUnicodeStringEncoding,        // Unicode
        NSASCIIStringEncoding           // ASCII
    };
    
    NSString *dataString = nil;
    
    int max = sizeof(encArray) / sizeof(encArray[0]);
    NSLog(@"%d", max);
    
    for (int i = 0; i < max; i++){
        dataString = [[NSString alloc] initWithData: data encoding:encArray[i]];
        if (dataString != nil) {
            break;
        }
    }
    
    // dataString内にHTTP通信でとれた結果がNSStringとして代入されています。
    // あとはお好きに...
    
    // --- 省略  --- //
}

// 非同期通信
// pushAsyncBtnが押されたら実行される処理
- (IBAction)pushAsyncBtn:(id)sender {
    // [1] リクエストの生成
    /**
     こちらは同期通信も非同期通信も同じくリクエストのクラスを生成しています。
     まずNSURLクラスをNSStringクラスから生成しています。
     その後、NSURLRequestクラスをNSURLクラスから生成しています。
     それと同じくNSURLResponseクラスとNSErrorクラスをnilで生成しています。
     */

    NSURL *url = [NSURL URLWithString:@"http://www.hatena.ne.jp"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // [5] 非同期通信
    /**
     非同期通信にはdelegateを自分自身に設定してあるメソッドを実装する必要があります。
     まずはメソッドの紹介です。
        -(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
        -(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
        -(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
        -(void)connectionDidFinishLoading:(NSURLConnection*)connection
     の４つになります。
     */
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection == nil) {
        // エラー処理
        // お好きにどうぞ！
        // --- 省略  ---
    }

}

// [6]
/**
 こちらのメソッドはレスポンスを受け取った時点で呼び出されます。
 バイナリデータの受信はまだ始まっていないので、注意してください。
 ソースコードではProgressViewの初期化をしています。
 */
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // データを初期化
    asyncData = [[NSMutableData alloc] initWithData:0];
    // プログレスバーを更新
    totalBytes = [response expectedContentLength];
    loadedBytes = 0.0;
    [_progressBar setProgress: loadedBytes];
}

// [7]
/**
 こちらのメソッドはデータを受け取る度に呼び出されるメソッドです。
 受け取るデータは断片的なのでインスタンス変数で宣言してあるNSMutableData *asyncDataに追加しています。
 */
- (void) connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
    // データを追加する
    [asyncData appendData:data];
    // プログレスバーを更新
    loadedBytes += [data length];
    [_progressBar setProgress:(loadedBytes / totalBytes)];
}

// [8]
/**
 こちらは通信時にエラーが起きた際に呼ばれるメソッドです。
 */
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // エラー処理
    // お好きにどうぞ！
    // --- 省略  ---
}

// [9]
/**
 こちらはデータをすべて受け取った時点で呼び出されるメソッドです。
 -(void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
 でスタックし続けたNSMutableDataを使って
 [4] NSDataをNSStringに変換すると同じ処理をしています。
 */
- (void) connectionDidFinishLoading:(NSURLConnection*)connection
{
    // [4]
    /**
     NSDataクラスはバイナリデータのためこのままでは使用できません。
     なのでNSStringにするなりして使用出来るデータ型やオブジェクトに変換する必要があります。
     ここではNSStringクラスに変換する方法を説明します。
     まずはencordの配列を生成します。
     こちらは返却されたバイナリデータの文字コードがなにか特定できない場合に限ります。
     文字コードがわかっている場合は生成しなくて問題ありません。
     その後
     int max = sizeof(encArray) / sizeof(encArray[0]);
     という処理でencArrayの要素数をint maxという変数に代入します。
     そしてforで要素数分だけループを回します。
     ループの中ではNSStringクラスの-(NSString *)initWithData:data encoding: encordというメソッドでバイナリデータをNSStringクラスに変換しています。
     このメソッドは文字コードが正しくない場合はnilを返すのでその性質を利用して変換できたかを
     if (dataString != nil) {
     }
     で確認しています。
     これでNSStringクラスに変換されたHTTP通信の結果を得ることが出来ました。
     あとはこれをJSONにするなり色々やってください。
     */
    int encArray[] = {
        NSUTF8StringEncoding,
        NSShiftJISStringEncoding,
        NSJapaneseEUCStringEncoding,
        NSISO2022JPStringEncoding,
        NSUnicodeStringEncoding,
        NSASCIIStringEncoding
    };
    
    NSString *dataString = nil;
    int max = sizeof(encArray) / sizeof(encArray[0]);
    for (int i = 0; i < max; i++){
        dataString = [[NSString alloc] initWithData:asyncData encoding:encArray[i]];
        if (dataString != nil){
            break;
        }
    }
    
    // プログレスバーを更新
    [_progressBar setProgress:1.0];
	
    // dataString内にHTTP通信でとれた結果がNSStringとして代入されています。
    // あとはお好きに...
    // --- 省略  --- //
}

@end
