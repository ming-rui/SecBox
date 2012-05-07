//
//  main.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/6/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "stdio.h"
#import "SecBox.h"
#import "SBoxAlgorithms.h"


SBoxReturnType SBoxShowStatus() {
	printf("show status\n");
	
	return SBoxSuccess;
};

SBoxReturnType SBoxSetAccountInfo(SBoxAccountType accountType, const char *userName, const char *password) {
	printf("set account info\n");
	
	return SBoxSuccess;
}

SBoxReturnType SBoxSetEncryptionInfo(const char *userName, const char *password) {
	printf("set encryption info\n");
	
	return SBoxSuccess;
}

SBoxReturnType SBoxListRemoteDirectory() {
	printf("list remote directory\n");
	
	return SBoxSuccess;
}

SBoxReturnType SBoxChangeRemoteDirectory(const char *path) {
	printf("change remote directory\n");
	
	return SBoxSuccess;
}

SBoxReturnType SBoxPutFile(const char *localSubPath, const char *remoteSubPath) {
	printf("put file from {%s} to {%s}\n", localSubPath, remoteSubPath);
	
	return SBoxSuccess;
}

SBoxReturnType SBoxGetFile(const char *remoteSubPath, const char *localSubPath) {
	printf("get file from {%s} to {%s}\n", remoteSubPath, localSubPath);
	
	return SBoxSuccess;
}

int main(int argc, const char * argv[]) {
	@autoreleasepool {
	    
//		NSString *s = [SBoxAlgorithms base64wsEncodeWithData:[NSData dataWithBytes:"abcdefgh" length:19]];
//		NSData *data = [SBoxAlgorithms base64wsDecodeWithString:s];
//		s = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		
//		NSData *origin = [NSData dataWithBytes:"test" length:4];
//		NSData *encrypted = [SBoxAlgorithms AES256EncryptWithData:origin key:@"password123123123"];
//		NSData *decrypted = [SBoxAlgorithms AES256DecryptWithData:encrypted Key:@"password123123123"];
//		NSString *s = [[NSString alloc] initWithData:decrypted encoding:NSASCIIStringEncoding];
//		
//	    NSLog(@"hello:%@",s);
		
		SBoxCLIMain(argc, argv);
	    
	}
	
    return 0;
}

