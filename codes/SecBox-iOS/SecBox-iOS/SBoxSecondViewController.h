//
//  SBoxSecondViewController.h
//  SecBox-iOS
//
//  Created by Zimmer on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBoxSecondViewController : UIViewController <UITableViewDataSource,UITableViewDelegate> {
	NSArray *_list;
}
@property (retain, nonatomic) IBOutlet UIImageView *imageView;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)fresh:(id)sender;

@end
