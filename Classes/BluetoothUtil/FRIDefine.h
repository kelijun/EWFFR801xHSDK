/*
//
 
@brief  预定义一些库的执行行为和配置
 
 */

// //
//  //
//  

#import <Foundation/Foundation.h>


# pragma mark - fri 行为定义

//FRI if show log 是否打印日志，默认1：打印 ，0：不打印
#define KFRI_IS_SHOW_LOG 1

//CBcentralManager等待设备打开次数
# define KFRI_CENTRAL_MANAGER_INIT_WAIT_TIMES 5

//CBcentralManager等待设备打开间隔时间
# define KFRI_CENTRAL_MANAGER_INIT_WAIT_SECOND 2.0

//FRIRhythm默认心跳时间间隔
#define KFRIRHYTHM_BEATS_DEFAULT_INTERVAL 3;

//FRI默认链式方法channel名称
#define KFRI_DETAULT_CHANNEL @"friDefault"

# pragma mark - fri通知

//蓝牙系统通知
//centralManager status did change notification
#define FRINotificationAtCentralManagerDidUpdateState @"FRINotificationAtCentralManagerDidUpdateState"
//did discover peripheral notification
#define FRINotificationAtDidDiscoverPeripheral @"FRINotificationAtDidDiscoverPeripheral"
//did connection peripheral notification
#define FRINotificationAtDidConnectPeripheral @"FRINotificationAtDidConnectPeripheral"
//did filed connect peripheral notification
#define FRINotificationAtDidFailToConnectPeripheral @"FRINotificationAtDidFailToConnectPeripheral"
//did disconnect peripheral notification
#define FRINotificationAtDidDisconnectPeripheral @"FRINotificationAtDidDisconnectPeripheral"
//did discover service notification
#define FRINotificationAtDidDiscoverServices @"FRINotificationAtDidDiscoverServices"
//did discover characteristics notification
#define FRINotificationAtDidDiscoverCharacteristicsForService @"FRINotificationAtDidDiscoverCharacteristicsForService"
//did read or notify characteristic when received value  notification
#define FRINotificationAtDidUpdateValueForCharacteristic @"FRINotificationAtDidUpdateValueForCharacteristic"
//did write characteristic and response value notification
#define FRINotificationAtDidWriteValueForCharacteristic @"FRINotificationAtDidWriteValueForCharacteristic"
//did change characteristis notify status notification
#define FRINotificationAtDidUpdateNotificationStateForCharacteristic @"FRINotificationAtDidUpdateNotificationStateForCharacteristic"
//did read rssi and receiced value notification
#define FRINotificationAtDidReadRSSI @"FRINotificationAtDidReadRSSI"

//蓝牙扩展通知
// did centralManager enable notification
#define FRINotificationAtCentralManagerEnable @"FRINotificationAtCentralManagerEnable"

# pragma mark - fri 定义的方法

//FRI log
#define FRILog(fmt, ...) if(KFRI_IS_SHOW_LOG) { NSLog(fmt,##__VA_ARGS__); }

