//
//  MGCTimeRowsView.m
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

#import "MGCTimeRowsView.h"
#import "NSCalendar+MGCAdditions.h"
#import "MGCAlignedGeometry.h"


@interface MGCTimeRowsView()

@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSUInteger rounding;

@end


@implementation MGCTimeRowsView

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
		_hourRange = NSMakeRange(0, 24);
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

- (void)setHourRange:(NSRange)hourRange
{
//    NSAssert(hourRange.length >= 1 && NSMaxRange(hourRange) <= 24, @"Invalid hour range %@", NSStringFromRange(hourRange));
    _hourRange = hourRange;
}

- (void)setTimeMark:(NSTimeInterval)timeMark
{
	_timeMark = timeMark;
	[self setNeedsDisplay];
}

- (void)timeChanged:(NSDictionary*)dictionary
{
	[self setNeedsDisplay];
}

- (NSAttributedString*)timeRowsViewAttributedStringBagde{
    NSAttributedString *attrStr = nil;
    
    if ([self.delegate respondsToSelector:@selector(timeRowsViewAttributedStringBagde:)]) {
        attrStr = [self.delegate timeRowsViewAttributedStringBagde:self];
    }
    
    if (!attrStr) {
        UIFont *font = [UIFont fontWithName:@"Palatino-Roman" size:6.0];
        attrStr = [[NSAttributedString alloc]initWithString:@"HH" attributes:@{ NSFontAttributeName: font}];
    }
    return attrStr;
}

- (NSAttributedString*)timeRowsViewAttributedStringMark{
    NSAttributedString *attrStr = nil;
    
    if ([self.delegate respondsToSelector:@selector(timeRowsViewAttributedStringMark:)]) {
       attrStr = [self.delegate timeRowsViewAttributedStringMark:self];
    }
    
    if (!attrStr) {
        attrStr = [[NSAttributedString alloc]initWithString:@"HH" attributes:@{ NSFontAttributeName: self.font }];
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
    for (NSUInteger i = self.hourRange.location; i <=  NSMaxRange(self.hourRange); i++) {
        y = MGCAlignedFloat((i - self.hourRange.location) * self.hourSlotHeight) - lineWidth * .5;
        
        // draw mark
        NSAttributedString *bagedAttrStr =[self timeRowsViewAttributedStringBagde];
        CGSize badgeSize = [bagedAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:MGCAlignedRectMake(kSpacing, y - (self.hourSlotHeight/2 + badgeSize.height/2),  badgeSize.width + kbadgeSpacing, badgeSize.height) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(2, 2)];
        [[UIColor redColor] setFill];
        [bezierPath fill];
        // draw bagger
       
        CGRect r = MGCAlignedRectMake(kSpacing + kbadgeSpacing/2, y - (self.hourSlotHeight/2 + badgeSize.height/2),  badgeSize.width, badgeSize.height);
        [bagedAttrStr drawInRect:r];
        
        NSAttributedString *markAttrStr =[self timeRowsViewAttributedStringMark];
        CGSize markSize = [markAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        CGRect mark = MGCAlignedRectMake(2*kSpacing + badgeSize.width + kbadgeSpacing, y - (self.hourSlotHeight/2 + markSize.height/2), markSize.width, markSize.height);
        [markAttrStr drawInRect:mark];
        
        
        CGContextSetStrokeColorWithColor(context, self.timeColor.CGColor);
        CGContextSetLineWidth(context, lineWidth);
        CGContextSetLineDash(context, 0, NULL, 0);
        CGContextMoveToPoint(context, self.timeColumnWidth, y);
        CGContextAddLineToPoint(context, self.timeColumnWidth + rect.size.width, y);
        CGContextStrokePath(context);
    
    }
}

@end
