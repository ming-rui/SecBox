//
//  SBoxFileSystem.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/20/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import "SBoxFileSystem.h"

#import "SBoxDefines.h"
#import "SBoxConfigs.h"
#import "SBoxAlgorithms.h"
#import "SBFSTree.h"


@implementation SBoxFileSystem

@synthesize diskManager=_diskManager;


#pragma mark object life

- (id) initWithDiskManager:(SBoxVDiskManager *)diskManager currentPath:(NSString *)currentPath userName:(NSString *)userName password:(NSString *)password {
	self = [super init];
	if(self){
		_diskManager = [diskManager retain];
		if(currentPath){
			_currentPath = [currentPath retain];
		}else{
			_currentPath = @"/";
		}
		_userName = [userName retain];
		_password = [password retain];
		_fileTree = [[SBFSTree alloc] init];
	}
	
	return self;
}

- (void) dealloc {
	[_diskManager release];
	[_currentPath release];
	[_userName release];
	[_password release];
	[_fileTree release];
	
	[super dealloc];
}

+ (SBoxFileSystem *) sharedSystem {
	static SBoxFileSystem *_sharedSystem = nil;
	
	@synchronized(self){
		if(_sharedSystem==nil){
			SBoxConfigs *configs = [SBoxConfigs sharedConfigs];
			
			SBoxAccountType accountType = [configs accountType];
			NSString *accUserName = [configs accountUserName];
			NSString *accPassword = [configs accountPassword];
			SBoxVDiskManager *diskManager = [SBoxVDiskManager managerWithAccountType:accountType userName:accUserName password:accPassword];
			
			NSString *currentPath = [configs currentRemotePath];
			NSString *userName = [configs encryptionUserName];
			NSString *password = [configs encryptionPassword];
			
			_sharedSystem = [[self alloc] initWithDiskManager:diskManager currentPath:currentPath userName:userName password:password];
		}
	}
	
	return _sharedSystem;
}


#pragma mark file name format

- (NSString *) fileNameWithPath:(NSString *)path {
	DAssert(_userName!=nil&&_password!=nil);
	NSData *data = [path dataUsingEncoding:NSUTF8StringEncoding];
	NSData *encryptedData = [SBoxAlgorithms encryptWithData:data key:_password];
	NSString *encodedString = [SBoxAlgorithms base64wsEncodeWithData:encryptedData];
	NSString *string = [NSString stringWithFormat:@"[SecBox][%@][%@]", _userName, encodedString];
	
	return string;
}

- (BOOL) _getUserName:(NSString **)userName string:(NSString **)string withFileName:(NSString *)fileName {
	if(![fileName hasPrefix:@"[SecBox]["])
		return NO;
	
	NSMutableString *userNameBuffer = [NSMutableString string];
	NSMutableString *stringBuffer = [NSMutableString string];
	
	int i;
	unichar ch = 0;
	for(i=9; i<[fileName length]; i++){
		ch = [fileName characterAtIndex:i];
		if(ch!=']')
			[userNameBuffer appendFormat:@"%C",ch];
		else
			break;
	}
	++i;
	if(i>=[fileName length]||[fileName characterAtIndex:i]!='[')
		return NO;
	for(++i; i<[fileName length]; i++){
		ch = [fileName characterAtIndex:i];
		if(ch!=']')
			[stringBuffer appendFormat:@"%C",ch];
		else
			break;
	}
	if([userNameBuffer length]==0||[stringBuffer length]==0)
		return NO;
	if(!(ch==']'&&i==[fileName length]-1))
		return NO;
	
	*userName = userNameBuffer;
	*string = stringBuffer;
	
	return YES;
}

- (NSString *) pathWithFileName:(NSString *)fileName {
	DAssert(_userName!=nil&&_password!=nil);
	NSString *userName = nil;
	NSString *string = nil;
	if(![self _getUserName:&userName string:&string withFileName:fileName])
		return nil;
	if(![userName isEqualToString:_userName])
		return nil;
	
	NSData *data = [SBoxAlgorithms base64wsDecodeWithString:string];
	NSData *decrytedData = [SBoxAlgorithms decryptWithData:data Key:_password];
	NSString *path = [[[NSString alloc] initWithData:decrytedData encoding:NSUTF8StringEncoding] autorelease];
	
	return path;
}

- (SBFSRet) _updateFileTree {
	[_fileTree removeAllData];
	
	NSMutableArray *fileList = [NSMutableArray array];
	VDiskRet retv = [_diskManager getRootFileList:fileList];
	if(retv!=VDiskRetSuccess)
		return retv;
	
	for(VDiskItemInfo *fileInfo in fileList){
		NSString *fileName = [fileInfo name];
		NSString *path = [self pathWithFileName:fileName];
		if(path)
			[_fileTree addFileNodeWithFilePath:path vDiskItemInfo:fileInfo overwrite:NO];
	}
	
	return SBFSRetSuccess;
}


#pragma mark interface

- (BOOL) configuationInvalid {
	return (_userName==nil||_password==nil||[_diskManager configurationInvalid]);
}

- (SBFSRet) update {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
	return [self _updateFileTree];
}

- (SBFSRet) getListInCurrentDirectory:(NSMutableArray *)list {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
}

- (SBFSRet) changeDirectoryWithSubPath:(NSString *)subPath {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
}

- (SBFSRet) removeFileWithFilePath:(NSString *)filePath {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
}

- (SBFSRet) putFileWithFilePath:(NSString *)filePath contents:(NSData *)contents {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
	SBFSRet retv = SBFSValidateFilePath(filePath);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	NSString *fileName = [self fileNameWithPath:filePath];
	NSData *encryptedContents = [SBoxAlgorithms encryptWithData:contents key:_password];
	if(encryptedContents==nil)
		return SBFSRetEncrytionError;
	
	retv = [_diskManager uploadFileToRootWithFileName:fileName contents:encryptedContents];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	retv = [self update];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	return SBFSRetSuccess;
}

- (SBFSRet) getFile:(NSData **)contents withFilePath:(NSString *)filePath {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
	SBFSRet retv = SBFSValidateFilePath(filePath);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	NSString *fileName = [self fileNameWithPath:filePath];
	NSData *encryptedContents;
	retv = [_diskManager downloadFileFromRoot:&encryptedContents withFileName:fileName];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	*contents = [SBoxAlgorithms decryptWithData:encryptedContents Key:_password];
	if(*contents==nil)
		return SBFSRetDecrytionError;
	
	return SBFSRetSuccess;
}

@end


SBFSRet SBFSValidatePath(NSString *path) {
	if([path length]==0||[path characterAtIndex:0]!='/')
		return SBFSRetInvalidPath;

	if([path length]>kSBoxMaxPathLength)
		return SBFSRetPathTooLong;

	return SBFSRetSuccess;
}

SBFSRet SBFSValidateFilePath(NSString *filePath) {
	if([filePath isEqualToString:@"/"])
		return SBFSRetInvalidFilePath;
	
	return SBFSValidatePath(filePath);
}

NSString *SBFSFileNameWithFilePath(NSString *filePath) {
	DCAssert(SBFSValidateFilePath(filePath)==SBFSRetSuccess);
	
	NSString *fileName = [filePath lastPathComponent];
	DCAssert(fileName!=nil&&[fileName length]>0);
	
	return fileName;
}

NSString *SBFSDirPathWithFilePath(NSString *filePath) {
	DCAssert(SBFSValidateFilePath(filePath)==SBFSRetSuccess);
	
	NSString *dirPath = [filePath stringByDeletingLastPathComponent];
	DCAssert(dirPath!=nil&&[dirPath length]>0);
	
	return dirPath;
}

NSString *SBFSDirNameWithDirPath(NSString *dirPath) {
	DCAssert(SBFSValidatePath(dirPath)==SBFSRetSuccess);
	
	NSString *dirName = [dirPath lastPathComponent];
	DCAssert(dirName!=nil&&[dirName length]>0);
	
	return dirName;
}

NSArray *SBFSDirNamesWithDirPath(NSString *dirPath) {
	DCAssert(SBFSValidatePath(dirPath)==SBFSRetSuccess);
	
	NSArray *dirNames = [dirPath pathComponents];
	DCAssert(dirNames!=nil);
	
	return dirNames;
}

