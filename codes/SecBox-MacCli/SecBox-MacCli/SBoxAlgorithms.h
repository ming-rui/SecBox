//
//  SBoxAlgorithms.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/6/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	SBoxAESKeySize128 = 0,
	SBoxAESKeySize256,
}SBoxAESKeySize;

@interface SBoxAlgorithms

+ (NSData *) AESEncryptWithData:(NSData*)data keySize:(SBoxAESKeySize)keySize key:(NSString *)key;
+ (NSData *) AESDecryptWithData:(NSData*)data keySize:(SBoxAESKeySize)keySize Key:(NSString *)key;

+ (NSString *) base64wsEncodeWithData:(NSData *)data;
+ (NSData *) base64wsDecodeWithString:(NSString *)string;

+ (NSString*) hmacSHA256WithKey:(NSString*)key string:(NSString*)string;

+ (NSString*) descriptionWithNumOfBytes:(long long)numOfBytes;

@end
