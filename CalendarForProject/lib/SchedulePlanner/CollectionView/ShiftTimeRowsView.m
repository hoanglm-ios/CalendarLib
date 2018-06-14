//
//  ShiftTimeRowsView.m
//  Graphical Calendars Library for iOS
//
//  Distributed under the MIT License
//  Get the latest version from here:
//
//	https://github.com/jumartin/Calendar
//
//  Copyright (c) 2014-2015 Julien Martin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "ShiftTimeRowsView.h"
#import "NSCalendar+MGCAdditions.h"
#import "MGCAlignedGeometry.h"


@interface ShiftTimeRowsView()

@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSUInteger rounding;

@end


@implementation ShiftTimeRowsView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		
		_calendar = [NSCalendar currentCalendar];
		_hourSlotHeight = 120;
		_insetsHeight = 45;
		_timeColumnWidth = 80;
		_font = [UIFont boldSystemFontOfSize:12];
		_timeColor = [UIColor lightGrayColor];
		_currentTimeColor = [UIColor redColor];
		_rounding = 15;
//        _hourRange = NSMakeRange(0, 24);
        _numColumn = 48;
        _currentTimeColor = [UIColor yellowColor];
        _currentIndex = 0;
		self.showsCurrentTime = YES;
	}
	return self;
}

- (void)setShowsCurrentTime:(BOOL)showsCurrentTime
{
	_showsCurrentTime = showsCurrentTime;
	
	[self.timer invalidate];
	if (_showsCurrentTime) {
		self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timeChanged:) userInfo:nil repeats:YES];
	}
	
	[self setNeedsDisplay];
}

- (void)setNumColumn:(NSInteger)numColumn
{
//    NSAssert(hourRange.length >= 1 && NSMaxRange(hourRange) <= 24, @"Invalid hour range %@", NSStringFromRange(hourRange));
    _numColumn = numColumn;
}

- (void)setTimeMark:(NSTimeInterval)timeMark
{
	_timeMark = timeMark;
	[self setNeedsDisplay];
}

- (void)setCurrentTimeColor:(UIColor *)currentTimeColor{
    _currentTimeColor = currentTimeColor;
    [self setNeedsDisplay];
}

-(void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    [self setNeedsDisplay];
}

- (void)timeChanged:(NSDictionary*)dictionary
{
	[self setNeedsDisplay];
}

- (NSAttributedString*)timeRowsViewAttributedStringBagdeWithIndex:(NSInteger) index{
    NSAttributedString *attrStr = nil;
    
    if ([self.delegate respondsToSelector:@selector(timeRowsViewAttributedStringBagde:withIndex:)]) {
        attrStr = [self.delegate timeRowsViewAttributedStringBagde:self withIndex:index];
    }
    
    if (!attrStr) {
        UIFont *font = [UIFont fontWithName:@"Palatino-Roman" size:6.0];
        attrStr = [[NSAttributedString alloc]initWithString:@"HH" attributes:@{ NSFontAttributeName: font}];
    }
    return attrStr;
}

- (NSAttributedString*)timeRowsViewAttributedStringMarkWithIndex:(NSInteger) index{
    NSAttributedString *attrStr = nil;
    
    if ([self.delegate respondsToSelector:@selector(timeRowsViewAttributedStringMark:withIndex:)]) {
        attrStr = [self.delegate timeRowsViewAttributedStringMark:self withIndex:index];
    }
    
    if (!attrStr) {
        attrStr = [[NSAttributedString alloc]initWithString:@"HH" attributes:@{ NSFontAttributeName: self.font }];
    }
    return attrStr;
}

- (NSAttributedString*)timeRowsViewAttributedStringGuestWithIndex:(NSInteger) index{
    NSAttributedString *attrStr = nil;
    
    if ([self.delegate respondsToSelector:@selector(timeRowsViewAttributedStringGuest:withIndex:)]) {
        attrStr = [self.delegate timeRowsViewAttributedStringGuest:self withIndex:index];
    }
    
    return attrStr;
}

- (void)drawRect:(CGRect)rect
{
    const CGFloat kSpacing = 2.;
     const CGFloat kbadgeSpacing = 4.;
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat y = 0;
    CGFloat lineWidth = 1. / [UIScreen mainScreen].scale;
    CGSize markSizeMax = CGSizeMake(self.timeColumnWidth - 2.*kSpacing, CGFLOAT_MAX);
    
	// draw the hour marks
    for (NSUInteger i = 0; i <=  self.numColumn; i++) {
        y = MGCAlignedFloat((i - 0) * self.hourSlotHeight) - lineWidth * .5;
        //
        if(i == _currentIndex){
            UIBezierPath *bezierRect = [UIBezierPath bezierPathWithRect:CGRectMake(0, y, self.timeColumnWidth, self.hourSlotHeight)];
            [_currentTimeColor setFill];
            [bezierRect fill];
        }
        NSAttributedString *guestStr = [self timeRowsViewAttributedStringGuestWithIndex:i];
        if(guestStr){
            // ve tam giac
            CGFloat startYColumn = y - self.hourSlotHeight;
            UIBezierPath* trianglePath = [UIBezierPath bezierPath];
            [trianglePath moveToPoint:CGPointMake(2, startYColumn + 2)];
            [trianglePath addLineToPoint:CGPointMake(8,startYColumn + 6)];
            [trianglePath addLineToPoint:CGPointMake(2,startYColumn + 10)];
            [[UIColor redColor] setFill];
            [trianglePath fill];
            // ve guest
             CGSize guestSize = [guestStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            CGRect r = CGRectMake(10, startYColumn + 2,  guestSize.width, guestSize.height);
            [guestStr drawInRect:r];
            
            // draw mark
            NSAttributedString *bagedAttrStr =[self timeRowsViewAttributedStringBagdeWithIndex:i];
            CGSize badgeSize = [bagedAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:MGCAlignedRectMake(kSpacing, y - (self.hourSlotHeight/2 + badgeSize.height/2 - 6),  badgeSize.width + kbadgeSpacing, badgeSize.height) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(2, 2)];
            // NSBackgroundColorAttributeName
            NSRange range =NSMakeRange(0,10);
            UIColor *color = [bagedAttrStr attribute:NSBackgroundColorAttributeName atIndex:0 effectiveRange:&range];
            [color setFill];
            [bezierPath fill];
            // draw bagger
            
            CGRect r1 = MGCAlignedRectMake(kSpacing + kbadgeSpacing/2, y - (self.hourSlotHeight/2 + badgeSize.height/2 - 6),  badgeSize.width, badgeSize.height);
            [bagedAttrStr drawInRect:r1];
            
            NSAttributedString *markAttrStr =[self timeRowsViewAttributedStringMarkWithIndex:i];
            CGSize markSize = [markAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            CGRect mark = MGCAlignedRectMake(2*kSpacing + badgeSize.width + kbadgeSpacing, y - (self.hourSlotHeight/2 + markSize.height/2 - 6), markSize.width, markSize.height);
            [markAttrStr drawInRect:mark];
            
        }else{
            // draw mark
            NSAttributedString *bagedAttrStr =[self timeRowsViewAttributedStringBagdeWithIndex:i];
            CGSize badgeSize = [bagedAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:MGCAlignedRectMake(kSpacing, y - (self.hourSlotHeight/2 + badgeSize.height/2),  badgeSize.width + kbadgeSpacing, badgeSize.height) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(2, 2)];
            // NSBackgroundColorAttributeName
            NSRange range =NSMakeRange(0,10);
            UIColor *color = [bagedAttrStr attribute:NSBackgroundColorAttributeName atIndex:0 effectiveRange:&range];
            [color setFill];
            [bezierPath fill];
            // draw bagger
            
            CGRect r = MGCAlignedRectMake(kSpacing + kbadgeSpacing/2, y - (self.hourSlotHeight/2 + badgeSize.height/2),  badgeSize.width, badgeSize.height);
            [bagedAttrStr drawInRect:r];
            
            NSAttributedString *markAttrStr =[self timeRowsViewAttributedStringMarkWithIndex:i];
            CGSize markSize = [markAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            CGRect mark = MGCAlignedRectMake(2*kSpacing + badgeSize.width + kbadgeSpacing, y - (self.hourSlotHeight/2 + markSize.height/2), markSize.width, markSize.height);
            [markAttrStr drawInRect:mark];
        }
        
        CGContextSetStrokeColorWithColor(context, self.timeColor.CGColor);
        CGContextSetLineWidth(context, lineWidth);
        CGContextSetLineDash(context, 0, NULL, 0);
        CGContextMoveToPoint(context, 0, y);
        CGContextAddLineToPoint(context, 0 + rect.size.width, y);
        CGContextStrokePath(context);
    
    }
}

@end
