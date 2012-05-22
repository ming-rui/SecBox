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
	SBFSRetNodeNotExist			= -213,
	SBFSRetFileInPath			= -214,
	SBFSRetNodeIsNotFile		= -215,
	SBFSRetNodeIsNotDir			= -216,
	SBFSRetNodeNameCollision	= -217,
	SBFSRetEncrytionError		= -220,
	SBFSRetDecrytionError		= -221,
}SBFSErrCode;

typedef int	SBFSRet;
#define SBFSRetSuccess 0

#define kSBoxMaxPathLength			170	/* (kVDiskMaxFileNameLength-12-userNameLength)*3/4 */
#define kSBoxMaxEncUserNameLength	15




