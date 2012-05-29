//
//  SBoxFirstViewController.h
//  SecBox-iOS
//
//  Created by Zimmer on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBoxFirstViewController : UIViewController
- (IBAction)textFieldDidEndOnExit:(id)sender;

@property (retain, nonatomic) IBOutlet UISwitch *accountType;
@property (retain, nonatomic) IBOutlet UITextField *encryptionPassword;
@property (retain, nonatomic) IBOutlet UITextField *encryptionUserName;
@property (retain, nonatomic) IBOutlet UITextField *accountPassword;
@property (retain, nonatomic) IBOutlet UITextField *accountUserName;

- (IBAction)save:(id)sender;

@end
