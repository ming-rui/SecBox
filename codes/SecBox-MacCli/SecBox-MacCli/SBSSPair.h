//
//  SBSSPair.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/23/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBSSPair : NSObject <NSCoding> {
	@private
	NSString *_localPath;
	NSString *_remotePath;
	NSString *_lastMd5;
}

@property(nonatomic,retain) NSString* localPath;
@property(nonatomic,retain) NSString* remotePath;
@property(nonatomic,retain) NSString* lastMd5;

+ (SBSSPair *) pairWithLocalPath:(NSString *)localPath remotePath:(NSString *)remotePath;

@end
