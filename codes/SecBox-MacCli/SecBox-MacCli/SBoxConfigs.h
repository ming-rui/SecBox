//
//  SBoxConfigs.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/7/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBoxConfigs : NSObject {
	@private
	//remote
	NSString *_accountUserName;
	NSString *_accountPassword;
	NSString *_currentRemotePath;
	
	//local
	NSString *_encryptionUserName;
	NSString *_encryptionPassword;
}

+ (SBoxConfigs *) sharedConfigs;

@end
