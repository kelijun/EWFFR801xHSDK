//
//  FRBleAbility.h
//  FRQBluetoothKit
//
//  Created by chunhai xu on 2021/1/3.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FRQErrorCode) {
    FRQErrorCode_ota = 10011, //ota升级错误
    FRQErrorCode_connect = 10022, //设备连接错误
};

//state
typedef NS_ENUM(NSUInteger, FRQManagerState) {
    FRQManagerStateUnknown = CBCentralManagerStateUnknown, //未知
    FRQManagerStateResetting = CBCentralManagerStateResetting, //重置
    FRQManagerStateUnsupported =CBCentralManagerStateUnsupported, //不支持
    FRQManagerStateUnauthorized =CBCentralManagerStateUnauthorized, //未授权
    FRQManagerStatePoweredOff =CBCentralManagerStatePoweredOff, //蓝牙关闭
    FRQManagerStatePoweredOn =CBCentralManagerStatePoweredOn, //蓝牙打开
};

@protocol FRBleAbility <NSObject>

@property (nonatomic, assign) FRQManagerState state;

/** 设置查找和连接Peripherals的规则，需要在scan之前设置
 @param discoverFilter 发现蓝牙设备时过滤条件
 @param connectFilter 连接设备时过滤条件
 */
- (void)setFilterForDiscoverPeripherals:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))discoverFilter andFilterForConnectToPeripherals:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))connectFilter;

/** 扫描Peripherals */
- (void)scanPeripherals;

/** 停止扫描 */
- (void)cancelScan;

/** 是否正在扫描中 */
- (BOOL)isScanning;

/** 连接到特定的蓝牙设备
 @param peripheral 蓝牙设备
 */
- (void)connectToPeripheral:(CBPeripheral *)peripheral;

/** 连接设备，支持自动重连
 @param peripheral 蓝牙设备
 */
- (void)autoReconnectToPeripheral:(CBPeripheral *)peripheral;

/**
 断开自动重连设备
 @param peripheral 蓝牙设备
 */
- (void)closeAuotReconnectPeripheral:(CBPeripheral *)peripheral;

/**
 断开设备连接
 @param peripheral 蓝牙设备
 */
- (void)closePeripheralConnection:(CBPeripheral *)peripheral;

/**
 断开所有已连接的设备
 @param block 断开回调
 */
- (void)closeAllPeripheralsConnection:(void(^)(id<FRBleAbility> ability))block;

/**
 获取当前连接的peripherals
 @return 返回所有已经连接好的设备数组
 */
- (NSArray *)allConnectedPeripherals;

/**
 获取当前连接的peripheral
 @param peripheralName 设备名
 @return 根据设备名获取连接的蓝牙外设
 */
- (CBPeripheral *)findConnectedPeripheralWithName:(NSString *)peripheralName;

/// OTA 升级

/**
 通过文件路径进行OTA升级
 @param filePath 文件路径
 @param perpheral 蓝牙外设
 */
- (void)updateOTAWithFilePath:(NSString *)filePath toPeripheral:(CBPeripheral*)perpheral;

/**
 通过Data进行OTA升级，会校验文件是否符合
 @param binData 升级文件数据
 @param perpheral 蓝牙外设
 */
- (void)updateOTAWithData:(NSData *)binData toPeripheral:(CBPeripheral*)perpheral;

/** 停止升级OTA操作，如果OTA已升级完成的话无操作 */
- (void)cancelOTAUpgrade;

@end

NS_ASSUME_NONNULL_END
