//
//  ButtonSelect.m
//  CalendarForProject
//
//  Created by LEMINHO on 6/12/18.
//  Copyright © 2018 LEMINHO. All rights reserved.
//

#import "ButtonSelect.h"


@implementation ButtonSelect

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
        _button = [[UIButton alloc] init];
        _button.backgroundColor = [UIColor clearColor];
        _button.translatesAutoresizingMaskIntoConstraints = false;
        [self addSubview:_button];
        [_button.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [_button.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
        [_button.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [_button.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [_button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        // create title
        _title = [[UILabel alloc] init];
        [_title setText:@"Dropdown"];
        [_title setFont:[UIFont systemFontOfSize:10.0]];
        _title.translatesAutoresizingMaskIntoConstraints = false;
        [self addSubview:_title];
        [_title.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
        [_title.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        // create UIImage
        _iv_popup = [[UIImageView alloc] init];
        _iv_popup.translatesAutoresizingMaskIntoConstraints = false;
        [self addSubview:_iv_popup];
        [_iv_popup.topAnchor constraintEqualToAnchor:_title.topAnchor constant:2].active = YES;
        [_iv_popup.leadingAnchor constraintEqualToAnchor:_title.trailingAnchor constant:1].active = YES;
        [_iv_popup.widthAnchor constraintEqualToConstant:10].active = YES;
        [_iv_popup.heightAnchor constraintEqualToConstant:10].active = YES;
        [_iv_popup setImage:[UIImage imageNamed:@"ic_dropdown"]];
    }
    return self;
}

-(void) setTextTitle:(NSString *)title{
    [_title setText:title];
}

- (void) clickButton:(UIButton *) sender {
    _sellectClick();
}
@end
