//
//  ShiftEventView.m
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

#import "ShiftEventView.h"

static CGFloat kSpace = 2;

@interface ShiftEventView ()

@property (nonatomic) UIView *leftBorderView;
@property (nonatomic) NSMutableAttributedString *attrString;

@end


@implementation ShiftEventView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
		self.contentMode = UIViewContentModeRedraw;
		
		_color1 = [UIColor orangeColor];
        _color2 = [UIColor blueColor];
        _color3 = [UIColor greenColor];
        
        _title1 = @"kk";
        _title2 = @"aa";
        _title3 = @"hh";
        _style = (int)MGCStandardScheduleDefault;
		_leftBorderView = [[UIView alloc]initWithFrame:CGRectZero];
		[self addSubview:_leftBorderView];
	}
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	self.leftBorderView.frame = CGRectMake(0, 0, 2, self.bounds.size.height);
	[self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected
{
	[super setSelected:selected];
    // update khi click
}

- (void)setVisibleHeight:(CGFloat)visibleHeight
{
	[super setVisibleHeight:visibleHeight];
	[self setNeedsDisplay];
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	[self setNeedsDisplay];
}

-(BOOL) checkAllTitleNil{
    if(_title1 == nil && _title2 == nil && _title3 == nil)
        return true;
    return false;
}

-(BOOL) checkAllTitleNotNil{
    if(_title1 != nil && _title2 != nil && _title3 != nil)
        return true;
    return false;
}

- (void)drawRect:(CGRect)rect
{
    // draw
    CGFloat rectheight = rect.size.height;
    CGFloat rectWidth = rect.size.width;
    CGFloat rectChild = rectWidth / 3;
   
    if((int)_style == (int)MGCStandardScheduleAll){
        UIBezierPath *path1 = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, rectWidth, rectheight)];
        [self.color1 setFill];
        [path1 fill];
        NSAttributedString *attrStr1 = [[NSAttributedString alloc]initWithString:_title1 attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:10] }];
        [attrStr1 drawInRect:CGRectMake(rectWidth/2 - 5, rectheight/2 - 5, rectWidth, rectheight)];
    }
    
    if((int)_style == (int)MGCStandardScheduleOne){
        // cot 1 duoc gap doi
        UIBezierPath *path1 = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, rectChild*2, rectheight)];
        [self.color1 setFill];
        [path1 fill];
        
        NSAttributedString *attrStr1 = [[NSAttributedString alloc]initWithString:_title1 attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:10] }];
        [attrStr1 drawInRect:CGRectMake(rectChild/2 + 5, rectheight/2 - 5, rectChild, rectheight)];
        
        if(_title2 != nil){
            UIBezierPath *path2 = [UIBezierPath bezierPathWithRect:CGRectMake(rectChild*2, 0, rectChild, rectheight)];
            [self.color2 setFill];
            [path2 fill];
            
            NSAttributedString *attrStr2 = [[NSAttributedString alloc]initWithString:_title2 attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:10] }];
            [attrStr2 drawInRect:CGRectMake(2*rectChild + 5,rectheight/2 - 5, rectChild, rectheight)];
        }
    }
    if((int)_style == (int)MGCStandardScheduleThree){
        // cot 3 duoc gap doi
        UIBezierPath *path2 = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, rectChild, rectheight)];
        [self.color2 setFill];
        [path2 fill];
        
      
        
        NSAttributedString *attrStr2 = [[NSAttributedString alloc]initWithString:_title2 attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:10] }];
        [attrStr2 drawInRect:CGRectMake(0 + 5, rectheight/2 - 5, rectChild, rectheight)];
        
        if(_title3 != nil){
            UIBezierPath *path3 = [UIBezierPath bezierPathWithRect:CGRectMake(rectChild,0 , rectChild*2, rectheight)];
            [self.color3 setFill];
            [path3 fill];
            
            NSAttributedString *attrStr3 = [[NSAttributedString alloc]initWithString:_title3 attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:10] }];
            [attrStr3 drawInRect:CGRectMake(rectChild + rectChild/2 + 5, rectheight/2 - 5 , rectChild, rectheight)];
        }
    }
    
    if((int)_style == (int)MGCStandardScheduleDefault){
        if(_title1!=nil ){
            UIBezierPath *path1 = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, rectChild, rectheight)];
            [self.color1 setFill];
            [path1 fill];
            
            NSAttributedString *attrStr1 = [[NSAttributedString alloc]initWithString:_title1 attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:10] }];
            [attrStr1 drawInRect:CGRectMake(0 + 5, rectheight/2 - 5, rectChild, rectheight)];
        }
        
        if(_title2!=nil){
            UIBezierPath *path2 = [UIBezierPath bezierPathWithRect:CGRectMake(rectChild,0 , rectChild, rectheight)];
            [self.color2 setFill];
            [path2 fill];
            
            NSAttributedString *attrStr2 = [[NSAttributedString alloc]initWithString:_title2 attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:10] }];
            [attrStr2 drawInRect:CGRectMake(rectChild + 5, rectheight/2 - 5 , rectChild, rectheight)];
        }
        
        if(_title3!=nil){
            UIBezierPath *path3 = [UIBezierPath bezierPathWithRect:CGRectMake(rectChild*2, 0, rectChild, rectheight)];
            [self.color3 setFill];
            [path3 fill];
            NSAttributedString *attrStr3 = [[NSAttributedString alloc]initWithString:_title3 attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:10] }];
            [attrStr3 drawInRect:CGRectMake(2*rectChild + 5,rectheight/2 - 5, rectChild, rectheight)];
        }
    }
}

#pragma mark - NSCopying protocol

- (id)copyWithZone:(NSZone *)zone
{
    ShiftEventView *cell = [super copyWithZone:zone];
    cell.title1 = self.title1;
    cell.title2 = self.title2;
    cell.title3 = self.title3;
    cell.color1 = self.color1;
    cell.color2 = self.color2;
    cell.color3 = self.color3;
    return cell;
}

@end
