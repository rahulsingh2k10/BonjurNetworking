//
//  BNViewController.m
//  BonjurNetworking
//
//  Created by Rahul Singh on 9/30/13.
//  Copyright (c) 2013 Creativeappz. All rights reserved.
//

#import "BNViewController.h"
#import "BNHostViewController.h"
#import "BNJoinViewController.h"
#import "BNConnectionManager.h"

@interface BNViewController ()<BNHostViewControllerProtocol,BNJoinViewControllerDelegate,BNConnectionManagerProtocol>
@property (strong, nonatomic) BNConnectionManager *connectionManger;
@end

@implementation BNViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"HostSegue"]) {
        BNHostViewController *host = [segue destinationViewController];
        host.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"JoinHost"]) {
        BNJoinViewController *join = [segue destinationViewController];
        join.delegate = self;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // Hide Disconnect Button
    [self.disconnectButton setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Host Game View Controller Methods
- (void)controller:(BNHostViewController *)controller didHostGameOnSocket:(GCDAsyncSocket *)socket {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // Start Game with Socket
    [self startGameWithSocket:socket];

    // Test Connection
    [self.connectionManger testConnection];
    
}

- (void)controllerDidCancelHosting:(BNHostViewController *)controller {
    NSLog(@"%s", __PRETTY_FUNCTION__);

}

#pragma mark -
#pragma mark Join Game View Controller Methods

- (void)controller:(BNJoinViewController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // Start Game with Socket
    [self startGameWithSocket:socket];
}
- (void)controllerDidCancelJoining:(BNJoinViewController *)controller {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


- (void)startGameWithSocket:(GCDAsyncSocket *)socket {
    // Initialize Game Controller
    self.connectionManger = [[BNConnectionManager alloc] initWithSocket:socket];
    // Configure Game Controller
    [self.connectionManger setDelegate:self];
    
    // Hide/Show Buttons
    [self.hostButton setHidden:YES];
    [self.joinButton setHidden:YES];
    [self.disconnectButton setHidden:NO];
}

- (void)controllerDidDisconnect:(BNConnectionManager *)controller {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // End Game
    [self endGame];
}

- (void)endGame {
    // Clean Up
    [self.connectionManger setDelegate:nil];
    [self setConnectionManger:nil];

    // Hide/Show Buttons
    [self.hostButton setHidden:NO];
    [self.joinButton setHidden:NO];
    [self.disconnectButton setHidden:YES];
}

-(void) dataParsed:(id)data {
    self.imageView.image = (UIImage*)data;
}

- (IBAction)disconnectConnection:(id)sender {
    [self endGame];
}

@end
