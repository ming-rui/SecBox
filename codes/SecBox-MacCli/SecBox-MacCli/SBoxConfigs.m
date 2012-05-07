//
//  SBoxConfigs.m
//  SecBox-MacCli
//
//  Created by Mingrui on 5/7/12.
//  Copyright (c) 2012 Mingrui. All rights reserved.
//

#import "SBoxConfigs.h"

@implementation SBoxConfigs

+ (SBoxConfigs *) sharedConfigs {
	static SBoxConfigs *_configs = nil;
	@synchronized(self) {
		if(_configs==nil)
			_configs = [[self alloc] init];
	}
	
	return _configs;
}

@end
