//
//  BBViewController.h
//  CircleView
//
//  Created by Bharath Booshan on 6/8/12.
//  Copyright (c) 2012 Bharath Booshan Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBViewController : UIViewController<UITableViewDataSource,UIScrollViewDelegate>
{
    IBOutlet UITableView *mTableView;
    NSMutableArray *mDataSource;
}

@end
