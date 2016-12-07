//
//  ThreeDES.h
//  VasGameSDK
//
//  Created by justin on 15/12/22.
//  Copyright © 2015年 justin. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CommonCrypto/CommonCryptor.h>
//#import <CommonCrypto/CommonDigest.h>

@interface ThreeDES : NSObject

+ (NSString*)encyrpt:(NSString*)plainText keyIndex:(int)key;

+ (NSString*)decyrpt:(NSString*)plainText keyIndex:(int)key;

//+ (NSString*)TripleDES:(NSString*)plainText encryptOrDecrypt:(CCOperation)encryptOrDecrypt keyIndex:(int)keyIndex;

+ (NSString*)md5:(NSString*)plainText;

+ (NSString*)encyrptNoIv:(NSString*)plainText key:(NSString*)key;

+ (NSString*)encodeInBip:(NSString*)str;

@end
