//
//  SBSSDefines.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/23/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

typedef enum {
	/* -300 ~ -399 */
	SBSSRetLocalPathCollision	= -300,
	SBSSRetInvalidLocalPath		= -301,
	SBSSRetLocalPathNotExist	= -302,
	SBSSRetCantCreateLocalFile	= -303,
}SBSSArgumentedErrCode;

typedef int	SBSSRet;
#define SBSSRetSuccess 0

typedef enum {
	SBSSSyncActionForceUpload,
	SBSSSyncActionForceDownload,
	SBSSSyncActionReportCollision,
}SBSSSyncAction;

typedef enum {
	SBSSSyncUploaded,
	SBSSSyncDownloaded,
	SBSSSyncSame,
	SBSSSyncFilesDoNotExist,
	SBSSSyncConflicted,
}SBSSSyncResult;