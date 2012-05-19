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


#define kSBoxVDiskURLGetToken			@"http://openapi.vdisk.me/?m=auth&a=get_token"
#define kSBoxVDiskURLKeepToken			@"http://openapi.vdisk.me/?m=user&a=keep_token"
#define kSBoxVDiskURLGetQuota			@"http://openapi.vdisk.me/?m=file&a=get_quota"
#define kSBoxVDiskURLGetList			@"http://openapi.vdisk.me/?m=dir&a=getlist"


#define kSBoxVDiskPostLabelAccountType	@"app_type"
#define kSBoxVDiskPostLabelUserName		@"account"
#define kSBoxVDiskPostLabelPassword		@"password"
#define kSBoxVDiskPostLabelAppKey		@"appkey"
#define kSBoxVDiskPostLabelTime			@"time"
#define kSBoxVDiskPostLabelSignature	@"signature"
#define kSBoxVDiskPostLabelToken		@"token"
#define kSBoxVDiskPostLabelDologID		@"dologid"
#define kSBoxVDiskPostLabelDirID		@"dir_id"
#define kSBoxVDiskPostLabelPage			@"page"
#define kSBoxVDiskPostLabelPageSize		@"pageSize"


#define kSBoxVDiskJsonLabelErrCode		@"err_code"
#define kSBoxVDiskJsonLabelErrMsg		@"err_msg"
#define kSBoxVDiskJsonLabelData			@"data"
#define kSBoxVDiskJsonLabelToken		@"token"
#define kSBoxVDiskJsonLabelUsed			@"used"
#define kSBoxVDiskJsonLabelTotal		@"total"
#define kSBoxVDiskJsonLabelDologID		@"dologid"
//#define kSBoxVDiskJsonLabelDologDir		@"dologdir"
#define kSBoxVDiskJsonLabelPageInfo		@"pageinfo"
#define kSBoxVDiskJsonLabelPageTotal	@"pageTotal"
#define kSBoxVDiskJsonLabelList			@"list"


#define kSBoxVDiskJsonLabelID			@"id"
#define kSBoxVDiskJsonLabelFileName		@"name"
#define kSBoxVDiskJsonLabelDirID		@"dir_id"
#define kSBoxVDiskJsonLabelCreationTime	@"ctime"
#define kSBoxVDiskJsonLabelLastModificationTime	@"ltime"
#define kSBoxVDiskJsonLabelSize_info	@"size"
#define kSBoxVDiskJsonLabelSize_list	@"byte"
#define kSBoxVDiskJsonLabelType			@"type"
#define kSBoxVDiskJsonLabelMD5			@"md5"
#define kSBoxVDiskJsonLabelSHA1			@"sha1"
#define kSBoxVDiskJsonLabelThumbnailURL	@"thumbnail"
#define kSBoxVDiskJsonLabelDownloadURL	@"s3_url"


