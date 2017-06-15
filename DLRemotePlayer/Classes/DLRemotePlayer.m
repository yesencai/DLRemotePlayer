//
//  DLRemotePlayer.m
//  DLRemotePlayer
//
//  Created by yesencai@163.com on 05/25/2017.
//  Copyright (c) 2017 yesencai@163.com. All rights reserved.
//

#import "DLRemotePlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "DLResourceLoader.h"
#import "NSURL+DLAudio.h"

@interface DLRemotePlayer ()
{
    BOOL _isUserPause;
}
@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) DLResourceLoader *resourceLoader;

@end


@implementation DLRemotePlayer

static DLRemotePlayer *_shareInstance;

+ (instancetype)shareInstance {
    if (!_shareInstance) {
        _shareInstance = [[DLRemotePlayer alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {

    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });

    }
    return _shareInstance;
}


//- (DLResourceLoader *)resourceLoader {
//    if (!_resourceLoader) {
//        _resourceLoader = [[DLResourceLoader alloc] init];
//    }
//    return _resourceLoader;
//}


- (void)playWithURL: (NSURL *)url isCache:(BOOL)isCache {

    
    if ([self.url isEqual:url]) {
        
        if (self.state == DLRemotePlayerStatePlaying) {
            return;
        }
        if (self.state == DLRemotePlayerStatePause) {
            [self resume];
            return;
        }
        if (self.state == DLRemotePlayerStateLoading) {
            return;
        }
        
    }
    
    
    self.url = url;
    // 其实, 系统已经帮我们封装了三个步骤
    // [AVPlayer playerWithURL:url]
    // 1. 资源的请求
    // 2. 资源的组织 AVPlayerItem
    // 3. 资源的播放
    
    if (self.player.currentItem) {
        [self clearObserver:self.player.currentItem];
    }

    _isUserPause = NO;
    NSURL *lastURL = url;
    if (isCache) {
        lastURL = [url streamingURL];
    }
    AVURLAsset *asset = [AVURLAsset assetWithURL:lastURL];
    self.resourceLoader = [[DLResourceLoader alloc] init];
    [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    // 监听资源的组织者, 有没有组织好数据
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playIntrupt) name:AVPlayerItemPlaybackStalledNotification object:nil];
    [self.player pause];
    self.player = [AVPlayer playerWithPlayerItem:item];
    
    
}

- (void)pause{ 
    [self.player pause];
    if (self.player) {
        _isUserPause = YES;
        self.state = DLRemotePlayerStatePause;
    }
}

- (void)resume{
    
    [self.player play];
    if (self.player && self.player.currentItem.playbackLikelyToKeepUp) {
        _isUserPause = NO;
        self.state = DLRemotePlayerStatePlaying;
    }
    
}

- (void)stop{ 
    [self.player pause];
    [self clearObserver:self.player.currentItem];
    self.player = nil;
    self.state = DLRemotePlayerStateStopped;
}

- (void)setRate:(float)rate {
    self.player.rate = rate;
}
- (float)rate {
    return self.player.rate;
}

- (void)setVolume:(float)volume {
    if (volume > 0) {
        [self setMute:NO];
    }
    self.player.volume = volume;
}
- (float)volume {
    return self.player.volume;
}

- (void)setMute:(BOOL)mute {
    self.player.muted = mute;
}

- (BOOL)mute {
    return self.player.isMuted;
}


- (void)seekWithTime: (NSTimeInterval)time{
    
    // CMTime 影片时间
    // 影片时间 -> 秒
    // 秒 -> 影片时间
    
    // 1. 获取当前的时间点(秒)
    double currentTime = self.currentTime + time;
    double totalTime = self.duration;
    
    [self setProgress:currentTime / totalTime];
    
}

- (double)duration {
    double time = CMTimeGetSeconds(self.player.currentItem.duration);
    if (isnan(time)) {
        return 0;
    }
    return time;
}

- (double)currentTime {
    
    double time = CMTimeGetSeconds(self.player.currentItem.currentTime);
    
    if (isnan(time)) {
        return 0;
    }
    return time;
}

- (float)progress {
    
    if (self.duration == 0) {
        return 0;
    }
    return self.currentTime / self.duration;
    
}

- (void)setProgress:(float)progress {
    
    // 0.0 - 1.0
    // 1. 计算总时间 (秒) * progress
    
    double totalTime = self.duration;
    double currentTimeSec = totalTime * progress;
    CMTime playTime = CMTimeMakeWithSeconds(currentTimeSec, NSEC_PER_SEC);
    [self.player seekToTime:playTime completionHandler:^(BOOL finished) {
        
        if (finished) {
            NSLog(@"确认加载这个时间节点的数据");
        }else {
            NSLog(@"取消加载这个时间节点的播放数据");
        }
    }];
    
    
}

- (void)setState:(DLRemotePlayerState)state {
//    if (_state == state) {
//        return;
//    }
    _state = state;
    if (self.stateChange) {
        self.stateChange(state);
    }
    if (self.url) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRemotePlayerURLOrStateChangeNotification object:nil userInfo:@{
                                                                                                                                   @"playURL": self.url,                                                                  @"playState": @(state)
                                                                                                                                   }];
    }

}

- (void)setUrl:(NSURL *)url {
    _url = url;

    if (self.url) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRemotePlayerURLOrStateChangeNotification object:nil userInfo:@{
                                                                                                                                   @"playURL": self.url,                                                                  @"playState": @(self.state)

                                                                                                                                   }];
    }

}


-(float)loadProgress {
    
    CMTimeRange range = [self.player.currentItem.loadedTimeRanges.lastObject CMTimeRangeValue];
    CMTime loadTime = CMTimeAdd(range.start, range.duration);
    double loadTimeSec = CMTimeGetSeconds(loadTime);
    
    if (self.duration == 0) {
        return 0;
    }
    
    return loadTimeSec / self.duration;
    
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                NSLog(@"准备完毕, 开始播放");
                [self resume];
                break;
            }
            case AVPlayerItemStatusFailed:
            {
                NSLog(@"数据准备失败, 无法播放");
                self.state = DLRemotePlayerStateFailed;
                break;
            }
                
            default:
            {
                NSLog(@"未知");
                self.state = DLRemotePlayerStateUnknown;
                break;
            }
        }
        
    }
    
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        // 代表, 是否加载的可以进行播放了
        BOOL playbackLikelyToKeepUp = [change[NSKeyValueChangeNewKey] boolValue];
        if (playbackLikelyToKeepUp) {
            NSLog(@"数据加载的足够播放了");
            
            // 能调用, 播放
            // 手动暂停, 优先级 > 自动播放
            if (!_isUserPause) {
                self.state = DLRemotePlayerStatePlaying;
                [self resume];
            }
   
        }else {
            NSLog(@"数据不够播放");
            self.state = DLRemotePlayerStateLoading;
        }
    }
    
    
    
}

- (void)playEnd {
    self.state = DLRemotePlayerStateStopped;
    if (self.playEndBlock) {
        self.playEndBlock();
    }
    
}

- (void)playIntrupt {
    NSLog(@"播放被打断");
    self.state = DLRemotePlayerStatePause;
}


- (void)clearObserver: (AVPlayerItem *)item {
    
    [item removeObserver:self forKeyPath:@"status"];
    [item removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
}


- (void)dealloc {
    
    [self clearObserver:self.player.currentItem];
    
}


@end
