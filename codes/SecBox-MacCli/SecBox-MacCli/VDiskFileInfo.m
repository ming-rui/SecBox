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

@synthesize itemID=_itemID;
@synthesize name=_name;
@synthesize creationDate=_creationDate;
@synthesize lastModificationDate=_lastModificationDate;
@dynamic isFile;
@dynamic isDirectory;
@synthesize fileSize=_fileSize;
@synthesize fileType=_fileType;
@synthesize fileMd5=_fileMd5;
@synthesize fileURL=_fileURL;

- (id) initWithDict:(NSDictionary*)dict {
	self = [super init];
	if(self){
		if([dict objectForKey:kVDiskJsonLabelDownloadURL]){
			_infoType = VDiskItemTypeInfoFile;
		}else if([dict objectForKey:kVDiskJsonLabelSHA1]){
			_infoType = VDiskItemTypeListFile;
		}else if([dict objectForKey:kVDiskJsonLabelNumOfFiles]){
			_infoType = VDiskItemTypeDirectory;
		}else{
			DAssert(NO,@"");
		}
		_itemID = VDiskItemIDInvalid;
		_fileSize = VDiskFileSizeInvalid;
		
		/* both for file and dir */
		NSNumber *itemIDNum = [dict objectForKey:kVDiskJsonLabelID];
		if(itemIDNum!=nil)
			[self setItemID:[itemIDNum integerValue]];
		[self setName:[dict objectForKey:kVDiskJsonLabelName]];
		NSNumber *cTimeNum = [dict objectForKey:kVDiskJsonLabelCreationTime];
		if(cTimeNum!=nil)
			[self setCreationDate:[NSDate dateWithTimeIntervalSince1970:((NSTimeInterval)[cTimeNum integerValue])]];
		NSNumber *lTimeNum = [dict objectForKey:kVDiskJsonLabelLastModificationTime];
		if(lTimeNum!=nil)
			[self setLastModificationDate:[NSDate dateWithTimeIntervalSince1970:((NSTimeInterval)[lTimeNum integerValue])]];
		
		/* only for file */
		[self setFileType:[dict objectForKey:kVDiskJsonLabelType]];
		[self setFileMd5:[dict objectForKey:kVDiskJsonLabelMD5]];
		if(_infoType==VDiskItemTypeListFile){
			NSNumber *sizeNum = [dict objectForKey:kVDiskJsonLabelSize_list];
			if(sizeNum!=nil)
				[self setFileSize:[sizeNum longLongValue]];
		}else if(_infoType==VDiskItemTypeInfoFile){
			NSNumber *sizeNum = [dict objectForKey:kVDiskJsonLabelSize_info];
			if(sizeNum!=nil)
				[self setFileSize:[sizeNum longLongValue]];
			
			[self setFileURL:[dict objectForKey:kVDiskJsonLabelDownloadURL]];
		}
		
		/* asserts for file and dir */
		DAssert(_itemID!=VDiskItemIDInvalid,@"");
		DAssert(_name!=nil,@"");
		DAssert(_creationDate!=nil,@"");
		DAssert(_lastModificationDate!=nil,@"");
		
		/* asserts only for file */
		if(_infoType!=VDiskItemTypeDirectory){
			DAssert(_fileType!=nil,@"");
			DAssert(_fileMd5!=nil,@"");
			DAssert(_fileSize!=VDiskFileSizeInvalid,@"");
		}
	}
	
	return self;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"<info %i, %@, %@, %@, %lli, %@, %@, %@>",
			_itemID, _name, _creationDate, _lastModificationDate,
			_fileSize, _fileType, _fileMd5, _fileURL];
}

- (BOOL) isFile {
	return (_infoType!=VDiskItemTypeDirectory);
}

- (BOOL) isDirectory {
	return (_infoType==VDiskItemTypeDirectory);
}

+ (VDiskFileInfo*) itemInfoWithDict:(NSDictionary*)dict {
	return [[[self alloc] initWithDict:dict] autorelease];
}



@end
