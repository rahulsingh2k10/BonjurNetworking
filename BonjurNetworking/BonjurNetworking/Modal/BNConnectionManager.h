//
//  BNConnectionManager.h
//  BonjurNetworking
//
//  Created by Rahul Singh on 10/1/13.
//  Copyright (c) 2013 Creativeappz. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCDAsyncSocket;
@protocol BNConnectionManagerProtocol;

@interface BNConnectionManager : NSObject
@property (weak, nonatomic) id<BNConnectionManagerProtocol> delegate;

- (void)testConnection;
- (id)initWithSocket:(GCDAsyncSocket *)socket;
@end

@protocol BNConnectionManagerProtocol
    - (void)controllerDidDisconnect:(BNConnectionManager *)controller;
    - (void)dataParsed:(id)data;
@end