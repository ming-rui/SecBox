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
	NSString *_accountToken;
	NSString *_currentRemotePath;
	
	//local
	NSString *_encryptionUserName;
	NSString *_encryptionPassword;
	
	//sync info
	NSMutableDictionary *_pairs;
}

@property(nonatomic,assign) SBoxAccountType accountType;
@property(nonatomic,retain) NSString *accountUserName;
@property(nonatomic,retain) NSString *accountPassword;
@property(nonatomic,retain) NSString *accountToken;
@property(nonatomic,retain) NSString *currentRemotePath;

@property(nonatomic,retain) NSString *encryptionUserName;
@property(nonatomic,retain) NSString *encryptionPassword;

@property(nonatomic,retain) NSMutableDictionary *pairs;

+ (SBoxConfigs *) sharedConfigs;

- (void) save;

@end
