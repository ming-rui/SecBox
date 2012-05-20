//
//  SBoxVDiskManager.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/8/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import "SBoxVDiskManager.h"

#import "SBoxDefines.h"
#import "SBoxConfigs.h"
#import "SBoxAlgorithms.h"
#import <CommonCrypto/CommonHMAC.h>
#import "SBJsonParser.h"
#import "VDiskConstants.h"


@interface SBoxVDiskManager()
@property(nonatomic,retain) NSString *token;
@end


@implementation SBoxVDiskManager

@synthesize token=_token;

+ (SBoxVDiskManager *) sharedManager {
	static SBoxVDiskManager *_manager = nil;
	@synchronized(self) {
		if(_manager==nil)
			_manager = [[self alloc] init];
	}
	
	return _manager;
}

- (id) init {
	self = [super init];
	if(self){
		SBoxConfigs *configs = [SBoxConfigs sharedConfigs];
		_accountType = [configs accountType];
		_userName = [[configs accountUserName] retain];
		_password = [[configs accountPassword] retain];
		
		_jsonParser = [[SBJsonParser alloc] init];
	}
	
	return self;
}

- (void) dealloc {
	[_userName release];
	[_password release];
	[_token release];
	[_root release];
	[_jsonParser release];
	
	[super dealloc];
}

NSData* dataToPostWithDictAndBoundary(NSDictionary *dict, NSString *boundary) {
	NSMutableData *data = [NSMutableData data];
	
	NSString *string = nil;
	
	for(NSString *key in dict){
		id value = [dict objectForKey:key];
		
		string = [NSString stringWithFormat:@"--%@\r\n", boundary];
		[data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
		
		if([value isKindOfClass:[NSString class]]){
			string = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, value];
		}else if([value isKindOfClass:[NSNumber class]]){
			string = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, [value stringValue]];
		}else{
			DCAssert(NO,@"");
		}
		[data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
		
		string = @"\r\n";
		[data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	string = [NSString stringWithFormat:@"--%@--\r\n", boundary];
	[data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	
	return data;
}

NSMutableURLRequest* requestToPostWithURLStringAndDict(NSString *urlString, NSDictionary *dict) {
	NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	[request setHTTPMethod:@"POST"];
	
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kSBoxURLPostBoundary];
	[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	
	NSData *contentData = dataToPostWithDictAndBoundary(dict, kSBoxURLPostBoundary);
	
	NSString *contentLength = [NSString stringWithFormat:@"%u", [contentData length]];
	[request addValue:contentLength forHTTPHeaderField:@"Content-Length"];
	
	[request setHTTPBody:contentData];
	
	return request;
}

VDiskRet errCodeWithDict(NSDictionary *dict) {
	DCAssert(dict!=nil,@"");
	NSNumber *errCode = [dict objectForKey:kVDiskJsonLabelErrCode];
	DCAssert(errCode!=nil,@"");
	
	return [errCode intValue];
}

NSString* tokenWithDict(NSDictionary *dict) {
	DCAssert(errCodeWithDict(dict)==0,@"");
	NSDictionary *data = [dict objectForKey:kVDiskJsonLabelData];
	DCAssert(data!=nil,@"");
	NSString *token = [data objectForKey:kVDiskJsonLabelToken];
	DCAssert(token!=nil,@"");
	
	return token;
}

- (VDiskRet) getToken {
	_state = VDiskManagerStateOffline;
	[self setToken:nil];
	
	NSString *appKey = [NSString stringWithCString:kSBoxVDiskAppKey encoding:NSUTF8StringEncoding];
	NSString *appSecret = [NSString stringWithCString:kSBoxVDiskAppSecret encoding:NSUTF8StringEncoding];
	NSString *appType = SBoxVDiskAppTypeWithAccountType(_accountType);
	NSString *timeString = [NSString stringWithFormat:@"%li",time((time_t*)NULL)];
	
	NSString *string = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@", 
						kVDiskPostLabelUserName, _userName,
						kVDiskPostLabelAppKey, appKey,
						kVDiskPostLabelPassword, _password,
						kVDiskPostLabelTime, timeString];
	NSString *signature = [SBoxAlgorithms hmacSHA256WithKey:appSecret string:string];
	
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
						  appType, kVDiskPostLabelAccountType,
						  _userName, kVDiskPostLabelUserName,
						  _password, kVDiskPostLabelPassword,
						  appKey, kVDiskPostLabelAppKey,
						  timeString, kVDiskPostLabelTime,
						  signature, kVDiskPostLabelSignature,
						  nil];
	NSMutableURLRequest *urlRequest = requestToPostWithURLStringAndDict(kVDiskURLGetToken, postDict);
	
	NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
	NSDictionary *dict = [_jsonParser objectWithData:data];
	
	if(dict==nil)
		return VDiskRetConnectionError;
	
	VDiskRet errCode = errCodeWithDict(dict);
	
	if(errCode!=VDiskRetSuccess)
		return errCode;
	
	_state = VDiskManagerStateOnline;
	NSString *token = tokenWithDict(dict);
	[self setToken:token];
	
	return VDiskRetSuccess;
}

NSInteger dologIDWithDict(NSDictionary *dict) {
	DCAssert(dict!=nil,@"");
	NSNumber *dologID = [dict objectForKey:kVDiskJsonLabelDologID];
	DCAssert(dologID!=nil,@"");
	
	return [dologID intValue];
}

- (VDiskRet) keepToken {
	if(_state==VDiskManagerStateOffline)
		return [self getToken];
	
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  _token, kVDiskPostLabelToken,
							  [NSNumber numberWithInt:_dologID], kVDiskPostLabelDologID,
							  nil];
	NSMutableURLRequest *request = requestToPostWithURLStringAndDict(kVDiskURLKeepToken, postDict);
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSDictionary *dict = [_jsonParser objectWithData:data];
	
	if(dict==nil)
		return VDiskRetConnectionError;
	
	VDiskRet errCode = errCodeWithDict(dict);
	
	if(errCode!=VDiskRetSuccess)
		return [self getToken];
	
	NSInteger dologID = dologIDWithDict(dict);
	if(dologID!=_dologID){
		/* update directory */
		_dologID = dologID;
	}
	
	return SBoxSuccess;
}

VDiskQuota quotaWithDict(NSDictionary *dict) {
	DCAssert(errCodeWithDict(dict)==0,@"");
	NSDictionary *data = [dict objectForKey:kVDiskJsonLabelData];
	DCAssert(data!=nil,@"");
	NSString *used = [data objectForKey:kVDiskJsonLabelUsed];
	DCAssert(used!=nil,@"");
	NSString *total = [data objectForKey:kVDiskJsonLabelTotal];
	DCAssert(total!=nil,@"");
	VDiskQuota quota = VDiskQuotaMake([used longLongValue], [total longLongValue]);
	
	return quota;
}

- (VDiskRet) getQuota:(VDiskQuota *)quota {
	VDiskRet retv = [self keepToken];
	if(retv!=VDiskRetSuccess)
		return retv;
	
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  _token, kVDiskPostLabelToken, nil];
	NSMutableURLRequest *request = requestToPostWithURLStringAndDict(kVDiskURLGetQuota, postDict);
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSDictionary *dict = [_jsonParser objectWithData:data];
	
	if(dict==nil)
		return VDiskRetConnectionError;
	
	VDiskRet errCode = errCodeWithDict(dict);
	
	if(errCode!=VDiskRetSuccess)
		return errCode;
	
	*quota = quotaWithDict(dict);
	
	return VDiskRetSuccess;
}

NSInteger pageTotalWithDict(NSDictionary *dict) {
	DCAssert(errCodeWithDict(dict)==0,@"");
	NSDictionary *data = [dict objectForKey:kVDiskJsonLabelData];
	DCAssert(data!=nil,@"");
	NSDictionary *pageInfo = [data objectForKey:kVDiskJsonLabelPageInfo];
	DCAssert(pageInfo!=nil,@"");
	NSNumber *pageTotal = [pageInfo objectForKey:kVDiskJsonLabelPageTotal];
	DCAssert(pageTotal!=nil,@"");
	
	return [pageTotal intValue];
}

void addFilesToListWithDict(NSMutableArray *fileList, NSDictionary *dict) {
	DCAssert(errCodeWithDict(dict)==0,@"");
	NSDictionary *data = [dict objectForKey:kVDiskJsonLabelData];
	DCAssert(data!=nil,@"");
	NSArray *list = [data objectForKey:kVDiskJsonLabelList];
	DCAssert(list!=nil,@"");
	for(NSDictionary *item in list){
		VDiskFileInfo *fileInfo = [VDiskFileInfo infoWithListItemDict:item];
		[fileList addObject:fileInfo];
	}
}

- (VDiskRet) _getFileList:(NSMutableArray *)fileList withDirID:(VDiskDirID)dirID page:(NSInteger)page {
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  _token, kVDiskPostLabelToken,
							  [NSNumber numberWithInt:dirID], kVDiskPostLabelDirID,
							  [NSNumber numberWithInt:page], kVDiskPostLabelPage,
							  [NSNumber numberWithInt:2], kVDiskPostLabelPageSize,
							  [NSNumber numberWithInt:_dologID], kVDiskPostLabelDologID,
							  nil];
	NSMutableURLRequest *request = requestToPostWithURLStringAndDict(kVDiskURLGetList, postDict);
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSDictionary *dict = [_jsonParser objectWithData:data];
	
	if(dict==nil)
		return VDiskRetConnectionError;
	
	VDiskRet errCode = errCodeWithDict(dict);
	
	if(errCode!=VDiskRetSuccess)
		return errCode;
	
	addFilesToListWithDict(fileList, dict);
	
	NSInteger pageTotal = pageTotalWithDict(dict);
	
	if(page<pageTotal)
		return [self _getFileList:fileList withDirID:dirID page:page+1];	//recursive add
	
	return VDiskRetSuccess;
}

- (VDiskRet) getFileList:(NSMutableArray *)fileList withDirID:(VDiskDirID)dirID {
	VDiskRet retv = [self keepToken];
	if(retv!=VDiskRetSuccess)
		return retv;
	
	[fileList removeAllObjects];
	
	return [self _getFileList:fileList withDirID:dirID page:1];
}

- (VDiskRet) getRootFileList:(NSMutableArray *)fileList {
	return [self getFileList:fileList withDirID:0];
}

- (VDiskRet) getRootFileID:(VDiskFileID *)fileID withFileName:(NSString *)fileName {
	NSMutableArray *fileList = [NSMutableArray array];
	VDiskRet retv = [self getRootFileList:fileList];
	if(retv!=VDiskRetSuccess)
		return retv;
	
	*fileID = VDiskFileIDInvalid;
	for(VDiskFileInfo *fileInfo in fileList)
		if([[fileInfo fileName] isEqualToString:fileName])
			*fileID = [fileInfo fileID];
	
	if(*fileID==VDiskFileIDInvalid)
		return VDiskRetNoMatchingFile;
	
	return VDiskRetSuccess;
}

- (VDiskRet) getFileInfo:(VDiskFileInfo **)fileInfo withFileID:(VDiskFileID)fileID {//
	VDiskRet retv = [self keepToken];
	if(retv!=VDiskRetSuccess)
		return retv;
	
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  _token, kVDiskPostLabelToken,
							  [NSNumber numberWithInteger:fileID], kVDiskPostLabelFileID,
							  [NSNumber numberWithInteger:_dologID], kVDiskPostLabelDologID,
							  nil];
	NSMutableURLRequest *request = requestToPostWithURLStringAndDict(kVDiskURLGetFileInfo, postDict);
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSDictionary *dict = [_jsonParser objectWithData:data];
	
	if(dict==nil)
		return VDiskRetConnectionError;
	
	VDiskRet errCode = errCodeWithDict(dict);
	
	if(errCode!=VDiskRetSuccess)
		return errCode;
	
	NSDictionary *dataItem = [dict objectForKey:kVDiskJsonLabelData];
	DAssert(data!=nil,@"");
	*fileInfo = [VDiskFileInfo infoWithFileInfoDict:dataItem];
	
	return VDiskRetSuccess;
}

- (VDiskRet) getRootFileInfo:(VDiskFileInfo **)fileInfo withFileName:(NSString *)fileName {
	VDiskFileID fileID = VDiskFileIDInvalid;
	VDiskRet retv = [self getRootFileID:&fileID withFileName:fileName];
	if(retv!=VDiskRetSuccess)
		return retv;
	
	retv = [self getFileInfo:fileInfo withFileID:fileID];
	if(retv!=VDiskRetSuccess)
		return retv;
	
	return VDiskRetSuccess;
}

@end
