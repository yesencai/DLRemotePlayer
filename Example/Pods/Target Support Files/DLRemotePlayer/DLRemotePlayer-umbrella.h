#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSURL+XMGAudio.h"
#import "XMGAudioDownLoader.h"
#import "XMGAudioFileTool.h"
#import "XMGRemotePlayer.h"
#import "XMGResourceLoader.h"

FOUNDATION_EXPORT double DLRemotePlayerVersionNumber;
FOUNDATION_EXPORT const unsigned char DLRemotePlayerVersionString[];

