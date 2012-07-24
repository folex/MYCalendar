//
//  Event.h
//  MYCalendar
//
//  Created by Alexey on 10.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSString * eventTitle;
@property (nonatomic, retain) NSNumber * startDate;
@property (nonatomic, retain) NSNumber * endDate;

@end
