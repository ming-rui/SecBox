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
@protocol VDiskManagerDelegate;

@interface VDiskManager : NSObject {
	@private
	id<VDiskManagerDelegate> _delegate;
	
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
	
	//cache
	NSArray *_rootFileList;	//ONLY accessed by getRootFileList:
}

@property(nonatomic,assign) id<VDiskManagerDelegate> delegate;
@property(nonatomic,assign) VDiskAccountType accountType;
@property(nonatomic,retain) NSString* userName;
@property(nonatomic,retain) NSString* password;
@property(nonatomic,retain) NSString* token;

+ (VDiskManager *) managerWithAccountType:(VDiskAccountType)accountType userName:(NSString *)userName 
								 password:(NSString *)password token:(NSString *)token;

- (BOOL) configurationInvalid;

- (VDiskRet) keepTokenAndSync;

- (VDiskRet) getQuota:(VDiskQuota *)quota;
- (VDiskRet) getRootFileList:(NSArray **)fileList;

- (VDiskRet) getRootFileInfo:(VDiskItemInfo **)fileInfo withFileName:(NSString *)fileName;
- (VDiskRet) removeRootFileWithFileName:(NSString *)fileName;
- (VDiskRet) renameRootFileWithOldFileName:(NSString *)oldFileName newFileName:(NSString *)newFileName;

- (VDiskRet) uploadFileToRootWithFileName:(NSString *)fileName contents:(NSData *)contents;
- (VDiskRet) downloadFileFromRoot:(NSData **)contents withFileName:(NSString *)fileName;


///* 下面的path是网盘上真正的path，不是程序虚拟的path */
//- (SBoxRet) putFile:(NSData*)data withPath:(NSString*)path;
//- (SBoxRet) getFile:(NSMutableData*)data withPath:(NSString*)path;

@end


@protocol VDiskManagerDelegate
@required
- (void) vDiskManagerFileListUpdated:(VDiskManager *)vDiskManager;
@end
