//
//  DLRemotePlayer.h
//  Pods
//
//  Created by Dylan on 2017/5/25.
//
//

#import <Foundation/Foundation.h>

/**
 * 播放器的状态
 * 因为UI界面需要加载状态显示, 所以需要提供加载状态
 - DLRemotePlayerStateUnknown: 未知(比如都没有开始播放音乐)
 - DLRemotePlayerStateLoading: 正在加载()
 - DLRemotePlayerStatePlaying: 正在播放
 - DLRemotePlayerStateStopped: 停止
 - DLRemotePlayerStatePause:   暂停
 - DLRemotePlayerStateFailed:  失败(比如没有网络缓存失败, 地址找不到)
 */
typedef NS_ENUM(NSInteger, DLRemotePlayerState) {
    DLRemotePlayerStateUnknown = 0,
    DLRemotePlayerStateLoading   = 1,
    DLRemotePlayerStatePlaying   = 2,
    DLRemotePlayerStateStopped   = 3,
    DLRemotePlayerStatePause     = 4,
    DLRemotePlayerStateFailed    = 5
};

@interface DLRemotePlayer : NSObject

/** 总时长 (秒)*/
@property (nonatomic, assign,readonly) NSTimeInterval totalSeconds;
/** 当前播放时长 (秒)*/
@property (nonatomic, assign,readonly) NSTimeInterval currentSeconds;
/** 当前播放url */
@property (nonatomic, strong,readonly) NSURL *url;
/** 当前播放进度 */
@property (nonatomic, assign,readonly) float progress;
/** 播放倍速 */
@property (nonatomic, assign) float rate;
/** 快进播放进度 */
@property (nonatomic, assign) float seekProgress;
/** 快进播放 */
@property (nonatomic, assign) NSTimeInterval seekTime;
/** 文件的加载进图 */
@property (nonatomic, assign,readonly) float loadDataProgress;
/** 是否静音 */
@property (nonatomic, assign) BOOL muted;
/** 设置声音大小 */
@property (nonatomic, assign) float volume;
/** 当前播放时间 */
@property (nonatomic, copy) NSString *currentTimeFomater;
/** 当前播放时间 */
@property (nonatomic, copy) NSString *totalTimeFomater;
/** 播放状态 */
@property (nonatomic, assign) DLRemotePlayerState status;
/** 状态发生改变 */
@property (nonatomic, copy) dispatch_block_t statusChanged;

+ (instancetype)shareInstance;

/**
 播放

 @param url url
 */
- (void)playWithURL:(NSURL *)url isCache:(BOOL)cache;

/**
 暂停
 */
- (void)pause;

/**
 继续播放
 */
- (void)resume;

/**
 停止播放
 */
- (void)stop;


@end
