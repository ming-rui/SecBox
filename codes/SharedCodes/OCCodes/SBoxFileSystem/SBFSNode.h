//
//  SBoxFileInfo.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/22/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VDiskItemInfo.h"


typedef enum {
	SBFSNodeTypeFile,
	SBFSNodeTypeDir,
}SBFSNodeType;

@interface SBFSNode : NSObject {
	@private
	SBFSNodeType _type;
	NSString *_name;
	NSString *_path;
	VDiskItemInfo *_itemInfo;
	NSMutableDictionary *_childs;
}

@property(nonatomic,readonly) SBFSNodeType type;
@property(nonatomic,readonly) BOOL isDirectory;
@property(nonatomic,readonly) BOOL isFile;
@property(nonatomic,readonly) NSString *name;
@property(nonatomic,readonly) NSString *path;
@property(nonatomic,readonly) VDiskItemInfo *itemInfo;

+ (SBFSNode *) fileNodeWithFilePath:(NSString *)filePath vDiskItemInfo:(VDiskItemInfo *)vDiskItemInfo;
+ (SBFSNode *) dirNodeWithDirPath:(NSString *)dirPath;

- (SBFSNode *) childNodeWithName:(NSString *)name;
- (BOOL) addChildNode:(SBFSNode *)node overwrite:(BOOL)overwrite;
- (BOOL) removeChildNodeWithName:(NSString *)name;
- (void) removeAllChildNodes;
- (NSArray *) allChildNodes;
- (NSUInteger) numOfChildNodes;

@end
