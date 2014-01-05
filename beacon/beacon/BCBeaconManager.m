//
//  BCBeaconManager.m
//  beacon
//
//  Created by Zac Bowling on 1/4/14.
//  Copyright (c) 2014 Hackathon. All rights reserved.
//

#import "BCBeaconManager.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <Parse/Parse.h>
#import <FYX/FYX.h>
#import <FYX/FYXVisitManager.h>
#import <FYX/FYXVisit.h>
#import <FYX/FYXTransmitter.h>
#import <FYX/FYXTransmitterManager.h>
#import <FYX/FYXSightingManager.h>

@interface BCBeacon()

@property (strong, nonatomic, readwrite) id<NSObject> identifier;

@property (strong, nonatomic, readwrite) NSString *title;

@property (strong, nonatomic, readwrite) NSString *subtitle;

@property (assign, nonatomic, readwrite) BCBeaconType type;

@property (assign, nonatomic, readwrite) NSTimeInterval lastSeen;

@property (assign, nonatomic, readwrite) CLProximity proximity;

@property (strong, nonatomic, readwrite) PFObject *profile;

@end

@implementation BCBeacon


- (NSArray *)keyPaths
{
    NSArray *result = @[@"identifier",
                       @"title",
                       @"subtitle",
                       @"type",
                       @"lastSeen",
                       @"proximity",
                       @"profile"];

    return result;
}


- (NSString *)descriptionForKeyPaths
{
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"<%@ ", NSStringFromClass([self class])];

    BOOL first = YES;
    NSArray *keyPathsArray = [self keyPaths];
    for (NSString *keyPath in keyPathsArray) {
        if (!first) {
            [desc appendString:@", "];
        }
        [desc appendFormat: @"%@: %@", keyPath, [self valueForKey:keyPath]];
        first = NO;
    }
    [desc appendString:@">"];

    return [NSString stringWithString:desc];
}

- (NSString *)description 
{
    return [self descriptionForKeyPaths]; 
}



@end

@interface BCBeaconManager()<CLLocationManagerDelegate,CBPeripheralManagerDelegate,FYXServiceDelegate,FYXVisitDelegate> {
    CLLocationManager *_locationManager;
    CLBeaconRegion *_beaconRegion;
    CLBeaconRegion *_userBeaconRegion;
    CBPeripheralManager *_cbManager;
    CBPeripheralManager *_cbUserManager;
    NSDictionary *_beaconData;
    NSDictionary *_userBeaconData;
    NSMutableSet *_currentBeacons;
    NSMutableDictionary *_beaconsById;
    FYXVisitManager *_visitManager;
}

@property (strong, readwrite) NSArray *beacons;

@end

@implementation BCBeaconManager

@synthesize beacons=_beacons;

+(BCBeaconManager *)sharedManager
{
    static BCBeaconManager *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BCBeaconManager alloc] init];
    });

    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"] identifier:@"beacon2"];
        //_beaconRegion.notifyEntryStateOnDisplay = YES;

        [_locationManager startMonitoringForRegion:_beaconRegion];
        [_locationManager startRangingBeaconsInRegion:_beaconRegion];
        _beaconData = [_beaconRegion peripheralDataWithMeasuredPower:nil];

        _currentBeacons = [[NSMutableSet alloc] init];
        _beaconsById = [[NSMutableDictionary alloc] init];

        PFQuery *query = [PFQuery queryWithClassName:@"Profile"];
        NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [query whereKey:@"deviceIdentifier" equalTo:deviceId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            PFObject *profile = [objects firstObject];
            if (!profile) {
                profile = [PFObject objectWithClassName:@"Profile"];
                profile[@"deviceIdentifier"] = deviceId;
                profile[@"profileIdentifier"] = @((u_int32_t)arc4random()); //hacks. FIXME
                [profile save];
            }
            u_int32_t profileId = [profile[@"profileIdentifier"] unsignedIntValue];

            u_int16_t maj = (u_int16_t) (profileId >> 16);
            u_int16_t min = (u_int16_t) (profileId & 0x0000ffff);

            dispatch_async(dispatch_get_main_queue(), ^{
                _userBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"] major:maj minor:min identifier:@"beacon"];
                _userBeaconData = [_userBeaconRegion peripheralDataWithMeasuredPower:nil];
                _cbUserManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue   ()];
            });


        }];

        [FYX startService:self];
        _visitManager = [[FYXVisitManager alloc] init];
        _visitManager.delegate = self;
        NSMutableDictionary *options = [NSMutableDictionary new];
        options[FYXVisitOptionDepartureIntervalInSecondsKey] = @15;
        options[FYXSightingOptionSignalStrengthWindowKey] = @(FYXSightingOptionSignalStrengthWindowNone);
        [_visitManager startWithOptions:options];
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isEqual:_beaconRegion]) {
        [_locationManager startRangingBeaconsInRegion:_beaconRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isEqual:_beaconRegion]) {
        [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
    }
}

- (u_int32_t)identifierForCLBeacon:(CLBeacon *)beacon
{
    u_int16_t maj = (u_int16_t)beacon.major.unsignedIntegerValue;
    u_int16_t min = (u_int16_t)beacon.minor.unsignedIntegerValue;

    u_int32_t val = (maj << 16) | (min & 0xffff);

    return val;
}


- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    for (CLBeacon *beacon in beacons) {
        NSNumber *beaconId = @([self identifierForCLBeacon:beacon]);
        BCBeacon *bbeacon = _beaconsById[beaconId];
        if (!bbeacon) {
            bbeacon = [[BCBeacon alloc] init];
            bbeacon.identifier = beaconId;
            bbeacon.title = @"Unidentified";
            bbeacon.subtitle = @"Searching";
            _beaconsById[beaconId] = bbeacon;
        }

        bbeacon.lastSeen = [NSDate timeIntervalSinceReferenceDate];
        bbeacon.type = BCBeaconTypePerson;
        if (beacon.proximity != CLProximityUnknown) {
            bbeacon.proximity = beacon.proximity;
        }

        if (![_currentBeacons member:bbeacon]) {
            PFQuery *query = [PFQuery queryWithClassName:@"Profile"];
            [query setMaxCacheAge:120];
            [query whereKey:@"profileIdentifier" equalTo:beaconId];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *object = [objects lastObject];
                if (object) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        bbeacon.profile = object;
                        NSString *beaconMessage;
                        if (object[@"name"]) {
                            bbeacon.title = object[@"name"];
                            beaconMessage = [NSString stringWithFormat:@"%@ is nearby. Say hello!", bbeacon.title];
                        } else {
                            beaconMessage = @"Another Relate user is nearby. Can you find him?";
                        }
                        UILocalNotification *notif = [[UILocalNotification alloc] init];
                        notif.fireDate = [NSDate date];
                        notif.alertAction = @"View";
                        notif.alertBody = beaconMessage;
                        [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
                        [self updateBeacons];
                    });
                }
            }];
        }
        [_currentBeacons addObject:bbeacon];
    }

    [self updateBeacons];
}

- (void)updateBeacons
{
    [_currentBeacons filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(BCBeacon *evaluatedObject, NSDictionary *bindings) {
        if ([NSDate timeIntervalSinceReferenceDate] - evaluatedObject.lastSeen < 600.0){
            return YES;
        }
        return NO;
    }]];

    self.beacons = [_currentBeacons sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"type" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"BCBeaconManagerUpdated" object:self];
    NSLog(@"beacons %@", _beacons);
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Powered On");
        if ([peripheral isEqual:_cbUserManager]) {
            [peripheral startAdvertising:_userBeaconData];
        }

    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        NSLog(@"Powered Off");
        [peripheral stopAdvertising];
    }
}

-(void)serviceStarted {

}

- (void)didArrive:(FYXVisit *)visit {

    NSLog(@"%@ visit", visit);
}

- (void)receivedSighting:(FYXVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI {
    BCBeacon *beacon = _beaconsById[visit.transmitter.identifier];
    if (!beacon) {
        BCBeacon *beacon = [[BCBeacon alloc] init];
        _beaconsById[visit.transmitter.identifier] = beacon;
        PFQuery *query = [PFQuery queryWithClassName:@"Profile"];
        [query whereKey:@"beaconIdentifier" equalTo:visit.transmitter.identifier];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            beacon.type = BCBeaconTypeMarketing;
            beacon.title = object[@"name"];
            beacon.subtitle = @"Local Deal";
            beacon.lastSeen = [NSDate timeIntervalSinceReferenceDate];
            beacon.identifier = visit.transmitter.identifier;
            beacon.profile = object;

            NSString *beaconMessage = [NSString stringWithFormat:@"Nearby deal from %@! Check it out.", object[@"name"]];
            UILocalNotification *notif = [[UILocalNotification alloc] init];
            notif.fireDate = [NSDate date];
            notif.alertAction = @"View";
            notif.alertBody = beaconMessage;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notif];

            [_currentBeacons addObject:beacon];
            [self updateBeacons];
        }];
    } else {
        beacon.lastSeen = [NSDate timeIntervalSinceReferenceDate];
    }
}


@end
