//
//  ViewController.m
//  CalendarForProject
//
//  Created by LEMINHO on 6/8/18.
//  Copyright © 2018 LEMINHO. All rights reserved.
//

#import "ViewController.h"
#import "MGCDayPlannerEKViewController.h"

@interface ViewController ()
@property (nonatomic) MGCDayPlannerEKViewController *weekViewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.weekViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WeekViewController"];
    [self addChildViewController:self.weekViewController];
    [self.weekViewController.view setFrame:CGRectMake(0.0f, 0.0f, self.containerView.frame.size.width, self.containerView.frame.size.height)];
    [self.containerView addSubview:self.weekViewController.view];
    [self.weekViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
