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
#import "MGCEventKitSupport.h"


typedef enum {
    TimedEventType = 1,
    AllDayEventType = 2,
    AnyEventType = TimedEventType|AllDayEventType
} EventType;


static const NSUInteger cacheSize = 400;	// size of the cache (in days)
static NSString* const EventCellReuseIdentifier = @"EventCellReuseIdentifier";


@interface MGCDayPlannerEKViewController ()

@property (nonatomic) MGCEventKitSupport *eventKitSupport;
@property (nonatomic) dispatch_queue_t bgQueue;			// dispatch queue for loading events
@property (nonatomic) NSMutableOrderedSet *daysToLoad;	// dates for months of which we want to load events
@property (nonatomic) NSCache *eventsCache;
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


- (instancetype)initWithEventStore:(EKEventStore*)eventStore
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _eventKitSupport = [[MGCEventKitSupport alloc]initWithEventStore:eventStore];
    }
    return self;
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

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    return [self initWithEventStore:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadEvents) name:EKEventStoreChangedNotification object:self.eventStore];
    
    self.eventsCache = [[OSCache alloc]init];
    self.eventsCache.countLimit = cacheSize;
    //self.eventsCache.delegate = self;
    
    self.bgQueue = dispatch_queue_create("MGCDayPlannerEKViewController.bgQueue", NULL);
    
    [self.eventKitSupport checkEventStoreAccessForCalendar:^(BOOL granted) {
        if (granted) {
            NSArray *calendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
            self.visibleCalendars = [NSSet setWithArray:calendars];
            [self reloadEvents];
        }
    }];
    
    
    self.dayPlannerView.calendar = self.calendar;
    [self.dayPlannerView registerClass:MGCStandardEventView.class forEventViewWithReuseIdentifier:EventCellReuseIdentifier];
//    self.dayPlannerView.sizeEventInSection = self.arrSize;
    // change backgroud color in header
//    self.dayPlannerView.backgroundColor = [UIColor lightGrayColor];
//    self.dayPlannerView.backgroundView = [UIView new];
//    self.dayPlannerView.backgroundView.backgroundColor = [UIColor whiteColor];
    
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
        [self fetchEventsInDate:now];
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

- (EKEventStore*)eventStore
{
    return self.eventKitSupport.eventStore;
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
    
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for(int i = 1;i<=10;i++){
        [events addObject:[NSString stringWithFormat:@"haha"]];
    }
    [self.eventsCache setObject:events forKey:range.start];
    [self.eventsCache setObject:events forKey:range.end];
//    [range enumerateDaysWithCalendar:self.calendar usingBlock:^(NSDate *date, BOOL *stop) {
//        NSDate *dayEnd = [self.calendar mgc_nextStartOfDayForDate:date];
//        NSArray *events = [self fetchEventsFrom:date to:dayEnd calendars:nil];
//        [self.eventsCache setObject:events forKey:date];
//    }];
    
}

- (void)fetchEventsInDate:(NSDate*)range
{
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for(int i = 1;i<=10;i++){
        [events addObject:[NSString stringWithFormat:@"haha"]];
    }
    [self.eventsCache setObject:events forKey:range];
}

- (NSArray*)fetchEventsFrom:(NSDate*)startDate to:(NSDate*)endDate calendars:(NSArray*)calendars
{
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendars];

    if (self.eventKitSupport.accessGranted) {
        NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
        if (events) {
            return [events sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];
        }
    }

   
    return [NSArray array];
}

// returns the events dictionary for given date
// try to load it from the cache, or create it if needed
- (NSArray*)eventsForDay:(NSDate*)date
{
    NSDate *dayStart = [self.calendar mgc_startOfDayForDate:date];
    
    NSArray *events = [self.eventsCache objectForKey:dayStart];
    
    if (!events) {  // cache miss: create dictionary...
        NSDate *dayEnd = [self.calendar mgc_nextStartOfDayForDate:dayStart];
        events = [self fetchEventsFrom:dayStart to:dayEnd calendars:nil];
        [self.eventsCache setObject:events forKey:dayStart];
    }
    
    return events;
}

- (NSArray*)eventsOfType:(EventType)type forDay:(NSDate*)date
{
    NSArray *events = [self eventsForDay:date];
    
//    NSMutableArray *filteredEvents = [NSMutableArray new];
//    [events enumerateObjectsUsingBlock:^(EKEvent *ev, NSUInteger idx, BOOL *stop) {
//
//        if ([self.visibleCalendars containsObject:ev.calendar]) {
//            if (type & AllDayEventType && ev.isAllDay)
//                [filteredEvents addObject:ev];
//            else if (type & TimedEventType && !ev.isAllDay)
//                [filteredEvents addObject:ev];
//        }
//    }];
    
    return events;
}

- (EKEvent*)eventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date
{
    NSArray *events = nil;
    
//    if (type == MGCTimedEventType) {
//        events = [self eventsOfType:TimedEventType forDay:date];
//    }
    
    events = [self eventsOfType:TimedEventType forDay:date];
    
    return [events objectAtIndex:index];
}

- (void)bg_loadEventsAtDate:(NSDate*)date
{
    //NSLog(@"bg_loadEventsAtDate: %@", date);
    
    NSDate *dayStart = [self.calendar mgc_startOfDayForDate:date];
    
    [self eventsOfType:AnyEventType forDay:dayStart];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dayPlannerView reloadEventsAtDate:date];
        [self.dayPlannerView setActivityIndicatorVisible:NO forDate:dayStart];
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
        
        dispatch_async(self.bgQueue, ^{	[self bg_loadOneDay]; });
        
        return YES;
    }
    return NO;
}

#pragma mark - MGCDayPlannerViewDataSource

- (NSInteger)dayPlannerView:(MGCDayPlannerView*)weekView numberOfEventsOfType:(MGCEventType)type atDate:(NSDate*)date
{
    NSInteger count = 0;
    
    if (![self loadEventsAtDate:date]) {
        count = [[self eventsOfType:TimedEventType forDay:date]count];
    }
    return count;
}

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
            evCell.title2 = @"ke";
            break;
        case 2:
            evCell.style = MGCStandardScheduleThree;
            evCell.title2 = @"aa";
            evCell.title3 = @"kk";
        default:
            evCell.style = MGCStandardScheduleAll;
            evCell.title1 = @"ah";
            break;
    }
   
    return evCell;
}

#pragma mark - MGCDayPlannerViewDelegate

- (void)dayPlannerView:(MGCDayPlannerView*)view didSelectEventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date{
    NSLog(@"Index click: %ld date: %@",(long)index,date);
    // doi mau 2 cai kia la ok
    [self.dayPlannerView changeClick:index withDate:date];
}

- (void)dayPlannerView:(MGCDayPlannerView*)view willDisplayDate:(NSDate*)date
{
    //NSLog(@"will display %@", date);
    BOOL loading = [self loadEventsAtDate:date];
    if (!loading) {
        [self.dayPlannerView setActivityIndicatorVisible:NO forDate:date];
    }
}

- (void)dayPlannerView:(MGCDayPlannerView*)view didEndDisplayingDate:(NSDate*)date
{
    //NSLog(@"did end displaying %@", date);
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
@end

