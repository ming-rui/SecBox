//
//  SBoxFileTree.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/21/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import "SBFSTree.h"

#import "SBoxFileSystem.h"
#import "SBoxDefines.h"


@implementation SBFSTree

- (id) init {
	self = [super init];
	if(self){
		_root = [[SBFSNode dirNodeWithDirPath:@"/"] retain];
	}
	
	return self;
}

- (void) dealloc {
	[_root release];
	
	[super dealloc];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"fileTree{%@}",_root];
}

- (void) removeAllData {
	[_root removeAllChildNodes];
}

BOOL hasFile(SBFSNode *dirNode){
	NSArray *nodes = [dirNode allChildNodes];
	for(SBFSNode *node in nodes){
		if([node isFile])
			return YES;
		if([node isDirectory]&&hasFile(node))
			return YES;
	}
	
	return NO;		
}

void removeEnptyChildDirNodes(SBFSNode *dirNode){
	DCAssert([dirNode isDirectory]);
	NSArray *nodes = [dirNode allChildNodes];
	for(SBFSNode *node in nodes){
		if(![node isDirectory])
			continue;
		if(!hasFile(node))
			[dirNode removeChildNodeWithName:[node name]];
	}
}

NSString *dirPathWithDirNames(NSArray *dirNames, int start, int end) {
	DCAssert(start<=end);
	DCAssert(end<[dirNames count]);
	NSMutableString *string = [NSMutableString string];
	for(int i=start; i<=end; i++){
		[string appendString:@"/"];
		[string appendString:[dirNames objectAtIndex:i]];
	}
	
	return string;
}

- (SBFSRet) getDirNode:(SBFSNode **)dirNode withDirPath:(NSString *)dirPath {
	SBFSRet retv = SBFSValidatePath(dirPath);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	NSArray *dirNames = SBFSDirNamesWithDirPath(dirPath);
	SBFSNode *currentNode = _root;
	for(int i=1; i<[dirNames count]; i++){
		NSString *dirName = [dirNames objectAtIndex:i];
		SBFSNode *nextNode = [currentNode childNodeWithName:dirName];
		if(nextNode==nil){
			NSString *dirPath = dirPathWithDirNames(dirNames, 1, i);
			nextNode = [SBFSNode dirNodeWithDirPath:dirPath];
			[currentNode addChildNode:nextNode overwrite:NO];
		}
		currentNode = nextNode;
		
		if(![currentNode isDirectory])
			return SBFSRetFileInPath;
	}
	
	removeEnptyChildDirNodes(currentNode);
	*dirNode = currentNode;
	
	return SBFSRetSuccess;
}

- (SBFSRet) addFileNodeWithFilePath:(NSString *)filePath vDiskItemInfo:(VDiskItemInfo *)vDiskItemInfo overwrite:(BOOL)overwrite{
	SBFSRet retv = SBFSValidateFilePath(filePath);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	NSString *dirPath = SBFSDirPathWithFilePath(filePath);
	SBFSNode *dirNode;
	retv = [self getDirNode:&dirNode withDirPath:dirPath];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	SBFSNode *fileNode = [SBFSNode fileNodeWithFilePath:filePath vDiskItemInfo:vDiskItemInfo];
	BOOL succeed = [dirNode addChildNode:fileNode overwrite:overwrite];
	if(!succeed)
		return SBFSRetNodeNameCollision;
	
	return SBFSRetSuccess;
}

- (SBFSRet) getFileNode:(SBFSNode **)fileNode withFilePath:(NSString *)filePath {
	SBFSRet retv = SBFSValidateFilePath(filePath);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	NSString *fileName = SBFSFileNameWithFilePath(filePath);
	NSString *dirPath = SBFSDirPathWithFilePath(filePath);
	SBFSNode *dirNode;
	retv = [self getDirNode:&dirNode withDirPath:dirPath];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	SBFSNode *node = [dirNode childNodeWithName:fileName];
	
	if(node==nil)
		return SBFSRetFileInfoNotExist;
	
	if(![node isFile])
		return SBFSRetIsNotFile;
	
	*fileNode = node;
	
	return SBFSRetSuccess;
}


@end
