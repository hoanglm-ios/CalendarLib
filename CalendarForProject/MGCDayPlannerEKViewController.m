//
//  MGCDayPlannerEKViewController.m
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

#import "MGCDayPlannerEKViewController.h"
#import "MGCStandardEventView.h"
#import "NSCalendar+MGCAdditions.h"
#import "MGCDateRange.h"
#import "OSCache.h"


typedef enum {
    TimedEventType = 1,
    AllDayEventType = 2,
    AnyEventType = TimedEventType|AllDayEventType
} EventType;


static const NSUInteger cacheSize = 400;	// size of the cache (in days)
static NSString* const EventCellReuseIdentifier = @"EventCellReuseIdentifier";


@interface MGCDayPlannerEKViewController ()

@property (nonatomic) dispatch_queue_t bgQueue;			// dispatch queue for loading events
@property (nonatomic) NSMutableOrderedSet *daysToLoad;	// dates for months of which we want to load events
@property (nonatomic) NSCache *eventsCache; // save events with key == date and value = ObjectEvent
@property (nonatomic) NSUInteger createdEventType;
@property (nonatomic, copy) NSDate *createdEventDate;
@end


@implementation MGCDayPlannerEKViewController

@synthesize calendar = _calendar;

- (MGCDayPlannerView*)dayPlannerView
{
    return (MGCDayPlannerView*)self.view;
}

- (void)setDayPlannerView:(MGCDayPlannerView*)dayPlannerView
{
    [super setView:dayPlannerView];
    
    if (!dayPlannerView.dataSource)
        dayPlannerView.dataSource = self;
    
    if (!dayPlannerView.delegate)
        dayPlannerView.delegate = self;
}

- (void)loadView
{
    MGCDayPlannerView *dayPlannerView = [[MGCDayPlannerView alloc]initWithFrame:CGRectZero];
    dayPlannerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.dayPlannerView = dayPlannerView;
    self.dayPlannerView.autoresizesSubviews = YES;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.dayPlannerView.visibleDays.start = [NSDate date];
}

- (void)reloadEvents
{
    for (NSDate *date in self.daysToLoad) {
        [self.dayPlannerView setActivityIndicatorVisible:NO forDate:date];
    }
    [self.daysToLoad removeAllObjects];

    [self.eventsCache removeAllObjects];
    [self fetchEventsInDateRange:self.dayPlannerView.visibleDays];
    [self.dayPlannerView reloadAllEvents];
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.eventsCache = [[OSCache alloc]init];
    self.eventsCache.countLimit = cacheSize;
    
    self.bgQueue = dispatch_queue_create("MGCDayPlannerEKViewController.bgQueue", NULL);
    
    self.dayPlannerView.calendar = self.calendar;
    [self.dayPlannerView registerClass:MGCStandardEventView.class forEventViewWithReuseIdentifier:EventCellReuseIdentifier];
//    self.dayPlannerView.sizeEventInSection = self.arrSize;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSDate* now = [NSDate date];
    NSDictionary *dicOne = @{@"title":@"Ana",@"image":@"ic_female"};
    NSDictionary *dicTwo = @{@"title":@"Ana",@"image":@"ic_female"};
    for(int i=1;i<=10;i++){
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        switch (i%3) {
            case 0:
                dicOne = @{@"title":[NSString stringWithFormat:@"Ana %d",i],@"image":@"ic_female"};
                dicTwo = @{@"title":@"Ana",@"image":@"ic_female"};
                [arr addObject:dicOne];
                [arr addObject:dicTwo];
                [dic setObject:arr forKey:now];
                break;
            case 1:
                dicOne = @{@"title":[NSString stringWithFormat:@"Ana %d",i],@"image":@"ic_female"};
                [arr addObject:dicOne];
                [dic setObject:arr forKey:now];
                break;
            default:
                break;
        }
        now = [self.calendar mgc_nextStartOfDayForDate:now];
    }
    self.dayPlannerView.listHeaderCell = dic;
    [self reloadEvents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Properties

- (NSCalendar*)calendar
{
    if (_calendar == nil) {
        _calendar = [NSCalendar currentCalendar];
    }
    return _calendar;
}

- (void)setCalendar:(NSCalendar*)calendar
{
    _calendar = calendar;
    self.dayPlannerView.calendar = calendar;
}

- (void)setVisibleCalendars:(NSSet*)visibleCalendars
{
    _visibleCalendars = visibleCalendars;
    [self.dayPlannerView reloadAllEvents];
}

#pragma mark - Loading events

- (void)fetchEventsInDateRange:(MGCDateRange*)range
{
    range.start = [self.calendar mgc_startOfDayForDate:range.start];
    range.end = [self.calendar mgc_nextStartOfDayForDate:range.end];
    // duyet cac ngay trong khoang start den end => sao do day vao queue load
}

// returns the events dictionary for given date
// try to load it from the cache, or create it if needed
- (NSArray*)eventsForDay:(NSDate*)date
{
    NSDate *dayStart = [self.calendar mgc_startOfDayForDate:date];

    NSArray *events = [self.eventsCache objectForKey:dayStart];

    if (!events) {  // cache miss: create dictionary...
        NSDate *dayEnd = [self.calendar mgc_nextStartOfDayForDate:dayStart];
         // load api trong day
        events = [self callApiWithStartDate:dayStart withEndDate:dayEnd];
        if(events)
            [self.eventsCache setObject:events forKey:dayStart];
    }

    return events;
}

-(NSArray*) callApiWithStartDate:(NSDate*) startDate withEndDate:(NSDate*) endDate{
//    if (self.eventStore && [self.eventStore respondsToSelector:@selector(fetchEventsFrom:to:)]) {
//        return [self.eventStore fetchEventsFrom:startDate to:endDate];
//    }
//    //    NSLog(@"*****warning: fetchEventsFrom:to: has to implemented in MonthPlannerViewController subclasses.");
//    return nil;
    return nil;
}

- (void)bg_loadEventsAtDate:(NSDate*)date
{
    //NSLog(@"bg_loadEventsAtDate: %@", date);

    NSDate *dayStart = [self.calendar mgc_startOfDayForDate:date];

    NSArray *listDate = [self eventsForDay:date];

    dispatch_async(dispatch_get_main_queue(), ^{
        if(listDate){
            [self.dayPlannerView reloadEventsAtDate:date];
            [self.dayPlannerView setActivityIndicatorVisible:NO forDate:dayStart];
        }
    });
}

- (void)bg_loadOneDay
{
    __block NSDate *date;

    dispatch_sync(dispatch_get_main_queue(), ^{
        if ((date = [self.daysToLoad firstObject])) {
            [self.daysToLoad removeObject:date];
        }

        if (![self.dayPlannerView.visibleDays containsDate:date]) {
            date = nil;
        }
    });

    if (date) {
        [self bg_loadEventsAtDate:date];
    }
}

- (BOOL)loadEventsAtDate:(NSDate*)date
{
    NSDate *dayStart = [self.calendar mgc_startOfDayForDate:date];

    if (![self.eventsCache objectForKey:dayStart]) {
        [self.dayPlannerView setActivityIndicatorVisible:YES forDate:dayStart];

        if (!self.daysToLoad) {
            self.daysToLoad = [NSMutableOrderedSet orderedSet];
        }

        [self.daysToLoad addObject:dayStart];

        dispatch_async(self.bgQueue, ^{    [self bg_loadOneDay]; });

        return YES;
    }
    return NO;
}

#pragma mark - MGCDayPlannerViewDataSource

- (MGCEventView*)dayPlannerView:(MGCDayPlannerView*)view viewForEventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date
{
    MGCStandardEventView *evCell = (MGCStandardEventView*)[view dequeueReusableViewWithIdentifier:EventCellReuseIdentifier forEventOfType:type atIndex:index date:date];
    evCell.backgroundColor = [UIColor whiteColor];
    switch (index%4) {
        case 0:
            evCell.style = MGCStandardScheduleDefault;
            evCell.title1 = @"hh";
            evCell.title2 = @"aa";
            evCell.title3 = @"kk";
            break;
        case 1:
            evCell.style = MGCStandardScheduleOne;
            evCell.title1 = @"ah";
            evCell.title2 = nil;
            break;
        case 2:
            evCell.style = MGCStandardScheduleThree;
            evCell.title2 = @"aa";
            evCell.title3 = @"kk";
            break;
        default:
            evCell.style = MGCStandardScheduleAll;
            evCell.title1 = @"ah";
            break;
    }
   
    return evCell;
}


#pragma mark - MGCDayPlannerViewDelegate

- (void)dayPlannerView:(MGCDayPlannerView*)view didSelectEventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date{
    // doi mau 2 cai kia la ok
    [self.dayPlannerView changeClick:index withDate:date];
}

- (void)dayPlannerView:(MGCDayPlannerView*)view willDisplayDate:(NSDate*)date
{
//    NSLog(@"will display %@", date);
    BOOL loading = [self loadEventsAtDate:date];
    if (!loading) {
        [self.dayPlannerView setActivityIndicatorVisible:NO forDate:date];
    }
}

- (void)dayPlannerView:(MGCDayPlannerView*)view didEndDisplayingDate:(NSDate*)date
{
//    NSLog(@"did end displaying %@", date);
    [self.daysToLoad removeObject:date];
}

- (NSAttributedString*)dayPlannerView:(MGCDayPlannerView *)view attributedStringForDayHeaderAtDate:(NSDate *)date
{
    
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"eee d";
    }
    
    NSString *dayStr = [dateFormatter stringFromDate:date];
    
    UIFont *font = [UIFont systemFontOfSize:15];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:dayStr attributes:@{ NSFontAttributeName: font }];
    
    NSMutableParagraphStyle *para = [NSMutableParagraphStyle new];
    para.alignment = NSTextAlignmentCenter;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:para range:NSMakeRange(0, attrStr.length)];
    
    return attrStr;
}

- (NSInteger)dayPlannerView:(MGCDayPlannerView *)view numberOfDimmedTimeRangesAtDate:(NSDate *)date{
    return [self.calendar isDateInWeekend:date] ? 1 : 2;
}

- (MGCDateRange*)dayPlannerView:(MGCDayPlannerView *)view dimmedTimeRangeAtIndex:(NSUInteger)index date:(NSDate *)date
{
    NSDate *start, *end;
    
    if ([self.calendar isDateInWeekend:date] || index == 0) {
        start = [self.calendar dateBySettingHour:0 minute:0 second:0 ofDate:date options:0];
    }
    else {
        start = [self.calendar dateBySettingHour:19 minute:0 second:0 ofDate:date options:0];
    }
    
    if ([self.calendar isDateInWeekend:date] || index == 1) {
        end = [self.calendar dateBySettingHour:23 minute:59 second:0 ofDate:date options:0];
    }
    else {
        end = [self.calendar dateBySettingHour:8 minute:59 second:0 ofDate:date options:0];
    }
    return [MGCDateRange dateRangeWithStart:start end:end];
}

-(NSAttributedString*) dayPlannerViewAttributedStringMark:(MGCDayPlannerView *)view withIndex:(NSInteger)index{
    UIFont *font = [UIFont fontWithName:@"Palatino-Roman" size:12.0];
    NSAttributedString *attrStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"row %ld",(long)index] attributes:@{ NSFontAttributeName: font }];
    return attrStr;
}
-(NSAttributedString*) dayPlannerViewAttribuedStringBagde:(MGCDayPlannerView *)view withIndex:(NSInteger)index{
    UIFont *font = [UIFont fontWithName:@"Palatino-Roman" size:8.0];
    NSAttributedString *attrStr = nil;
    switch (index%3) {
        case 0:
            attrStr = [[NSAttributedString alloc]initWithString:@"AT" attributes:@{ NSFontAttributeName: font,NSBackgroundColorAttributeName:[UIColor redColor]}];
            break;
        case 1:
            attrStr = [[NSAttributedString alloc]initWithString:@"AT" attributes:@{ NSFontAttributeName: font,NSBackgroundColorAttributeName:[UIColor greenColor]}];
            break;
        default:
            attrStr = [[NSAttributedString alloc]initWithString:@"AT" attributes:@{ NSFontAttributeName: font,NSBackgroundColorAttributeName:[UIColor yellowColor]}];
            break;
    }
    
    return attrStr;
}

- (void)dayPlannerViewLoadMore:(MGCDayPlannerView*)view{
    if (@available(iOS 10.0, *)) {
        [NSTimer scheduledTimerWithTimeInterval:2 repeats:false block:^(NSTimer * _Nonnull timer) {
            // call api self.dayPlannerView.visibleDays
            [self.dayPlannerView hideLoadMore];
            [self.dayPlannerView setSizeEventInSection:60];
            [self.dayPlannerView reloadAllEvents];
            self.dayPlannerView.isLimitLoadMore = YES;
        }];
    }
}

- (NSAttributedString*)dayPlannerViewttributedStringGuest:(MGCDayPlannerView*)view withIndex:(NSInteger) index{
    
    if(index == 4){
        UIFont *font = [UIFont fontWithName:@"Palatino-Roman" size:8.0];
        NSAttributedString *attrStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"row %ld",(long)index] attributes:@{ NSFontAttributeName: font }];
        return attrStr;
    }
    return nil;
}

- (void)dayPlannerViewClickButtonSelect{
    NSLog(@"Click ne");
}
@end

