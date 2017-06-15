//
//  DLAudioFileTool.h
//  DLRemotePlayer
//
//  Created by yesencai@163.com on 05/25/2017.
//  Copyright (c) 2017 yesencai@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLAudioFileTool : NSObject

+ (NSString *)cachePathWithURL: (NSURL *)url;
+ (NSString *)tmpPathWithURL: (NSURL *)url;

+ (BOOL)isCacheFileExists: (NSURL *)url;
+ (BOOL)isTmpFileExists: (NSURL *)url;


+ (NSString *)contentTypeWithURL: (NSURL *)url;


+ (long long)cacheFileSizeWithURL: (NSURL *)url;
+ (long long)tmpFileSizeWithURL: (NSURL *)url;

+ (void)removeTmpFileWithURL: (NSURL *)url;


+ (void)moveTmpPathToCachePath: (NSURL *)url;

@end
