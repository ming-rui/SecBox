//
//  main.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/6/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SecBox.h"
#import "SBoxDefines.h"
#import "SBoxFileSystem.h"


int main(int argc, const char * argv[]) {
	SBoxRet retv;
	@autoreleasepool {
		
		retv = SBoxCLIMain(argc, argv);
		if(retv!=SBoxSuccess){
			printf("Operation Error! Code:%i\n",retv);
		}else{
			printf("Operation Completed.\n");
		}
		
		//SBoxShowStatus();//test
		
		
		//SBoxFileSystem *system = [SBoxFileSystem sharedSystem];
		//VDiskManager *manager = [system diskManager];//test
		
		
		//[manager getToken];//test
		
		
		//NSMutableArray *list = [NSMutableArray array];//test
		//[manager getRootFileList:list];//test
		
		
		//VDiskFileID fileID;//test
		//[manager getRootFileID:&fileID withFileName:@"t"];//test
		//VDiskItemInfo *fileInfo;//test
		//[manager getFileInfo:&fileInfo withFileID:fileID];//test
		
		
		//VDiskItemInfo *fileInfo;//test
		//[manager getRootFileInfo:&fileInfo withFileName:@"t"];//test
		
		
		//[manager removeFileWithFileID:(VDiskFileID)94740958];//test
		
		
		//[manager removeRootFileWithFileName:@"filename"];//test
		
		
//		char n[170];//test
//		for(int i=0; i<sizeof(n)-1; i++){//test
//			n[i] = 't';//test
//			if(i%8==0)
//				n[i] = '/';
//		}
//		n[sizeof(n)-1] = '\0';//test
//		char d[1];//test
//		NSData *data = [NSData dataWithBytes:d length:sizeof(d)];//test
//		NSString *name = [NSString stringWithCString:n encoding:NSUTF8StringEncoding];//test
//		//[manager uploadFileToRootWithFileName:name contents:data];//test
//		retv = [system putFileWithFilePath:name contents:data];
		
		
		//NSData *data = nil;//test
		//[manager downloadFileFromRoot:&data withFileName:@"foobar2000.exe"];//test
		
		
		//SBoxFileSystem *system = [SBoxFileSystem sharedSystem];//test
		//NSString *s = [system fileNameWithPath:@"/abc/def/ghi"];//test
		//NSString *s2 = [system pathWithFileName:s];//test
		
//		[[SBoxFileSystem sharedSystem] putFileWithFilePath:@"/test/test/test" contents:[NSData dataWithBytes:"test" length:5]];
//		[[SBoxFileSystem sharedSystem] putFileWithFilePath:@"/file1" contents:[NSData dataWithBytes:"file1" length:6]];
//		[[SBoxFileSystem sharedSystem] putFileWithFilePath:@"/file2" contents:[NSData dataWithBytes:"file2" length:6]];
//		[[SBoxFileSystem sharedSystem] putFileWithFilePath:@"/file3" contents:[NSData dataWithBytes:"file3" length:6]];
//		[[SBoxFileSystem sharedSystem] putFileWithFilePath:@"/file4" contents:[NSData dataWithBytes:"file4" length:6]];
//		[[SBoxFileSystem sharedSystem] putFileWithFilePath:@"/file5" contents:[NSData dataWithBytes:"file5" length:6]];
//		[[SBoxFileSystem sharedSystem] putFileWithFilePath:@"/test/file1" contents:[NSData dataWithBytes:"file1" length:6]];
//		[[SBoxFileSystem sharedSystem] putFileWithFilePath:@"/test/file2" contents:[NSData dataWithBytes:"file2" length:6]];
//		[[SBoxFileSystem sharedSystem] putFileWithFilePath:@"/test/file3" contents:[NSData dataWithBytes:"file3" length:6]];
//		[[SBoxFileSystem sharedSystem] putFileWithFilePath:@"/test/test/file1" contents:[NSData dataWithBytes:"file1" length:6]];
//		[[SBoxFileSystem sharedSystem] putFileWithFilePath:@"/test/test/file2" contents:[NSData dataWithBytes:"file2" length:6]];
//		[[SBoxFileSystem sharedSystem] putFileWithFilePath:@"/test/test/file3" contents:[NSData dataWithBytes:"file3" length:6]];
		
		//NSData *file = nil;
		//[[SBoxFileSystem sharedSystem] getFile:&file withFilePath:@"/test/test/test"];
		//char *str = [file bytes];
		
		//NSString *s = [@"/a/../../" stringByStandardizingPath];
		
		//SBoxListRemoteDirectory();
		
		//[[SBoxFileSystem sharedSystem] removeFileWithFilePath:@"file4"];
		
		
		[[SBoxFileSystem sharedSystem] saveConfigs];
	}
	
    return retv;
}

