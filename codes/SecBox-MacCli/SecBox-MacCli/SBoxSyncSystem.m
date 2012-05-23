//
//  SBoxSyncSystem.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/23/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import "SBoxDefines.h"
#import "SBoxSyncSystem.h"
#import "SBoxConfigs.h"
#import "SBoxFileSystem.h"
#import "SBoxUtils.h"


@implementation SBoxSyncSystem

- (id) initWithPairs:(NSMutableDictionary *)pairs {
	self = [super init];
	if(self){
		if(pairs){
			_pairs = [pairs retain];
		}else{
			_pairs = [[NSMutableDictionary alloc] init];
		}
	}
	
	return self;
}

- (void) dealloc {
	[_pairs release];
	[_syncList release];
	
	[super dealloc];
}

+ (SBoxSyncSystem *) sharedSystem {
	static SBoxSyncSystem *_sharedSystem = nil;
	
	if(_sharedSystem==nil){
		SBoxConfigs *configs = [SBoxConfigs sharedConfigs];
		_sharedSystem = [[self alloc] initWithPairs:[configs pairs]];
	}
	
	return _sharedSystem;
}

- (void) saveConfigs {
	SBoxConfigs *configs = [SBoxConfigs sharedConfigs];
	[configs setPairs:_pairs];
	[configs save];
}

- (NSArray*) allPairs {
	return [_pairs allValues];
}

- (SBSSRet) addMapWithLocalFilePath:(NSString *)localFilePath remoteFilePath:(NSString *)remoteFilePath {
	localFilePath = SBoxAbsoluteLocalPathWithPath(localFilePath);
	if(!SBoxValidateAbsoluteLocalPath(localFilePath))
		return SBSSRetInvalidLocalPath;
	
	remoteFilePath = [[SBoxFileSystem sharedSystem] absolutePathWithPath:remoteFilePath];
	SBSSRet retv = SBFSValidateAbsolutePath(remoteFilePath);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	if([_pairs objectForKey:localFilePath]!=nil)
		return SBSSRetLocalPathCollision;
	
	SBSSPair *pair = [SBSSPair pairWithLocalPath:localFilePath remotePath:remoteFilePath];
	[_pairs setObject:pair forKey:localFilePath];
	
	return SBSSRetSuccess;
}

- (SBSSRet) removeMapWithLocalFilePath:(NSString *)localFilePath {
	localFilePath = SBoxAbsoluteLocalPathWithPath(localFilePath);
	if(!SBoxValidateAbsoluteLocalPath(localFilePath))
		return SBSSRetInvalidLocalPath;
	
	if([_pairs objectForKey:localFilePath]==nil)
		return SBSSRetLocalPathNotExist;
	
	[_pairs removeObjectForKey:localFilePath];
	
	return SBSSRetSuccess;
}

- (void) initSync {
	[_syncList release];
	_syncList = [[_pairs allValues] retain];
	_syncIndex = 0;
}

- (SBSSRet) syncOneWithAction:(SBSSSyncAction)action andGetResult:(SBSSSyncResult *)result pair:(SBSSPair **)pair {
	SBSSPair *currentPair = [_syncList objectAtIndex:_syncIndex];
	*pair = currentPair;
	NSString *localPath = [currentPair localPath];
	NSString *remotePath = [currentPair remotePath];
	
	NSFileManager *local = [NSFileManager defaultManager];
	SBoxFileSystem *remote = [SBoxFileSystem sharedSystem];
	
	NSData *fileContents = [local contentsAtPath:localPath];
	NSString *localMd5 = [remote fileMd5InRemoteWithContents:fileContents];
	BOOL localFileExist = (fileContents!=nil);
	
	SBFSNode *fileNode = nil;
	BOOL remoteFileExist = YES;
	SBFSRet retv = [remote getFileNode:&fileNode withFilePath:remotePath];
	if(retv==SBFSRetNodeNotExist){
		remoteFileExist = NO;
	}else if(retv!=SBFSRetSuccess){
		return retv;
	}
	NSString *remoteMd5 = [[fileNode itemInfo] fileMd5];
	
	if(localFileExist&&remoteFileExist&&[localMd5 isEqualToString:remoteMd5]){
		/* no action */
		*result = SBSSSyncSame;
	}else if((localFileExist&&remoteFileExist&&action==SBSSSyncActionForceUpload)||(localFileExist&&!remoteFileExist)){
		/* put */
		*result = SBSSSyncUploaded;
		retv = [remote putFileWithFilePath:remotePath contents:fileContents];
		if(retv!=SBFSRetSuccess)
			return retv;
		[currentPair setLastMd5:localMd5];
	}else if((localFileExist&&remoteFileExist&&action==SBSSSyncActionForceDownload)||(!localFileExist&&remoteFileExist)){
		/* get */
		*result = SBSSSyncDownloaded;
		retv = [remote getFile:&fileContents withFilePath:remotePath];
		if(retv!=SBFSRetSuccess)
			return retv;
		
		BOOL rt = [local createFileAtPath:localPath contents:fileContents attributes:nil];
		if(!rt)
			return SBSSRetCantCreateLocalFile;
		[currentPair setLastMd5:remoteMd5];
	}else if(localFileExist&&remoteFileExist&&action==SBSSSyncActionReportCollision){
		/* report */
		*result = SBSSSyncConflicted;
	}else if(!localFileExist&&!remoteFileExist){
		/* both files do not exist */
		*result = SBSSSyncFilesDoNotExist;
	}else{
		DAssert(NO);
	}
	
	_syncIndex++;
	
	return SBSSRetSuccess;
}

- (BOOL) stillCanSync {
	return (_syncIndex<[_syncList count]);
}

@end
