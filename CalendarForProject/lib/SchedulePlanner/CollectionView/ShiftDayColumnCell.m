//
//  ShiftDayColumnCell.m
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

#import "ShiftDayColumnCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ShiftDayColumnCell ()

@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) CAShapeLayer *dotLayer;
@property (nonatomic) CALayer *leftBorder;
@property (nonatomic) CGFloat headerHeight;                                // height of the header
@property (nonatomic) NSMutableArray *arr;
@end


@implementation ShiftDayColumnCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
		_markColor = [UIColor blackColor];
        _separatorColor = [UIColor lightGrayColor];
		
        _fontSizeNameDay = 12;
        _heightHeaderDayCell = 28;
        _maxCellVisible = 2;
        _listHeaderCell = [[NSDictionary alloc] init];
        _headerHeight = _maxCellVisible*_heightHeaderDayCell + _fontSizeNameDay+2+10; // 10 is height UIStackView
        _indexColor = [UIColor greenColor];
        _normalColor = [UIColor whiteColor];
        _arr = [[NSMutableArray alloc] init];
        
        _viewShowClick  = [[UIView alloc] init];
        [self.contentView addSubview:_viewShowClick];
        
		_dayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_dayLabel.numberOfLines = 0;
		_dayLabel.adjustsFontSizeToFitWidth = YES;
		_dayLabel.minimumScaleFactor = .7;
        _dayLabel.textColor = [UIColor redColor];
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        _dayLabel.layer.borderColor = [UIColor grayColor].CGColor;
        
		[self.contentView addSubview:_dayLabel];
        _viewContannerTableView = [[UIView alloc] init];
        
        _stackTable = [[UIView alloc] init];
        [_viewContannerTableView addSubview:_stackTable];
        
        [self.contentView addSubview:_viewContannerTableView];
        _viewContannerTableView.layer.borderColor = [UIColor grayColor].CGColor;
        _viewContannerTableView.layer.borderWidth = 0.5;
		
        //create three morning, afternoon, evening
        UILabel *morning = [[UILabel alloc] init];
        [morning setText:@"SS"];
        [morning setFont:[UIFont systemFontOfSize:8]];
        morning.textColor = [UIColor redColor];
        morning.textAlignment = NSTextAlignmentCenter;
        morning.layer.borderColor = [UIColor grayColor].CGColor;
        morning.layer.borderWidth = 0.5;
        
        UILabel *afternoon = [[UILabel alloc] init];
        [afternoon setText:@"CC"];
        [afternoon setFont:[UIFont systemFontOfSize:8]];
        afternoon.textAlignment = NSTextAlignmentCenter;
        afternoon.layer.borderColor = [UIColor grayColor].CGColor;
        afternoon.layer.borderWidth = 0.5;
        
        UILabel *evening = [[UILabel alloc] init];
        [evening setText:@"TT"];
        [evening setFont:[UIFont systemFontOfSize:8]];
        evening.textAlignment = NSTextAlignmentCenter;
        evening.layer.borderColor = [UIColor grayColor].CGColor;
        evening.layer.borderWidth = 0.5;
        
        if (@available(iOS 9.0, *)) {
            [morning.widthAnchor constraintEqualToConstant:self.contentView.bounds.size.width/3].active = true;
            [afternoon.widthAnchor constraintEqualToConstant:self.contentView.bounds.size.width/3].active = true;
            [evening.widthAnchor constraintEqualToConstant:self.contentView.bounds.size.width/3].active = true;
            
            _stackView = [[UIStackView alloc] init];
            [_stackView addArrangedSubview:morning];
            [_stackView addArrangedSubview:afternoon];
            [_stackView addArrangedSubview:evening];
            [self.contentView addSubview:_stackView];
        }
        
        _leftBorder = [CALayer layer];
        [self.contentView.layer addSublayer:_leftBorder];
	}
    return self;
}

- (void)setActivityIndicatorVisible:(BOOL)visible
{
    if (!visible) {
        [self.activityIndicatorView stopAnimating];
    }
    else if (self.headerHeight > 0) {
        if (!self.activityIndicatorView) {
            self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.activityIndicatorView.color = [UIColor blackColor];
            self.activityIndicatorView.transform = CGAffineTransformMakeScale(0.6, 0.6);
            [self.contentView addSubview:self.activityIndicatorView];
        }
        [self.activityIndicatorView startAnimating];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.accessoryTypes = ShiftDayColumnCellAccessoryNone;
    self.markColor = [UIColor blackColor];
    [self setActivityIndicatorVisible:NO];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    
	[CATransaction begin];
	[CATransaction setDisableActions:YES];

    _headerHeight = _maxCellVisible*_heightHeaderDayCell + _fontSizeNameDay+2+10;
	if (self.headerHeight != 0) {
		CGSize headerSize = CGSizeMake(self.contentView.bounds.size.width, self.headerHeight);
        self.viewShowClick.frame =  CGRectMake(0, 0, headerSize.width, self.headerHeight - 10);
        if([_currentDate isEqual:self.indexDate]){
            self.viewShowClick.backgroundColor = self.indexColor;
        }else{
             self.viewShowClick.backgroundColor = self.normalColor;
        }
        self.arr = [_listHeaderCell objectForKey:self.currentDate];
        if(!self.arr)
            self.arr = [[NSMutableArray alloc] init];
		CGSize labelSize = CGSizeMake(headerSize.width, _fontSizeNameDay);
		self.dayLabel.frame = (CGRect) { 0, 0, labelSize };
        //table view
        if(_maxCellVisible > 0){
             self.viewContannerTableView.frame = (CGRect) {0,_fontSizeNameDay,headerSize.width,self.headerHeight - 10 - _fontSizeNameDay};
            if(_arr.count  == 1)
                 _stackTable.frame = CGRectMake(0, _viewContannerTableView.frame.size.height/2 - _heightHeaderDayCell/2, _viewContannerTableView.frame.size.width, _viewContannerTableView.frame.size.height);
            else
                 _stackTable.frame = CGRectMake(0, 0, _viewContannerTableView.frame.size.width, _viewContannerTableView.frame.size.height);
            [_stackTable.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];

            for(int i=0;i<self.arr.count;i++){
                NSDictionary *dic = [self.arr objectAtIndex:i];
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, i*_heightHeaderDayCell, _stackTable.frame.size.width,_heightHeaderDayCell )];

                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 3, _heightHeaderDayCell - 10, _heightHeaderDayCell - 10)];
                [view addSubview:imgView];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_heightHeaderDayCell - 10, 0, _stackTable.frame.size.width - _heightHeaderDayCell + 10,_heightHeaderDayCell )];
                [view addSubview:label];
                [label setText:[dic valueForKey:@"title"]];
                [label setFont:[UIFont fontWithName:@"Palatino-Roman" size:10]];
                [imgView setImage:[UIImage imageNamed:[dic valueForKey:@"image"]]];
                [_stackTable addSubview:view];
            }
            
        }else{
             [_stackTable.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
             self.viewContannerTableView.frame = CGRectZero;
             self.stackTable.frame = CGRectZero;
        }
        
        //uiStackView
        CGSize stackSize = CGSizeMake(self.contentView.bounds.size.width, 10);
        self.stackView.frame = (CGRect) { 0, self.headerHeight - 10, stackSize };
	}
	self.dayLabel.hidden = (self.headerHeight == 0);

    // border
    CGRect borderFrame = CGRectZero;
    if (self.accessoryTypes & ShiftDayColumnCellAccessoryBorder) {
        borderFrame = CGRectMake(0, self.headerHeight, 1./[UIScreen mainScreen].scale, self.contentView.bounds.size.height-self.headerHeight);
    }
    else if (self.accessoryTypes & ShiftDayColumnCellAccessorySeparator) {
        borderFrame = CGRectMake(0, 0, 2./[UIScreen mainScreen].scale, self.contentView.bounds.size.height);
    }

    self.leftBorder.frame = borderFrame;
    self.leftBorder.borderColor = self.separatorColor.CGColor;
    self.leftBorder.borderWidth = borderFrame.size.width / 2.;


    [CATransaction commit];
    
}

- (void)setAccessoryTypes:(ShiftDayColumnCellAccessoryType)accessoryTypes
{
    _accessoryTypes = accessoryTypes;
    [self setNeedsLayout];
}

@end
