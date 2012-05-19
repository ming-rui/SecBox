//
//  SBoxVDiskFileInfo.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/19/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	SBoxVDiskFileInfoTypeList = 0,
	SBoxVDiskFileInfoTypeInfo,
}SBoxVDiskFileInfoType;

@interface SBoxVDiskFileInfo : NSObject {
	@private
	SBoxVDiskFileInfoType	_infoType;
	NSInteger _fileID;		//id
	NSString *_fileName;	//name
	NSInteger _dirID;		//dir_id
	NSDate *_creationDate;	//ctime
	NSDate *_lastModificationDate;	//ltime
	long long _size;		//(info)size, (list)byte/length
	NSString *_type;		//type
	NSString *_md5;			//md5
	NSString *_sha1;		//(list)sha1
	NSString *_thumbnailURL;//(list)thumbnail
	NSString *_downloadURL;	//(info)s3_url
}

@property(nonatomic,assign) NSInteger fileID;
@property(nonatomic,retain) NSString *fileName;
@property(nonatomic,assign) NSInteger dirID;
@property(nonatomic,retain) NSDate *creationDate;
@property(nonatomic,retain) NSDate *lastModificationDate;
@property(nonatomic,assign) long long size;
@property(nonatomic,retain) NSString *type;
@property(nonatomic,retain) NSString *md5;
@property(nonatomic,retain) NSString *sha1;
@property(nonatomic,retain) NSString *thumbnailURL;
@property(nonatomic,retain) NSString *downloadURL;

+ (SBoxVDiskFileInfo*) infoWithListItemDict:(NSDictionary*)dict;
+ (SBoxVDiskFileInfo*) infoWithFileInfoDict:(NSDictionary*)dict;

@end
