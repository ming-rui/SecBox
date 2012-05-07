//
//  SBoxAlgorithms.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/6/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBoxAlgorithms

+ (NSData *) AES256EncryptWithData:(NSData*)data key:(NSString *)key;
+ (NSData *) AES256DecryptWithData:(NSData*)data Key:(NSString *)key;

+ (NSString *) base64wsEncodeWithData:(NSData *)data;
+ (NSData *) base64wsDecodeWithString:(NSString *)string;

@end
