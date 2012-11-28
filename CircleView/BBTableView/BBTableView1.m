//
//  BBTableView.m
//  CircleView
//
//  Created by Bhagya on 9/11/12.
//  Copyright (c) 2012 Integral Development Corporation. All rights reserved.
//

#import "BBTableView.h"
#import <objc/objc-class.h>

#define HORIZONTAL_RADIUS_RATIO 0.8
#define VERTICAL_RADIUS_RATIO 1.2
#define CIRCLE_DIRECTION_RIGHT 0



@interface BBTableView()
{
    int mTotalCellsVisible;
    id<UITableViewDataSource> _ourNewDelegate;
}
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section;
@end

@implementation BBTableView


-(void)layoutSubviews
{
    self.backgroundColor = [UIColor blackColor];
    mTotalCellsVisible = self.frame.size.height / self.rowHeight;
    [self resetContentOffsetIfNeeded];
    [super layoutSubviews];
    [self setupShapeFormationInVisibleCells];
}

-(void)switchMethod
{
    SEL dataCountSel = @selector(tableView:numberOfRowsInSection:);
    Method theirMethod = class_getInstanceMethod([_ourNewDelegate class], dataCountSel);
    
    SEL ournewSel = @selector(tableview:numberOfRowsInSection:);	
    Method ourMethod = class_getInstanceMethod([self class], ournewSel);
    
    method_exchangeImplementations(theirMethod, ourMethod);     
}


- (void)resetContentOffsetIfNeeded
{
    NSArray *indexpaths = [self indexPathsForVisibleRows];
    int totalVisibleCells =[indexpaths count];
    if( mTotalCellsVisible > totalVisibleCells )
    {
        //we dont have enough content to generate scroll
        return;
    }
    CGPoint contentOffset  = self.contentOffset;
    
    //check the top condition
    //check if the scroll view reached its top.. if so.. move it to center.. remember center is the start of the data repeating for 2nd time.
    if( contentOffset.y<=0.0)
    {
        contentOffset.y = self.contentSize.height/3.0f;
    }
    else if( contentOffset.y >= ( self.contentSize.height - self.bounds.size.height) )//scrollview content offset reached bottom minus the height of the tableview
    {
        //this scenario is same as the data repeating for 2nd time minus the height of the table view
        contentOffset.y = self.contentSize.height/3.0f- self.bounds.size.height;
    }
    [self setContentOffset: contentOffset];
}


//The heart of this app.
//this function iterates through all visible cells and lay them in a circular shape
- (void)setupShapeFormationInVisibleCells
{
    NSArray *indexpaths = [self indexPathsForVisibleRows];
    int totalVisibleCells =[indexpaths count];

    float shift = ((int)self.contentOffset.y % (int)self.rowHeight);  
    float angle_gap = M_PI/(mTotalCellsVisible+1); // find the angle difference after dividing the table into totalVisibleCells +1
    float percentage_visible = shift/self.rowHeight;// if the cell is visible only half.. that the content offset is not multiples of row height.. then find by how much percentage the first cell is visible.

    float radius = self.frame.size.height/2.0f;
    float xRadius = radius*2/3;
    
    for( NSUInteger index =0; index < totalVisibleCells; index++ )
    {
        UITableViewCell *cell = (UITableViewCell*)[self cellForRowAtIndexPath:[ indexpaths objectAtIndex:index]];
        CGRect frame = cell.frame;
       
        
        //We can find the x Point by finding the Angle from the Ellipse Equation of finding y
        //i.e. Y= vertical_radius * sin(t )
        // t= asin(Y / vertical_radius) or asin = sin inverse
        float angle = (index +1)*angle_gap -( ( percentage_visible) * angle_gap);
        
        if( CIRCLE_DIRECTION_RIGHT )
        {
            angle =  angle + M_PI_2;
        }
        else {
            angle -= M_PI_2;

        }
      //  NSLog(@"Angle %f Row %d Radius %f Y: %f", angle * 180 / M_PI, index, radius, frame.origin.y);
        
        //Apply Angle in X point of Ellipse equation
        //i.e. X = horizontal_radius * cos( t )
        //here horizontal_radius would be some percentage off the vertical radius. percentage is defined by HORIZONTAL_RADIUS_RATIO
        //HORIZONTAL_RADIUS_RATIO of 1 is equal to circle
        float x = (floorf(xRadius*[self getDistanceRatio])) * cosf(angle );
        
        //Assuming, you have laid your tableview so that the entire frame is visible
        //TO DISPLAY RIGHT: then to display the circle towards right move the cellX (var x here) by half the width towards the right
        //TO DISPLAY LEFT : move the cellX by quarter the radius 
        //FEEL FREE to play with x to allign the circle as per your needs
        if( CIRCLE_DIRECTION_RIGHT )
        {
            //
           // x = x + self.frame.size.width/2;// we have to shift the center of the circle toward the right
        }
        else {
           // x = x - self.frame.size.width/2;//HORIZONTAL_TRANSLATION;  
        }
        
        frame.origin.x = x ;
        if( !isnan(x))
        {
            cell.frame = frame;
        }
    }
}


- (float)getDistanceRatio
{
    return 1.0;
    return (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? VERTICAL_RADIUS_RATIO : HORIZONTAL_RADIUS_RATIO);
}


@end
