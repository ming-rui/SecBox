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
#import "SBoxFileSystem.h"


SBoxRet SBoxShowStatus() {
	DLog(@"show status");
	SBoxConfigs *configs = [SBoxConfigs sharedConfigs];
	VDiskQuota quota;
	const char *quotaString = "";
	VDiskRet retv = [[[SBoxFileSystem sharedSystem] diskManager] getQuota:&quota];
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
	DLog(@"set account info");
	SBoxConfigs *configs = [SBoxConfigs sharedConfigs];
	[configs setAccountType:accountType];
	[configs setAccountUserName:[NSString stringWithCString:userName encoding:NSUTF8StringEncoding]];
	[configs setAccountPassword:[NSString stringWithCString:password encoding:NSUTF8StringEncoding]];
	
	
	return SBoxSuccess;
}

SBoxRet SBoxSetEncryptionInfo(const char *userName, const char *password) {
	DLog(@"set encryption info");
	//检测数据合法性
	NSString *userNameString = [NSString stringWithCString:userName encoding:NSUTF8StringEncoding];
	NSString *passwordString = [NSString stringWithCString:password encoding:NSUTF8StringEncoding];
	if([userNameString length]==0||[passwordString length]==0)
		return SBoxFail;
	for(int i=0; i<[userNameString length]; i++){
		unichar ch = [userNameString characterAtIndex:i];
		if(ch=='['||ch==']')
			return SBoxFail;
	}
	
	SBoxConfigs *configs = [SBoxConfigs sharedConfigs];
	[configs setEncryptionUserName:userNameString];
	[configs setEncryptionPassword:passwordString];
	
	return SBoxSuccess;
}

SBoxRet SBoxListRemoteDirectory() {
	DLog(@"list remote directory");
	
	return SBoxSuccess;
}

SBoxRet SBoxChangeRemoteDirectory(const char *path) {
	DLog(@"change remote directory");
	
	return SBoxSuccess;
}

SBoxRet SBoxPutFile(const char *localSubPath, const char *remoteSubPath) {
	DLog(@"put file from {%s} to {%s}", localSubPath, remoteSubPath);
	
	return SBoxSuccess;
}

SBoxRet SBoxGetFile(const char *remoteSubPath, const char *localSubPath) {
	DLog(@"get file from {%s} to {%s}", remoteSubPath, localSubPath);
	
	return SBoxSuccess;
}

SBoxRet SBoxRemoveRemoteFile(const char *remoteSubPath) {
	DLog(@"remove remote file {%s}",remoteSubPath);
	
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
		
		
		SBoxVDiskManager *manager = [[SBoxFileSystem sharedSystem] diskManager];//test
		
		
		//[manager getToken];//test
		
		
		//NSMutableArray *list = [NSMutableArray array];//test
		//[manager getRootFileList:list];//test
		
		
		//VDiskFileID fileID;//test
		//[manager getRootFileID:&fileID withFileName:@"t"];//test
		//VDiskItemInfo *fileInfo;//test
		//[manager getFileInfo:&fileInfo withFileID:fileID];//test
		
		
		//VDiskItemInfo *fileInfo;//test
		//[manager getRootFileInfo:&fileInfo withFileName:@"t"];//test
		
		
		//[manager removeFileWithFileID:(VDiskFileID)94740958];//test
		
		
		//[manager removeRootFileWithFileName:@"filename"];//test
		
		
		//char n[1024];//test
		//for(int i=0; i<sizeof(n)-1; i++)//test
		//	n[i] = 't';//test
		//n[sizeof(n)-1] = '\0';//test
		//char d[1];//test
		//NSData *data = [NSData dataWithBytes:d length:sizeof(d)];//test
		//NSString *name = [NSString stringWithCString:n encoding:NSUTF8StringEncoding];//test
		//[manager uploadFileToRootWithFileName:name contents:data];//test
		
		
		//NSData *data = nil;//test
		//[manager downloadFileFromRoot:&data withFileName:@"foobar2000.exe"];//test
		
		
		//SBoxFileSystem *system = [SBoxFileSystem sharedSystem];//test
		//NSString *s = [system fileNameWithPath:@"/abc/def/ghi"];//test
		//NSString *s2 = [system pathWithFileName:s];//test
		
		
		[SBoxConfigs save];
	}
	
    return 0;
}

