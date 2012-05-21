//
//  SBoxFileInfo.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/22/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import "SBFSNode.h"

#import "SBoxFileSystem.h"
#import "SBoxDefines.h"

@implementation SBFSNode

@synthesize type=_type;
@dynamic isDirectory;
@dynamic isFile;
@synthesize name=_name;
@synthesize path=_path;
@synthesize itemInfo=_itemInfo;

- (id) initWithFilePath:(NSString *)filePath vDiskItemInfo:(VDiskItemInfo *)vDiskItemInfo {
	self = [super init];
	if(self){
		_type = SBoxINodeTypeFile;
		_name = [SBFSFileNameWithFilePath(filePath) retain];
		_path = [filePath retain];
		_itemInfo = [vDiskItemInfo retain];
	}
	
	return self;
}

- (id) initWithDirPath:(NSString *)dirPath {
	self = [super init];
	if(self){
		_type = SBoxINodeTypeDir;
		_name = [SBFSDirNameWithDirPath(dirPath) retain];
		_path = [dirPath retain];
		_childs = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (void) dealloc {
	[_name release];
	[_path release];
	[_itemInfo release];
	[_childs release];
	
	[super dealloc];
}

+ (SBFSNode *) fileNodeWithFilePath:(NSString *)filePath vDiskItemInfo:(VDiskItemInfo *)itemInfo {
	return [[[self alloc] initWithFilePath:filePath vDiskItemInfo:itemInfo] autorelease];
}

+ (SBFSNode *) dirNodeWithDirPath:(NSString *)dirPath {
	return [[[self alloc] initWithDirPath:dirPath] autorelease];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"INode[%@,%@]%@", _name, _path, _childs];
}

- (BOOL) isDirectory {
	return (_type==SBoxINodeTypeDir);
}

- (BOOL) isFile {
	return (_type=SBoxINodeTypeFile);
}

- (SBFSNode *) childNodeWithName:(NSString *)name {
	DAssert(_type==SBoxINodeTypeDir);
	
	return [_childs objectForKey:name];
}

- (BOOL) addChildNode:(SBFSNode *)node overwrite:(BOOL)overwrite {
	DAssert(_type==SBoxINodeTypeDir);
	NSString *name = [node name];
	BOOL exist = ([_childs objectForKey:name]!=nil);
	if((!overwrite)&&exist)
	   return NO;
	
	[_childs setObject:node forKey:name];
	
	return YES;
}

- (BOOL) removeChildNodeWithName:(NSString *)name {
	DAssert(_type==SBoxINodeTypeDir);
	BOOL exist = ([_childs objectForKey:name]!=nil);
	[_childs removeObjectForKey:name];
	
	return exist;
}

- (void) removeAllChildNodes {
	[_childs removeAllObjects];
}

- (NSArray *) allChildNodes {
	DAssert(_type==SBoxINodeTypeDir);
	return [_childs allValues];
}

- (NSUInteger) numOfChildNodes {
	DAssert(_type==SBoxINodeTypeDir);
	return [_childs count];
}


@end
