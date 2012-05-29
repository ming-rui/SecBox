//
//  SBoxFirstViewController.m
//  SecBox-iOS
//
//  Created by Zimmer on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SBoxFirstViewController.h"
#import "SBoxFileSystem.h"
#import "SBoxConfigs.h"

@interface SBoxFirstViewController ()

@end

@implementation SBoxFirstViewController
@synthesize accountType;
@synthesize encryptionPassword;
@synthesize encryptionUserName;
@synthesize accountPassword;
@synthesize accountUserName;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	SBoxConfigs *configs = [SBoxConfigs sharedConfigs];
	[accountType setOn:([configs accountType]==1)];
	[accountUserName setText:[configs accountUserName]];
	[accountPassword setText:[configs accountPassword]];
	[encryptionUserName setText:[configs encryptionUserName]];
	[encryptionPassword setText:[configs encryptionPassword]];
}

- (void)viewDidUnload
{
    [self setAccountUserName:nil];
    [self setAccountPassword:nil];
    [self setEncryptionUserName:nil];
    [self setEncryptionPassword:nil];
    [self setAccountType:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    [accountUserName release];
    [accountPassword release];
    [encryptionUserName release];
    [encryptionPassword release];
    [accountType release];
    [super dealloc];
}
- (IBAction)save:(id)sender {
	SBoxAccountType accType = [accountType isOn]?1:0;
	NSString *accUserName = [accountUserName text];
	NSString *accPassword = [accountPassword text];
	NSString *encUserName = [encryptionUserName text];
	NSString *encPassword = [encryptionPassword text];
	
	[[SBoxFileSystem sharedSystem] setAccountInfoWithAccountType:accType userName:accUserName password:accPassword];
	[[SBoxFileSystem sharedSystem] setEncryptionInfoWithUserName:encUserName password:encPassword];
	
	[[SBoxFileSystem sharedSystem] saveConfigs];
}
- (IBAction)textFieldDidEndOnExit:(id)sender {
	[sender resignFirstResponder];
}
@end
