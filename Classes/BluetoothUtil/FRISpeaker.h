/*
//
 
 @brief  fribluetooth block查找和channel切换

 */

//
//

#import "FRICallback.h"
#import <CoreBluetooth/CoreBluetooth.h>


@interface FRISpeaker : NSObject

- (FRICallback *)callback;
- (FRICallback *)callbackOnCurrChannel;
- (FRICallback *)callbackOnChnnel:(NSString *)channel;
- (FRICallback *)callbackOnChnnel:(NSString *)channel
               createWhenNotExist:(BOOL)createWhenNotExist;

//切换频道
- (void)switchChannel:(NSString *)channel;

//添加到notify list
- (void)addNotifyCallback:(CBCharacteristic *)c
           withBlock:(void(^)(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error))block;

//添加到notify list
- (void)removeNotifyCallback:(CBCharacteristic *)c;

//获取notify list
- (NSMutableDictionary *)notifyCallBackList;

//获取notityBlock
- (void(^)(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error))notifyCallback:(CBCharacteristic *)c;

@end
