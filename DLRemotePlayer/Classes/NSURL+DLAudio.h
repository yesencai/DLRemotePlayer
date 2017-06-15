//
//  NSURL+DLAudio.h
//  DLRemotePlayer
//
//  Created by yesencai@163.com on 05/25/2017.
//  Copyright (c) 2017 yesencai@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (DLAudio)

- (NSURL *)streamingURL;

- (NSURL *)httpURL;

@end
