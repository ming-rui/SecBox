//
//  SBoxFileTree.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/21/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBFSDefines.h"
#import "SBFSNode.h"


@interface SBFSTree : NSObject {
	@private
	SBFSNode *_root;
}

- (SBFSRet) getDirNode:(SBFSNode **)dirNode withDirPath:(NSString *)dirPath;
- (SBFSRet) addFileNodeWithFilePath:(NSString *)filePath vDiskItemInfo:(VDiskItemInfo *)vDiskItemInfo overwrite:(BOOL)overwrite;
- (SBFSRet) getFileNode:(SBFSNode **)fileNode withFilePath:(NSString *)filePath;
//不需要removeNode操作，永远完全刷新

- (void) removeAllData;

@end
