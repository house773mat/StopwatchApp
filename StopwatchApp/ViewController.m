//
//  ViewController.m
//  StopwatchApp
//
//  Created by 松下泰久 on 2015/12/11.
//  Copyright © 2015年 yasuhisa.matsushita. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    NSInteger countNumber;
    UIButton *start_button;
    UIButton *stop_button;
    UILabel *timeLabel;
    NSTimer *timer;
    NSTimer *stopTimer;
    NSDate *aDate; //タイマーの時間を格納する
    
    NSTimeInterval n; //*を付けるのはポインタ型かどうか。実際の数字ではなくメモリの番地だけをやりとりしてる。
    NSTimeInterval m;
    NSTimeInterval stopTime;
    
    NSDate *startDate;//スタートを押した時間
    NSDate *runDate;//同時に走る時間
    NSDate *stopDate;//ストップを押した時間
    NSDate *ajustDate;
    
    BOOL isFlag;
    

}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初期化
    isFlag = YES;

    //aDate = [NSDate ];//unix time stamp
    
    //ラベルを配置する
    [self timeLabel];
    //ボタンを配置する
    [self start_button];
    [self stop_button];
    [self reset_button];
    [self partSets];
}




////////////////*  ボタンの配置メソッド　*////////////////
-(void)partSets {
    //Stop Startのボタン切り替え
    if (countNumber == 0) {
        start_button.hidden = NO;
        stop_button.hidden = YES;
    } else {
        start_button.hidden = YES;
        stop_button.hidden = NO;
    }
}

//addSubviewがメモリを食べてる imageViewが最悪

-(void) start_button{ //変数とメソッドは共通でも動くのか？問題ないのか？現場での名前のルールは？
    //スタートボタンの配置
    start_button = [UIButton buttonWithType:UIButtonTypeSystem];
    start_button.frame = CGRectMake(0, 0, 100, 30);
    start_button.center = CGPointMake(160, 400);
    start_button.layer.cornerRadius = 5.0;
    start_button.layer.borderWidth = 1.0;
    start_button.layer.borderColor = [UIColor orangeColor].CGColor;//[]を付けるものとつけないものの違いは？？
    [start_button setTitle:@"Start" forState:UIControlStateNormal];
    [start_button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [start_button addTarget:self action:@selector(start_push) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:start_button];
}
-(void) stop_button {
    //ストップボタンの配置
    stop_button = [UIButton buttonWithType:UIButtonTypeSystem];
    stop_button.frame = CGRectMake(0, 0, 100, 30);
    stop_button.center = CGPointMake(160, 400);
    stop_button.layer.cornerRadius = 5.0;
    stop_button.layer.borderWidth = 1.0;
    stop_button.backgroundColor = [UIColor orangeColor];//カラーコードは標準ではできない。colorwith RGBでカテゴリメソッド。
    stop_button.layer.borderColor = [UIColor orangeColor].CGColor;
    [stop_button setTitle:@"Stop" forState:UIControlStateNormal];
    [stop_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [stop_button addTarget:self action:@selector(stop_push) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stop_button];
    
}

-(void) reset_button{
    //リセットボタンの配置
    UIButton *reset_button = [UIButton buttonWithType:UIButtonTypeSystem];
    reset_button.frame = CGRectMake(0, 0, 100, 30);
    reset_button.center = CGPointMake(160, 450);
    reset_button.layer.cornerRadius = 5.0;
    reset_button.layer.borderWidth = 1.0;
    reset_button.layer.borderColor = [UIColor orangeColor].CGColor;
    [reset_button setTitle:@"Reset" forState:UIControlStateNormal];
    [reset_button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];//押した時に文字に透過60％を適用したい.alphaはラベル全体が変わる
    [reset_button addTarget:self action:@selector(reset_push) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reset_button];
}
////////////////////////////////////////////////////////


////////////////*  ボタンを押した時のメソッド　*////////////////
-(void) start_push {
    //ボタンのフラグ制御
    countNumber = 1;
    if (isFlag) {
      startDate = [NSDate date];//if分の制御でフラグ管理
      isFlag = NO;
    }else{
    //(startDate+stopDate)-runDate
      startDate = [startDate dateByAddingTimeInterval:m];
    }
    if (stopTimer != nil) {
        [stopTimer invalidate];
        stopTimer = nil;
    }
    m = 0;
    [self Timer];
    [self partSets];

}

-(void) stop_push {
    //ボタンのフラグ制御
    countNumber = 0;
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    [self partSets];
    
    [self stopTimer];
}

-(void) reset_push {
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    isFlag = YES;
    timeLabel.text = @"00:00:00";
    start_button.hidden = NO;
    stop_button.hidden = YES;
    m = 0;
}

///////////////////////////////////////////////////////////

////////////////*  タイマー関連の処理　*////////////////
//タイムラベルを作成
-(void) timeLabel{
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
    timeLabel.center = CGPointMake(160,200);
    timeLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:48];
    timeLabel.text = @"00:00:00";
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:timeLabel];
}

//秒数をコントロール
-(void)Timer {
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(tick:) userInfo:nil repeats:YES];//f float型にする。fをつけないとダブル型になる　メソッドに合わせるのが普通。
}

-(void)stopTimer {
    stopTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(stoptick:) userInfo:nil repeats:YES];
}


-(void) tick:(NSTimer*)Timer{
    //formatterを定義
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateStyle:NSDateFormatterNoStyle];
//    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    formatter.dateFormat = @"mm:ss:SS";
    runDate = [NSDate date];
    
    n = [runDate timeIntervalSinceDate:startDate];//NSdateinterval 数字だけを持っている型
    
    runDate = [NSDate dateWithTimeIntervalSinceReferenceDate:n];//NStimeintervalをNSDateに変換
    NSString *dateStr = [formatter stringFromDate:runDate];
    timeLabel.text = dateStr;//[-----]メソッドにつつかう　.はプロパティ、設定を意味する
}

-(void) stoptick:(NSTimer*) stopTimer{
    m = m + 0.01f;
}


////////////////////////////////////////////////////

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
