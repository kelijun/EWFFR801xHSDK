
#import "FRIBluetooth.h"


@implementation FRIBluetooth{
    FRICentralManager *friCentralManager;
    FRISpeaker *friSpeaker;
    int CENTRAL_MANAGER_INIT_WAIT_TIMES;
    NSTimer *timerForStop;
}
//单例模式
+ (instancetype)shareBluetooth {
    static FRIBluetooth *share = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        share = [[FRIBluetooth alloc]init];
    });
   return share;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //初始化对象
        friCentralManager = [[FRICentralManager alloc]init];
        friSpeaker = [[FRISpeaker alloc]init];
        friCentralManager->friSpeaker = friSpeaker;
    }
    return self;
    
}

#pragma mark - fribluetooth的委托
/*
 默认频道的委托
 */
//设备状态改变的委托
- (void)setBlockOnCentralManagerDidUpdateState:(void (^)(CBCentralManager *central))block {
    [[friSpeaker callback]setBlockOnCentralManagerDidUpdateState:block];
}
//找到Peripherals的委托
- (void)setBlockOnDiscoverToPeripherals:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI))block{
    [[friSpeaker callback]setBlockOnDiscoverPeripherals:block];
}
//连接Peripherals成功的委托
- (void)setBlockOnConnected:(void (^)(CBCentralManager *central,CBPeripheral *peripheral))block {
    [[friSpeaker callback]setBlockOnConnectedPeripheral:block];
}
//连接Peripherals失败的委托
- (void)setBlockOnFailToConnect:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block {
    [[friSpeaker callback]setBlockOnFailToConnect:block];
}
//断开Peripherals的连接
- (void)setBlockOnDisconnect:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block {
    [[friSpeaker callback]setBlockOnDisconnect:block];
}
//设置查找服务回叫
- (void)setBlockOnDiscoverServices:(void (^)(CBPeripheral *peripheral,NSError *error))block {
    [[friSpeaker callback]setBlockOnDiscoverServices:block];
}
//设置查找到Characteristics的block
- (void)setBlockOnDiscoverCharacteristics:(void (^)(CBPeripheral *peripheral,CBService *service,NSError *error))block {
    [[friSpeaker callback]setBlockOnDiscoverCharacteristics:block];
}
//设置获取到最新Characteristics值的block
- (void)setBlockOnReadValueForCharacteristic:(void (^)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error))block {
    [[friSpeaker callback]setBlockOnReadValueForCharacteristic:block];
}
//设置查找到Characteristics描述的block
- (void)setBlockOnDiscoverDescriptorsForCharacteristic:(void (^)(CBPeripheral *peripheral,CBCharacteristic *service,NSError *error))block {
    [[friSpeaker callback]setBlockOnDiscoverDescriptorsForCharacteristic:block];
}
//设置读取到Characteristics描述的值的block
- (void)setBlockOnReadValueForDescriptors:(void (^)(CBPeripheral *peripheral,CBDescriptor *descriptor,NSError *error))block {
    [[friSpeaker callback]setBlockOnReadValueForDescriptors:block];
}

//写Characteristic成功后的block
- (void)setBlockOnDidWriteValueForCharacteristic:(void (^)(CBCharacteristic *characteristic,NSError *error))block {
    [[friSpeaker callback]setBlockOnDidWriteValueForCharacteristic:block];
}
//写descriptor成功后的block
- (void)setBlockOnDidWriteValueForDescriptor:(void (^)(CBDescriptor *descriptor,NSError *error))block {
    [[friSpeaker callback]setBlockOnDidWriteValueForDescriptor:block];
}
//characteristic订阅状态改变的block
- (void)setBlockOnDidUpdateNotificationStateForCharacteristic:(void (^)(CBCharacteristic *characteristic,NSError *error))block {
    [[friSpeaker callback]setBlockOnDidUpdateNotificationStateForCharacteristic:block];
}
//读取RSSI的委托
- (void)setBlockOnDidReadRSSI:(void (^)(NSNumber *RSSI,NSError *error))block {
    [[friSpeaker callback]setBlockOnDidReadRSSI:block];
}
//discoverIncludedServices的回调，暂时在fribluetooth中无作用
- (void)setBlockOnDidDiscoverIncludedServicesForService:(void (^)(CBService *service,NSError *error))block {
    [[friSpeaker callback]setBlockOnDidDiscoverIncludedServicesForService:block];
}
//外设更新名字后的block
- (void)setBlockOnDidUpdateName:(void (^)(CBPeripheral *peripheral))block {
    [[friSpeaker callback]setBlockOnDidUpdateName:block];
}
//外设更新服务后的block
- (void)setBlockOnDidModifyServices:(void (^)(CBPeripheral *peripheral,NSArray *invalidatedServices))block {
    [[friSpeaker callback]setBlockOnDidModifyServices:block];
}

//设置蓝牙使用的参数参数
- (void)setFriOptionsWithScanForPeripheralsWithOptions:(NSDictionary *) scanForPeripheralsWithOptions
                          connectPeripheralWithOptions:(NSDictionary *) connectPeripheralWithOptions
                        scanForPeripheralsWithServices:(NSArray *)scanForPeripheralsWithServices
                                  discoverWithServices:(NSArray *)discoverWithServices
                           discoverWithCharacteristics:(NSArray *)discoverWithCharacteristics {
    FRIOptions *option = [[FRIOptions alloc]initWithscanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectPeripheralWithOptions scanForPeripheralsWithServices:scanForPeripheralsWithServices discoverWithServices:discoverWithServices discoverWithCharacteristics:discoverWithCharacteristics];
    [[friSpeaker callback]setFriOptions:option];
}

/*
 channel的委托
 */
//设备状态改变的委托
- (void)setBlockOnCentralManagerDidUpdateStateAtChannel:(NSString *)channel
                                                 block:(void (^)(CBCentralManager *central))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnCentralManagerDidUpdateState:block];
}
//找到Peripherals的委托
- (void)setBlockOnDiscoverToPeripheralsAtChannel:(NSString *)channel
                                          block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnDiscoverPeripherals:block];
}

//连接Peripherals成功的委托
- (void)setBlockOnConnectedAtChannel:(NSString *)channel
                              block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnConnectedPeripheral:block];
}

//连接Peripherals失败的委托
- (void)setBlockOnFailToConnectAtChannel:(NSString *)channel
                                  block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnFailToConnect:block];
}

//断开Peripherals的连接
- (void)setBlockOnDisconnectAtChannel:(NSString *)channel
                               block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnDisconnect:block];
}

//设置查找服务回叫
- (void)setBlockOnDiscoverServicesAtChannel:(NSString *)channel
                                     block:(void (^)(CBPeripheral *peripheral,NSError *error))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnDiscoverServices:block];
}

//设置查找到Characteristics的block
- (void)setBlockOnDiscoverCharacteristicsAtChannel:(NSString *)channel
                                            block:(void (^)(CBPeripheral *peripheral,CBService *service,NSError *error))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnDiscoverCharacteristics:block];
}
//设置获取到最新Characteristics值的block
- (void)setBlockOnReadValueForCharacteristicAtChannel:(NSString *)channel
                                               block:(void (^)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnReadValueForCharacteristic:block];
}
//设置查找到Characteristics描述的block
- (void)setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:(NSString *)channel
                                                         block:(void (^)(CBPeripheral *peripheral,CBCharacteristic *service,NSError *error))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnDiscoverDescriptorsForCharacteristic:block];
}
//设置读取到Characteristics描述的值的block
- (void)setBlockOnReadValueForDescriptorsAtChannel:(NSString *)channel
                                            block:(void (^)(CBPeripheral *peripheral,CBDescriptor *descriptor,NSError *error))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnReadValueForDescriptors:block];
}

//写Characteristic成功后的block
- (void)setBlockOnDidWriteValueForCharacteristicAtChannel:(NSString *)channel
                                                        block:(void (^)(CBCharacteristic *characteristic,NSError *error))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidWriteValueForCharacteristic:block];
}
//写descriptor成功后的block
- (void)setBlockOnDidWriteValueForDescriptorAtChannel:(NSString *)channel
                                      block:(void (^)(CBDescriptor *descriptor,NSError *error))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidWriteValueForDescriptor:block];
}
//characteristic订阅状态改变的block
- (void)setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:(NSString *)channel
                                                                     block:(void (^)(CBCharacteristic *characteristic,NSError *error))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidUpdateNotificationStateForCharacteristic:block];
}
//读取RSSI的委托
- (void)setBlockOnDidReadRSSIAtChannel:(NSString *)channel
                                block:(void (^)(NSNumber *RSSI,NSError *error))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidReadRSSI:block];
}
//discoverIncludedServices的回调，暂时在fribluetooth中无作用
- (void)setBlockOnDidDiscoverIncludedServicesForServiceAtChannel:(NSString *)channel
                                                          block:(void (^)(CBService *service,NSError *error))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidDiscoverIncludedServicesForService:block];
}
//外设更新名字后的block
- (void)setBlockOnDidUpdateNameAtChannel:(NSString *)channel
                                  block:(void (^)(CBPeripheral *peripheral))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidUpdateName:block];
}
//外设更新服务后的block
- (void)setBlockOnDidModifyServicesAtChannel:(NSString *)channel
                                      block:(void (^)(CBPeripheral *peripheral,NSArray *invalidatedServices))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidModifyServices:block];
}


//设置蓝牙运行时的参数
- (void)setFriOptionsAtChannel:(NSString *)channel
 scanForPeripheralsWithOptions:(NSDictionary *) scanForPeripheralsWithOptions
  connectPeripheralWithOptions:(NSDictionary *) connectPeripheralWithOptions
    scanForPeripheralsWithServices:(NSArray *)scanForPeripheralsWithServices
          discoverWithServices:(NSArray *)discoverWithServices
   discoverWithCharacteristics:(NSArray *)discoverWithCharacteristics {
    
    FRIOptions *option = [[FRIOptions alloc]initWithscanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectPeripheralWithOptions scanForPeripheralsWithServices:scanForPeripheralsWithServices discoverWithServices:discoverWithServices discoverWithCharacteristics:discoverWithCharacteristics];
     [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES]setFriOptions:option];
}

#pragma mark - fribluetooth filter委托
//设置查找Peripherals的规则
- (void)setFilterOnDiscoverPeripherals:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))filter {
    [[friSpeaker callback]setFilterOnDiscoverPeripherals:filter];
}
//设置连接Peripherals的规则
- (void)setFilterOnConnectToPeripherals:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))filter {
    [[friSpeaker callback]setFilterOnconnectToPeripherals:filter];
}
//设置查找Peripherals的规则
- (void)setFilterOnDiscoverPeripheralsAtChannel:(NSString *)channel
                                      filter:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))filter {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setFilterOnDiscoverPeripherals:filter];
}
//设置连接Peripherals的规则
- (void)setFilterOnConnectToPeripheralsAtChannel:(NSString *)channel
                                     filter:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))filter {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setFilterOnconnectToPeripherals:filter];
}

#pragma mark - fribluetooth Special
//friBluettooth cancelScan方法调用后的回调
- (void)setBlockOnCancelScanBlock:(void(^)(CBCentralManager *centralManager))block {
    [[friSpeaker callback]setBlockOnCancelScan:block];
}
//friBluettooth cancelAllPeripheralsConnectionBlock 方法调用后的回调
- (void)setBlockOnCancelAllPeripheralsConnectionBlock:(void(^)(CBCentralManager *centralManager))block{
    [[friSpeaker callback]setBlockOnCancelAllPeripheralsConnection:block];
}
//friBluettooth cancelScan方法调用后的回调
- (void)setBlockOnCancelScanBlockAtChannel:(NSString *)channel
                                    block:(void(^)(CBCentralManager *centralManager))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnCancelScan:block];
}
//friBluettooth cancelAllPeripheralsConnectionBlock 方法调用后的回调
- (void)setBlockOnCancelAllPeripheralsConnectionBlockAtChannel:(NSString *)channel
                                                        block:(void(^)(CBCentralManager *centralManager))block {
    [[friSpeaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnCancelAllPeripheralsConnection:block];
}

#pragma mark - 链式函数
//查找Peripherals
- (FRIBluetooth *(^)(void)) scanForPeripherals {
    return ^FRIBluetooth *() {
        [self->friCentralManager->pocket setObject:@"YES" forKey:@"needScanForPeripherals"];
        return self;
    };
}

//连接Peripherals
- (FRIBluetooth *(^)(void)) connectToPeripherals {
    return ^FRIBluetooth *() {
        [self->friCentralManager->pocket setObject:@"YES" forKey:@"needConnectPeripheral"];
        return self;
    };
}

//发现Services
- (FRIBluetooth *(^)(void)) discoverServices {
    return ^FRIBluetooth *() {
        [self->friCentralManager->pocket setObject:@"YES" forKey:@"needDiscoverServices"];
        return self;
    };
}

//获取Characteristics
- (FRIBluetooth *(^)(void)) discoverCharacteristics {
    return ^FRIBluetooth *() {
        [self->friCentralManager->pocket setObject:@"YES" forKey:@"needDiscoverCharacteristics"];
        return self;
    };
}

//更新Characteristics的值
- (FRIBluetooth *(^)(void)) readValueForCharacteristic {
    return ^FRIBluetooth *() {
        [self->friCentralManager->pocket setObject:@"YES" forKey:@"needReadValueForCharacteristic"];
        return self;
    };
}

//设置查找到Descriptors名称的block
- (FRIBluetooth *(^)(void)) discoverDescriptorsForCharacteristic {
    return ^FRIBluetooth *() {
        [self->friCentralManager->pocket setObject:@"YES" forKey:@"needDiscoverDescriptorsForCharacteristic"];
        return self;
    };
}

//设置读取到Descriptors值的block
- (FRIBluetooth *(^)(void)) readValueForDescriptors {
    return ^FRIBluetooth *() {
        [self->friCentralManager->pocket setObject:@"YES" forKey:@"needReadValueForDescriptors"];
        return self;
    };
}

//开始并执行
- (FRIBluetooth *(^)(void)) begin {
    return ^FRIBluetooth *() {
        //取消未执行的stop定时任务
        [self->timerForStop invalidate];
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self resetSeriseParmeter];
            //处理链式函数缓存的数据
            if ([[self->friCentralManager->pocket valueForKey:@"needScanForPeripherals"] isEqualToString:@"YES"]) {
                self->friCentralManager->needScanForPeripherals = YES;
            }
            if ([[self->friCentralManager->pocket valueForKey:@"needConnectPeripheral"] isEqualToString:@"YES"]) {
                self->friCentralManager->needConnectPeripheral = YES;
            }
            if ([[self->friCentralManager->pocket valueForKey:@"needDiscoverServices"] isEqualToString:@"YES"]) {
                self->friCentralManager->needDiscoverServices = YES;
            }
            if ([[self->friCentralManager->pocket valueForKey:@"needDiscoverCharacteristics"] isEqualToString:@"YES"]) {
                self->friCentralManager->needDiscoverCharacteristics = YES;
            }
            if ([[self->friCentralManager->pocket valueForKey:@"needReadValueForCharacteristic"] isEqualToString:@"YES"]) {
                self->friCentralManager->needReadValueForCharacteristic = YES;
            }
            if ([[self->friCentralManager->pocket valueForKey:@"needDiscoverDescriptorsForCharacteristic"] isEqualToString:@"YES"]) {
                self->friCentralManager->needDiscoverDescriptorsForCharacteristic = YES;
            }
            if ([[self->friCentralManager->pocket valueForKey:@"needReadValueForDescriptors"] isEqualToString:@"YES"]) {
                self->friCentralManager->needReadValueForDescriptors = YES;
            }
            //调整委托方法的channel，如果没设置默认为缺省频道
            NSString *channel = [self->friCentralManager->pocket valueForKey:@"channel"];
            [self->friSpeaker switchChannel:channel];
            //缓存的peripheral
            CBPeripheral *cachedPeripheral = [self->friCentralManager->pocket valueForKey:NSStringFromClass([CBPeripheral class])];
            //校验series合法性
            [self validateProcess];
            //清空pocjet
            self->friCentralManager->pocket = [[NSMutableDictionary alloc]init];
            //开始扫描或连接设备
            [self start:cachedPeripheral];
        });
        return self;
    };
}


//私有方法，扫描或连接设备
- (void)start:(CBPeripheral *)cachedPeripheral {
    if (friCentralManager->centralManager.state == CBCentralManagerStatePoweredOn) {
        CENTRAL_MANAGER_INIT_WAIT_TIMES = 0;
        //扫描后连接
        if (friCentralManager->needScanForPeripherals) {
            //开始扫描peripherals
            [friCentralManager scanPeripherals];
        }
        //直接连接
        else {
            if (cachedPeripheral) {
                [friCentralManager connectToPeripheral:cachedPeripheral];
            }
        }
        return;
    }
    //尝试重新等待CBCentralManager打开
    CENTRAL_MANAGER_INIT_WAIT_TIMES ++;
    if (CENTRAL_MANAGER_INIT_WAIT_TIMES >= KFRI_CENTRAL_MANAGER_INIT_WAIT_TIMES ) {
        FRILog(@">>> 第%d次等待CBCentralManager 打开任然失败，请检查你蓝牙使用权限或检查设备问题。",CENTRAL_MANAGER_INIT_WAIT_TIMES);
        return;
        //[NSException raise:@"CBCentralManager打开异常" format:@"尝试等待打开CBCentralManager5次，但任未能打开"];
    }
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, KFRI_CENTRAL_MANAGER_INIT_WAIT_SECOND * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self start:cachedPeripheral];
    });
    FRILog(@">>> 第%d次等待CBCentralManager打开",CENTRAL_MANAGER_INIT_WAIT_TIMES);
}

//sec秒后停止
- (FRIBluetooth *(^)(int sec))  stop {
    
    return ^FRIBluetooth *(int sec) {
        FRILog(@">>> stop in %d sec",sec);
        
        //听见定时器执行friStop
        self->timerForStop = [NSTimer timerWithTimeInterval:sec target:self selector:@selector(friStop) userInfo:nil repeats:NO];
        [self->timerForStop setFireDate: [[NSDate date]dateByAddingTimeInterval:sec]];
        [[NSRunLoop currentRunLoop] addTimer:self->timerForStop forMode:NSRunLoopCommonModes];
        
        return self;
    };
}

//私有方法，停止扫描和断开连接，清空pocket
- (void)friStop {
    FRILog(@">>>did stop");
    [timerForStop invalidate];
    [self resetSeriseParmeter];
    friCentralManager->pocket = [[NSMutableDictionary alloc]init];
    //停止扫描，断开连接
    [friCentralManager cancelScan];
    [friCentralManager cancelAllPeripheralsConnection];
}

//重置串行方法参数
- (void)resetSeriseParmeter {
    friCentralManager->needScanForPeripherals = NO;
    friCentralManager->needConnectPeripheral = NO;
    friCentralManager->needDiscoverServices = NO;
    friCentralManager->needDiscoverCharacteristics = NO;
    friCentralManager->needReadValueForCharacteristic = NO;
    friCentralManager->needDiscoverDescriptorsForCharacteristic = NO;
    friCentralManager->needReadValueForDescriptors = NO;
}

//持有对象
- (FRIBluetooth *(^)(id obj)) having {
    return ^(id obj) {
        [self->friCentralManager->pocket setObject:obj forKey:NSStringFromClass([obj class])];
        return self;
    };
}


//切换委托频道
- (FRIBluetooth *(^)(NSString *channel)) channel {
    return ^FRIBluetooth *(NSString *channel) {
        //先缓存数据，到begin方法统一处理
        [self->friCentralManager->pocket setValue:channel forKey:@"channel"];
        return self;
    };
}

- (void)validateProcess {
    
    NSMutableArray *faildReason = [[NSMutableArray alloc]init];
    
    //规则：不执行discoverDescriptorsForCharacteristic()时，不能执行readValueForDescriptors()
    if (!friCentralManager->needDiscoverDescriptorsForCharacteristic) {
        if (friCentralManager->needReadValueForDescriptors) {
            [faildReason addObject:@"未执行discoverDescriptorsForCharacteristic()不能执行readValueForDescriptors()"];
        }
    }
    
    //规则：不执行discoverCharacteristics()时，不能执行readValueForCharacteristic()或者是discoverDescriptorsForCharacteristic()
    if (!friCentralManager->needDiscoverCharacteristics) {
        if (friCentralManager->needReadValueForCharacteristic||friCentralManager->needDiscoverDescriptorsForCharacteristic) {
            [faildReason addObject:@"未执行discoverCharacteristics()不能执行readValueForCharacteristic()或discoverDescriptorsForCharacteristic()"];
        }
    }
    
    //规则： 不执行discoverServices()不能执行discoverCharacteristics()、readValueForCharacteristic()、discoverDescriptorsForCharacteristic()、readValueForDescriptors()
    if (!friCentralManager->needDiscoverServices) {
        if (friCentralManager->needDiscoverCharacteristics||friCentralManager->needDiscoverDescriptorsForCharacteristic ||friCentralManager->needReadValueForCharacteristic ||friCentralManager->needReadValueForDescriptors) {
             [faildReason addObject:@"未执行discoverServices()不能执行discoverCharacteristics()、readValueForCharacteristic()、discoverDescriptorsForCharacteristic()、readValueForDescriptors()"];
        }
        
    }

    //规则：不执行connectToPeripherals()时，不能执行discoverServices()
    if(!friCentralManager->needConnectPeripheral) {
        if (friCentralManager->needDiscoverServices) {
             [faildReason addObject:@"未执行connectToPeripherals()不能执行discoverServices()"];
        }
    }
    
    //规则：不执行needScanForPeripherals()，那么执行connectToPeripheral()方法时必须用having(peripheral)传入peripheral实例
    if (!friCentralManager->needScanForPeripherals) {
        CBPeripheral *peripheral = [friCentralManager->pocket valueForKey:NSStringFromClass([CBPeripheral class])];
        if (!peripheral) {
            [faildReason addObject:@"若不执行scanForPeripherals()方法，则必须执行connectToPeripheral方法并且需要传入参数(CBPeripheral *)peripheral"];
        }
    }
    
    //抛出异常
    if ([faildReason lastObject]) {
        NSException *e = [NSException exceptionWithName:@"BadyBluetooth usage exception" reason:[faildReason lastObject]  userInfo:nil];
        @throw e;
    }
  
}

- (FRIBluetooth *) and {
    return self;
}
- (FRIBluetooth *) then {
    return self;
}
- (FRIBluetooth *) with {
    return self;
}

- (FRIBluetooth *(^)(void)) enjoy {
    return ^FRIBluetooth *(void) {
        self.connectToPeripherals().discoverServices().discoverCharacteristics()
        .readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
        return self;
    };
}

#pragma mark - 工具方法
//断开连接
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
    [friCentralManager cancelPeripheralConnection:peripheral];
}
//断开所有连接
- (void)cancelAllPeripheralsConnection {
    [friCentralManager cancelAllPeripheralsConnection];
}
//停止扫描
- (void)cancelScan{
    [friCentralManager cancelScan];
}
//读取Characteristic的详细信息
- (FRIBluetooth *(^)(CBPeripheral *peripheral,CBCharacteristic *characteristic)) characteristicDetails {
    //切换频道
    [friSpeaker switchChannel:[friCentralManager->pocket valueForKey:@"channel"]];
    friCentralManager->pocket = [[NSMutableDictionary alloc]init];
    
    return ^(CBPeripheral *peripheral,CBCharacteristic *characteristic) {
        //判断连接状态
        if (peripheral.state == CBPeripheralStateConnected) {
            self->friCentralManager->oneReadValueForDescriptors = YES;
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral discoverDescriptorsForCharacteristic:characteristic];
        }
        else {
            FRILog(@"!!!设备当前处于非连接状态");
        }
        
        return self;
    };
}

- (void)notify:(CBPeripheral *)peripheral
characteristic:(CBCharacteristic *)characteristic
        block:(void(^)(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error))block {
    //设置通知
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    [friSpeaker addNotifyCallback:characteristic withBlock:block];
}

- (void)cancelNotify:(CBPeripheral *)peripheral
     characteristic:(CBCharacteristic *)characteristic {
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
    [friSpeaker removeNotifyCallback:characteristic];
}

//获取当前连接的peripherals
- (NSArray *)findConnectedPeripherals {
     return [friCentralManager findConnectedPeripherals];
}

- (NSArray *)allRestorePeripherals{
    return [friCentralManager allRestorePeripherals];
}

//获取当前连接的peripheral
- (CBPeripheral *)findConnectedPeripheral:(NSString *)peripheralName {
     return [friCentralManager findConnectedPeripheral:peripheralName];
}

//获取当前corebluetooth的centralManager对象
- (CBCentralManager *)centralManager {
    return friCentralManager->centralManager;
}

/**
 添加断开自动重连的外设
 */
- (void)AutoReconnect:(CBPeripheral *)peripheral{
    [friCentralManager sometimes_ever:peripheral];
}

/**
 删除断开自动重连的外设
 */
- (void)AutoReconnectCancel:(CBPeripheral *)peripheral{
    [friCentralManager sometimes_never:peripheral];
}
 
- (CBPeripheral *)retrievePeripheralWithUUIDString:(NSString *)UUIDString {
    CBPeripheral *p = nil;
    @try {
        NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:UUIDString];
        p = [self.centralManager retrievePeripheralsWithIdentifiers:@[uuid]][0];
    } @catch (NSException *exception) {
        FRILog(@">>> retrievePeripheralWithUUIDString error:%@",exception)
    } @finally {
    }
    return p;
}

@end


