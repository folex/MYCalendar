//
//  DatePickPopoverContent.h
//  MYCalendar
//
//  Created by Alexey on 23.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickPopoverContent : UIViewController
{
    UIButton *_onChangeButton;
}
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UIDatePicker *picker;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *endButton;
@property (weak, nonatomic) IBOutlet UIButton *setDateButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)savePickedData:(id)sender;
- (IBAction) cancelPicking:(id)sender;
- (IBAction) showDatePicker:(id)sender;
- (IBAction) SetOnChangeButton: (UIButton*) button;
- (IBAction) dateSelected: (UIDatePicker*) sender;
@end
