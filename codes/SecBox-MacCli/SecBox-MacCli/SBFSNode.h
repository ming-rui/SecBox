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
	SBoxINodeTypeFile,
	SBoxINodeTypeDir,
}SBoxINodeType;

@interface SBFSNode : NSObject {
	@private
	SBoxINodeType _type;
	NSString *_name;
	NSString *_path;
	VDiskItemInfo *_itemInfo;
	NSMutableDictionary *_childs;
}

@property(nonatomic,readonly) SBoxINodeType type;
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
