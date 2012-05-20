//
//  SBoxVDiskConstants.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/20/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#define kSBoxURLPostBoundary			@"==boundary=="


#define kSBoxVDiskAppTypeWeipan			@"local"
#define kSBoxVDiskAppTypeWeibo			@"sinat"
#define SBoxVDiskAppTypeWithAccountType(type)	((type)?kSBoxVDiskAppTypeWeipan:kSBoxVDiskAppTypeWeibo)


#define kVDiskURLGetToken			@"http://openapi.vdisk.me/?m=auth&a=get_token"
#define kVDiskURLKeepToken			@"http://openapi.vdisk.me/?m=user&a=keep_token"
#define kVDiskURLGetQuota			@"http://openapi.vdisk.me/?m=file&a=get_quota"
#define kVDiskURLGetList			@"http://openapi.vdisk.me/?m=dir&a=getlist"
#define kVDiskURLGetFileInfo		@"http://openapi.vdisk.me/?m=file&a=get_file_info"


#define kVDiskPostLabelAccountType	@"app_type"
#define kVDiskPostLabelUserName		@"account"
#define kVDiskPostLabelPassword		@"password"
#define kVDiskPostLabelAppKey		@"appkey"
#define kVDiskPostLabelTime			@"time"
#define kVDiskPostLabelSignature	@"signature"
#define kVDiskPostLabelToken		@"token"
#define kVDiskPostLabelDologID		@"dologid"
#define kVDiskPostLabelDirID		@"dir_id"
#define kVDiskPostLabelPage			@"page"
#define kVDiskPostLabelPageSize		@"pageSize"
#define kVDiskPostLabelFileID		@"fid"


#define kVDiskJsonLabelErrCode		@"err_code"
#define kVDiskJsonLabelErrMsg		@"err_msg"
#define kVDiskJsonLabelData			@"data"
#define kVDiskJsonLabelToken		@"token"
#define kVDiskJsonLabelUsed			@"used"
#define kVDiskJsonLabelTotal		@"total"
#define kVDiskJsonLabelDologID		@"dologid"
//#define kVDiskJsonLabelDologDir		@"dologdir"
#define kVDiskJsonLabelPageInfo		@"pageinfo"
#define kVDiskJsonLabelPageTotal	@"pageTotal"
#define kVDiskJsonLabelList			@"list"


#define kVDiskJsonLabelID			@"id"
#define kVDiskJsonLabelFileName		@"name"
#define kVDiskJsonLabelDirID		@"dir_id"
#define kVDiskJsonLabelCreationTime	@"ctime"
#define kVDiskJsonLabelLastModificationTime	@"ltime"
#define kVDiskJsonLabelSize_info	@"size"
#define kVDiskJsonLabelSize_list	@"byte"
#define kVDiskJsonLabelType			@"type"
#define kVDiskJsonLabelMD5			@"md5"
#define kVDiskJsonLabelSHA1			@"sha1"
#define kVDiskJsonLabelThumbnailURL	@"thumbnail"
#define kVDiskJsonLabelDownloadURL	@"s3_url"


