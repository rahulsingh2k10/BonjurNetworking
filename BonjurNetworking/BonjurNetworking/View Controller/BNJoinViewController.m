//
//  BNJoinViewController.m
//  BonjurNetworking
//
//  Created by Rahul Singh on 9/30/13.
//  Copyright (c) 2013 Creativeappz. All rights reserved.
//

#import "BNJoinViewController.h"
#import "BNPacket.h"

@interface BNJoinViewController () <GCDAsyncSocketDelegate,NSNetServiceDelegate,NSNetServiceBrowserDelegate>
@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;
@end

@implementation BNJoinViewController

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
	// Do any additional setup after loading the view.

    // Start Browsing
    [self startBrowsing];
}

- (void)startBrowsing {
    if (self.services) {
        [self.services removeAllObjects];
    } else {
        self.services = [[NSMutableArray alloc] init];
    }
    // Initialize Service Browser
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    // Configure Service Browser
    [self.serviceBrowser setDelegate:self];
    [self.serviceBrowser searchForServicesOfType:@"_bonjurnetwork._tcp." inDomain:@"local."];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    // Update Services
    [self.services addObject:service];
    if(!moreComing) {
        // Sort Services
        [self.services sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        // Update Table View
        [self.tableView reloadData];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    // Update Services
    [self.services removeObject:service];
    if(!moreComing) {
        // Update Table View
        [self.tableView reloadData];
    }
}

- (IBAction)dismissViewController:(id)sender {
    
    // Notify Delegate
    [self.delegate controllerDidCancelJoining:self];
    // Stop Browsing Services
    [self stopBrowsing];
    // Dismiss View Controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)serviceBrowser {
    [self stopBrowsing];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didNotSearch:(NSDictionary *)userInfo {
    [self stopBrowsing];
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

- (void)stopBrowsing {
    if (self.serviceBrowser) {
        [self.serviceBrowser stop];
        [self.serviceBrowser setDelegate:nil];
        [self setServiceBrowser:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.services ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ServiceCell = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ServiceCell];
    if (!cell) {
        // Initialize Table View Cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ServiceCell];
    }
    // Fetch Service
    NSNetService *service = [self.services objectAtIndex:[indexPath row]];
    // Configure Cell
    [cell.textLabel setText:[service name]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Fetch Service
    NSNetService *service = [self.services objectAtIndex:[indexPath row]];
    // Resolve Service
    [service setDelegate:self];
    [service resolveWithTimeout:30.0];
}

- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    [service setDelegate:nil];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    // Connect With Service
    if ([self connectWithService:service]) {
        NSLog(@"Did Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
    } else {
        NSLog(@"Unable to Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
    }
}

- (BOOL)connectWithService:(NSNetService *)service {
    BOOL _isConnected = NO;
    // Copy Service Addresses
    NSArray *addresses = [[service addresses] mutableCopy];
    if (!self.socket || ![self.socket isConnected]) {
        // Initialize Socket
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        // Connect
        while (!_isConnected && [addresses count]) {
            NSData *address = [addresses objectAtIndex:0];
            NSError *error = nil;
            if ([self.socket connectToAddress:address error:&error]) {
                _isConnected = YES;
            } else if (error) {
                NSLog(@"Unable to connect to address. Error %@ with user info %@.", error, [error userInfo]);
            }
        }
    } else {
        _isConnected = [self.socket isConnected];
    }
    return _isConnected;
}

//- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port {
//    NSLog(@"Socket Did Connect to Host: %@ Port: %hu", host, port);
//    // Start Reading
//    [socket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
//}

- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Socket Did Connect to Host: %@ Port: %hu", host, port);
    // Notify Delegate
    [self.delegate controller:self didJoinGameOnSocket:socket];
    // Stop Browsing
    [self stopBrowsing];
    // Dismiss View Controller
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    NSLog(@"Socket Did Disconnect with Error %@ with User Info %@.", error, [error userInfo]);
    [socket setDelegate:nil];
    [self setSocket:nil];
}

//- (void)socket:(GCDAsyncSocket *)socket didReadData:(NSData *)data withTag:(long)tag {
//    if (tag == 0) {
//        uint64_t bodyLength = [self parseHeader:data];
//        [socket readDataToLength:bodyLength withTimeout:-1.0 tag:1];
//    } else if (tag == 1) {
//        [self parseBody:data];
//        [socket readDataToLength:sizeof(uint64_t) withTimeout:30.0 tag:0];
//    }
//}

//- (uint64_t)parseHeader:(NSData *)data {
//    uint64_t headerLength = 0;
//    memcpy(&headerLength, [data bytes], sizeof(uint64_t));
//    return headerLength;
//}

//- (void)parseBody:(NSData *)data {
//    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//    BNPacket *packet = [unarchiver decodeObjectForKey:@"packet"];
//    [unarchiver finishDecoding];
//    NSLog(@"Packet Data > %@", packet.data);
//    NSLog(@"Packet Type > %i", packet.type);
//    NSLog(@"Packet Action > %i", packet.action);
//}

@end