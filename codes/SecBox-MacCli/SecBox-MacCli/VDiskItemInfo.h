//
//  SBoxVDiskFileInfo.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/19/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	VDiskItemTypeListFile = 0,
	VDiskItemTypeInfoFile,
	VDiskItemTypeDirectory,
}VDiskItemType;

typedef NSInteger VDiskItemID;
#define VDiskItemIDInvalid	-1

typedef VDiskItemID VDiskFileID;
#define VDiskFileIDInvalid	-1

typedef VDiskItemID VDiskDirID;
#define VDiskDirIDInvalid	-1
#define VDiskRootDirID		0

typedef long long VDiskFileSize;
#define VDiskFileSizeInvalid	-1

@interface VDiskFileInfo : NSObject {
	@private
	VDiskItemType _infoType;
	
	VDiskItemID _itemID;			//id				-file&dir
	NSString *_name;				//name				-file&dir
	NSDate *_creationDate;			//ctime				-file&dir
	NSDate *_lastModificationDate;	//ltime				-file&dir
	
	VDiskFileSize _fileSize;		//(info)size, (list)byte/length	-file
	NSString *_fileType;			//type				-file
	NSString *_fileMd5;				//md5				-file
	NSString *_fileURL;				//(info)s3_url		-file
	
	//pid, dir_num, file_num							-dir
	//dir_id, sha1, share, thumbnail, url				-file
}

@property(nonatomic,assign) VDiskItemID itemID;
@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSDate *creationDate;
@property(nonatomic,retain) NSDate *lastModificationDate;
@property(nonatomic,readonly) BOOL isFile;
@property(nonatomic,readonly) BOOL isDirectory;
@property(nonatomic,assign) VDiskFileSize fileSize;
@property(nonatomic,retain) NSString *fileType;
@property(nonatomic,retain) NSString *fileMd5;
@property(nonatomic,retain) NSString *fileURL;

+ (VDiskFileInfo*) itemInfoWithDict:(NSDictionary*)dict;

@end
