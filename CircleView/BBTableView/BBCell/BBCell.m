//
//  BBCell.m
//  CircleView
//
//  Created by Bharath Booshan on 6/8/12.
//  Copyright (c) 2012 Bharath Booshan Inc. All rights reserved.
//

#import "BBCell.h"

@implementation BBCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //add the image layer
        self.contentView.backgroundColor = [UIColor blackColor];
        mImageLayer =[CALayer layer];
        mImageLayer.cornerRadius = 16.0;
        //mImageLayer.backgroundColor = [UIColor greenColor].CGColor;
      //  mImageLayer.contents = (id)[UIImage imageNamed:@"2.png"].CGImage;
        [self.contentView.layer addSublayer:mImageLayer];
        mImageLayer.borderWidth=4.0;
        mImageLayer.borderColor = [UIColor whiteColor].CGColor;
       
        //the title label
       mCellTtleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44.0, 10.0, self.contentView.bounds.size.width - 44.0, 21.0)];
        [self.contentView addSubview:mCellTtleLabel];
        mCellTtleLabel.backgroundColor= [UIColor clearColor];
        mCellTtleLabel.textColor = [UIColor whiteColor];
        mCellTtleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
       
    }
    return self;
}



-(void)layoutSubviews
{
    [super layoutSubviews];
    float imageY = 4.0;
    float heightOfImageLayer  = self.bounds.size.height - imageY*2.0;
    heightOfImageLayer = floorf(heightOfImageLayer);
    mImageLayer.cornerRadius = heightOfImageLayer/2.0f;
    mImageLayer.frame = CGRectMake(4.0, imageY, heightOfImageLayer, heightOfImageLayer);
    mCellTtleLabel.frame = CGRectMake(heightOfImageLayer+10.0, floorf(heightOfImageLayer/2.0 - (21/2.0f))+4.0, self.contentView.bounds.size.width-heightOfImageLayer+10.0, 21.0);  
    
}

-(void)setCellTitle:(NSString*)title
{
    mCellTtleLabel.text = title;    
}

-(void)setIcon:(UIImage*)image
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    mImageLayer.contents = (id)image.CGImage;
    [CATransaction commit];
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    mImageLayer.borderColor = selected ? [UIColor orangeColor].CGColor : [UIColor whiteColor].CGColor;
    mCellTtleLabel.textColor = selected ? [UIColor orangeColor] : [UIColor whiteColor];
}

@end
