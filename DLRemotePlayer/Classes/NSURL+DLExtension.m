//
//  NSURL+DLExtension.m
//  Pods
//
//  Created by Dylan on 2017/6/8.
//
//

#import "NSURL+DLExtension.h"

@implementation NSURL (DLExtension)

- (NSURL *)steamingUrl{
    NSURLComponents *components= [NSURLComponents componentsWithString:self.absoluteString];
    components.scheme = @"steaming";
    return components.URL;
}
@end
