
//
//

#import "FRISpeaker.h"
#import "FRIDefine.h"


typedef NS_ENUM(NSUInteger, FRISpeakerType) {
    FRISpeakerTypeDiscoverPeripherals,
    FRISpeakerTypeConnectedPeripheral,
    FRISpeakerTypeDiscoverPeripheralsFailToConnect,
    FRISpeakerTypeDiscoverPeripheralsDisconnect,
    FRISpeakerTypeDiscoverPeripheralsDiscoverServices,
    FRISpeakerTypeDiscoverPeripheralsDiscoverCharacteristics,
    FRISpeakerTypeDiscoverPeripheralsReadValueForCharacteristic,
    FRISpeakerTypeDiscoverPeripheralsDiscoverDescriptorsForCharacteristic,
    FRISpeakerTypeDiscoverPeripheralsReadValueForDescriptorsBlock
};


@implementation FRISpeaker {
    //所有委托频道
    NSMutableDictionary *channels;
    //当前委托频道
    NSString *currChannel;
    //notifyList
    NSMutableDictionary *notifyList;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        FRICallback *defaultCallback = [[FRICallback alloc]init];
        notifyList = [[NSMutableDictionary alloc]init];
        channels = [[NSMutableDictionary alloc]init];
        currChannel = KFRI_DETAULT_CHANNEL;
        [channels setObject:defaultCallback forKey:KFRI_DETAULT_CHANNEL];
    }
    return self;
}

- (FRICallback *)callback {
    return [channels objectForKey:KFRI_DETAULT_CHANNEL];
}

- (FRICallback *)callbackOnCurrChannel {
    return [self callbackOnChnnel:currChannel];
}

- (FRICallback *)callbackOnChnnel:(NSString *)channel {
    if (!channel) {
        [self callback];
    }
    return [channels objectForKey:channel];
}

- (FRICallback *)callbackOnChnnel:(NSString *)channel
               createWhenNotExist:(BOOL)createWhenNotExist {
    
    FRICallback *callback = [channels objectForKey:channel];
    if (!callback && createWhenNotExist) {
        callback = [[FRICallback alloc]init];
        [channels setObject:callback forKey:channel];
    }
    
    return callback;
}

- (void)switchChannel:(NSString *)channel {
    if (channel) {
        if ([self callbackOnChnnel:channel]) {
            currChannel = channel;
//            FRILog(@">>>已切换到%@",channel);
        }
        else {
//            FRILog(@">>>所要切换的channel不存在");
        }
    }
    else {
        currChannel = KFRI_DETAULT_CHANNEL;
//            FRILog(@">>>已切换到默认频道");
    }
}

//添加到notify list
- (void)addNotifyCallback:(CBCharacteristic *)c
           withBlock:(void(^)(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error))block {
    [notifyList setObject:block forKey:c.UUID.description];
}

//添加到notify list
- (void)removeNotifyCallback:(CBCharacteristic *)c {
    [notifyList removeObjectForKey:c.UUID.description];
}

//获取notify list
- (NSMutableDictionary *)notifyCallBackList {
    return notifyList;
}

//获取notityBlock
- (void(^)(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error))notifyCallback:(CBCharacteristic *)c {
    return [notifyList objectForKey:c.UUID.description];
}
@end
