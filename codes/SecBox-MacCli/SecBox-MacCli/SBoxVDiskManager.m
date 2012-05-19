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

#define kSBoxURLPostBoundary			@"==boundary=="

#define kSBoxVDiskAppTypeWeipan			@"local"
#define kSBoxVDiskAppTypeWeibo			@"sinat"
#define SBoxVDiskAppTypeWithAccountType(type)	((type)?kSBoxVDiskAppTypeWeipan:kSBoxVDiskAppTypeWeibo)

#define kSBoxVDiskURLGetToken			@"http://openapi.vdisk.me/?m=auth&a=get_token"
#define kSBoxVDiskURLGetQuota			@"http://openapi.vdisk.me/?m=file&a=get_quota"

#define kSBoxVDiskPostLabelAccountType	@"app_type"
#define kSBoxVDiskPostLabelUserName		@"account"
#define kSBoxVDiskPostLabelPassword		@"password"
#define kSBoxVDiskPostLabelAppKey		@"appkey"
#define kSBoxVDiskPostLabelTime			@"time"
#define kSBoxVDiskPostLabelSignature	@"signature"
#define kSBoxVDiskPostLabelToken		@"token"

#define kSBoxVDiskJsonLabelErrCode		@"err_code"
#define kSBoxVDiskJsonLabelErrMsg		@"err_msg"
#define kSBoxVDiskJsonLabelData			@"data"
#define kSBoxVDiskJsonLabelToken		@"token"
#define kSBoxVDiskJsonLabelUsed			@"used"
#define kSBoxVDiskJsonLabelTotal		@"total"
#define kSBoxVDiskJsonLabelDologID		@"dologid"
//#define kSBoxVDiskJsonLabelDologDir		@"dologdir"

@implementation SBoxVDiskManager

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
	[_dologID release];
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
			[data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
		}else{
			DAssert(NO,@"");
		}
		
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

int errCodeWithDict(NSDictionary *dict) {
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

- (SBoxVDRet) getToken {
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
	
	SBoxVDRet retv = errCodeWithDict(dict);
	
	if(retv!=SBoxVDRetSuccess)
		return retv;
	
	NSString *token = tokenWithDict(dict);
	_token = [token retain];
	
	return SBoxVDRetSuccess;
}

- (SBoxVDRet) getQuota:(SBoxVDiskQuota *)quota {
	if(_token==nil){
		int retv = [self getToken];
		if(retv!=SBoxVDRetSuccess)
			return retv;
	}
	
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  _token, kSBoxVDiskPostLabelToken, nil];
	NSMutableURLRequest *urlRequest = [self requestToPostWithURLString:kSBoxVDiskURLGetQuota dict:postDict];
	
	NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
	
	NSDictionary *dict = [_jsonParser objectWithData:data];
	
	if(dict==nil)
		return SBoxVDRetConnectionError;
	
	SBoxVDRet retv = errCodeWithDict(dict);
	
	if(retv==SBoxVDRetInvalidToken)
		retv = [self getToken];
	
	if(retv!=SBoxVDRetSuccess)
		return retv;
	
	*quota = quotaWithDict(dict);
	
	return SBoxVDRetSuccess;
}

@end
