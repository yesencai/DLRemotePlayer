//
//  DLAudioDownLoader.h
//  DLRemotePlayer
//
//  Created by yesencai@163.com on 05/25/2017.
//  Copyright (c) 2017 yesencai@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DLAudioDownLoaderDelegate <NSObject>

- (void)downLoaderLoading;

@end


@interface DLAudioDownLoader : NSObject

@property (nonatomic, assign) long long loadedSize;
@property (nonatomic, assign) long long offset;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, assign) long long totalSize;

@property (nonatomic, weak) id<DLAudioDownLoaderDelegate> delegate;

- (void)downLoadWithURL: (NSURL *)url offset: (long long)offset;


@end
