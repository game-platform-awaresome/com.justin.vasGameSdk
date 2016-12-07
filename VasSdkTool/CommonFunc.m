//
//  CommonFunc.m
//  HeartBookSDKDemo
//
//  Created by justin on 16/6/13.
//  Copyright © 2016年 justin. All rights reserved.
//

#import "CommonFunc.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

@implementation CommonFunc

+ (NSString*)md5:(NSString*)plainText
{
    const char* cStr = [plainText UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for (NSInteger i=0; i<CC_MD5_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x", result[i]];
    }
    
    return ret;
}

@end
