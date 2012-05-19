//
//  SBoxVDiskManager.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/8/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SecBox.h"

typedef enum {
	SBoxVDiskManagerStateOffline = 0,
	SBoxVDiskManagerStateNeedUpdate,
	SBoxVDiskManagerStateOnline,
}SBoxVDiskManagerState;

typedef enum {
	SBoxVDRetSuccess			= SBoxSuccess,	//...
	SBoxVDRetConnectionError	= -1,
	SBoxVDRetInvalidSignature	= 1,	//get_token,
	SBoxVDRetInvalidCover		= 1,	//upload_file
	SBoxVDRetInvalidAccount		= 2,	//get_token,
	SBoxVDRetInvalidDirID		= 2,	//getlist,
	SBoxVDRetInvalidFile		= 2,	//delete_file
	SBoxVDRetInvalidTime		= 3,	//get_token,
	SBoxVDRetInvalidDir			= 3,	//upload_file
	SBoxVDRetFileLocked			= 3,	//delete_file
	SBoxVDRetFileNameCollision	= 4,	//upload_file
	SBoxVDRetSystemError		= 5,	//delete_file, upload_file
	SBoxVDRetS3Error			= 6,	//?upload_file
	SBoxVDRetLowCapacity		= 7,	//upload_file
	SBoxVDRetOverUpMaxFileSize	= 101,	//upload_file
	SBoxVDRetOverMaxFileSize	= 102,	//upload_file
	SBoxVDRetUploadNotFull		= 103,	//upload_file
	SBoxVDRetUploadFail			= 104,	//upload_file
	SBoxVDRetFormatCanNotShare	= 105,	//upload_file
	SBoxVDRetFileCanNotShare	= 106,	//upload_file
	SBoxVDRetDirFull			= 601,	//upload_file
	SBoxVDRetOldDolog			= 602,	//...
	SBoxVDRetLackParameter		= 701,	//get_token, upload_file
	SBoxVDRetInvalidToken		= 702,	//...
	SBoxVDRetReUpload			= 721,	//upload_file
	SBoxVDRetExceedLimits		= 900,	//...
	SBoxVDRetInvalidParameter	= 909,	//getlist, get_quota
}SBoxVDErrCode;


typedef int SBoxVDRet;

typedef struct {
	long long used;
	long long total;
}SBoxVDiskQuota;
#define SBoxVDiskQuotaMake(used,total)	((SBoxVDiskQuota){(used),(total)})

@class SBJsonParser;

@interface SBoxVDiskManager : NSObject {
	@private
	//account info
	SBoxAccountType _accountType;
	NSString *_userName;
	NSString *_password;
	
	//sate info
	SBoxVDiskManagerState _state;
	NSString *_token;
	NSString *_dologID;
	
	//dictionary
	NSMutableArray *_root;
	
	//helper
	SBJsonParser *_jsonParser;
}

+ (SBoxVDiskManager *) sharedManager;

- (SBoxVDRet) getToken;
//- (SBoxVDRet) keepToken;

- (SBoxVDRet) getQuota:(SBoxVDiskQuota *)quota;
- (SBoxVDRet) getRootFileList:(NSMutableArray *)fileList;

//- (SBoxVDRet) getFileInfo:(SBoxVDFileInfo*)fileInfo;
//- (SBoxVDRet) removeFileInRootWithFileName:(NSString *)fileName;

- (SBoxVDRet) putFileToRootWithData:(NSData *)data;
//- (SBoxVDRet) getFileFromRoot:(NSMutableData *)data;


///* 下面的path是网盘上真正的path，不是程序虚拟的path */
//- (SBoxRet) putFile:(NSData*)data withPath:(NSString*)path;
//- (SBoxRet) getFile:(NSMutableData*)data withPath:(NSString*)path;

@end
