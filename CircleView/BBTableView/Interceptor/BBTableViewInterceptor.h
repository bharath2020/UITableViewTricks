//
//  BBTableViewInterceptor.h
//  BBTableView
//
//  Created by Evadne Wu on 6/20/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBTableViewInterceptor : NSObject

@property (nonatomic, readwrite, weak) id receiver;
@property (nonatomic, readwrite, weak) id middleMan;

@end
