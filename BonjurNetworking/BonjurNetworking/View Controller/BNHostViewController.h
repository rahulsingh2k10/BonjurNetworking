//
//  BNHostViewController.h
//  BonjurNetworking
//
//  Created by Rahul Singh on 9/30/13.
//  Copyright (c) 2013 Creativeappz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCDAsyncSocket;
@protocol BNHostViewControllerProtocol;

@interface BNHostViewController : UIViewController
- (IBAction)dismissViewController:(id)sender;
@property (weak, nonatomic) id<BNHostViewControllerProtocol> delegate;
@end

@protocol BNHostViewControllerProtocol
    - (void)controller:(BNHostViewController *)controller didHostGameOnSocket:(GCDAsyncSocket *)socket;
    - (void)controllerDidCancelHosting:(BNHostViewController *)controller;
@end