//
//  SBoxFileSystem.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/20/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SecBox.h"
#import "SBoxVDiskManager.h"
#import "SBFSDefines.h"


//@class SBoxVDiskManager;
@class SBFSTree;

@interface SBoxFileSystem : NSObject {
	@private
	//remote
	SBoxVDiskManager *_diskManager;
	NSString *_currentPath;
	NSString *_userName;
	NSString *_password;
	SBFSTree *_fileTree;
	//local
}

@property(nonatomic,readonly) SBoxVDiskManager* diskManager;

+ (SBoxFileSystem *) sharedSystem;

- (SBFSRet) update;

- (SBFSRet) getListInCurrentDirectory:(NSMutableArray *)list;
- (SBFSRet) changeDirectoryWithSubPath:(NSString *)subPath;

- (SBFSRet) removeFileWithFilePath:(NSString *)filePath;

- (SBFSRet) putFileWithFilePath:(NSString *)filePath contents:(NSData *)contents;
- (SBFSRet) getFile:(NSData **)contents withFilePath:(NSString *)filePath;

@end

SBFSRet SBFSValidatePath(NSString *path);
SBFSRet SBFSValidateFilePath(NSString *filePath);

NSString *SBFSFileNameWithFilePath(NSString *filePath);
NSString *SBFSDirPathWithFilePath(NSString *filePath);

NSString *SBFSDirNameWithDirPath(NSString *dirPath);
NSArray *SBFSDirNamesWithDirPath(NSString *dirPath);
