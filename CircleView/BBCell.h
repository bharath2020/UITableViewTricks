//
//  BBCell.h
//  CircleView
//
//  Created by Bharath Booshan on 6/8/12.
//  Copyright (c) 2012 Bharath Booshan Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface BBCell : UITableViewCell
{
    UILabel *mCellTtleLabel;
    CALayer *mImageLayer;
}

-(void)setCellTitle:(NSString*)title;
-(void)setIcon:(UIImage*)image;

@end
