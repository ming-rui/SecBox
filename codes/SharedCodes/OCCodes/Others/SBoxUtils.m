//
//  SBoxUtils.c
//  SecBox-MacCli
//
//  Created by Mingrui on 5/24/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//


NSString* SBoxAbsoluteLocalPathWithPath(NSString *path) {
	if([path length]==0)
		return nil;
	
	if([path characterAtIndex:0]!='/'){
		NSString *currentPath = [[NSFileManager defaultManager] currentDirectoryPath];
		path = [NSString stringWithFormat:@"%@/%@", currentPath, path];
	}
	path = [path stringByStandardizingPath];
	
	return path;
}

BOOL SBoxValidateAbsoluteLocalPath(NSString *path) {
	if([path length]==0||[path characterAtIndex:0]!='/')
		return NO;
	
	return YES;
}

