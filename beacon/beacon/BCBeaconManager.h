//
//  BCBeaconManager.h
//  beacon
//
//  Created by Zac Bowling on 1/4/14.
//  Copyright (c) 2014 Hackathon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum _BCBeaconType {
    BCBeaconTypeUnkown,
    BCBeaconTypePerson,
    BCBeaconTypeMarketing
} BCBeaconType;

@class PFObject;

@interface BCBeacon : NSObject

@property (strong, nonatomic, readonly) id<NSObject> identifier;

@property (strong, nonatomic, readonly) NSString *title;

@property (strong, nonatomic, readonly) NSString *subtitle;

@property (assign, nonatomic, readonly) BCBeaconType type;

@property (assign, nonatomic, readonly) NSTimeInterval lastSeen;

@property (assign, nonatomic, readonly) CLProximity proximity;

@property (strong, nonatomic, readonly) PFObject *profile;

@end

@interface BCBeaconManager : NSObject

+(BCBeaconManager *)sharedManager;

@property (strong, readonly) NSArray *beacons;



@end
