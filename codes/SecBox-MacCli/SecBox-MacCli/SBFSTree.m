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
		if(hasFile(node))
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

- (SBFSRet) getNode:(SBFSNode **)node withPath:(NSString *)path createDir:(BOOL)createDir {
	SBFSRet retv = SBFSValidateAbsolutePath(path);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	NSArray *names = SBFSNamesWithPath(path);
	SBFSNode *pNode = _root;
	for(int i=1; i<[names count]; i++){
		if(![pNode isDirectory])
			return SBFSRetFileInPath;
		
		NSString *name = [names objectAtIndex:i];
		SBFSNode *cNode = [pNode childNodeWithName:name];
		if(cNode==nil){
			if(!createDir)
				return SBFSRetNodeNotExist;
			NSString *dirPath = dirPathWithDirNames(names, 1, i);
			cNode = [SBFSNode dirNodeWithDirPath:dirPath];
			[pNode addChildNode:cNode overwrite:NO];
		}
		pNode = cNode;
	}
	
	if([pNode isDirectory])
		removeEnptyChildDirNodes(pNode);
	*node = pNode;
	
	return SBFSRetSuccess;
}

- (SBFSRet) getDirNode:(SBFSNode **)dirNode withDirPath:(NSString *)dirPath createDir:(BOOL)createDir {
	SBFSNode *node = nil;
	SBFSRet retv = [self getNode:&node withPath:dirPath createDir:createDir];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	if(![node isDirectory])
		return SBFSRetNodeIsNotDir;
	
	*dirNode = node;
	
	return SBFSRetSuccess;
}

- (SBFSRet) addFileNodeWithFilePath:(NSString *)filePath vDiskItemInfo:(VDiskItemInfo *)vDiskItemInfo overwrite:(BOOL)overwrite {
	SBFSRet retv = SBFSValidateAbsoluteFilePath(filePath);
	if(retv!=SBFSRetSuccess)
		return retv;
	
	NSString *dirPath = SBFSDirPathWithFilePath(filePath);
	SBFSNode *dirNode;
	retv = [self getDirNode:&dirNode withDirPath:dirPath createDir:YES];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	SBFSNode *fileNode = [SBFSNode fileNodeWithFilePath:filePath vDiskItemInfo:vDiskItemInfo];
	BOOL succeed = [dirNode addChildNode:fileNode overwrite:overwrite];
	if(!succeed)
		return SBFSRetNodeNameCollision;
	
	return SBFSRetSuccess;
}

- (SBFSRet) getFileNode:(SBFSNode **)fileNode withFilePath:(NSString *)filePath {
	SBFSNode *node;
	SBFSRet retv = [self getNode:&node withPath:filePath createDir:NO];
	if(retv!=SBFSRetSuccess)
		return retv;
	
	if(![node isFile])
		return SBFSRetNodeIsNotFile;
	
	*fileNode = node;
	
	return SBFSRetSuccess;
}


@end
