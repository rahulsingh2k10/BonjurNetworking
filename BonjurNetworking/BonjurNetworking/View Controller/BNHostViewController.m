//
//  BNHostViewController.m
//  BonjurNetworking
//
//  Created by Rahul Singh on 9/30/13.
//  Copyright (c) 2013 Creativeappz. All rights reserved.
//

#import "BNHostViewController.h"
#import "GCDAsyncSocket.h"
#import "BNPacket.h"
typedef unsigned long long   uint64_t;
@interface BNHostViewController () <NSNetServiceDelegate,GCDAsyncSocketDelegate>

@property (strong, nonatomic) NSNetService *service;
@property (strong, nonatomic) GCDAsyncSocket *socket;

@end


@implementation BNHostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Start Broadcast
    [self startBroadcast];
}

- (void)startBroadcast {
    // Initialize GCDAsyncSocket
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    // Start Listening for Incoming Connections
    NSError *error = nil;
    if ([self.socket acceptOnPort:0 error:&error]) {
        // Initialize Service
        self.service = [[NSNetService alloc] initWithDomain:@"local." type:@"_bonjurnetwork._tcp." name:@"" port:[self.socket localPort]];
        // Configure Service
        [self.service setDelegate:self];
        // Publish Service
        [self.service publish];
    } else {
        NSLog(@"Unable to create socket. Error %@ with user info %@.", error, [error userInfo]);
    }
}

- (void)netServiceDidPublish:(NSNetService *)service {
    NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
}

- (void)netService:(NSNetService *)service didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@", [service domain], [service type], [service name], errorDict);
}

//- (void)socket:(GCDAsyncSocket *)socket didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
//    NSLog(@"Accepted New Socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
//    // Socket
//    [self setSocket:newSocket];
//    // Read Data from Socket
//    [newSocket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
//    // Create Packet
//    NSString *message = @"This is a proof of concept.";
//    BNPacket *packet = [[BNPacket alloc] initWithData:message type:0 action:0];
//    // Send Packet
//    [self sendPacket:packet];
//}

- (void)socket:(GCDAsyncSocket *)socket didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"Accepted New Socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
    // Notify Delegate
    [self.delegate controller:self didHostGameOnSocket:newSocket];
    // End Broadcast
    [self endBroadcast];
    // Dismiss View Controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)endBroadcast {
    if (self.socket) {
        [self.socket setDelegate:nil delegateQueue:NULL];
        [self setSocket:nil];
    }
    if (self.service) {
        [self.service setDelegate:nil];
        [self setService:nil];
    }
}


//- (void)sendPacket:(BNPacket *)packet {
//    // Encode Packet Data
//    NSMutableData *packetData = [[NSMutableData alloc] init];
//    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:packetData];
//    [archiver encodeObject:packet forKey:@"packet"];
//    [archiver finishEncoding];
//    // Initialize Buffer
//    NSMutableData *buffer = [[NSMutableData alloc] init];
//    // Fill Buffer
//    uint64_t headerLength = [packetData length];
//    [buffer appendBytes:&headerLength length:sizeof(uint64_t)];
//    [buffer appendBytes:[packetData bytes] length:[packetData length]];
//    // Write Buffer
//    [self.socket writeData:buffer withTimeout:-1.0 tag:0];
//}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (self.socket == socket) {
        [self.socket setDelegate:nil];
        [self setSocket:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissViewController:(id)sender {
    // Cancel Hosting Game
    [self.delegate controllerDidCancelHosting:self];
    // End Broadcast
    [self endBroadcast];
    // Dismiss View Controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    if (_delegate) {
        _delegate = nil;
    }
    if (_socket) {
        [_socket setDelegate:nil delegateQueue:NULL];
        _socket = nil;
    }
}

@end
