//
//  SBoxVDiskManager.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/8/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import "SBoxVDiskManager.h"

@implementation SBoxVDiskManager

+ (SBoxVDiskManager *) sharedVDiskManager {
	static SBoxVDiskManager *_manager = nil;
	@synchronized(self) {
		if(_manager==nil)
			_manager = [[self alloc] init];
	}
	
	return _manager;
}

@end
