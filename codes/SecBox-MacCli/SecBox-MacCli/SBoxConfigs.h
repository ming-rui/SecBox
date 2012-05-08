//
//  SBoxConfigs.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/7/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SecBox.h"

@interface SBoxConfigs : NSObject <NSCoding> {
	@private
	//remote
	SBoxAccountType _accountType;
	NSString *_accountUserName;
	NSString *_accountPassword;
	NSString *_currentRemotePath;
	
	//local
	NSString *_encryptionUserName;
	NSString *_encryptionPassword;
}

@property(nonatomic,assign) SBoxAccountType accountType;
@property(nonatomic,retain) NSString *accountUserName;
@property(nonatomic,retain) NSString *accountPassword;
@property(nonatomic,retain) NSString *currentRemotePath;

@property(nonatomic,retain) NSString *encryptionUserName;
@property(nonatomic,retain) NSString *encryptionPassword;

+ (SBoxConfigs *) sharedConfigs;
+ (void) save;

@end
