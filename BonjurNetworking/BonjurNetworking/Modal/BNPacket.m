//
//  BNPacket.m
//  BonjurNetworking
//
//  Created by Rahul Singh on 9/30/13.
//  Copyright (c) 2013 Creativeappz. All rights reserved.
//

#import "BNPacket.h"

NSString * const MTPacketKeyData = @"data";
NSString * const MTPacketKeyType = @"type";
NSString * const MTPacketKeyAction = @"action";

@implementation BNPacket
#pragma mark -
#pragma mark Initialization
- (id)initWithData:(id)data type:(MTPacketType)type action:(MTPacketAction)action {
    self = [super init];
    if (self) {
        self.data = data;
        self.type = type;
        self.action = action;
    }
    return self;
}
#pragma mark -
#pragma mark NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.data forKey:MTPacketKeyData];
    [coder encodeInteger:self.type forKey:MTPacketKeyType];
    [coder encodeInteger:self.action forKey:MTPacketKeyAction];
}
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        [self setData:[decoder decodeObjectForKey:MTPacketKeyData]];
        [self setType:[decoder decodeIntegerForKey:MTPacketKeyType]];
        [self setAction:[decoder decodeIntegerForKey:MTPacketKeyAction]];
    }
    return self;
}
@end
