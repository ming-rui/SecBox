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
#import "SBoxVDiskFileInfo.h"
#import "SBoxVDiskConstants.h"


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

- (NSData*) dataToPostWithDict:(NSDictionary*)dict boundary:(NSString*)boundary {
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
			DAssert(NO,@"");
		}
		[data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
		
		string = @"\r\n";
		[data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	string = [NSString stringWithFormat:@"--%@--\r\n", boundary];
	[data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	
	return data;
}

- (NSMutableURLRequest*) requestToPostWithURLString:(NSString*)urlString dict:(NSDictionary*)dict {
	NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	[request setHTTPMethod:@"POST"];
	
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kSBoxURLPostBoundary];
	[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	
	NSData *contentData = [self dataToPostWithDict:dict boundary:kSBoxURLPostBoundary];
	
	NSString *contentLength = [NSString stringWithFormat:@"%u", [contentData length]];
	[request addValue:contentLength forHTTPHeaderField:@"Content-Length"];
	
	[request setHTTPBody:contentData];
	
	return request;
}

SBoxVDRet errCodeWithDict(NSDictionary *dict) {
	DCAssert(dict!=nil,@"");
	NSNumber *errCode = [dict objectForKey:kSBoxVDiskJsonLabelErrCode];
	DCAssert(errCode!=nil,@"");
	
	return [errCode intValue];
}

NSString* tokenWithDict(NSDictionary *dict) {
	DCAssert(errCodeWithDict(dict)==0,@"");
	NSDictionary *data = [dict objectForKey:kSBoxVDiskJsonLabelData];
	DCAssert(data!=nil,@"");
	NSString *token = [data objectForKey:kSBoxVDiskJsonLabelToken];
	DCAssert(token!=nil,@"");
	
	return token;
}

- (SBoxVDRet) getToken {
	_state = SBoxVDiskManagerStateOffline;
	[self setToken:nil];
	
	NSString *appKey = [NSString stringWithCString:kSBoxVDiskAppKey encoding:NSUTF8StringEncoding];
	NSString *appSecret = [NSString stringWithCString:kSBoxVDiskAppSecret encoding:NSUTF8StringEncoding];
	NSString *appType = SBoxVDiskAppTypeWithAccountType(_accountType);
	NSString *timeString = [NSString stringWithFormat:@"%li",time((time_t*)NULL)];
	
	NSString *string = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@", 
						kSBoxVDiskPostLabelUserName, _userName,
						kSBoxVDiskPostLabelAppKey, appKey,
						kSBoxVDiskPostLabelPassword, _password,
						kSBoxVDiskPostLabelTime, timeString];
	NSString *signature = [SBoxAlgorithms hmacSHA256WithKey:appSecret string:string];
	
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
						  appType, kSBoxVDiskPostLabelAccountType,
						  _userName, kSBoxVDiskPostLabelUserName,
						  _password, kSBoxVDiskPostLabelPassword,
						  appKey, kSBoxVDiskPostLabelAppKey,
						  timeString, kSBoxVDiskPostLabelTime,
						  signature, kSBoxVDiskPostLabelSignature,
						  nil];
	NSMutableURLRequest *urlRequest = [self requestToPostWithURLString:kSBoxVDiskURLGetToken dict:postDict];
	
	NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
	NSDictionary *dict = [_jsonParser objectWithData:data];
	
	if(dict==nil)
		return SBoxVDRetConnectionError;
	
	SBoxVDRet errCode = errCodeWithDict(dict);
	
	if(errCode!=SBoxVDRetSuccess)
		return errCode;
	
	_state = SBoxVDiskManagerStateOnline;
	NSString *token = tokenWithDict(dict);
	[self setToken:token];
	
	return SBoxVDRetSuccess;
}

NSInteger dologIDWithDict(NSDictionary *dict) {
	DCAssert(dict!=nil,@"");
	NSNumber *dologID = [dict objectForKey:kSBoxVDiskJsonLabelDologID];
	DCAssert(dologID!=nil,@"");
	
	return [dologID intValue];
}

- (SBoxVDRet) keepToken {
	if(_state==SBoxVDiskManagerStateOffline)
		return [self getToken];
	
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  _token, kSBoxVDiskPostLabelToken,
							  [NSNumber numberWithInt:_dologID], kSBoxVDiskPostLabelDologID,
							  nil];
	NSMutableURLRequest *request = [self requestToPostWithURLString:kSBoxVDiskURLKeepToken dict:postDict];
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSDictionary *dict = [_jsonParser objectWithData:data];
	
	if(dict==nil)
		return SBoxVDRetConnectionError;
	
	SBoxVDRet errCode = errCodeWithDict(dict);
	
	if(errCode!=SBoxVDRetSuccess)
		return [self getToken];
	
	NSInteger dologID = dologIDWithDict(dict);
	if(dologID!=_dologID){
		/* update directory */
		_dologID = dologID;
	}
	
	return SBoxSuccess;
}

SBoxVDiskQuota quotaWithDict(NSDictionary *dict) {
	DCAssert(errCodeWithDict(dict)==0,@"");
	NSDictionary *data = [dict objectForKey:kSBoxVDiskJsonLabelData];
	DCAssert(data!=nil,@"");
	NSString *used = [data objectForKey:kSBoxVDiskJsonLabelUsed];
	DCAssert(used!=nil,@"");
	NSString *total = [data objectForKey:kSBoxVDiskJsonLabelTotal];
	DCAssert(total!=nil,@"");
	SBoxVDiskQuota quota = SBoxVDiskQuotaMake([used longLongValue], [total longLongValue]);
	
	return quota;
}

- (SBoxVDRet) getQuota:(SBoxVDiskQuota *)quota {
	SBoxVDRet retv = [self keepToken];
	if(retv!=SBoxVDRetSuccess)
		return retv;
	
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  _token, kSBoxVDiskPostLabelToken, nil];
	NSMutableURLRequest *request = [self requestToPostWithURLString:kSBoxVDiskURLGetQuota dict:postDict];
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSDictionary *dict = [_jsonParser objectWithData:data];
	
	if(dict==nil)
		return SBoxVDRetConnectionError;
	
	SBoxVDRet errCode = errCodeWithDict(dict);
	
	if(errCode!=SBoxVDRetSuccess)
		return errCode;
	
	*quota = quotaWithDict(dict);
	
	return SBoxVDRetSuccess;
}

NSInteger pageTotalWithDict(NSDictionary *dict) {
	DCAssert(errCodeWithDict(dict)==0,@"");
	NSDictionary *data = [dict objectForKey:kSBoxVDiskJsonLabelData];
	DCAssert(data!=nil,@"");
	NSDictionary *pageInfo = [data objectForKey:kSBoxVDiskJsonLabelPageInfo];
	DCAssert(pageInfo!=nil,@"");
	NSNumber *pageTotal = [pageInfo objectForKey:kSBoxVDiskJsonLabelPageTotal];
	DCAssert(pageTotal!=nil,@"");
	
	return [pageTotal intValue];
}

void addFilesToListWithDict(NSMutableArray *fileList, NSDictionary *dict) {
	DCAssert(errCodeWithDict(dict)==0,@"");
	NSDictionary *data = [dict objectForKey:kSBoxVDiskJsonLabelData];
	DCAssert(data!=nil,@"");
	NSArray *list = [data objectForKey:kSBoxVDiskJsonLabelList];
	DCAssert(list!=nil,@"");
	for(NSDictionary *item in list){
		SBoxVDiskFileInfo *fileInfo = [SBoxVDiskFileInfo infoWithListItemDict:item];
		[fileList addObject:fileInfo];
	}
}

- (SBoxVDRet) _getRootFileList:(NSMutableArray *)fileList withPage:(NSInteger)page {
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  _token, kSBoxVDiskPostLabelToken,
							  [NSNumber numberWithInt:0], kSBoxVDiskPostLabelDirID,
							  [NSNumber numberWithInt:page], kSBoxVDiskPostLabelPage,
							  [NSNumber numberWithInt:2], kSBoxVDiskPostLabelPageSize,
							  [NSNumber numberWithInt:_dologID], kSBoxVDiskPostLabelDologID,
							  nil];
	NSMutableURLRequest *request = [self requestToPostWithURLString:kSBoxVDiskURLGetList dict:postDict];
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSDictionary *dict = [_jsonParser objectWithData:data];
	
	if(dict==nil)
		return SBoxVDRetConnectionError;
	
	SBoxVDRet errCode = errCodeWithDict(dict);
	
	if(errCode!=SBoxVDRetSuccess)
		return errCode;
	
	addFilesToListWithDict(fileList, dict);
	
	NSInteger pageTotal = pageTotalWithDict(dict);
	
	if(page<pageTotal)
		return [self _getRootFileList:fileList withPage:page+1];	//recursive add
	
	return SBoxVDRetSuccess;
}

- (SBoxVDRet) getRootFileList:(NSMutableArray *)fileList {
	SBoxVDRet retv = [self keepToken];
	if(retv!=SBoxVDRetSuccess)
		return retv;
	
	return [self _getRootFileList:fileList withPage:1];
}

- (SBoxVDRet) getFileInfo:(SBoxVDiskFileInfo*)fileInfo {

}

@end
