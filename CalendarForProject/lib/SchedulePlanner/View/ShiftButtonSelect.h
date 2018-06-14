//
//  ShiftButtonSelect.h
//  CalendarForProject
//
//  Created by LEMINHO on 6/12/18.
//  Copyright © 2018 LEMINHO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShiftButtonSelect : UIView

@property (nonatomic, readonly) UIButton *button;
@property (nonatomic,readonly) UIImageView *iv_popup;
@property (nonatomic,readonly) UILabel *title;
@property (nonatomic) void (^sellectClick)(void);
- (void) setTextTitle:(NSString*) title;
@end
