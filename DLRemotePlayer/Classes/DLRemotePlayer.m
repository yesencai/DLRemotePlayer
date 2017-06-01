//
//  DLRemotePlayer.m
//  Pods
//
//  Created by Dylan on 2017/5/25.
//
//

#import "DLRemotePlayer.h"
#import "AVFoundation/AVFoundation.h"

@interface DLRemotePlayer()
{
    BOOL _isUserPause;
}
/** 播放器 */
@property (nonatomic, strong) AVPlayer *player;
@end

@implementation DLRemotePlayer

+ (instancetype)shareInstance{
    static DLRemotePlayer *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[DLRemotePlayer alloc]init];
    });
    return player;
}

- (void)playWithURL:(NSURL *)url{
    
    NSURL *currentUrl = [(AVURLAsset *)self.player.currentItem.asset URL];
    if ([currentUrl isEqual:url]) {
        [self resume];
        return;
    }
    _url = url;
    _isUserPause = NO;
    //1、资源的请求
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    if (self.player.currentItem) {
        [self removeObserver];
    }
    //2、资源的组织
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    //当资源文件准备好之后，就通知可以播放器播放
    //利用kvo监听status的变化，从而判断资源文件是否准备完成
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playInterupt) name:AVPlayerItemPlaybackStalledNotification object:nil];
    //3、资源的播放
    self.player = [AVPlayer playerWithPlayerItem:item];
}

/**
 暂停
 */
- (void)pause{
    [self.player pause];
    _isUserPause = YES;
}

/**
 继续播放
 */
- (void)resume{
    _isUserPause = NO;
    if (self.player&&self.player.currentItem.playbackLikelyToKeepUp) {
        [self.player play];
        self.status = DLRemotePlayerStatePlaying;
    }
}

/**
 停止播放
 */
- (void)stop{
    _isUserPause = YES;
    [self.player pause];
    [self removeObserver];
    
    self.player = nil;
}

/**
 快进播放
 
 @param seekTime 快进时间
 */
- (void)setSeekTime:(NSTimeInterval)seekTime{
   
    //转换成秒的总时长
    NSTimeInterval totalSec = self.totalSeconds;
    //转换成秒的当前播放时长
    NSTimeInterval currentSec = self.currentSeconds;
    currentSec += seekTime;
    [self setSeekProgress:currentSec / totalSec];
}

/**
 指定进度播放
 
 @param seekProgress 进度大小
 */
- (void)setSeekProgress:(float)seekProgress{
    
    if (seekProgress <0 || seekProgress >1) {
        return;
    }
    //1、计算出已经播放的时长 总时长 / progress（进度）
    NSTimeInterval totalSeconds = self.totalSeconds;
    NSTimeInterval currentSeconds = totalSeconds * seekProgress;
    CMTime currentTime = CMTimeMake(currentSeconds, 1);
    if (self.player.timeControlStatus != AVPlayerTimeControlStatusPlaying ) {
        [self resume];
    }
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"确认加载时间点的资源");
        }else{
            NSLog(@"取消加载时间点的资源");
        }
    }];
}

/**
 设置倍速
 
 @param rate 倍速大小
 */
- (void)setRate:(float)rate{
    self.player.rate = rate;
}

#pragma mark - get数据方法
- (NSTimeInterval)totalSeconds{
    //1、拿到音频文件总时长
    CMTime totalTime = self.player.currentItem.duration;
    //2、计算出已经播放的时长 总时长 / progress（进度）
    NSTimeInterval totalSeconds = CMTimeGetSeconds(totalTime);
    if (isnan(totalSeconds)) {
        return 0;
    }
    return totalSeconds;
}

- (NSTimeInterval)currentSeconds{
    // 1、获取当前音频已经播放的时间长
    CMTime currentTime = self.player.currentItem.currentTime;
    //当前播放的秒数
    NSTimeInterval currentSec = CMTimeGetSeconds(currentTime);
    if (isnan(currentSec)) {
        return 0;
    }
    return currentSec;
}

/**
 播放进度

 @return 进度
 */
- (float)progress{
    if (self.totalSeconds==0) {
        return 0;
    }
   return self.currentSeconds / self.totalSeconds;
}

/**
 加载资源的进度
 @return 进度
 */
- (float)loadDataProgress{
    if (self.totalSeconds==0) {
        return 0;
    }
    CMTimeRange timeRange =  [self.player.currentItem.loadedTimeRanges.lastObject CMTimeRangeValue];
    CMTime loadTime = CMTimeAdd(timeRange.start, timeRange.duration);
    NSTimeInterval loadSeconds = CMTimeGetSeconds(loadTime);
    if (!isnan(loadSeconds)) {
        return loadSeconds / self.totalSeconds;
    }
    return 0;
}

- (BOOL)muted{
    return self.player.muted;
}

/**
 设置是否静音
 @param muted 是否静音
 */

- (void)setMuted:(BOOL)muted{
    self.player.muted = muted;
}

- (float)volume{
    return self.player.volume;
}

- (void)setVolume:(float)volume{
    self.player.volume = volume;
    if ([self.player isMuted]) {
        self.player.muted = NO;
    }
}

- (NSString *)currentTimeFomater{
    return  [NSString stringWithFormat:@"%02d:%02d",(int)self.currentSeconds / 60 , (int)self.currentSeconds % 60];
}

- (NSString *)totalTimeFomater{
    return  [NSString stringWithFormat:@"%02d:%02d",(int)self.totalSeconds / 60 , (int)self.totalSeconds % 60];
}

- (void)playInterupt{
    [self playEnd];
}

- (void)playEnd{
    [self stop];
    self.status = DLRemotePlayerStateStopped;
}

/**
 删除监听
 */
- (void)removeObserver{
    [self.player.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

/**
 监听资源文件发生的变化

 @param keyPath 发生变化的属性文件
 @param object self
 @param change 发生变化后
 @param context 内容
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status==AVPlayerItemStatusReadyToPlay) {
            [self resume];
        }else{
            self.status = DLRemotePlayerStateFailed;
            NSLog(@"状态未知");
        }
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        BOOL isOk = [change[NSKeyValueChangeNewKey] boolValue];
        if (isOk) {
            if (!_isUserPause) {
                [self resume];
            }else{
                
            }
        }else{
            self.status = DLRemotePlayerStateLoading;
        }
    }

}
@end
