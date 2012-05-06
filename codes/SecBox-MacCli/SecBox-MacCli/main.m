//
//  main.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/6/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBoxAlgorithms.h"

int main(int argc, const char * argv[]) {
	@autoreleasepool {
	    
//		NSString *s = [SBoxAlgorithms base64wsEncodeWithData:[NSData dataWithBytes:"abcdefgh" length:19]];
//		NSData *data = [SBoxAlgorithms base64wsDecodeWithString:s];
//		s = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		
		NSData *origin = [NSData dataWithBytes:"test" length:4];
		NSData *encrypted = [SBoxAlgorithms AES128EncryptWithData:origin key:@"password123123123"];
		NSData *decrypted = [SBoxAlgorithms AES128DecryptWithData:encrypted Key:@"password123123123"];
		NSString *s = [[NSString alloc] initWithData:decrypted encoding:NSASCIIStringEncoding];
		
	    NSLog(@"hello:%@",s);
	    
	}
	
    return 0;
}

