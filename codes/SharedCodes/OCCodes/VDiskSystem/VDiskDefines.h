//
//  VDiskConstants.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/20/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//


typedef int VDiskRet;
#define	VDiskRetSuccess	0

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
	VDiskRenameFileRetInvalidFid		= 1,
	VDiskRenameFileRetInvalidFileName	= 2,
	VDiskRenameFileRetFileNotExist		= 3,
	VDiskRenameFileRetSystemError		= 5,
	VDiskRenameFileRetFileNameCollision	= 6,
	VDiskRenameFileRetDirFull			= 601,
}VDiskRenameFileErrCode;

typedef enum {
	/* -100 ~ -199 */
	VDiskRetConnectionError		= -100,
	VDiskRetNoMatchingFile		= -101,
	VDiskRetWrongItemType		= -102,
	VDiskRetFileNameTooLong		= -103,
	VDiskRetInvalidFileName		= -104,
	VDiskRetInvalidFileContents	= -105,
	VDiskRetFileSizeTooLarge	= -106,
}VDiskArgumentedErrCode;


#define kVDiskMaxFileNameLength		255
#define kVDiskMaxFileSize			1024*1024*10













