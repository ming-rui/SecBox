//
//  VDiskConstants.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/20/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#define kSBoxURLPostBoundary			@"==boundary=="


#define kSBoxVDiskAppTypeWeipan			@"local"
#define kSBoxVDiskAppTypeWeibo			@"sinat"
#define SBoxVDiskAppTypeWithAccountType(type)	((type)?kSBoxVDiskAppTypeWeipan:kSBoxVDiskAppTypeWeibo)


#define kVDiskURLGetToken			@"http://openapi.vdisk.me/?m=auth&a=get_token"
#define kVDiskURLKeepToken			@"http://openapi.vdisk.me/?m=user&a=keep_token"
#define kVDiskURLGetQuota			@"http://openapi.vdisk.me/?m=file&a=get_quota"
#define kVDiskURLGetList			@"http://openapi.vdisk.me/?m=dir&a=getlist"
#define kVDiskURLGetFileInfo		@"http://openapi.vdisk.me/?m=file&a=get_file_info"
#define kVDiskURLDeleteFile			@"http://openapi.vdisk.me/?m=file&a=delete_file"


#define kVDiskPostLabelAccountType	@"app_type"
#define kVDiskPostLabelUserName		@"account"
#define kVDiskPostLabelPassword		@"password"
#define kVDiskPostLabelAppKey		@"appkey"
#define kVDiskPostLabelTime			@"time"
#define kVDiskPostLabelSignature	@"signature"
#define kVDiskPostLabelToken		@"token"
#define kVDiskPostLabelDologID		@"dologid"
#define kVDiskPostLabelDirID		@"dir_id"
#define kVDiskPostLabelPage			@"page"
#define kVDiskPostLabelPageSize		@"pageSize"
#define kVDiskPostLabelFileID		@"fid"


#define kVDiskJsonLabelErrCode		@"err_code"
#define kVDiskJsonLabelErrMsg		@"err_msg"
#define kVDiskJsonLabelData			@"data"
#define kVDiskJsonLabelToken		@"token"
#define kVDiskJsonLabelUsed			@"used"
#define kVDiskJsonLabelTotal		@"total"
#define kVDiskJsonLabelDologID		@"dologid"
//#define kVDiskJsonLabelDologDir		@"dologdir"
#define kVDiskJsonLabelPageInfo		@"pageinfo"
#define kVDiskJsonLabelPageTotal	@"pageTotal"
#define kVDiskJsonLabelList			@"list"


#define kVDiskJsonLabelID			@"id"
#define kVDiskJsonLabelFileName		@"name"
#define kVDiskJsonLabelDirID		@"dir_id"
#define kVDiskJsonLabelCreationTime	@"ctime"
#define kVDiskJsonLabelLastModificationTime	@"ltime"
#define kVDiskJsonLabelSize_info	@"size"
#define kVDiskJsonLabelSize_list	@"byte"
#define kVDiskJsonLabelType			@"type"
#define kVDiskJsonLabelMD5			@"md5"
#define kVDiskJsonLabelSHA1			@"sha1"
#define kVDiskJsonLabelThumbnailURL	@"thumbnail"
#define kVDiskJsonLabelDownloadURL	@"s3_url"


typedef enum {
	VDiskRetSuccess				= 0,	//...
	VDiskRetOldDolog			= 602,	//...,~get_token
	VDiskRetLackParameter		= 701,	//get_token, upload_file
	VDiskRetInvalidToken		= 702,	//...,~get_token
	VDiskRetExceedLimits		= 900,	//...
	VDiskRetInvalidParameter	= 909,	//getlist, get_quota
}VDiskCommonErrCode;

typedef enum {
	VDiskGetTokenRetInvalidSignature	= 1,
	VDiskGetTokenRetRetInvalidAccount	= 2,
	VDiskGetToeknRetRetInvalidTime		= 3,
}VDiskGetTokenErrCode;

typedef enum {
	VDiskGetFileListRetDirNotExist		= 2,
}VDiskGetFileListErrCode;

typedef enum {
	VDiskGetFileInfoRetInvalidFileIDFormat	= 1,
	VDiskGetFileInfoRetFileNotExist		= 3,
}VDiskGetFileInfoErrCode;

typedef enum {
	VDiskDeleteFileRetFileNotExist		= 2,
	VDiskDeleteFileRetFileIsLocked		= 3,
	VDiskDeleteFileRetSystemError		= 5,
}VDiskDeleteFileErrCode;

typedef enum {
	VDiskRetConnectionError		= -1,	//[argumented]
	VDiskRetNoMatchingFile		= -2,	//[argumented]getRootFileID
	VDiskRetInvalidCover		= 1,	//upload_file
	VDiskRetInvalidFile			= 2,	//delete_file
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
	VDiskRetReUpload			= 721,	//upload_file
}VDiskErrCode;
