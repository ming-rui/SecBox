//
//  SBFSConstants.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/22/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

typedef enum{
	/* -200 ~ -299 */
	SBFSRetInvalidConfiguation	= -200,
	SBFSRetPathTooLong			= -210,
	SBFSRetInvalidPath			= -211,
	SBFSRetInvalidFilePath		= -212,
	SBFSRetFileInfoNotExist		= -213,
	SBFSRetFileInPath			= -214,
	SBFSRetIsNotFile			= -215,
	SBFSRetNodeNameCollision	= -216,
	SBFSRetEncrytionError		= -220,
	SBFSRetDecrytionError		= -221,
}SBFSErrCode;

typedef int	SBFSRet;
#define SBFSRetSuccess 0

#define kSBoxMaxPathLength	255	/* ==kVDiskMaxFileNameLength */




