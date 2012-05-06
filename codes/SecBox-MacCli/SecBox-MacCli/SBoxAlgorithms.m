//
//  SBoxAlgorithms.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/6/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import "SBoxAlgorithms.h"

#import <CommonCrypto/CommonCryptor.h>
#import "GTMStringEncoding.h"

@implementation SBoxAlgorithms


+ (NSData *) AES128EncryptWithData:(NSData*)data key:(NSString *)key {
	if([data length]==0||[key length]==0)
		return nil;
	
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    size_t bufferSize = [data length]+kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
	
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes], [data length],
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
	
    if(cryptStatus != kCCSuccess){
		free(buffer);
		return nil;
	}
	
	return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
}

+ (NSData *) AES128DecryptWithData:(NSData*)data Key:(NSString *)key {
	if([data length]==0||[key length]==0)
		return nil;
	
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    size_t bufferSize = [data length]+kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
	
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes], [data length],
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
	
    if (cryptStatus != kCCSuccess){
		free(buffer);
		return nil;
	}
	
	return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
}


+ (NSString *) base64wsEncodeWithData:(NSData *)data {
	GTMStringEncoding *encoding = [GTMStringEncoding rfc4648Base64WebsafeStringEncoding];
	return [encoding encode:data];
}

+ (NSData *) base64wsDecodeWithString:(NSString *)string {
	GTMStringEncoding *encoding = [GTMStringEncoding rfc4648Base64WebsafeStringEncoding];
	return [encoding decode:string];
}

@end
