//
//  SBoxVDiskManager.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/8/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SecBox.h"
#import "SBoxVDiskFileInfo.h"

typedef enum {
	VDiskManagerStateOffline = 0,
	VDiskManagerStateNeedUpdate,
	VDiskManagerStateOnline,
}VDiskManagerState;

typedef enum {
	VDiskRetSuccess				= SBoxSuccess,	//...
	VDiskRetConnectionError		= -1,	//[argumented]
	VDiskRetNoMatchingFile		= -2,	//[argumented]getRootFileID
	VDiskRetInvalidSignature	= 1,	//get_token,
	VDiskRetInvalidCover		= 1,	//upload_file
	VDiskRetInvalidAccount		= 2,	//get_token,
	VDiskRetInvalidDirID		= 2,	//getlist,
	VDiskRetInvalidFile			= 2,	//delete_file
	VDiskRetInvalidTime			= 3,	//get_token,
	VDiskRetInvalidDir			= 3,	//upload_file
	VDiskRetFileLocked			= 3,	//delete_file
	VDiskRetFileNameCollision	= 4,	//upload_file
	VDiskRetSystemError			= 5,	//delete_file, upload_file
	VDiskRetS3Error				= 6,	//?upload_file
	VDiskRetLowCapacity			= 7,	//upload_file
	VDiskRetOverUpMaxFileSize	= 101,	//upload_file
	VDiskRetOverMaxFileSize		= 102,	//upload_file
	VDiskRetUploadNotFull		= 103,	//upload_file
	VDiskRetUploadFail			= 104,	//upload_file
	VDiskRetFormatCanNotShare	= 105,	//upload_file
	VDiskRetFileCanNotShare		= 106,	//upload_file
	VDiskRetDirFull				= 601,	//upload_file
	VDiskRetOldDolog			= 602,	//...
	VDiskRetLackParameter		= 701,	//get_token, upload_file
	VDiskRetInvalidToken		= 702,	//...
	VDiskRetReUpload			= 721,	//upload_file
	VDiskRetExceedLimits		= 900,	//...
	VDiskRetInvalidParameter	= 909,	//getlist, get_quota
}VDiskErrCode;
typedef int VDiskRet;

typedef struct {
	long long used;
	long long total;
}VDiskQuota;
#define VDiskQuotaMake(used,total)	((VDiskQuota){(used),(total)})

@class SBJsonParser;
@class SBoxVDiskFileInfo;

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

- (VDiskRet) getRootFileInfo:(SBoxVDiskFileInfo **)fileInfo withFileName:(NSString *)fileName;
- (VDiskRet) removeRootFileWithFileName:(NSString *)fileName;

- (VDiskRet) putFileToRootWithFileName:(NSString *)fileName data:(NSData *)data;
- (VDiskRet) getFileFromRoot:(NSMutableData *)data withFileName:(NSString *)fileName;


///* 下面的path是网盘上真正的path，不是程序虚拟的path */
//- (SBoxRet) putFile:(NSData*)data withPath:(NSString*)path;
//- (SBoxRet) getFile:(NSMutableData*)data withPath:(NSString*)path;

@end
