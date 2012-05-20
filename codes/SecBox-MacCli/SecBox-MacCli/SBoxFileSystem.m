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

@implementation SBoxFileSystem

@synthesize diskManager=_diskManager;

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
		_filePathes = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void) dealloc {
	[_diskManager release];
	[_currentPath release];
	[_userName release];
	[_password release];
	[_filePathes release];
	
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

- (NSString *) fileNameWithPath:(NSString *)path {
	DAssert(_userName!=nil&&_password!=nil,@"");
	NSData *data = [path dataUsingEncoding:NSUTF8StringEncoding];
	NSData *encryptedData = [SBoxAlgorithms encryptWithData:data key:_password];
	NSString *encoded = [SBoxAlgorithms base64wsEncodeWithData:encryptedData];
	NSString *string = [NSString stringWithFormat:@"[SecBox][%@][%@]", _userName, encoded];
	
	return string;
}

- (BOOL) _getUserName:(NSString **)userName string:(NSString **)string withFileName:(NSString *)fileName {
	if(![fileName hasPrefix:@"[SecBox]["])
		return NO;
	
	NSMutableString *userNameBuffer = [NSMutableString string];
	NSMutableString *stringBuffer = [NSMutableString string];
	
	int i;
	unichar ch;
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
	DAssert(_userName!=nil&&_password!=nil,@"");
	NSString *userName = nil;
	NSString *string = nil;
	if(![self _getUserName:&userName string:&string withFileName:fileName])
		return nil;
	if(![userName isEqualToString:_userName])
		return nil;
	
	NSData *data = [SBoxAlgorithms base64wsDecodeWithString:string];
	NSData *decrytedData = [SBoxAlgorithms decryptWithData:data Key:_password];
	NSString *path = [[NSString alloc] initWithData:decrytedData encoding:NSUTF8StringEncoding];
	
	return path;
}

- (SBFSRet) _updateFilePathes {
	[_filePathes removeAllObjects];
	
	NSMutableArray *fileList = [NSMutableArray array];
	VDiskRet retv = [_diskManager getRootFileList:fileList];
	if(retv!=VDiskRetSuccess)
		return retv;
	
	for(VDiskItemInfo *fileInfo in fileList){
		NSString *fileName = [fileInfo name];
		NSString *path = [self pathWithFileName:fileName];
		if(path)
			[_filePathes addObject:path];
	}
	
	return SBFSRetSuccess;
}

- (BOOL) configuationInvalid {
	return _userName==nil;
}

- (SBFSRet) update {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
	return [self _updateFilePathes];
}

- (SBFSRet) getListInCurrentDirectory:(NSMutableArray *)list {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
}

- (SBFSRet) changeDirectoryWithSubPath:(NSString *)subPath {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
}

- (SBFSRet) removeFileWithPath:(NSString *)path {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
}

- (SBFSRet) putFileWithPath:(NSString *)path contents:(NSData *)contents {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
}

- (SBFSRet) getFile:(NSData **)contents withPath:(NSString *)path {
	if([self configuationInvalid])
		return SBFSRetInvalidConfiguation;
	
}

@end
