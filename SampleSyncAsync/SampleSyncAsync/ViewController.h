//
//  ViewController.h
//  SampleSyncAsync
//
//  Created by Ryo Kosuge on 2013/08/08.
//  Copyright (c) 2013年 programmatore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    
    IBOutlet UIProgressView *_progressBar;
    IBOutlet UIButton *_syncBtn;
    IBOutlet UIButton *_asyncBtn;
}
- (IBAction)pushAsyncBtn:(id)sender;
- (IBAction)pushSyncBtn:(id)sender;

@end
