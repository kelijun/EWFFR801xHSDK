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

/**
 @brief 当发现周围蓝牙外设时候回调
 @param ability 当前管理对象
 @param peripheral 外设
 @param advertisementData 设备相关信息数据
 @param RSSI    dBm
 */
-(void)onBLEManagerDiscoverPeripheral:(id<FRBleAbility>)ability peripheral:(CBPeripheral *)peripheral advertisement:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

/**
 @brief 当前设备的状态发生变更
 @param ability 当前管理对象
 */
-(void)onBLEManagerStateChange:(id<FRBleAbility>)ability;

/**
 @brief 蓝牙设备连接上时回调
 @param ability 当前管理对象
 @param peripheral 蓝牙外设
 @param error 如果为空表示蓝牙设备连接成功，否则连接蓝牙设备失败，可以查看详细信息 errCode @see FRQErrorCode
 */
-(void)onBLEManagerConnect:(id<FRBleAbility>)ability peripheral:(CBPeripheral *)peripheral error:(NSError *)error;

/**
 @brief 设备断开连接时回调
 @param ability 当前管理对象
 @param peripheral 蓝牙外设
 @param error 如果为空表示蓝牙连接正常断开，否则为异常断开，可以查看详细信息 errCode @see FRQErrorCode
 */
-(void)onBLEManagerDisconnect:(id<FRBleAbility>)ability peripheral:(CBPeripheral *)peripheral error:(NSError *)error;

/**
 @brief 取消设备扫描操作
 @param ability 当前管理对象
 */
-(void)onBLEManagerCancelScan:(id<FRBleAbility>)ability;

// OTA升级阶段回调

/**
 @brief 设备的OTA开始升级时调用
 @param ability 当前管理对象
 */
-(void)onBLEManagerBeginUpdateOTA:(id<FRBleAbility>)ability;

/**
 @brief 设备OTA升级过程中调用
 @param ability 当前管理对象
 @param aProgress 当前升级进度，0-100
 */
-(void)onBLEManagerUpdateOTA:(id<FRBleAbility>)ability progress:(double)aProgress;

/**
 @brief 设备OTA升级完成后调用
 @param ability 当前管理对象
 @param error 如果为空则升级正常，否则失败可以查看详细错误信息，errCode @see FRQErrorCode
 */
-(void)onBLEManagerUpdateOTAFinish:(id<FRBleAbility>)ability error:(NSError *)error;

@end



/**
 @discussion  FRQBluetoothManager 提供了蓝牙相关的处理操作以及OTA功能
 
 一、使用该功能前需要支持在project的info.plist中支持
 
 1、 Privacy - Bluetooth Peripheral Usage Description 和Privacy - Bluetooth Always Usage Description
 
 2、设置App后台模式
 - use bluetooth LE accessory
 - external accessory communication
 
 二、基本使用
 1、蓝牙扫描外设：
 [[FRQBluetoothManager shareManager] scanPeripherals]
 
 2、取消扫描：
 [[FRQBluetoothManager shareManager] cancelScan]
 
 3、连接蓝牙设备：
 [[FRQBluetoothManager shareManager] connectToPeripheral:peripheral];
 
 4、断开蓝牙设备：
 [[FRQBluetoothManager shareManager] closePeripheralConnection:peripheral];
 
 5、开始进行OTA升级：
 [[FRQBluetoothManager shareManager] updateOTAWithData:otaBinData toPeripheral:peripheral];

 三、注意事项
  建议在app进行蓝牙升级过程中，不要进行其他额外操作导致设备OTA中断，否则可能会引起设备升级中出现问题
 
 
 
 */
@interface FRQBluetoothManager : NSObject<FRBleAbility>

/**
 @brief 蓝牙操作代理对象
 @see FRQBluetoothManagerDelegate
 */
@property(nonatomic, weak) id<FRQBluetoothManagerDelegate> delegate; 

/**
 @brief 单例方法调用
 */
+(instancetype)shareManager;

@end

NS_ASSUME_NONNULL_END
