//
//  SBoxFileSystem.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/20/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SecBoxDefines.h"
#import "VDiskManager.h"
#import "SBFSDefines.h"
#import "SBFSTree.h"


@interface SBoxFileSystem : NSObject <VDiskManagerDelegate> {
	@private
	VDiskManager *_diskManager;
	NSString *_currentPath;
	NSString *_userName;
	NSString *_password;
	SBFSTree *_fileTree;	//ONLY accessed by getFileTree:, _updateFileTree
	BOOL _fileTreeUpdated;
}

@property(nonatomic,readonly) VDiskManager* diskManager;

+ (SBoxFileSystem *) sharedSystem;

- (NSString *) userName;
- (NSString *) currentPath;

- (SBFSRet) setAccountInfoWithAccountType:(SBoxAccountType)accountType userName:(NSString *)userName password:(NSString *)password;
- (SBFSRet) setEncryptionInfoWithUserName:(NSString *)userName password:(NSString *)password;
- (void) saveConfigs;

- (NSString *) absolutePathWithPath:(NSString *)path;
- (NSString *) fileMd5InRemoteWithContents:(NSData *)contents;

- (SBFSRet) getFileNode:(SBFSNode **)fileNode withFilePath:(NSString *)filePath;

- (SBFSRet) getNodesInCurrentDirectory:(NSArray **)nodes sort:(BOOL)sort;
- (SBFSRet) changeDirectoryWithPath:(NSString *)path;

- (SBFSRet) removeFileWithFilePath:(NSString *)filePath;
- (SBFSRet) moveFileWithOldFilePath:(NSString *)oldFilePath newFilePath:(NSString *)newFilePath;

- (SBFSRet) putFileWithFilePath:(NSString *)filePath contents:(NSData *)contents;
- (SBFSRet) getFile:(NSData **)contents withFilePath:(NSString *)filePath;

@end

SBFSRet SBFSValidateAbsolutePath(NSString *path);
SBFSRet SBFSValidateAbsoluteFilePath(NSString *filePath);

NSString *SBFSFileNameWithFilePath(NSString *filePath);
NSString *SBFSDirPathWithFilePath(NSString *filePath);

NSString *SBFSDirNameWithDirPath(NSString *dirPath);
NSArray *SBFSNamesWithPath(NSString *path);
