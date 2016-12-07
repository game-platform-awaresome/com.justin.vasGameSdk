//
//  ThreeDES.m
//  VasGameSDK
//
//  Created by justin on 15/12/22.
//  Copyright © 2015年 justin. All rights reserved.
//

#import "ThreeDES.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "GTMBase64.h"

@implementation ThreeDES

unsigned char testKeys[10][24] = {
    {
        0x15, 0xB9, 0xFD, 0xAE, 0xDA, 0x40, 0xF8, 0x6B,
        0xF7, 0x1C, 0x73, 0x29, 0x25, 0x16, 0x92, 0x4A,
        0x29, 0x4F, 0xC8, 0xBA, 0x31, 0xB6, 0xE9, 0xEA
    },
    {
        0x29, 0x02, 0x8A, 0x76, 0x98, 0xEF, 0x4C, 0x6D,
        0x3D, 0x25, 0x2F, 0x02, 0xF4, 0xF7, 0x9D, 0x58,
        0x15, 0x38, 0x9D, 0xF1, 0x85, 0x25, 0xD3, 0x26
    },
    {
        0xD0, 0x46, 0xE6, 0xB6, 0xA4, 0xA8, 0x5E, 0xB6,
        0xC4, 0x4C, 0x73, 0x37, 0x2A, 0x0D, 0x5D, 0xF1,
        0xAE, 0x76, 0x40, 0x51, 0x73, 0xB3, 0xD5, 0xEC
    },
    {
        0x43, 0x52, 0x29, 0xC8, 0xF7, 0x98, 0x31, 0x13,
        0x19, 0x23, 0xF1, 0x8C, 0x5D, 0xE3, 0x2F, 0x25,
        0x3E, 0x2A, 0xF2, 0xAD, 0x34, 0x8C, 0x46, 0x15
    },
    {
        0x9B, 0x29, 0x15, 0xA7, 0x2F, 0x83, 0x29, 0xA2,
        0xFE, 0x6B, 0x68, 0x1C, 0x8A, 0xAE, 0x1F, 0x97,
        0xAB, 0xA8, 0xD9, 0xD5, 0x85, 0x76, 0xAB, 0x20
    },
    {
        0xB3, 0xB0, 0xCD, 0x83, 0x0D, 0x92, 0xCB, 0x37,
        0x20, 0xA1, 0x3E, 0xF4, 0xD9, 0x3B, 0x1A, 0x13,
        0x3D, 0xA4, 0x49, 0x76, 0x67, 0xF7, 0x51, 0x91
    },
    {
        0xAD, 0x32, 0x7A, 0xFB, 0x5E, 0x19, 0xD0, 0x23,
        0x15, 0x0E, 0x38, 0x2F, 0x6D, 0x3B, 0x3E, 0xB5,
        0xB6, 0x31, 0x91, 0x20, 0x64, 0x9D, 0x31, 0xF8
    },
    {
        0xC4, 0x2F, 0x31, 0xB0, 0x08, 0xBF, 0x25, 0x70,
        0x67, 0xAB, 0xF1, 0x15, 0xE0, 0x34, 0x6E, 0x29,
        0x23, 0x13, 0xC7, 0x46, 0xB3, 0x58, 0x1F, 0xB0
    },
    {
        0x52, 0x9B, 0x75, 0xBA, 0xE0, 0xCE, 0x20, 0x38,
        0x46, 0x67, 0x04, 0xA8, 0x6D, 0x98, 0x5E, 0x1C,
        0x25, 0x57, 0x23, 0x0D, 0xDF, 0x31, 0x1A, 0xBC
    },
    {
        0x8A, 0x52, 0x9D, 0x5D, 0xCE, 0x91, 0xFE, 0xE3,
        0x9E, 0x9E, 0xE9, 0x54, 0x5D, 0xF4, 0x2C, 0x3D,
        0x9D, 0xEC, 0x2F, 0x76, 0x7C, 0x89, 0xCE, 0xAB
    }
};

const unsigned char iv[8] = { 0x70, 0x70, 0x6C, 0x69, 0x76, 0x65, 0x6F, 0x6B };

+ (NSString*)TripleDES:(NSString*)plainText encryptOrDecrypt:(CCOperation)encryptOrDecrypt keyIndex:(int)key
{
    const void *vplainText;
    size_t plainTextBufferSize;
    
    const void *vkey = (const void *) testKeys[key];
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        NSData *EncryptData = [GTMBase64 decodeData:[plainText dataUsingEncoding:NSUTF8StringEncoding]];
        plainTextBufferSize = [EncryptData length];
        vplainText = [EncryptData bytes];
    }
    else
    {
        NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
        plainTextBufferSize = [data length];
        vplainText = (const void *)[data bytes];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    // uint8_t ivkCCBlockSize3DES;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    // memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    //    NSString *key = @"123456789012345678901234";
    
//    const void *vkey = (const void *) [key UTF8String];
    
    
//    const unsigned char *pKey = testKeys[pKeyIndex];
//    const void *vinitVec = (const void *) [initVec UTF8String];
    
    
//    NSString *initVec = @"70706C6976656F6B";
//    NSData* bytes = [initVec dataUsingEncoding:NSUTF8StringEncoding];
//    NSData* bytes = [ThreeDES hexToBytes:initVec];
    
//    NSUInteger len =  [bytes length];
//    NSLog(@"len:%lu", (unsigned long)len);
    
//    Byte* myByte = (Byte *)[bytes bytes];
    
//    int len = sizeof(myByte);
//    for (int x = 0;x<len;x++)
//    {
//        NSLog(@"byte in Byte:%c", myByte[x]);
//    }
//    const void *vinitVec = (const void *) myByte;
    
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey, //"123456789012345678901234", //key
                       kCCKeySize3DES,
                       iv, //"init Vec", //iv,//vinitVec
                       vplainText, //"Your Name", //plainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    //if (ccStatus == kCCSuccess) NSLog(@"SUCCESS");
    /*else if (ccStatus == kCC ParamError) return @"PARAM ERROR";
     else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
     else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
     else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
     else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
     else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED"; */
    
    
    NSString *result;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
                                                                length:(NSUInteger)movedBytes]encoding:NSUTF8StringEncoding];
    }
    else
    {
        NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
        result = [GTMBase64 stringByEncodingData:myData];
    }
    
    return result;
}

+ (NSString*)encyrpt:(NSString*)plainText keyIndex:(int)key
{
    
    CCOperation ed = kCCEncrypt;
    
    NSString* result = [ThreeDES TripleDES:plainText encryptOrDecrypt:ed keyIndex:key];
    
    return result;
}

+ (NSString*)decyrpt:(NSString*)plainText keyIndex:(int)key
{
    CCOperation ed = kCCDecrypt;
    
    NSString* result = [ThreeDES TripleDES:plainText encryptOrDecrypt:ed keyIndex:key];
    
    return result;
}

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

+(NSString*)encyrptNoIv:(NSString *)plainText key:(NSString *)key
{
    const void *vplainText;
    size_t plainTextBufferSize;
    
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    plainTextBufferSize = [data length];
    vplainText = (const void *)[data bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *) [key UTF8String];
    
//    NSString *initVec = @"";
//    const void *vinitVec = (const void *)[initVec UTF8String];
    
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding|kCCOptionECBMode,
                       vkey, //"123456789012345678901234", //key
                       kCCKeySize3DES,
                       nil, //"init Vec", //iv,//vinitVec
                       vplainText, //"Your Name", //plainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    //if (ccStatus == kCCSuccess) NSLog(@"SUCCESS");
    /*else if (ccStatus == kCC ParamError) return @"PARAM ERROR";
     else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
     else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
     else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
     else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
     else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED"; */
    
    
    NSString *result;
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    result = [GTMBase64 stringByEncodingData:myData];
    
    return result;

}

+ (NSString*)encodeInBip:(NSString*)str
{
//    helloworld
    NSString *PPL_KEY = @"pplive_vas";
    
    NSInteger KEY_LEN = PPL_KEY.length;
    
//    NSLog(@"KEY_LEN: %ld", (long)KEY_LEN);
    
    
    
    NSData* strData = [str dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"strData length: %ld", (long)strData.length);
    Byte* enUrl = (Byte *)[strData bytes];
    
    Byte* result = (Byte *)[strData bytes];
    
    NSInteger enUrlLength = strData.length;//sizeof(enUrl)/sizeof(Byte);
    
//    NSLog(@"enUrlLength: %ld", (long)enUrlLength);
    
    for(NSInteger i = 0; i < enUrlLength; i++)
    {
        NSInteger key_index = i%KEY_LEN;
        
//        NSLog(@"enUrl[i]: %c", enUrl[i]);
//        NSLog(@"PPL_KEY characterAtIndex:key_index: %c", (Byte)[PPL_KEY characterAtIndex:key_index]);
        
        result[i] = ((Byte)enUrl[i] + (Byte)[PPL_KEY characterAtIndex:key_index]);
        
//        NSLog(@"result[i]: %hhu", result[i]);
    }
    
//    NSLog(@"result: %s", result);
    
    NSData* resultData = [GTMBase64 encodeBytes:result length:enUrlLength];
    
    NSString* resultStr = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    
    return resultStr;
}


@end
