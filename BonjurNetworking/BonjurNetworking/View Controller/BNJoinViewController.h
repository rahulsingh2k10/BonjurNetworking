//
//  BNJoinViewController.h
//  BonjurNetworking
//
//  Created by Rahul Singh on 9/30/13.
//  Copyright (c) 2013 Creativeappz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GCDAsyncSocket;
@protocol BNJoinViewControllerDelegate;

@interface BNJoinViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
- (IBAction)dismissViewController:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) id<BNJoinViewControllerDelegate> delegate;

@end

@protocol BNJoinViewControllerDelegate
    - (void)controller:(BNJoinViewController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket;
    - (void)controllerDidCancelJoining:(BNJoinViewController *)controller;
@end