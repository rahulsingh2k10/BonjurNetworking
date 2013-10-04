//
//  BNPacket.h
//  BonjurNetworking
//
//  Created by Rahul Singh on 9/30/13.
//  Copyright (c) 2013 Creativeappz. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const MTPacketKeyData;
extern NSString * const MTPacketKeyType;
extern NSString * const MTPacketKeyAction;

typedef enum {
    MTPacketTypeUnknown = -1
} MTPacketType;

typedef enum {
    MTPacketActionUnknown = -1
} MTPacketAction;

@interface BNPacket : NSObject <NSCoding>
@property (strong, nonatomic) id data;
@property (assign, nonatomic) MTPacketType type;
@property (assign, nonatomic) MTPacketAction action;

- (id)initWithData:(id)data type:(MTPacketType)type action:(MTPacketAction)action;

@end
