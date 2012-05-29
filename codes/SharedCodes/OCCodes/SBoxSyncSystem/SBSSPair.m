//
//  SBSSPair.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/23/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import "SBSSPair.h"

@implementation SBSSPair

@synthesize localPath=_localPath;
@synthesize remotePath=_remotePath;
@synthesize lastMd5=_lastMd5;


#pragma mark object life

- (id) initWithLocalPath:(NSString *)localPath remotePath:(NSString *)remotePath {
	self = [super init];
	if(self){
		_localPath = [localPath retain];
		_remotePath = [remotePath retain];
	}
	
	return self;
}


+ (SBSSPair *) pairWithLocalPath:(NSString *)localPath remotePath:(NSString *)remotePath {
	return [[[self alloc] initWithLocalPath:localPath remotePath:remotePath] autorelease];
}


#pragma mark -
#pragma mark NSCoding

#define kLocalPathKey	@"localPath"
#define kRemotePathKey	@"remotePath"
#define kLastMd5Key		@"lastMd5"

- (id) initWithCoder:(NSCoder *)decoder {
	self = [super init];
	if(self){
		_localPath = [[decoder decodeObjectForKey:kLocalPathKey] retain];
		_remotePath = [[decoder decodeObjectForKey:kRemotePathKey] retain];
		_lastMd5 = [[decoder decodeObjectForKey:kLastMd5Key] retain];
	}
	
	return self;
}

-(void) encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:_localPath forKey:kLocalPathKey];
	[coder encodeObject:_remotePath forKey:kRemotePathKey];
	[coder encodeObject:_lastMd5 forKey:kLastMd5Key];
}

@end
