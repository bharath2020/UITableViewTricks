//
//  BBTableView.m
//  CircleView
//
//  Created by Bharath Booshan  on 9/11/12.
//  Copyright (c) 2012 Bharath Booshan. All rights reserved.
//

#import "BBTableView.h"
#import "BBTableViewInterceptor.h"

#define HORIZONTAL_RADIUS_RATIO 0.8
#define VERTICAL_RADIUS_RATIO 1.2
#define CIRCLE_DIRECTION_RIGHT 0


#define MORPHED_INDEX_PATH( __INDEXPATH__ ) [self morphedIndexPathForIndexPath:__INDEXPATH__  totalRows:_totalRows]

@interface BBTableView()
{
    int mTotalCellsVisible;
    BBTableViewInterceptor *_dataSourceInterceptor;
    NSInteger _totalRows;
}
- (void)customIntitialization;
- (NSIndexPath*)actualIndexPath;
- (void)resetContentOffsetIfNeeded;
- (void)setupShapeFormationInVisibleCells;
- (CGFloat)getAngleForYOffset:(CGFloat)yOffset;
@end

@implementation BBTableView
@synthesize enableInfiniteScrolling;
@synthesize contentAlignment;
@synthesize horizontalRadiusCorrection;

#pragma mark Private methods
- (CGFloat)getAngleForYOffset:(CGFloat)yOffset
{
    //normalise into 0 ...... rowheight
    CGFloat shift = ((int)self.contentOffset.y % (int)self.rowHeight);
    CGFloat percentage = shift / self.rowHeight ;
    
    CGFloat angle_gap = M_PI/(mTotalCellsVisible+1);
    
    int rows = 0;
    if( yOffset <0.0 )
    {
         rows = fabsf(yOffset) / self.rowHeight;
    }
    return fabsf(angle_gap * (1.0f -percentage)) + rows * angle_gap;
}

- (NSIndexPath*)morphedIndexPathForIndexPath:(NSIndexPath*)oldIndexPath totalRows:(NSInteger)totalRows
{
    return self.enableInfiniteScrolling ? [NSIndexPath indexPathForRow:oldIndexPath.row % totalRows inSection:oldIndexPath.section] : oldIndexPath;
}

- (void)customIntitialization
{
    self.backgroundColor = [UIColor blackColor];
    contentAlignment = eBBTableViewContentAlignmentLeft;
    self.enableInfiniteScrolling = NO;
    self.horizontalRadiusCorrection=1.0;
}

- (void)resetContentOffsetIfNeeded
{
    if( !self.enableInfiniteScrolling )
        return;
    
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
    NSUInteger totalVisibleCells =[indexpaths count];
    
    CGFloat angle_gap = M_PI/(mTotalCellsVisible+1); // find the angle difference after dividing the table into totalVisibleCells +1
    
    CGFloat vRadius = (self.frame.size.height-self.rowHeight*2.0f)/2.0f;
    CGFloat hRadius = (self.frame.size.width )/2.0f;
    CGFloat radius = (vRadius <  hRadius) ? vRadius : hRadius;

    CGFloat xRadius = radius;
    
    CGFloat firstCellAngle = [self getAngleForYOffset:self.contentOffset.y];

    for( NSUInteger index =0; index < totalVisibleCells; index++ )
    {
        UITableViewCell *cell = (UITableViewCell*)[self cellForRowAtIndexPath:[ indexpaths objectAtIndex:index]];
        CGRect frame = cell.frame;
        
        
        //We can find the x Point by finding the Angle from the Ellipse Equation of finding y
        //i.e. Y= vertical_radius * sin(t )
        // t= asin(Y / vertical_radius) or asin = sin inverse
        //CGFloat angle = (index +1)*angle_gap -( ( percentage_visible) * angle_gap);
        CGFloat angle = firstCellAngle;
        firstCellAngle+= angle_gap;
        if( contentAlignment == eBBTableViewContentAlignmentLeft )
        {
            angle =  angle + M_PI_2;
        }
        else {
            angle -= M_PI_2;
        }
        
        //Apply Angle in X point of Ellipse equation
        //i.e. X = horizontal_radius * cos( t )
        //here horizontal_radius would be some percentage off the vertical radius. percentage is defined by HORIZONTAL_RADIUS_RATIO
        //HORIZONTAL_RADIUS_RATIO of 1 is equal to circle
        CGFloat x = xRadius  * cosf(angle );
        
        //Assuming, you have laid your tableview so that the entire frame is visible
        //TO DISPLAY RIGHT: then to display the circle towards right move the cellX (var x here) by half the width towards the right
        //TO DISPLAY LEFT : move the cellX by quarter the radius
        //FEEL FREE to play with x to allign the circle as per your needs
        if( contentAlignment == eBBTableViewContentAlignmentLeft )
        {
            x = x + self.frame.size.width/2;// we have to shift the center of the circle toward the right
        }
        
        frame.origin.x = x ;
        if( !isnan(x))
        {
            cell.frame = frame;
        }
    }
}

#pragma mark Initialization
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        [self customIntitialization];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if( self )
    {
        [self customIntitialization];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self customIntitialization];
    }
    return self;
}

#pragma mark Layout

- (void)layoutSubviews
{
    mTotalCellsVisible = self.frame.size.height / self.rowHeight;
    [self resetContentOffsetIfNeeded];
    [super layoutSubviews];
    [self setupShapeFormationInVisibleCells];
}

#pragma mark Setter/Getter
- (void)setDataSource:(id<UITableViewDataSource>)dataSource
{
    if( !_dataSourceInterceptor)
    {
        _dataSourceInterceptor = [[BBTableViewInterceptor alloc] init];
    }
    
    _dataSourceInterceptor.receiver = dataSource;
    _dataSourceInterceptor.middleMan = self;
    
    [super setDataSource:(id<UITableViewDataSource>)_dataSourceInterceptor];
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    _totalRows = [_dataSourceInterceptor.receiver tableView:tableView numberOfRowsInSection:section  ];
    return _totalRows *( self.enableInfiniteScrolling ? 3 : 1 );
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_dataSourceInterceptor.receiver tableView:tableView cellForRowAtIndexPath:MORPHED_INDEX_PATH(indexPath)];
}


@end
