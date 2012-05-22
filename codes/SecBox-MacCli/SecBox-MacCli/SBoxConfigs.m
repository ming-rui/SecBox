//
//  SBoxConfigs.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/7/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import "SBoxConfigs.h"

@implementation SBoxConfigs

@synthesize accountType = _accountType;
@synthesize accountUserName = _accountUserName;
@synthesize accountPassword = _accountPassword;
@synthesize accountToken = _accountToken;
@synthesize currentRemotePath = _currentRemotePath;

@synthesize encryptionUserName = _encryptionUserName;
@synthesize encryptionPassword = _encryptionPassword;

#pragma mark -
#pragma mark Class Methods

#define kSBoxConfigsKey			@"SBoxConfigs"

+ (SBoxConfigs *) sharedConfigs {
	static SBoxConfigs *_configs = nil;
	@synchronized(self) {
		if(_configs==nil){
			NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kSBoxConfigsKey];
			if(data!=nil&&[data isKindOfClass:[NSData class]]){
				_configs = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
				if(![_configs isKindOfClass:self]){
					[_configs release];
					_configs = nil;
				}
			}
		}
		if(_configs==nil)
			_configs = [[self alloc] init];
	}
	
	return _configs;
}

- (void) save {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:kSBoxConfigsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) dealloc {
	[_accountUserName release];
	[_accountPassword release];
	[_accountToken release];
	[_currentRemotePath release];
	[_encryptionUserName release];
	[_encryptionPassword release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark NSCoding

#define kAccountTypeKey			@"accType"
#define kAccountUserNameKey		@"accUserName"
#define kAccountPasswordKey		@"accPass"
#define kAccountTokenKey		@"accToken"
#define kCurrentRemotePathKey	@"currRemotePath"
#define kEncryptionUserNameKey	@"encUserName"
#define kEncryptionPasswordKey	@"encPass"

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if(self){
        _accountType = [coder decodeIntForKey:kAccountTypeKey];
		_accountUserName = [[coder decodeObjectForKey:kAccountUserNameKey] retain];
		_accountPassword = [[coder decodeObjectForKey:kAccountPasswordKey] retain];
		_accountToken = [[coder decodeObjectForKey:kAccountTokenKey] retain];
		_currentRemotePath = [[coder decodeObjectForKey:kCurrentRemotePathKey] retain];
		
		_encryptionUserName = [[coder decodeObjectForKey:kEncryptionUserNameKey] retain];
		_encryptionPassword = [[coder decodeObjectForKey:kEncryptionPasswordKey] retain];
    }
	
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:_accountType forKey:kAccountTypeKey];
	[coder encodeObject:_accountUserName forKey:kAccountUserNameKey];
	[coder encodeObject:_accountPassword forKey:kAccountPasswordKey];
	[coder encodeObject:_accountToken forKey:kAccountTokenKey];
	[coder encodeObject:_currentRemotePath forKey:kCurrentRemotePathKey];
	
	[coder encodeObject:_encryptionUserName forKey:kEncryptionUserNameKey];
	[coder encodeObject:_encryptionPassword forKey:kEncryptionPasswordKey];
}

@end
