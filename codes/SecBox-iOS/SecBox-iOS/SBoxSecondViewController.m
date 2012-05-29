//
//  SBoxSecondViewController.m
//  SecBox-iOS
//
//  Created by Zimmer on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SBoxSecondViewController.h"

#import "SBoxFileSystem.h"

@interface SBoxSecondViewController ()

@end

@implementation SBoxSecondViewController
@synthesize imageView;
@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
	[self setTableView:nil];
	[self setImageView:nil];
	[self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)fresh:(id)sender {
	[_list release];
	_list = nil;
	[[SBoxFileSystem sharedSystem] getNodesInCurrentDirectory:&_list sort:YES];
	[_list retain];
	
	[imageView removeFromSuperview];
	
	[tableView reloadData];
}
- (void)dealloc {
	[tableView release];
	[_list release];
	
	[imageView release];
	[imageView release];
	[super dealloc];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *string = [[_list objectAtIndex:[indexPath row]] name];
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leak"];
	cell.textLabel.text = string;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	SBFSNode *node = [_list objectAtIndex:[indexPath row]];
	if(![[[node name] pathExtension] isEqualToString:@"jpg"])
		return;
	
	SBoxFileSystem *system = [SBoxFileSystem sharedSystem];
	NSData *data = nil;
	[system getFile:&data withFilePath:[node path]];
	
	if(data==nil)
		return;
	
	[imageView setImage:[UIImage imageWithData:data]];
	
	[[self view] addSubview:imageView];
}

@end
