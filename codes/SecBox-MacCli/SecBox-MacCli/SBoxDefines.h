//
//  SBoxIncludes.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/8/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#define GMBDEBUG

//#define DLOG
//#define SLOG

#ifdef GMBDEBUG
#	define	DAssert(...)	NSAssert(__VA_ARGS__)
#	define	DCAssert(...)	NSCAssert(__VA_ARGS__)
#
#	ifdef DLOG
#		define	DLog(...)	NSLog(__VA_ARGS__) 
#	else 
#		define	DLog(...)	/* */ 
#	endif
#	
#	ifdef SLOG
#		define	SLog(...)	NSLog(__VA_ARGS__)
#	else
#		define	SLog(...)	/* */
#	endif
#else
#	define	DAssert(...)	/* */
#	define	DCAssert(...)	/* */
#	define	DLog(...)		/* */ 
#	define	SLog(...)		/* */
#endif 

#define	SysLog(...)			NSLog(__VA_ARGS__) 
