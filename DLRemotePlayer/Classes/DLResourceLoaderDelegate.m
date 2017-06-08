//
//  DLResourceLoaderDelegate.m
//  Pods
//
//  Created by Dylan on 2017/6/8.
//
//

#import "DLResourceLoaderDelegate.h"

@implementation DLResourceLoaderDelegate


- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    
    
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
}


@end
