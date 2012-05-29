//
//  SBoxSyncSystem.h
//  SecBox-MacCli
//
//  Created by Mingrui on 5/23/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBSSDefines.h"
#import "SBSSPair.h"

@interface SBoxSyncSystem : NSObject {
	@private
	NSMutableDictionary *_pairs;
	NSArray *_syncList;
	NSInteger _syncIndex;
}

+ (SBoxSyncSystem *) sharedSystem;

- (void) saveConfigs;

- (NSArray*) allPairs;

- (SBSSRet) addMapWithLocalFilePath:(NSString *)localFilePath remoteFilePath:(NSString *)remoteFilePath;
- (SBSSRet) removeMapWithLocalFilePath:(NSString *)localFilePath;

- (void) initSync;
- (SBSSRet) syncOneWithAction:(SBSSSyncAction)action andGetResult:(SBSSSyncResult *)result pair:(SBSSPair **)pair;
- (BOOL) stillCanSync;

@end
