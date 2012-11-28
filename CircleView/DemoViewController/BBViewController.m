//
//  BBViewController.m
//  CircleView
//
//  Created by Bharath Booshan on 6/8/12.
//  Copyright (c) 2012 Bharath Booshan Inc. All rights reserved.
//

#import "BBViewController.h"
#import "BBCell.h"
#import <QuartzCore/QuartzCore.h>

//Keys used in the plist file to read the data for the table
#define KEY_TITLE @"title"
#define KEY_IMAGE_NAME @"image_name"
#define KEY_IMAGE @"image"



@interface BBViewController ()
-(void)setupShapeFormationInVisibleCells;
-(void)loadDataSource;
-(float)getDistanceRatio;
@end

@implementation BBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   // [mTableView setBackgroundColor:[UIColor clearColor]];
    mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    mTableView.opaque=NO;
    mTableView.showsHorizontalScrollIndicator=NO;
    mTableView.showsVerticalScrollIndicator=YES;
    
    UILabel *mainTitle = (UILabel*) [self.view viewWithTag:100];
    mainTitle.text = @"CRICKET \n LEGENDS";
    [self loadDataSource];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //we need to update the cells as the table might have changed its dimensions after rotation
   // [self setupShapeFormationInVisibleCells];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //update the cells to form the circle shape
    //[self setupShapeFormationInVisibleCells];
}


- (IBAction)enableInfiniteScrolling:(id)sender
{
    [mTableView setEnableInfiniteScrolling:[sender isOn]];
    [mTableView reloadData];
}

- (IBAction)switchDirections:(id)sender
{
    [mTableView setContentAlignment:[sender selectedSegmentIndex] ? eBBTableViewContentAlignmentRight : eBBTableViewContentAlignmentLeft];
    [mTableView reloadData];
}

#pragma mark UITableViewDelegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [mDataSource count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *test = @"table";
    BBCell *cell = (BBCell*)[tableView dequeueReusableCellWithIdentifier:test];
    if( !cell )
    {
        cell = [[BBCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:test];
    }
    NSDictionary *info = [mDataSource objectAtIndex:indexPath.row ];
    [cell setCellTitle:[info objectForKey:KEY_TITLE]];
    [cell setIcon:[info objectForKey:KEY_IMAGE]];
    
    return cell;
}



//read the data from the plist and alos the image will be masked to form a circular shape
- (void)loadDataSource
{
    NSMutableArray *dataSource = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];
    
    mDataSource = [[NSMutableArray alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //generate image clipped in a circle
        for( NSDictionary * dataInfo in dataSource )
        {
            NSMutableDictionary *info = [dataInfo mutableCopy];
            UIImage *image = [UIImage imageNamed:[info objectForKey:KEY_IMAGE_NAME]];
            UIImage *finalImage = nil;
            UIGraphicsBeginImageContext(image.size);
            {
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                CGAffineTransform trnsfrm = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeScale(1.0, -1.0));
                trnsfrm = CGAffineTransformConcat(trnsfrm, CGAffineTransformMakeTranslation(0.0, image.size.height));
                CGContextConcatCTM(ctx, trnsfrm);
                CGContextBeginPath(ctx);
                CGContextAddEllipseInRect(ctx, CGRectMake(0.0, 0.0, image.size.width, image.size.height));
                CGContextClip(ctx);
                CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, image.size.width, image.size.height), image.CGImage);
                finalImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            [info setObject:finalImage forKey:KEY_IMAGE];
            
            [mDataSource addObject:info];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [mTableView reloadData];
           // [self setupShapeFormationInVisibleCells];
        });
    });
}

@end
