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
#import "SBoxUtils.h"
#import "SBoxSyncSystem.h"


const char * SBoxErrStringWithErrCode(SBoxRet errCode) {
	if(errCode>0){
		switch(errCode){
			case 1:
			case 2:
			case 3:
				return "Invalid Parameters.";
			case VDiskUploadFileRetFileNameCollision:
			case VDiskRenameFileRetFileNameCollision:
				return "Remote File Already Exists.";
			case VDiskUploadFileRetSystemError:
				return "Server Error.";
			case VDiskUploadFileRetLowCapacity:
				return "Lack Of Remote Disk Space.";
			case VDiskUploadFileRetOverUpMaxFileSize:
			case VDiskUploadFileRetOverMaxFileSize:
				return "File Size Too Large (>10 MB).";
			case VDiskUploadFileRetUploadNotFull:
			case VDiskUploadFileRetUploadFail:
				return "Failed To Upload The File.";
			case VDiskUploadFileRetDirFull:
				return "Too Many Files On The Server.";
			case VDiskRetExceedLimits:
				return "Exceeded Operation Limits. Try Again Latter.";
			default:
				return "Error Occurred.";
		}
	}
	
	if(errCode<0){
		switch(errCode){
			case SBoxRetInvalidArgument:
				return "Invalid Arguments.";
			case SBoxRetInvalidInput:
				return "Invalid Inputs.";
			case SBoxRetLocalFileNotExist:
				return "Local File Do Not Exist.";
			case SBoxRetCantCreateLocalFile:
				return "Can't Create Local File.";
			case VDiskRetConnectionError:
				return "Network Connection Error.";
			case VDiskRetNoMatchingFile:
				return "Can't Find The File.";
			case VDiskRetWrongItemType:
				return "It's Not A File Or Directory.";
			case VDiskRetFileNameTooLong:
				return "File Name Is Too Long.";
			case VDiskRetInvalidFileName:
				return "Invalid File Name.";
			case VDiskRetInvalidFileContents:
				return "Invalid File Contents.";
			case VDiskRetFileSizeTooLarge:
				return "File Size Too Large (>10 MB).";
			case SBFSRetInvalidConfiguation:
				return "Invalid Configurations. Please Finish The Settings First.";
			case SBFSRetPathTooLong:
				return "File Path Is Too Long.";
			case SBFSRetInvalidPath:
				return "Invalid Path.";
			case SBFSRetInvalidFilePath:
				return "Invalid File Path.";
			case SBFSRetNodeNotExist:
				return "File/Directory Not Found.";
			case SBFSRetFileInPath:
				return "Wrong Path.";
			case SBFSRetNodeIsNotFile:
				return "It Is Not A File.";
			case SBFSRetNodeIsNotDir:
				return "It Is Not A Directory.";
			case SBFSRetNodeNameCollision:
				return "File Name Already Exists.";
			case SBFSRetEncrytionError:
				return "Encrytion Error.";
			case SBFSRetDecrytionError:
				return "Decryption Error.";
			case SBSSRetLocalPathCollision:
				return "The Local Path Already Exists.";
			case SBSSRetInvalidLocalPath:
				return "Invalid Local Path.";
			case SBSSRetLocalPathNotExist:
				return "Local Path Do Not Exist.";
			case SBSSRetCantCreateLocalFile:
				return "Can't Save Local File.";
			default:
				return "Application Error.";
		}
	}
	
	return "Operation Completed.";
}

SBoxRet SBoxShowStatus() {
	DLog(@"show status");
	/* show configs & server status */
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
		   " Account Type: %s, User Name: %s;\n"
		   " Encryption User Name: %s;\n"
		   " %s\n",
		   SBoxAccountTypeString([diskManager accountType]),
		   [[diskManager userName] cStringUsingEncoding:NSUTF8StringEncoding],
		   [[system userName] cStringUsingEncoding:NSUTF8StringEncoding],
		   quotaString
		   );
	/* show maps */
	SBoxSyncSystem *syncSystem = [SBoxSyncSystem sharedSystem];
	NSArray *pairs = [syncSystem allPairs];
	printf("%lu map records for syncronization:\n", [pairs count]);
	for(int i=0; i<[pairs count]; i++){
		SBSSPair *pair = [pairs objectAtIndex:i];
		printf(" <%s, %s>\n",
			   [[pair localPath] cStringUsingEncoding:NSUTF8StringEncoding],
			   [[pair remotePath] cStringUsingEncoding:NSUTF8StringEncoding]);
	}
	
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

SBoxRet SBoxPutFile(const char *localPath, const char *remotePath) {
	DLog(@"put file from {%s} to {%s}", localPath, remotePath);
	
	NSString *localPathString = [NSString stringWithCString:localPath encoding:NSUTF8StringEncoding];
	localPathString = SBoxAbsoluteLocalPathWithPath(localPathString);
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
	
	NSString *localPathString = [NSString stringWithCString:localPath encoding:NSUTF8StringEncoding];
	localPathString = SBoxAbsoluteLocalPathWithPath(localPathString);
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

SBoxRet SBoxMove(const char *remotePath1, const char *remotePath2) {
	DLog(@"move remote file from {%s} to {%s}", remotePath1, remotePath2);
	
	NSString *oldPath = [NSString stringWithCString:remotePath1 encoding:NSUTF8StringEncoding];
	NSString *newPath = [NSString stringWithCString:remotePath2 encoding:NSUTF8StringEncoding];
	SBoxFileSystem *system = [SBoxFileSystem sharedSystem];
	SBFSRet retv = [system moveFileWithOldFilePath:oldPath newFilePath:newPath];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	return SBoxSuccess;
	
}

SBoxRet SBoxAddMap(const char *localPath, const char *remotePath) {
	NSString *localPathString = [NSString stringWithCString:localPath encoding:NSUTF8StringEncoding];
	NSString *remotePathString = [NSString stringWithCString:remotePath encoding:NSUTF8StringEncoding];
	SBoxSyncSystem *system = [SBoxSyncSystem sharedSystem];
	SBFSRet retv = [system addMapWithLocalFilePath:localPathString remoteFilePath:remotePathString];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	return SBoxSuccess;
}

SBoxRet SBoxRemoveMap(const char *localPath) {
	NSString *localPathString = [NSString stringWithCString:localPath encoding:NSUTF8StringEncoding];
	SBoxSyncSystem *system = [SBoxSyncSystem sharedSystem];
	SBFSRet retv = [system removeMapWithLocalFilePath:localPathString];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	return SBoxSuccess;
}

SBoxRet SBoxSync() {
	SBoxSyncSystem *system = [SBoxSyncSystem sharedSystem];
	[system initSync];
	SBSSSyncAction nextAction = SBSSSyncActionSync;
	while([system stillCanSync]){
		SBSSSyncResult result;
		SBSSPair *pair;
		SBSSRet retv = [system syncOneWithAction:nextAction andGetResult:&result pair:&pair];
		if(retv!=SBSSRetSuccess)
			return retv;
		
		nextAction = SBSSSyncActionSync;
		const char *localPath = [[pair localPath] cStringUsingEncoding:NSUTF8StringEncoding];
		switch(result){
			case SBSSSyncUploaded:
				printf("File \"%s\" is uploaded.\n",localPath);
				break;
			case SBSSSyncDownloaded:
				printf("File \"%s\" is downloaded.\n",localPath);
				break;
			case SBSSSyncSame:
				printf("File \"%s\" is ok.\n",localPath);
				break;
			case SBSSSyncFilesDoNotExist:
				printf("File \"%s\" and its online counterpart neither exist.\n",localPath);
				break;
			case SBSSSyncConflicted:{
				printf("File \"%s\" conflicts the online version.\n",localPath);
				char buff[10];
				char *ans = getString(buff, sizeof(buff), 0, "upload, download or skip?");
				if(strcmp(ans, "upload")==0){
					nextAction = SBSSSyncActionForceUpload;
				}else if(strcmp(ans, "download")==0){
					nextAction = SBSSSyncActionForceDownload;
				}else if(strcmp(ans, "skip")==0){
					nextAction = SBSSSyncActionSkip;
				}
				break;
			}
			case SBSSSyncSkipped:
				printf("File \"%s\" is skipped.\n",localPath);
				break;
		}
	}
	
	return SBoxSuccess;
}



