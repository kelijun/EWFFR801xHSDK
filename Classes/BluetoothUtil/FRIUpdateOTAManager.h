//
//  FRIUpdateOTAManager.h
//  FRQBluetoothKit
//
//  Created by chunhai xu on 2021/1/3.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FRIBluetooth.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FRIOTAStatus) {
    FRIOTAStatusNotStart, //未开始
    FRIOTAStatusGetBaseAddr, //获取基地址
    FRIOTAStatusEraseOut, //擦除
    FRIOTAStatusFileTransform, //文件传输
    FRIOTAStatusReboot, //重启
    FRIOTAStatusFailure, //失败
    FRIOTAStatusFinish, //成功
    FRIOTAStatusCanceled, //cancel
};

@class FRIUpdateOTAManager;
@protocol FRIUpdateOTAManagerDelegate <NSObject>

-(void)onOTAUpdateStatusDidChange:(FRIUpdateOTAManager *)ota withProgress:(float)aProgress;
-(void)onOTAUpdateStatusCompletion:(FRIUpdateOTAManager *)ota;
-(void)onOTAUpdateStart:(FRIUpdateOTAManager *)ota;
-(void)onOTAUpdateStatusFailure:(FRIUpdateOTAManager *)ota error:(NSError *)err;

@end


@interface FRIUpdateOTAManager : NSObject

@property(nonatomic, weak) id<FRIUpdateOTAManagerDelegate> delegate;

@property(nonatomic, assign, readonly) FRIOTAStatus otaStatus; //!< ota操作状态
@property(nonatomic, strong, readonly) CBPeripheral *curPeripheral; //当前连接外设

@property(nonatomic, strong) FRIBluetooth *friBLE; //!< 蓝牙工具
@property(nonatomic, strong) NSData *binData; //bin file data


-(void)resetOTAStatus;

-(void)startUpdateOTA:(CBPeripheral *)peripheral writeCharacteristic:(CBCharacteristic *)writeCharacteristic readCharacteristic:(CBCharacteristic *)readCharacteristic;

-(void)cancelOTAUpdate;

@end

NS_ASSUME_NONNULL_END
