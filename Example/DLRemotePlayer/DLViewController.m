//
//  DLViewController.m
//  DLRemotePlayer
//
//  Created by yesencai@163.com on 05/25/2017.
//  Copyright (c) 2017 yesencai@163.com. All rights reserved.
//

#import "DLViewController.h"
#import "DLRemotePlayer.h"
#import <MediaPlayer/MPVolumeView.h>

@interface DLViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UISlider *into;
@property (weak, nonatomic) IBOutlet UISlider *voice;
@property (weak, nonatomic) IBOutlet UILabel *starTimeLable;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLable;
/** 定时器 */
@property (nonatomic, weak) NSTimer *timer;
@end

@implementation DLViewController
- (NSTimer *)timer
{
    if (!_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}

//播放
- (IBAction)play:(id)sender {
    [[DLRemotePlayer shareInstance]playWithURL:[NSURL URLWithString:@"http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a"]];
    [self.timer fire];

}
- (IBAction)stop:(id)sender {
    [[DLRemotePlayer shareInstance] stop];
}

//暂停
- (IBAction)pause:(id)sender {
    [[DLRemotePlayer shareInstance] pause];
}

//继续
- (IBAction)continued:(id)sender {
    [[DLRemotePlayer shareInstance] resume];

}

//快进
- (IBAction)forwardRewind:(id)sender {
    [[DLRemotePlayer shareInstance] setSeekTime:10];
    [self updateTime];

}
//快进滑块控件
- (void)forwardSlider:(UISlider *)sender {
    float value = [sender value];
    [[DLRemotePlayer shareInstance]setSeekProgress:value];
    [self updateTime];
}

//加倍播放
- (IBAction)times:(id)sender {
    [[DLRemotePlayer shareInstance]setRate:2];
}

//静音
- (IBAction)mute:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    [[DLRemotePlayer shareInstance]setMuted:button.selected];

}

//滑块
- (IBAction)slider:(id)sender {
    [[DLRemotePlayer shareInstance]setVolume:2];

}

- (void)viewDidLoad{
    [super viewDidLoad];
//    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(10, 50, 200, 50)];
//    [self.view addSubview:volumeView];

    self.into.value = 0;
    [self.into addTarget:self action:@selector(forwardSlider:) forControlEvents:UIControlEventValueChanged];
    [self.into setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
    self.voice.value = 0;
    [self.voice setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
//    for (UIView *view in [volumeView subviews]) {
//        if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
//            self.voice = (UISlider *)view;
//            break;
//        }
//    }
//    [self.voice sendActionsForControlEvents:UIControlEventTouchUpInside];
    self.progress.progress = 0;
}

- (void)updateTime{

    self.starTimeLable.text = [[DLRemotePlayer shareInstance] currentTimeFomater];
    
    self.endTimeLable.text = [[DLRemotePlayer shareInstance] totalTimeFomater];
    
    float playProgress = [[DLRemotePlayer shareInstance]progress];
    float loadProgress = [[DLRemotePlayer shareInstance]loadDataProgress];
    [self.into setValue:playProgress animated:YES];
    [self.progress setProgress:loadProgress animated:YES];
    NSLog(@"loadProgress%f",loadProgress);
    
}

@end
