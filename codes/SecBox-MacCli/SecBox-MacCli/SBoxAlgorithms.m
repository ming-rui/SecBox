//
//  SBoxAlgorithms.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/6/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import "SBoxAlgorithms.h"

#import <CommonCrypto/CommonCryptor.h>
#import "GTMStringEncoding.h"
#import <CommonCrypto/CommonHMAC.h>
#import "SBoxDefines.h"


typedef enum {
	SBoxAESKeySize128 = 0,
	SBoxAESKeySize256,
}SBoxAESKeySize;


@implementation SBoxAlgorithms


+ (NSData *) AESEncryptWithData:(NSData*)data keySize:(SBoxAESKeySize)keySize key:(NSString *)key {
	if([data length]==0||[key length]==0)
		return nil;
	
	size_t ccKeySize = (keySize==SBoxAESKeySize128?kCCKeySizeAES128:kCCKeySizeAES256);
    char keyPtr[ccKeySize+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    size_t bufferSize = [data length]+kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
	
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr, ccKeySize,
                                          NULL,
                                          [data bytes], [data length],
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
	
    if(cryptStatus!=kCCSuccess){
		free(buffer);
		return nil;
	}
	
	return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
}

+ (NSData *) AESDecryptWithData:(NSData*)data keySize:(SBoxAESKeySize)keySize Key:(NSString *)key {
	if([data length]==0||[key length]==0)
		return nil;
	
	size_t ccKeySize = (keySize==SBoxAESKeySize128?kCCKeySizeAES128:kCCKeySizeAES256);
    char keyPtr[ccKeySize+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    size_t bufferSize = [data length]+kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
	
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr, ccKeySize,
                                          NULL,
                                          [data bytes], [data length],
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
	
    if (cryptStatus!=kCCSuccess){
		free(buffer);
		return nil;
	}
	
	return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
}

+ (NSData *) encryptWithData:(NSData *)data key:(NSString *)key {
	return [self AESEncryptWithData:data keySize:SBoxAESKeySize128 key:key];
}

+ (NSData *) decryptWithData:(NSData *)data Key:(NSString *)key {
	return [self AESDecryptWithData:data keySize:SBoxAESKeySize128 Key:key];
}


+ (NSString *) base64wsEncodeWithData:(NSData *)data {
	GTMStringEncoding *encoding = [GTMStringEncoding rfc4648Base64WebsafeStringEncoding];
	return [encoding encode:data];
}

+ (NSData *) base64wsDecodeWithString:(NSString *)string {
	GTMStringEncoding *encoding = [GTMStringEncoding rfc4648Base64WebsafeStringEncoding];
	return [encoding decode:string];
}

+ (NSString*) hmacSHA256WithKey:(NSString*)key string:(NSString*)string {
	const char *cStrKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
	const char *cString = [string cStringUsingEncoding:NSUTF8StringEncoding];
	
	unsigned char macOut[CC_SHA256_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA256, cStrKey, strlen(cStrKey), cString, strlen(cString), macOut);
	
	NSMutableString *result = [NSMutableString string];
	for(int i=0; i<CC_SHA256_DIGEST_LENGTH; i++)
		[result appendFormat:@"%02x", macOut[i]];
	
	return result;
}

+ (NSString*) descriptionWithNumOfBytes:(long long)numOfBytes {
	static const int numOfUnits = 5;
	static const long long rank[] = {1024ll*1024*1024*1024, 1024ll*1024*1024, 1024ll*1024, 1024ll, 1ll};
	static const NSString *units[] = {@"TB",@"GB",@"MB",@"KB",@"B"};
	
	DCAssert(numOfBytes>=0,@"");
	for(int i=0; i<numOfUnits ;i++){
		if(numOfBytes<rank[i])
			continue;
		
		double num = (double)numOfBytes/rank[i];
		NSString *result = [NSString stringWithFormat:@"%7.1llf %@", num, units[i]];
		
		return result;
	}
	
	return @"0 bytes";
}

@end
