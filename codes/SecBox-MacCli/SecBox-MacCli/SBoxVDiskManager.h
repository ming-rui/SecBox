//
//  SBoxVDiskManager.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/8/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SecBox.h"
#import "VDiskFileInfo.h"

typedef enum {
	VDiskManagerStateOffline = 0,
	VDiskManagerStateNeedUpdate,
	VDiskManagerStateOnline,
}VDiskManagerState;

typedef int VDiskRet;

typedef struct {
	long long used;
	long long total;
}VDiskQuota;
#define VDiskQuotaMake(used,total)	((VDiskQuota){(used),(total)})

@class SBJsonParser;
@class VDiskFileInfo;

@interface SBoxVDiskManager : NSObject {
	@private
	//account info
	SBoxAccountType _accountType;
	NSString *_userName;
	NSString *_password;
	
	//sate info
	VDiskManagerState _state;
	NSString *_token;
	NSInteger _dologID;
	
	//dictionary
	NSMutableArray *_root;
	
	//helper
	SBJsonParser *_jsonParser;
}

+ (SBoxVDiskManager *) sharedManager;

- (VDiskRet) getToken;
- (VDiskRet) keepToken;

- (VDiskRet) getQuota:(VDiskQuota *)quota;
- (VDiskRet) getRootFileList:(NSMutableArray *)fileList;

- (VDiskRet) getRootFileInfo:(VDiskFileInfo **)fileInfo withFileName:(NSString *)fileName;
- (VDiskRet) removeRootFileWithFileName:(NSString *)fileName;

- (VDiskRet) putFileToRootWithFileName:(NSString *)fileName data:(NSData *)data;
- (VDiskRet) getFileFromRoot:(NSMutableData *)data withFileName:(NSString *)fileName;


///* 下面的path是网盘上真正的path，不是程序虚拟的path */
//- (SBoxRet) putFile:(NSData*)data withPath:(NSString*)path;
//- (SBoxRet) getFile:(NSMutableData*)data withPath:(NSString*)path;

@end
