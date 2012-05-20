//
//  main.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/6/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBoxDefines.h"
#import "SecBox.h"
#import "SBoxAlgorithms.h"
#import "SBoxConfigs.h"
#import "SBoxVDiskManager.h"


SBoxRet SBoxShowStatus() {
	DLog("show status");
	SBoxConfigs *configs = [SBoxConfigs sharedConfigs];
	VDiskQuota quota;
	const char *quotaString = "";
	VDiskRet retv = [[SBoxVDiskManager sharedManager] getQuota:&quota];
	if(retv==VDiskRetSuccess){
		NSString *usedString = [SBoxAlgorithms descriptionWithNumOfBytes:quota.used];
		NSString *totalString = [SBoxAlgorithms descriptionWithNumOfBytes:quota.total];
		NSString *string = [NSString stringWithFormat:@"\t Server Used: %@, Server Total: %@\n", usedString, totalString];
		quotaString = [string cStringUsingEncoding:NSUTF8StringEncoding];
	}else{
		quotaString = "\t Server status unavailable.\n";
	}
	printf("\nStatus:\n"
		   "\t Account Type: %s, User Name: %s\n"
		   "\t Encryption User Name: %s\n"
		   "%s\n",
		   SBoxAccountTypeString([configs accountType]),
		   [[configs accountUserName] cStringUsingEncoding:NSUTF8StringEncoding],
		   [[configs encryptionUserName] cStringUsingEncoding:NSUTF8StringEncoding],
		   quotaString
		   );
	
	return SBoxSuccess;
};

SBoxRet SBoxSetAccountInfo(SBoxAccountType accountType, const char *userName, const char *password) {
	DLog("set account info");
	SBoxConfigs *configs = [SBoxConfigs sharedConfigs];
	[configs setAccountType:accountType];
	[configs setAccountUserName:[NSString stringWithCString:userName encoding:NSUTF8StringEncoding]];
	[configs setAccountPassword:[NSString stringWithCString:password encoding:NSUTF8StringEncoding]];
	
	
	return SBoxSuccess;
}

SBoxRet SBoxSetEncryptionInfo(const char *userName, const char *password) {
	DLog("set encryption info");
	SBoxConfigs *configs = [SBoxConfigs sharedConfigs];
	[configs setEncryptionUserName:[NSString stringWithCString:userName encoding:NSUTF8StringEncoding]];
	[configs setEncryptionPassword:[NSString stringWithCString:password encoding:NSUTF8StringEncoding]];
	
	return SBoxSuccess;
}

SBoxRet SBoxListRemoteDirectory() {
	DLog("list remote directory");
	
	return SBoxSuccess;
}

SBoxRet SBoxChangeRemoteDirectory(const char *path) {
	DLog("change remote directory");
	
	return SBoxSuccess;
}

SBoxRet SBoxPutFile(const char *localSubPath, const char *remoteSubPath) {
	DLog("put file from {%s} to {%s}", localSubPath, remoteSubPath);
	
	return SBoxSuccess;
}

SBoxRet SBoxGetFile(const char *remoteSubPath, const char *localSubPath) {
	DLog("get file from {%s} to {%s}", remoteSubPath, localSubPath);
	
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
		
		
		//SBoxCLIMain(argc, argv);
	    
		//SBoxShowStatus();//test
		
		//[[SBoxVDiskManager sharedManager] getToken];//test
		
		//SBoxVDiskQuota quota;
		//[[SBoxVDiskManager sharedManager] getQuota:&quota];//test
		
		//NSMutableArray *list = [NSMutableArray array]; 
		//[[SBoxVDiskManager sharedManager] getRootFileList:list];//test
		
		//VDiskFileID fileID;//test
		//[[SBoxVDiskManager sharedManager] getRootFileID:&fileID withFileName:@"showimg785.jpg"];//test
		//SBoxVDiskFileInfo *fileInfo;//test
		//[[SBoxVDiskManager sharedManager] getFileInfo:&fileInfo withFileID:fileID];//test
		
		//SBoxVDiskFileInfo *fileInfo;//test
		//[[SBoxVDiskManager sharedManager] getRootFileInfo:&fileInfo withFileName:@"showimg785.jpg"];//test
		
		[SBoxConfigs save];
	}
	
    return 0;
}

