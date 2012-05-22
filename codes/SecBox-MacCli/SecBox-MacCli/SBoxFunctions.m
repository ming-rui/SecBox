//
//  SBoxFunctions.m
//  SecBox-MacCli
//
//  Created by Zimmer on 5/22/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import "SecBox.h"
#import "SBoxDefines.h"
#import "SBoxAlgorithms.h"
#import "SBoxFileSystem.h"


SBoxRet SBoxShowStatus() {
	DLog(@"show status");
	SBoxFileSystem *system = [SBoxFileSystem sharedSystem];
	VDiskManager *diskManager = [system diskManager];
	VDiskQuota quota;
	const char *quotaString = "";
	VDiskRet retv = [diskManager getQuota:&quota];
	if(retv==VDiskRetSuccess){
		NSString *usedString = [SBoxAlgorithms descriptionWithNumOfBytes:quota.used];
		NSString *totalString = [SBoxAlgorithms descriptionWithNumOfBytes:quota.total];
		NSString *string = [NSString stringWithFormat:@"Server Used: %@, Server Total: %@.", usedString, totalString];
		quotaString = [string cStringUsingEncoding:NSUTF8StringEncoding];
	}else{
		quotaString = "Server status unavailable.";
	}
	printf("Status:\n"
		   "\t Account Type: %s, User Name: %s;\n"
		   "\t Encryption User Name: %s;\n"
		   "\t %s\n",
		   SBoxAccountTypeString([diskManager accountType]),
		   [[diskManager userName] cStringUsingEncoding:NSUTF8StringEncoding],
		   [[system userName] cStringUsingEncoding:NSUTF8StringEncoding],
		   quotaString
		   );
	
	return SBoxSuccess;
};

SBoxRet SBoxSetAccountInfo(SBoxAccountType accountType, const char *userName, const char *password) {
	DLog(@"set account info");
	NSString *userNameString = [NSString stringWithCString:userName encoding:NSUTF8StringEncoding];
	NSString *passwordString = [NSString stringWithCString:password encoding:NSUTF8StringEncoding];
	
	SBoxFileSystem *system = [SBoxFileSystem sharedSystem];
	SBoxRet retv = [system setAccountInfoWithAccountType:accountType userName:userNameString password:passwordString];
	
	return retv;
}

SBoxRet SBoxSetEncryptionInfo(const char *userName, const char *password) {
	DLog(@"set encryption info");
	//检测数据合法性
	NSString *userNameString = [NSString stringWithCString:userName encoding:NSUTF8StringEncoding];
	NSString *passwordString = [NSString stringWithCString:password encoding:NSUTF8StringEncoding];
	
	SBoxFileSystem *system = [SBoxFileSystem sharedSystem];
	SBoxRet retv = [system setEncryptionInfoWithUserName:userNameString password:passwordString];
	
	return retv;
}

SBoxRet SBoxListRemoteDirectory() {
	DLog(@"list remote directory");
	
	SBoxFileSystem *system = [SBoxFileSystem sharedSystem];
	NSArray *nodes;
	SBoxRet retv = [system getNodesInCurrentDirectory:&nodes sort:YES];
	if(retv!=SBoxSuccess)
		return retv;
	
	printf("%lu items in \"%s\":\n", [nodes count], [[system currentPath] cStringUsingEncoding:NSUTF8StringEncoding]);
	
	for(SBFSNode *node in nodes){
		BOOL isFile = [node isFile];
		//const char *fileID = isFile?([[NSString stringWithFormat:@"%i", [[node itemInfo] itemID]] cStringUsingEncoding:NSUTF8StringEncoding]):("--\t");
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		NSString *lmDateString = [dateFormatter stringFromDate:[[node itemInfo] lastModificationDate]];
		const char *lmDate = isFile?([lmDateString cStringUsingEncoding:NSUTF8StringEncoding]):(" --\t\t");
		const char *dir = isFile?(""):("<DIR>");
		const char *size = isFile?([[SBoxAlgorithms descriptionWithNumOfBytes:[[node itemInfo] fileSize]] cStringUsingEncoding:NSUTF8StringEncoding]):("\t");
		const char *name = [[node name] cStringUsingEncoding:NSUTF8StringEncoding];
		printf(" %s\t%s\t%s\t%s\n", lmDate, dir, size, name);
	}
	
	return SBoxSuccess;
}

SBoxRet SBoxChangeRemoteDirectory(const char *path) {
	DLog(@"change remote directory");
	
	NSString *pathString = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
	SBoxFileSystem *system = [SBoxFileSystem sharedSystem];
	SBoxRet retv = [system changeDirectoryWithPath:pathString];
	if(retv!=SBoxSuccess)
		return retv;
	
	const char *currentPath = [[system currentPath] cStringUsingEncoding:NSUTF8StringEncoding];
	printf("current path: \"%s\"\n", currentPath);
	
	return SBoxSuccess;
}

NSString* absoluteLocalPath(const char *path) {
	NSString *pathString = nil;
	if(path[0]=='/'){
		pathString = [NSString stringWithFormat:@"%s", path];
	}else{
		NSString *currentPath = [[NSFileManager defaultManager] currentDirectoryPath];
		pathString = [NSString stringWithFormat:@"%@/%s", currentPath, path];
	}
	pathString = [pathString stringByStandardizingPath];
	
	DLog(@"absolutePath:%@",pathString);
	
	return pathString;
}

SBoxRet SBoxPutFile(const char *localPath, const char *remotePath) {
	DLog(@"put file from {%s} to {%s}", localPath, remotePath);
	
	NSString *localPathString = absoluteLocalPath(localPath);
	NSString *remotePathString = [NSString stringWithCString:remotePath encoding:NSUTF8StringEncoding];
	
	SBoxFileSystem *system = [SBoxFileSystem sharedSystem];
	NSFileManager *manager = [NSFileManager defaultManager];
	NSData *fileContents = [manager contentsAtPath:localPathString];
	if(fileContents==nil)
		return SBoxRetLocalFileNotExist;
	
	SBFSRet retv = [system putFileWithFilePath:remotePathString contents:fileContents];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	return SBoxSuccess;
}

SBoxRet SBoxGetFile(const char *remotePath, const char *localPath) {
	DLog(@"get file from {%s} to {%s}", remotePath, localPath);
	
	NSString *localPathString = absoluteLocalPath(localPath);
	NSString *remotePathString = [NSString stringWithCString:remotePath encoding:NSUTF8StringEncoding];
	
	SBoxFileSystem *system = [SBoxFileSystem sharedSystem];
	NSFileManager *manager = [NSFileManager defaultManager];
	NSData *fileContents = nil;
	SBFSRet retv = [system getFile:&fileContents withFilePath:remotePathString];
	if(retv!=SBFSRetSuccess)
		return retv;

	BOOL rt = [manager createFileAtPath:localPathString contents:fileContents attributes:nil];
	if(!rt)
		return SBoxRetCantCreateLocalFile;
	
	return SBoxSuccess;
}

SBoxRet SBoxRemove(const char *remotePath) {
	DLog(@"remove remote file {%s}",remotePath);
	
	NSString *remotePathString = [NSString stringWithCString:remotePath encoding:NSUTF8StringEncoding];
	SBoxFileSystem *system = [SBoxFileSystem sharedSystem];
	SBFSRet retv = [system removeFileWithFilePath:remotePathString];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	return SBoxSuccess;
}



