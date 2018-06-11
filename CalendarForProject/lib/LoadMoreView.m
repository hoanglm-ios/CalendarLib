//
//  LoadMoreView.m
//  CalendarForProject
//
//  Created by LEMINHO on 6/10/18.
//  Copyright © 2018 LEMINHO. All rights reserved.
//

#import "LoadMoreView.h"

@implementation LoadMoreView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id) initWithFrame:(CGRect)frame{
     self = [super initWithFrame:frame];
    if(self){
        _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
        _activityIndicatorView.tintColor = [UIColor redColor];
        _activityIndicatorView.color = [UIColor redColor];
        [_activityIndicatorView startAnimating];
        _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false;
        [self addSubview:_activityIndicatorView];
        [_activityIndicatorView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
        [_activityIndicatorView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [_activityIndicatorView.heightAnchor constraintEqualToConstant:40].active = YES;
        [_activityIndicatorView.widthAnchor constraintEqualToConstant:40].active = YES;
    }
    return self;
}

@end
