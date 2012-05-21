//
//  SBoxVDiskManager.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/8/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VDiskDefines.h"
#import "VDiskItemInfo.h"


typedef enum{
	VDiskAccountTypeWeibo	=	0,
	VDiskAccountTypeWeipan	=	1,
}VDiskAccountType;

typedef enum {
	VDiskManagerStateOffline = 0,
	VDiskManagerStateNeedUpdate,
	VDiskManagerStateOnline,
}VDiskManagerState;

typedef struct {
	long long used;
	long long total;
}VDiskQuota;
#define VDiskQuotaMake(used,total)	((VDiskQuota){(used),(total)})

@class SBJsonParser;

@interface VDiskManager : NSObject {
	@private
	//account info
	VDiskAccountType _accountType;
	NSString *_userName;
	NSString *_password;
	
	//sate info
	VDiskManagerState _state;
	NSString *_token;
	NSInteger _dologID;
	
	//helper
	SBJsonParser *_jsonParser;
}

+ (VDiskManager *) managerWithAccountType:(VDiskAccountType)accountType userName:(NSString *)userName password:(NSString *)password;

- (BOOL) configurationInvalid;

- (VDiskRet) getToken;
- (VDiskRet) keepToken;

- (VDiskRet) getQuota:(VDiskQuota *)quota;
- (VDiskRet) getRootFileList:(NSMutableArray *)fileList;

- (VDiskRet) getRootFileInfo:(VDiskItemInfo **)fileInfo withFileName:(NSString *)fileName;
- (VDiskRet) removeRootFileWithFileName:(NSString *)fileName;

- (VDiskRet) uploadFileToRootWithFileName:(NSString *)fileName contents:(NSData *)contents;
- (VDiskRet) downloadFileFromRoot:(NSData **)contents withFileName:(NSString *)fileName;


///* 下面的path是网盘上真正的path，不是程序虚拟的path */
//- (SBoxRet) putFile:(NSData*)data withPath:(NSString*)path;
//- (SBoxRet) getFile:(NSMutableData*)data withPath:(NSString*)path;

@end
