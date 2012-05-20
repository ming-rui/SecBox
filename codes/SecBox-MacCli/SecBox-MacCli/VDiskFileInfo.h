//
//  SBoxVDiskFileInfo.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/19/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	VDiskFileInfoTypeList = 0,
	VDiskFileInfoTypeInfo,
}VDiskFileInfoType;

typedef NSInteger VDiskFileID;
#define VDiskFileIDInvalid	-1

typedef NSInteger VDiskDirID;
#define VDiskDirIDInvalid	-1

typedef long long VDiskFileSize;
#define VDiskFileSizeInvalid	-1

@interface VDiskFileInfo : NSObject {
	@private
	VDiskFileInfoType	_infoType;
	VDiskFileID _fileID;	//id
	NSString *_fileName;	//name
	VDiskDirID _dirID;		//dir_id
	NSDate *_creationDate;	//ctime
	NSDate *_lastModificationDate;	//ltime
	VDiskFileSize _size;	//(info)size, (list)byte/length
	NSString *_type;		//type
	NSString *_md5;			//md5
	NSString *_sha1;		//(list)sha1
	NSString *_thumbnailURL;//(list)thumbnail
	NSString *_downloadURL;	//(info)s3_url
}

@property(nonatomic,assign) VDiskFileID fileID;
@property(nonatomic,retain) NSString *fileName;
@property(nonatomic,assign) VDiskDirID dirID;
@property(nonatomic,retain) NSDate *creationDate;
@property(nonatomic,retain) NSDate *lastModificationDate;
@property(nonatomic,assign) VDiskFileSize size;
@property(nonatomic,retain) NSString *type;
@property(nonatomic,retain) NSString *md5;
@property(nonatomic,retain) NSString *sha1;
@property(nonatomic,retain) NSString *thumbnailURL;
@property(nonatomic,retain) NSString *downloadURL;

+ (VDiskFileInfo*) infoWithListItemDict:(NSDictionary*)dict;
+ (VDiskFileInfo*) infoWithFileInfoDict:(NSDictionary*)dict;

@end
