//
//  BBTableViewInterceptor.m
//  BBTableView
//
//  Created by Evadne Wu on 6/20/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "BBTableViewInterceptor.h"

@implementation BBTableViewInterceptor
@synthesize receiver = _receiver;
@synthesize middleMan = _middleMan;

- (id) forwardingTargetForSelector:(SEL)aSelector {

	if ([_middleMan respondsToSelector:aSelector])
		return _middleMan;
	
	if ([_receiver respondsToSelector:aSelector])
		return _receiver;
	
	return	[super forwardingTargetForSelector:aSelector];
	
}

- (BOOL) respondsToSelector:(SEL)aSelector {

	if ([_middleMan respondsToSelector:aSelector])
		return YES;
	
	if ([_receiver respondsToSelector:aSelector])
		return YES;
	
	return [super respondsToSelector:aSelector];
	
}

@end
