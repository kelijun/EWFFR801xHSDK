//
//  FRQBluetoothManager.h
//  FRQBluetoothKit
//
//  Created by chunhai xu on 2021/1/3.
//

#import <Foundation/Foundation.h>
#import "FRBleAbility.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FRQBluetoothManagerDelegate <NSObject>

@optional

-(void)onBLEManagerDiscoverPeripheral:(id<FRBleAbility>)ability peripheral:(CBPeripheral *)peripheral advertisement:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

-(void)onBLEManagerStateChange:(id<FRBleAbility>)ability;

-(void)onBLEManagerConnect:(id<FRBleAbility>)ability peripheral:(CBPeripheral *)peripheral error:(NSError *)error;

-(void)onBLEManagerDisconnect:(id<FRBleAbility>)ability peripheral:(CBPeripheral *)peripheral error:(NSError *)error;

-(void)onBLEManagerCancelScan:(id<FRBleAbility>)ability;

// OTA升级阶段回调
-(void)onBLEManagerBeginUpdateOTA:(id<FRBleAbility>)ability;

-(void)onBLEManagerUpdateOTA:(id<FRBleAbility>)ability progress:(double)aProgress;

-(void)onBLEManagerUpdateOTAFinish:(id<FRBleAbility>)ability error:(NSError *)error;

@end




@interface FRQBluetoothManager : NSObject<FRBleAbility>

@property(nonatomic, weak) id<FRQBluetoothManagerDelegate> delegate; 

+(instancetype)shareManager;

@end

NS_ASSUME_NONNULL_END
