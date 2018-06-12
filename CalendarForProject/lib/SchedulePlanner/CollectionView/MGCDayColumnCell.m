//
//  MGCDayColumnCell.m
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

#import "MGCDayColumnCell.h"
#import <QuartzCore/QuartzCore.h>

@interface MGCDayColumnCell () <UITableViewDataSource>

@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) CAShapeLayer *dotLayer;
@property (nonatomic) CALayer *leftBorder;
@property (nonatomic) CGFloat headerHeight;                                // height of the header

@end


@implementation MGCDayColumnCell

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
        
        _viewShowClick  = [[UIView alloc] init];
        [self.contentView addSubview:_viewShowClick];
        
		_dayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_dayLabel.numberOfLines = 0;
		_dayLabel.adjustsFontSizeToFitWidth = YES;
		_dayLabel.minimumScaleFactor = .7;
        _dayLabel.textColor = [UIColor redColor];
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        _dayLabel.layer.borderColor = [UIColor grayColor].CGColor;
        
//        CALayer* layer = [_dayLabel layer];
//
//        CALayer *bottomBorder = [CALayer layer];
//        bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
//        bottomBorder.borderWidth = 0.5;
//        bottomBorder.frame = CGRectMake(-1, layer.frame.size.height-1, layer.frame.size.width, 1);
//        [bottomBorder setBorderColor:[UIColor blackColor].CGColor];
//        [layer addSublayer:bottomBorder];
        
		[self.contentView addSubview:_dayLabel];
        _viewContannerTableView = [[UIView alloc] init];
        
        _tableView = [[UITableView alloc] init];
        _tableView.rowHeight = 28;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.translatesAutoresizingMaskIntoConstraints = false;
        [_viewContannerTableView addSubview:_tableView];
        [_tableView.centerXAnchor constraintEqualToAnchor:_viewContannerTableView.centerXAnchor].active = YES;
        [_tableView.centerYAnchor constraintEqualToAnchor:_viewContannerTableView.centerYAnchor].active = YES;
        
        [self.contentView addSubview:_viewContannerTableView];
        [_tableView registerNib:[UINib nibWithNibName:@"HeaderDayColumCell" bundle:nil] forCellReuseIdentifier:@"cell"];
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
    
    self.accessoryTypes = MGCDayColumnCellAccessoryNone;
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
        
		CGSize labelSize = CGSizeMake(headerSize.width, _fontSizeNameDay);
		self.dayLabel.frame = (CGRect) { 0, 0, labelSize };
        //table view
        if(_maxCellVisible > 0){
            NSArray *arr = [_listHeaderCell objectForKey:self.currentDate];
            [self.tableView.widthAnchor constraintEqualToConstant:headerSize.width].active = YES;
            [self.tableView.heightAnchor constraintEqualToConstant:arr.count * _heightHeaderDayCell].active = YES;
            _tableView.dataSource = self;
            
             self.viewContannerTableView.frame = (CGRect) {0,_fontSizeNameDay,headerSize.width,self.headerHeight - 10 - _fontSizeNameDay};
        }
        //uiStackView
        CGSize stackSize = CGSizeMake(self.contentView.bounds.size.width, 10);
        self.stackView.frame = (CGRect) { 0, self.headerHeight - 10, stackSize };
	}
	self.dayLabel.hidden = (self.headerHeight == 0);

    // border
    CGRect borderFrame = CGRectZero;
    if (self.accessoryTypes & MGCDayColumnCellAccessoryBorder) {
        borderFrame = CGRectMake(0, self.headerHeight, 1./[UIScreen mainScreen].scale, self.contentView.bounds.size.height-self.headerHeight);
    }
    else if (self.accessoryTypes & MGCDayColumnCellAccessorySeparator) {
        borderFrame = CGRectMake(0, 0, 2./[UIScreen mainScreen].scale, self.contentView.bounds.size.height);
    }

    self.leftBorder.frame = borderFrame;
    self.leftBorder.borderColor = self.separatorColor.CGColor;
    self.leftBorder.borderWidth = borderFrame.size.width / 2.;


    [CATransaction commit];
}

- (void)setAccessoryTypes:(MGCDayColumnCellAccessoryType)accessoryTypes
{
    _accessoryTypes = accessoryTypes;
    [self setNeedsLayout];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    HeaderDayColumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSArray *arr = [_listHeaderCell objectForKey:self.currentDate];
    if(arr){
        NSDictionary *dic = [arr objectAtIndex:indexPath.row];
        cell.label.text = [dic objectForKey:@"title"];
        cell.label.textColor = [UIColor redColor];
        [cell.img setImage:[UIImage imageNamed:[dic objectForKey:@"image"]]];
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     NSArray *arr = [_listHeaderCell objectForKey:self.currentDate];
    if(arr.count>_maxCellVisible)
        return _maxCellVisible;
    return arr.count;
}

@end
