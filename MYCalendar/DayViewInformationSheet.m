//
//  DayViewInformationSheet.m
//  MYCalendar
//
//  Created by Alexey on 12.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DayViewInformationSheet.h"

@implementation DayViewInformationSheet
@synthesize mainDateLabel;
@synthesize secondaryDateLabel;
@synthesize durationLabel;
@synthesize statusLabel;
@synthesize titleLabel;
@synthesize descriptionLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
