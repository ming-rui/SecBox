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
	SBoxVDiskManagerStateOffline,
	SBoxVDiskManagerStateNeedUpdate,
	SBoxVDiskManagerStateOnline,
}SBoxVDiskManagerState;

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
}

+ (SBoxVDiskManager *) sharedVDiskManager;

@end
