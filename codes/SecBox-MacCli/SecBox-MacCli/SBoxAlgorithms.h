//
//  SBoxAlgorithms.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/6/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SBoxAlgorithms

+ (NSData *) encryptWithData:(NSData *)data key:(NSString *)key;
+ (NSData *) decryptWithData:(NSData *)data Key:(NSString *)key;

+ (NSString *) base64wsEncodeWithData:(NSData *)data;
+ (NSData *) base64wsDecodeWithString:(NSString *)string;

+ (NSString*) hmacSHA256WithKey:(NSString *)key string:(NSString *)string;

+ (NSString*) descriptionWithNumOfBytes:(long long)numOfBytes;


@end
