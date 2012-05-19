//
//  SBoxVDiskFileInfo.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/19/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import "SBoxVDiskFileInfo.h"

#import "SBoxVDiskConstants.h"

@implementation SBoxVDiskFileInfo

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

- (id) initWithInfoType:(SBoxVDiskFileInfoType)infoType dict:(NSDictionary*)dict {
	self = [super init];
	if(self){
		_infoType = infoType;
		[self setFileID:[[dict objectForKey:kSBoxVDiskJsonLabelID] integerValue]];
		[self setFileName:[dict objectForKey:kSBoxVDiskJsonLabelFileName]];
		[self setDirID:[[dict objectForKey:kSBoxVDiskJsonLabelDirID] integerValue]];
		NSTimeInterval ctime = (NSTimeInterval)[[dict objectForKey:kSBoxVDiskJsonLabelCreationTime] integerValue];
		[self setCreationDate:[NSDate dateWithTimeIntervalSince1970:ctime]];
		NSTimeInterval ltime = (NSTimeInterval)[[dict objectForKey:kSBoxVDiskJsonLabelLastModificationTime] integerValue];
		[self setLastModificationDate:[NSDate dateWithTimeIntervalSince1970:ltime]];
		[self setType:[dict objectForKey:kSBoxVDiskJsonLabelType]];
		[self setMd5:[dict objectForKey:kSBoxVDiskJsonLabelMD5]];
		
		if(_infoType==SBoxVDiskFileInfoTypeList){
			[self setSize:[[dict objectForKey:kSBoxVDiskJsonLabelSize_list] longLongValue]];
			[self setSha1:[dict objectForKey:kSBoxVDiskJsonLabelSHA1]];
			[self setThumbnailURL:[dict objectForKey:kSBoxVDiskJsonLabelThumbnailURL]];
		}else if(_infoType==SBoxVDiskFileInfoTypeInfo){
			[self setSize:[[dict objectForKey:kSBoxVDiskJsonLabelSize_info] longLongValue]];
			[self setDownloadURL:[dict objectForKey:kSBoxVDiskJsonLabelDownloadURL]];
		}
	}
	
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<info %i, %@, %i, %@, %@, %lli, %@, %@, %@, %@, %@>",
			_fileID, _fileName, _dirID, _creationDate, _lastModificationDate,
			_size, _type, _md5, _sha1, _thumbnailURL, _downloadURL];
}

+ (SBoxVDiskFileInfo*) infoWithListItemDict:(NSDictionary*)dict {
	return [[[self alloc] initWithInfoType:SBoxVDiskFileInfoTypeList dict:dict] autorelease];
}

+ (SBoxVDiskFileInfo*) infoWithFileInfoDict:(NSDictionary*)dict {
	return [[[self alloc] initWithInfoType:SBoxVDiskFileInfoTypeInfo dict:dict] autorelease];
}



@end
