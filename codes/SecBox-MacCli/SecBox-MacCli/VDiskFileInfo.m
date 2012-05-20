//
//  SBoxVDiskFileInfo.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/19/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import "VDiskFileInfo.h"

#import "VDiskConstants.h"
#import "SBoxDefines.h"

@implementation VDiskFileInfo

@synthesize fileID=_fileID;
@synthesize fileName=_fileName;
@synthesize dirID=_dirID;
@synthesize creationDate=_creationDate;
@synthesize lastModificationDate=_lastModificationDate;
@synthesize size=_size;
@synthesize type=_type;
@synthesize md5=_md5;
@synthesize sha1=_sha1;
@synthesize thumbnailURL=_thumbnailURL;
@synthesize downloadURL=_downloadURL;

- (id) initWithInfoType:(VDiskFileInfoType)infoType dict:(NSDictionary*)dict {
	self = [super init];
	if(self){
		_infoType = infoType;
		_fileID = VDiskFileIDInvalid;
		_dirID = VDiskDirIDInvalid;
		_size = VDiskFileSizeInvalid;
		
		NSNumber *fileIDNum = [dict objectForKey:kVDiskJsonLabelID];
		if(fileIDNum!=nil)
			[self setFileID:[fileIDNum integerValue]];
		
		[self setFileName:[dict objectForKey:kVDiskJsonLabelFileName]];
		
		NSNumber *dirIDNum = [dict objectForKey:kVDiskJsonLabelDirID];
		if(dirIDNum!=nil)
			[self setDirID:[dirIDNum integerValue]];
		
		NSNumber *cTimeNum = [dict objectForKey:kVDiskJsonLabelCreationTime];
		if(cTimeNum!=nil)
			[self setCreationDate:[NSDate dateWithTimeIntervalSince1970:((NSTimeInterval)[cTimeNum integerValue])]];
		
		NSNumber *lTimeNum = [dict objectForKey:kVDiskJsonLabelLastModificationTime];
		if(lTimeNum!=nil)
			[self setLastModificationDate:[NSDate dateWithTimeIntervalSince1970:((NSTimeInterval)[lTimeNum integerValue])]];
		
		[self setType:[dict objectForKey:kVDiskJsonLabelType]];
		[self setMd5:[dict objectForKey:kVDiskJsonLabelMD5]];
		
		if(_infoType==VDiskFileInfoTypeList){
			NSNumber *fileSizeNum = [dict objectForKey:kVDiskJsonLabelSize_list];
			if(fileSizeNum!=nil)
				[self setSize:[fileSizeNum longLongValue]];
			
			[self setSha1:[dict objectForKey:kVDiskJsonLabelSHA1]];
			
			[self setThumbnailURL:[dict objectForKey:kVDiskJsonLabelThumbnailURL]];
		}else if(_infoType==VDiskFileInfoTypeInfo){
			NSNumber *fileSizeNum = [dict objectForKey:kVDiskJsonLabelSize_info];
			if(fileSizeNum!=nil)
				[self setSize:[fileSizeNum longLongValue]];
			
			[self setDownloadURL:[dict objectForKey:kVDiskJsonLabelDownloadURL]];
		}
		
		DAssert(_fileID!=VDiskFileIDInvalid,@"");
		DAssert(_fileName!=nil,@"");
		DAssert(_dirID!=VDiskDirIDInvalid,@"");
		DAssert(_creationDate!=nil,@"");
		DAssert(_lastModificationDate!=nil,@"");
		DAssert(_type!=nil,@"");
		DAssert(_md5!=nil,@"");
		DAssert(_size!=VDiskFileSizeInvalid,@"");
	}
	
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<info %i, %@, %i, %@, %@, %lli, %@, %@, %@, %@, %@>",
			_fileID, _fileName, _dirID, _creationDate, _lastModificationDate,
			_size, _type, _md5, _sha1, _thumbnailURL, _downloadURL];
}

+ (VDiskFileInfo*) infoWithListItemDict:(NSDictionary*)dict {
	return [[[self alloc] initWithInfoType:VDiskFileInfoTypeList dict:dict] autorelease];
}

+ (VDiskFileInfo*) infoWithFileInfoDict:(NSDictionary*)dict {
	return [[[self alloc] initWithInfoType:VDiskFileInfoTypeInfo dict:dict] autorelease];
}



@end
