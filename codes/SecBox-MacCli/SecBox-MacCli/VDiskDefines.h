//
//  VDiskConstants.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/20/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//


#define kSBoxVDiskAppKey			"2172384310"
#define kSBoxVDiskAppSecret			"800ae25ba6a1f3f4d8345080ca434bc7"


#define kVDiskURLPostBoundary		@"==boundary=="


#define kVDiskAppTypeWeibo			@"sinat"
#define kVDiskAppTypeWeipan			@"local"
#define VDiskAppTypeWithAccountType(type)	((type)?kVDiskAppTypeWeipan:kVDiskAppTypeWeibo)


#define kVDiskURLGetToken			@"http://openapi.vdisk.me/?m=auth&a=get_token"
#define kVDiskURLKeepToken			@"http://openapi.vdisk.me/?m=user&a=keep_token"
#define kVDiskURLGetQuota			@"http://openapi.vdisk.me/?m=file&a=get_quota"
#define kVDiskURLGetList			@"http://openapi.vdisk.me/?m=dir&a=getlist"
#define kVDiskURLGetFileInfo		@"http://openapi.vdisk.me/?m=file&a=get_file_info"
#define kVDiskURLDeleteFile			@"http://openapi.vdisk.me/?m=file&a=delete_file"
#define kVDiskURLUploadFile			@"http://openapi.vdisk.me/?m=file&a=upload_file"


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
#define kVDiskPostLabelCoverFile	@"cover"
#define kVDiskPostLabelFile			@"file"


#define kVDiskPostCoverFileYES		@"yes"
#define kVDiskPostCoverFileNO		@"no"


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
#define kVDiskJsonLabelName			@"name"
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
#define kVDiskJsonLabelNumOfDirs	@"dir_num"
#define kVDiskJsonLabelNumOfFiles	@"file_num"


typedef enum {
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
	VDiskUploadFileRetInvalidCover		= 1,
	VDiskUploadFileRetDirNotExist		= 3,
	VDiskUploadFileRetFileNameCollision	= 4,
	VDiskUploadFileRetSystemError		= 5,
	VDiskUploadFileRetS3Error			= 6,
	VDiskUploadFileRetLowCapacity		= 7,
	VDiskUploadFileRetOverUpMaxFileSize	= 101,
	VDiskUploadFileRetOverMaxFileSize	= 102,
	VDiskUploadFileRetUploadNotFull		= 103,
	VDiskUploadFileRetUploadFail		= 104,
	VDiskUploadFileRetFormatCanNotShare	= 105,
	VDiskUploadFileRetFileCanNotShare	= 106,
	VDiskUploadFileRetDirFull			= 601,
	VDiskUploadFileRetReUpload			= 721,
}VDiskUploadFileErrCode;

typedef enum {
	/* -100 ~ -199 */
	VDiskRetConnectionError		= -101,
	VDiskRetNoMatchingFile		= -102,
	VDiskRetWrongItemType		= -103,
}VDiskArgumentedErrCode;
















