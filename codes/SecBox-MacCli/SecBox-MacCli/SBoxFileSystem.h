//
//  SBoxFileSystem.h
//  SecBox-MacCli
//
//  Created by Zimmer on 5/20/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SecBox.h"
#import "SBoxVDiskManager.h"


typedef enum{
	/* -200 ~ -299 */
	SBFSRetInvalidConfiguation	= -200
}SBFSErrCode;

typedef int	SBFSRet;
#define SBFSRetSuccess 0


//@class SBoxVDiskManager;

@interface SBoxFileSystem : NSObject {
	@private
	SBoxVDiskManager *_diskManager;
	NSString *_currentPath;
	NSString *_userName;
	NSString *_password;
	NSMutableArray *_filePathes;
}

@property(nonatomic,readonly) SBoxVDiskManager* diskManager;

+ (SBoxFileSystem *) sharedSystem;

- (SBFSRet) update;

- (SBFSRet) getListInCurrentDirectory:(NSMutableArray *)list;
- (SBFSRet) changeDirectoryWithSubPath:(NSString *)subPath;

- (SBFSRet) removeFileWithPath:(NSString *)path;

- (SBFSRet) putFileWithPath:(NSString *)path contents:(NSData *)contents;
- (SBFSRet) getFile:(NSData **)contents withPath:(NSString *)path;



@end
