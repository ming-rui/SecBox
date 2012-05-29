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


@interface SBoxFileSystem()
@property(nonatomic,retain) NSString* currentPath;
@property(nonatomic,retain) NSString* userName;
@property(nonatomic,retain) NSString* password;
@end


@implementation SBoxFileSystem

@synthesize diskManager=_diskManager;
@synthesize currentPath=_currentPath;
@synthesize userName=_userName;
@synthesize password=_password;


#pragma mark object life

- (id) initWithDiskManager:(VDiskManager *)diskManager currentPath:(NSString *)currentPath userName:(NSString *)userName password:(NSString *)password {
	self = [super init];
	if(self){
		_diskManager = [diskManager retain];
		[_diskManager setDelegate:self];
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
	
	if(_sharedSystem==nil){
		SBoxConfigs *configs = [SBoxConfigs sharedConfigs];
			
		SBoxAccountType accountType = [configs accountType];
		NSString *accUserName = [configs accountUserName];
		NSString *accPassword = [configs accountPassword];
		NSString *accToken = [configs accountToken];
		VDiskManager *diskManager = [VDiskManager managerWithAccountType:accountType userName:accUserName password:accPassword token:accToken];
		
		NSString *currentPath = [configs currentRemotePath];
		NSString *userName = [configs encryptionUserName];
		NSString *password = [configs encryptionPassword];
		
		_sharedSystem = [[self alloc] initWithDiskManager:diskManager currentPath:currentPath userName:userName password:password];
	}
	
	return _sharedSystem;
}


#pragma configs

- (SBFSRet) setAccountInfoWithAccountType:(SBoxAccountType)accountType userName:(NSString *)userName password:(NSString *)password {
	[_diskManager setAccountType:accountType];
	[_diskManager setUserName:userName];
	[_diskManager setPassword:password];
	
	return SBFSRetSuccess;
}

- (SBFSRet) setEncryptionInfoWithUserName:(NSString *)userName password:(NSString *)password {
	if([userName length]==0||[userName length]>kSBoxMaxEncUserNameLength)
		return SBoxRetInvalidInput;
	
	for(int i=0; i<[userName length]; i++){
		unichar ch = [userName characterAtIndex:i];
		if(ch=='['||ch==']')
			return SBoxRetInvalidInput;
	}
	
	if([password length]==0)
		return SBoxRetInvalidInput;
	
	[self setUserName:userName];
	[self setPassword:password];
	
	return SBFSRetSuccess;
}

- (void) saveConfigs {
	SBoxConfigs *configs = [SBoxConfigs sharedConfigs];
	
	[configs setAccountType:[_diskManager accountType]];
	[configs setAccountUserName:[_diskManager userName]];
	[configs setAccountPassword:[_diskManager password]];
	
	[configs setCurrentRemotePath:_currentPath];
	[configs setEncryptionUserName:_userName];
	[configs setEncryptionPassword:_password];
	
	[configs save];
}

#pragma mark file name format

- (NSString *) physicalNameWithFilePath:(NSString *)filePath {
	DAssert(_userName!=nil&&_password!=nil);
	NSData *data = [filePath dataUsingEncoding:NSUTF8StringEncoding];
	NSData *encryptedData = [SBoxAlgorithms encryptWithData:data key:_password];
	NSString *encodedString = [SBoxAlgorithms base64wsEncodeWithData:encryptedData];
	NSString *string = [NSString stringWithFormat:@"[SecBox][%@][%@]", _userName, encodedString];
	
	return string;
}

- (BOOL) _getUserName:(NSString **)userName string:(NSString **)string withPhysicalName:(NSString *)physicalName {
	if(![physicalName hasPrefix:@"[SecBox]["])
		return NO;
	
	NSMutableString *userNameBuffer = [NSMutableString string];
	NSMutableString *stringBuffer = [NSMutableString string];
	
	int i;
	int length = [physicalName length];
	unichar ch = 0;
	for(i=9; i<length; i++){
		ch = [physicalName characterAtIndex:i];
		if(ch!=']')
			[userNameBuffer appendFormat:@"%C",ch];
		else
			break;
	}
	++i;
	if(i>=length||[physicalName characterAtIndex:i]!='[')
		return NO;
	for(++i; i<length; i++){
		ch = [physicalName characterAtIndex:i];
		if(ch!=']')
			[stringBuffer appendFormat:@"%C",ch];
		else
			break;
	}
	if([userNameBuffer length]==0||[stringBuffer length]==0)
		return NO;
	if(!(ch==']'&&i==length-1))
		return NO;
	
	*userName = userNameBuffer;
	*string = stringBuffer;
	
	return YES;
}

- (NSString *) _processPath:(NSString *)path {
	//for compatability
	//WARRNING! this may lead to some bugs.
	if([path hasPrefix:@"/"])
		return path;
	path = [path stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
	if(![path hasPrefix:@"/"])
		path = [@"/" stringByAppendingString:path];
	
	return path;
}

- (NSString *) pathWithPhysicalName:(NSString *)physicalName {
	DAssert(_userName!=nil&&_password!=nil);
	NSString *userName = nil;
	NSString *string = nil;
	if(![self _getUserName:&userName string:&string withPhysicalName:physicalName])
		return nil;
	if(![userName isEqualToString:_userName])
		return nil;
	
	NSData *data = [SBoxAlgorithms base64wsDecodeWithString:string];
	NSData *decrytedData = [SBoxAlgorithms decryptWithData:data Key:_password];
	NSString *path = [[[NSString alloc] initWithData:decrytedData encoding:NSUTF8StringEncoding] autorelease];
	path = [self _processPath:path];
	
	return path;
}


#pragma mark fileTree cache

- (SBFSRet) _updateFileTree {
	[_fileTree removeAllData];
	
	NSArray *fileList;
	VDiskRet retv = [_diskManager getRootFileList:&fileList];
	if(retv!=VDiskRetSuccess)
		return retv;
	
	for(VDiskItemInfo *fileInfo in fileList){
		NSString *physicalFileName = [fileInfo name];
		NSString *path = [self pathWithPhysicalName:physicalFileName];
		if(path)
			[_fileTree addFileNodeWithFilePath:path vDiskItemInfo:fileInfo overwrite:NO];
	}
	
	_fileTreeUpdated = YES;
	
	return SBFSRetSuccess;
}

- (SBFSRet) getFileTree:(SBFSTree **)fileTree {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
	if(!_fileTreeUpdated){
		SBFSRet retv = [self _updateFileTree];
		if(retv!=SBFSRetSuccess)
			return retv;
	}
	
	*fileTree = _fileTree;
	
	return SBFSRetSuccess;
}


#pragma mark interface

- (BOOL) configuationInvalid {
	return (_userName==nil||_password==nil||[_diskManager configurationInvalid]);
}

- (NSString *) absolutePathWithPath:(NSString *)path {
	if(![path hasPrefix:@"/"]){
		path = [NSString stringWithFormat:@"%@/%@", _currentPath, path];
	}
	path = [path stringByStandardizingPath];
	
	return path;
}

- (NSString *) fileMd5InRemoteWithContents:(NSData *)contents {
	NSData *encryptedData = [SBoxAlgorithms encryptWithData:contents key:_password];
	NSString *md5 = [SBoxAlgorithms md5WithData:encryptedData];
	
	return md5;
}

- (SBFSRet) getFileNode:(SBFSNode **)fileNode withFilePath:(NSString *)filePath {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
	filePath = [self absolutePathWithPath:filePath];
	SBFSRet retv = SBFSValidateAbsoluteFilePath(filePath);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	SBFSTree *fileTree;
	retv = [self getFileTree:&fileTree];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	SBFSNode *node;
	retv = [fileTree getFileNode:&node withFilePath:filePath];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	*fileNode = node;
	
	return SBFSRetSuccess;
}

- (SBFSRet) getNodesInCurrentDirectory:(NSArray **)nodes sort:(BOOL)sort{
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
	SBFSRet retv = SBFSValidateAbsolutePath(_currentPath);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	SBFSTree *fileTree;
	retv = [self getFileTree:&fileTree];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	SBFSNode *dirNode;
	retv = [fileTree getDirNode:&dirNode withDirPath:_currentPath createDir:YES];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	*nodes = [dirNode allChildNodes];
	if(sort)
		*nodes = [*nodes sortedArrayUsingSelector:@selector(compare:)];
	
	return SBFSRetSuccess;
}

- (SBFSRet) changeDirectoryWithPath:(NSString *)path {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
	path = [self absolutePathWithPath:path];
	SBFSRet retv = SBFSValidateAbsolutePath(path);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	[self setCurrentPath:path];
	
	return SBFSRetSuccess;
}

- (SBFSRet) removeFileWithFilePath:(NSString *)filePath {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
	filePath = [self absolutePathWithPath:filePath];
	SBFSRet retv = SBFSValidateAbsoluteFilePath(filePath);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	NSString *fileName = [self physicalNameWithFilePath:filePath];
	retv = [_diskManager removeRootFileWithFileName:fileName];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	return SBFSRetSuccess;
}

- (SBFSRet) moveFileWithOldFilePath:(NSString *)oldFilePath newFilePath:(NSString *)newFilePath {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
	oldFilePath = [self absolutePathWithPath:oldFilePath];
	SBFSRet retv = SBFSValidateAbsoluteFilePath(oldFilePath);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	newFilePath = [self absolutePathWithPath:newFilePath];
	retv = SBFSValidateAbsoluteFilePath(newFilePath);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	NSString *oldFileName = [self physicalNameWithFilePath:oldFilePath];
	NSString *newFileName = [self physicalNameWithFilePath:newFilePath];
	
	retv = [_diskManager renameRootFileWithOldFileName:oldFileName newFileName:newFileName];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	return SBFSRetSuccess;
}

- (SBFSRet) putFileWithFilePath:(NSString *)filePath contents:(NSData *)contents {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
	NSString *path = [self absolutePathWithPath:filePath];
	SBFSRet retv = SBFSValidateAbsoluteFilePath(path);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	NSString *fileName = [self physicalNameWithFilePath:path];
	NSData *encryptedContents = [SBoxAlgorithms encryptWithData:contents key:_password];
	if(encryptedContents==nil)
		return SBFSRetEncrytionError;
	
	retv = [_diskManager uploadFileToRootWithFileName:fileName contents:encryptedContents];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	return SBFSRetSuccess;
}

- (SBFSRet) getFile:(NSData **)contents withFilePath:(NSString *)filePath {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
	NSString *path = [self absolutePathWithPath:filePath];
	
	SBFSRet retv = SBFSValidateAbsoluteFilePath(path);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	NSString *fileName = [self physicalNameWithFilePath:path];
	NSData *encryptedContents;
	retv = [_diskManager downloadFileFromRoot:&encryptedContents withFileName:fileName];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	*contents = [SBoxAlgorithms decryptWithData:encryptedContents Key:_password];
	if(*contents==nil)
		return SBFSRetDecrytionError;
	
	return SBFSRetSuccess;
}


#pragma mark VDiskManagerDelegate

- (void) vDiskManagerFileListUpdated:(VDiskManager *)vDiskManager {
	_fileTreeUpdated = NO;
}

@end


#pragma mark -
#pragma mark C functions

SBFSRet SBFSValidateAbsolutePath(NSString *path) {
	if([path length]==0||[path characterAtIndex:0]!='/')
		return SBFSRetInvalidPath;

	if([path length]>kSBoxMaxPathLength)
		return SBFSRetPathTooLong;

	return SBFSRetSuccess;
}

SBFSRet SBFSValidateAbsoluteFilePath(NSString *filePath) {
	if([filePath isEqualToString:@"/"])
		return SBFSRetInvalidFilePath;
	
	return SBFSValidateAbsolutePath(filePath);
}

NSString *SBFSFileNameWithFilePath(NSString *filePath) {
	DCAssert(SBFSValidateAbsoluteFilePath(filePath)==SBFSRetSuccess);
	
	NSString *fileName = [filePath lastPathComponent];
	DCAssert(fileName!=nil&&[fileName length]>0);
	
	return fileName;
}

NSString *SBFSDirPathWithFilePath(NSString *filePath) {
	DCAssert(SBFSValidateAbsoluteFilePath(filePath)==SBFSRetSuccess);
	
	NSString *dirPath = [filePath stringByDeletingLastPathComponent];
	DCAssert(dirPath!=nil&&[dirPath length]>0);
	
	return dirPath;
}

NSString *SBFSDirNameWithDirPath(NSString *dirPath) {
	DCAssert(SBFSValidateAbsolutePath(dirPath)==SBFSRetSuccess);
	
	NSString *dirName = [dirPath lastPathComponent];
	DCAssert(dirName!=nil&&[dirName length]>0);
	
	return dirName;
}

NSArray *SBFSNamesWithPath(NSString *path) {
	DCAssert(SBFSValidateAbsolutePath(path)==SBFSRetSuccess);
	
	NSArray *names = [path pathComponents];
	DCAssert(names!=nil);
	
	return names;
}

