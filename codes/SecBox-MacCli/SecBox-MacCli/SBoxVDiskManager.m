//
//  SBoxVDiskManager.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/8/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import "SBoxVDiskManager.h"

#import "SBoxDefines.h"
#import "SBoxAlgorithms.h"
#import <CommonCrypto/CommonHMAC.h>
#import "SBJsonParser.h"
#import "VDiskConstants.h"


#pragma mark -
#pragma mark VDiskFilePack

@interface VDiskFilePack : NSObject {
	NSString *_fileName;
	NSData *_contents;
}
@property(nonatomic,readonly) NSString *fileName;
@property(nonatomic,readonly) NSData *contents;
+ (id) filePackWithName:(NSString*)name contents:(NSData*)contents;
@end

@implementation VDiskFilePack
@synthesize fileName=_fileName;
@synthesize contents=_contents;
- (id) initWithName:(NSString*)name contents:(NSData*)contents {
	self = [super init];
	if(self){
		_fileName = [name retain];
		_contents = [contents retain];
	}
	return self;
}
+ (id) filePackWithName:(NSString*)name contents:(NSData*)contents {
	return [[[self alloc] initWithName:name contents:contents] autorelease];
}
- (void) dealloc {
	[_fileName release];
	[_contents release];
	[super dealloc];
}
@end


#pragma mark -
#pragma mark SBoxVDiskManager

@interface SBoxVDiskManager()
@property(nonatomic,retain) NSString *token;
@end


@implementation SBoxVDiskManager

@synthesize token=_token;

- (id) initWithAccountType:(VDiskAccountType)accountType userName:(NSString *)userName password:(NSString *)password {
	self = [super init];
	if(self){
		_accountType = accountType;
		_userName = [userName retain];
		_password = [password retain];
		
		_jsonParser = [[SBJsonParser alloc] init];
	}
	
	return self;
}

- (void) dealloc {
	[_userName release];
	[_password release];
	[_token release];
	[_jsonParser release];
	
	[super dealloc];
}

+ (SBoxVDiskManager *) managerWithAccountType:(VDiskAccountType)accountType userName:(NSString *)userName password:(NSString *)password {
	return [[[self alloc] initWithAccountType:accountType userName:userName password:password] autorelease];
}

NSData* dataToPostWithDictAndBoundary(NSDictionary *dict, NSString *boundary) {
	NSMutableData *data = [NSMutableData data];
	
	NSString *string = nil;
	
	for(NSString *key in dict){
		id value = [dict objectForKey:key];
		
		string = [NSString stringWithFormat:@"--%@\r\n", boundary];
		[data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
		
		if([value isKindOfClass:[NSString class]]){
			string = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, (NSString*)value];
			[data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
		}else if([value isKindOfClass:[NSNumber class]]){
			string = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, [(NSNumber*)value stringValue]];
			[data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
		}else if([value isKindOfClass:[VDiskFilePack class]]){
			NSString *fileName = [(VDiskFilePack*)value fileName];
			NSData *contents = [(VDiskFilePack*)value contents];
			string = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n"
					  "Content-Type: application/octet-stream\r\n\r\n", key, fileName];
			[data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:contents];
		}else{
			DCAssert(NO,@"");
		}
		
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
	
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kVDiskURLPostBoundary];
	[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	
	NSData *contentData = dataToPostWithDictAndBoundary(dict, kVDiskURLPostBoundary);
	
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
	NSString *appType = VDiskAppTypeWithAccountType(_accountType);
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
	if(_state==VDiskManagerStateOffline){
		VDiskRet retv = [self getToken];
		if(retv!=VDiskRetSuccess)
			return retv;
	}
	
	/* keepToken的作用除了保持token，还在于更新dologID */
	
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
	
	return VDiskRetSuccess;
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
		VDiskFileInfo *itemInfo = [VDiskFileInfo itemInfoWithDict:item];
		if([itemInfo isFile])
			[fileList addObject:itemInfo];
	}
}

- (VDiskRet) _getFileList:(NSMutableArray *)fileList withDirID:(VDiskDirID)dirID page:(NSInteger)page {
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  _token, kVDiskPostLabelToken,
							  [NSNumber numberWithInt:dirID], kVDiskPostLabelDirID,
							  [NSNumber numberWithInt:page], kVDiskPostLabelPage,
							  //[NSNumber numberWithInt:2], kVDiskPostLabelPageSize,
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
	return [self getFileList:fileList withDirID:VDiskRootDirID];
}

- (VDiskRet) getRootFileID:(VDiskFileID *)fileID withFileName:(NSString *)fileName {
	NSMutableArray *fileList = [NSMutableArray array];
	VDiskRet retv = [self getRootFileList:fileList];
	if(retv!=VDiskRetSuccess)
		return retv;
	
	*fileID = VDiskFileIDInvalid;
	for(VDiskFileInfo *fileInfo in fileList)
		if([[fileInfo name] isEqualToString:fileName]){
			*fileID = [fileInfo itemID];
			DAssert([fileInfo isFile],@"");
			break;
		}
	
	if(*fileID==VDiskFileIDInvalid)
		return VDiskRetNoMatchingFile;
	
	return VDiskRetSuccess;
}

- (VDiskRet) getFileInfo:(VDiskFileInfo **)fileInfo withFileID:(VDiskFileID)fileID {
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
	DAssert(dataItem!=nil,@"");
	*fileInfo = [VDiskFileInfo itemInfoWithDict:dataItem];
	DAssert([*fileInfo isFile],@"");
	
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

- (VDiskRet) removeFileWithFileID:(VDiskFileID)fileID {
	VDiskRet retv = [self keepToken];
	if(retv!=VDiskRetSuccess)
		return retv;
	
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  _token, kVDiskPostLabelToken,
							  [NSNumber numberWithInteger:fileID], kVDiskPostLabelFileID,
							  [NSNumber numberWithInteger:_dologID], kVDiskPostLabelDologID,
							  nil];
	NSMutableURLRequest *request = requestToPostWithURLStringAndDict(kVDiskURLDeleteFile, postDict);
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSDictionary *dict = [_jsonParser objectWithData:data];
	
	if(dict==nil)
		return VDiskRetConnectionError;
	
	VDiskRet errCode = errCodeWithDict(dict);
	
	if(errCode!=VDiskRetSuccess)
		return errCode;
	
	return VDiskRetSuccess;
}

- (VDiskRet) removeRootFileWithFileName:(NSString *)fileName {
	VDiskFileID fileID = VDiskFileIDInvalid;
	VDiskRet retv = [self getRootFileID:&fileID withFileName:fileName];
	if(retv!=VDiskRetSuccess)
		return retv;
	
	retv = [self removeFileWithFileID:fileID];
	if(retv!=VDiskRetSuccess)
		return retv;
	
	return VDiskRetSuccess;
}

- (VDiskRet) uploadFileWithFileName:(NSString *)fileName contents:(NSData *)contents dirID:(VDiskDirID)dirID {
	VDiskRet retv = [self keepToken];
	if(retv!=VDiskRetSuccess)
		return retv;
	
	VDiskFilePack *filePack = [VDiskFilePack filePackWithName:fileName contents:contents];
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  _token, kVDiskPostLabelToken,
							  [NSNumber numberWithInteger:dirID], kVDiskPostLabelDirID,
							  kVDiskPostCoverFileYES, kVDiskPostLabelCoverFile,
							  filePack, kVDiskPostLabelFile,
							  [NSNumber numberWithInteger:_dologID], kVDiskPostLabelDologID,
							  nil];
	NSMutableURLRequest *request = requestToPostWithURLStringAndDict(kVDiskURLUploadFile, postDict);
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSDictionary *dict = [_jsonParser objectWithData:data];
	
	if(dict==nil)
		return VDiskRetConnectionError;
	
	VDiskRet errCode = errCodeWithDict(dict);
	
	if(errCode!=VDiskRetSuccess)
		return errCode;
	
	return VDiskRetSuccess;
}

- (VDiskRet) uploadFileToRootWithFileName:(NSString *)fileName contents:(NSData *)contents {
	return [self uploadFileWithFileName:fileName contents:contents dirID:VDiskRootDirID];
}

- (VDiskRet) downloadFileFromRoot:(NSData **)contents withFileName:(NSString *)fileName {
	VDiskFileInfo *fileInfo = nil;
	VDiskRet retv = [self getRootFileInfo:&fileInfo withFileName:fileName];
	if(retv!=VDiskRetSuccess)
		return retv;
	
	NSString *urlString = [fileInfo fileURL];
	DAssert(urlString!=nil,@"");
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	if(data==nil)
		return VDiskRetConnectionError;
	
	*contents = data;
	
	return VDiskRetSuccess;
}

@end
