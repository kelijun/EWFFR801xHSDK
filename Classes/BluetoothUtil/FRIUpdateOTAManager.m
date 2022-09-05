//
//  FRIUpdateOTAManager.m
//  FRQBluetoothKit
//
//  Created by chunhai xu on 2021/1/3.
//

#import "FRIUpdateOTAManager.h"
#import "FRIBluetooth.h"
#import "FRIConvert.h"
#import "FRBleAbility.h"
#import "FRIBinFileCheck.h"


#define kFRQCmdHeadLen 3 //cmd head = 3
#define kFRQRspHeadLen 4 //rsp head = 4
#define kFRQBaseAddressResultLen 4 //base addr len 4
#define kFRQUpdateAddressLen 4
#define kFRQRspResultCodeLen 1 //response result head code

#define ERASE_PAGE_SIZE  4096 //erase out page offset

#define BLE_SEND_MAX_LEN 20 //最大发送20字节
#define OTA_SUBPACKAGE_LEN 235 //ota subpackage len 235


typedef NS_ENUM(NSUInteger, FRQRspHeadCode) {
    FRQRspHeadCodeOk = 0, //ok
    FRQRspHeadCodeFail = 1, //fail
};

//响应数据
@interface FRITrunk : NSObject

@property(nonatomic, assign) uint8_t rsp_code; //response code 0: ok; 1: fail
@property(nonatomic, assign) uint32_t base_addr; //base address
@property(nonatomic, assign) uint32_t erase_base_addr; //erase base address

@property(nonatomic, strong) NSData *rsp_data; //rsp data

@property(nonatomic, assign) uint32_t update_addr; //ota update base address


@end

@implementation FRITrunk
@end


@interface FRIUpdateOTAManager ()

@property(nonatomic, assign, readwrite) FRIOTAStatus otaStatus; //!< ota操作状态
@property(nonatomic, strong, readwrite) CBPeripheral *curPeripheral; //蓝牙外设

@property(nonatomic, strong) FRITrunk *otaTrunk; //ota trunk


@property(nonatomic, strong) CBCharacteristic *writeCharacteristic; //写特征值
@property(nonatomic, strong) CBCharacteristic *readCharacteristic; //读特征值

@end


@implementation FRIUpdateOTAManager

static NSThread *shareThread = nil;
#pragma mark -- thread
- (NSThread *)otaThread {
    @synchronized (self) {
        if (!shareThread) {
            shareThread = [[NSThread alloc] initWithTarget:self selector:@selector(onOTAThreadStart) object:nil];
            shareThread.name = @"com.frq.ota.thread";
        }
    }
    return shareThread;
}

-(void)onOTAThreadStart{
    @autoreleasepool {

        [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        //保持循环执行
        while ((self.otaStatus != FRIOTAStatusCanceled && self.otaStatus != FRIOTAStatusFinish && self.otaStatus !=FRIOTAStatusFailure)
               && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
        
        shareThread = nil;
    }
}

#pragma mark -- getter and setter
- (FRITrunk *)otaTrunk{
    if (!_otaTrunk) {
        _otaTrunk = [[FRITrunk alloc] init];
    }
    return _otaTrunk;
}

- (void)setFriBLE:(FRIBluetooth *)friBLE{
    _friBLE = friBLE;
    [self _setupBleBlocks];
}

#pragma mark --- private
-(void)_setupBleBlocks{
    
    __weak typeof(self) weakSelf = self;
    [self.friBLE setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        if (error) {
            FRILog(@"💥💥💥💥on write value to characteristic!! %@, error %@ !!",characteristic.UUID.UUIDString,error);
        }
        else{
            FRILog(@"did write value to characteristic %@!!",characteristic.UUID.UUIDString);
            
            if (strongSelf.otaStatus == FRIOTAStatusReboot) { //重启指令暂无rsp，所以在指令发送成功后就直接断开
                
                FRILog(@"🏆🏆 重启完成 ！！");
                strongSelf.otaStatus = FRIOTAStatusFinish;
                [strongSelf postOTAUpdateProgressChanged:100.0];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([strongSelf.delegate respondsToSelector:@selector(onOTAUpdateStatusCompletion:)]) {
                        [strongSelf.delegate onOTAUpdateStatusCompletion:strongSelf];
                    }
                });
            }
        }
    }];
    
}

-(void)resetOTAStatus{
    
    self.otaStatus = FRIOTAStatusNotStart;
}

-(BOOL)isPeripheralConnected:(CBPeripheral *)peripheral{
    
    if ([self.friBLE findConnectedPeripheral:peripheral.name]) {
        return YES;
    }
    return NO;
}

//写数据
-(void)_writeDataToPeripheral:(CBPeripheral *)peripheral
            characteristic:(CBCharacteristic *)characteristic
                     value:(NSData *)data{

    if (![self isPeripheralConnected:peripheral]) {
        
        [self postErrorWithCode:FRQErrorCode_connect msg:@"蓝牙设备未连接，请重试！"];
        return;
    }
    
    //开始处理交互数据
    if (!self.writeCharacteristic) {
        [self postErrorWithCode:FRQErrorCode_connect msg:@"当前未找到蓝牙读写设备！"];
        return;
    }
    FRILog(@"😀😀😀😀send data<%@> = %@  to <%@>！！",@(data.length),[FRIConvert prexHexStrFromData:data], characteristic.UUID.UUIDString);
    
    //这是一个NS_OPTIONS，就是可以同时用于好几个值，常见的有read，write，notify，indicate，知知道这几个基本就够用了，前连个是读写权限，后两个都是通知，两种不同的通知方式。
    /*
     typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
     CBCharacteristicPropertyBroadcast                                                = 0x01,
     CBCharacteristicPropertyRead                                                    = 0x02,
     CBCharacteristicPropertyWriteWithoutResponse                                    = 0x04,
     CBCharacteristicPropertyWrite                                                    = 0x08,
     CBCharacteristicPropertyNotify                                                    = 0x10,
     CBCharacteristicPropertyIndicate                                                = 0x20,
     CBCharacteristicPropertyAuthenticatedSignedWrites                                = 0x40,
     CBCharacteristicPropertyExtendedProperties                                        = 0x80,
     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)        = 0x100,
     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)    = 0x200
     };

     */
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWrite){
        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
    else if (characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
        
        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    }
    else{
        FRILog(@"该字段不可写！");
    }
    
}

//分包发送蓝牙数据
-(void)sendMsgWithSubPackage:(NSData*)msgData
                  Peripheral:(CBPeripheral*)peripheral
              Characteristic:(CBCharacteristic*)character
{
    
    for (int i = 0; i < msgData.length; i += BLE_SEND_MAX_LEN) {
        
        NSData *subData = nil;
        // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
        if ((i + BLE_SEND_MAX_LEN) < [msgData length]) {
            subData = [msgData subdataWithRange:NSMakeRange(i, BLE_SEND_MAX_LEN)];
        }
        else {
            subData = [msgData subdataWithRange:NSMakeRange(i, [msgData length] - i)];
        }
        
        [self _writeDataToPeripheral:peripheral
                   characteristic:character
                            value:subData];
    }
   
}


#pragma mark -- build head cmd
-(NSData *)buildCMDHeaderDataWithOpcode:(NSString *)opcodeHex len:(NSString *)lenHex {
    
    NSMutableData *headData = [NSMutableData data];
    NSData *opcodeData = [FRIConvert prexHexStrToData:opcodeHex];
    [headData appendBytes:opcodeData.bytes length:1];

    //大小端数据转化
    NSString *bigEndianStr = [FRIConvert convertHexEndianToEndian:lenHex];
    NSData *bigEndianData = [FRIConvert prexHexStrToData:bigEndianStr];
    [headData appendBytes:bigEndianData.bytes length:2];
    
    return headData;
}

-(NSData *)buildCmdDataForBaseAddress{
    
    NSData *cmdHead = [self buildCMDHeaderDataWithOpcode:@"0x01" len:@"0x0000"];
    
    //build
    NSMutableData *cmdData = [NSMutableData dataWithLength:kFRQCmdHeadLen + 6];
    [cmdData replaceBytesInRange:NSMakeRange(0, kFRQCmdHeadLen) withBytes:cmdHead.bytes];//replace 3 bytes
    
    return cmdData;
}

-(NSData *)buildCmdDataForErase{
    
    NSData *cmdHead = [self buildCMDHeaderDataWithOpcode:@"0x03" len:@"0x0004"];
    
    NSMutableData *cmdData = [NSMutableData dataWithLength:kFRQCmdHeadLen + 4];
    [cmdData replaceBytesInRange:NSMakeRange(0, kFRQCmdHeadLen) withBytes:cmdHead.bytes];//replace 3 bytes
    
    //base address
    
    NSString *hex = [FRIConvert noPrexHexStrFromDecimal:self.otaTrunk.erase_base_addr];
    NSString *newHexStr = [FRIConvert addString:@"0" length:4*2 onString:hex]; //补位
    
    //数据大小端转化
    NSString *bigEndianStr = [FRIConvert convertHexEndianToEndian:newHexStr];
    NSData *baseAddrData = [FRIConvert prexHexStrToData:bigEndianStr];
    
    [cmdData replaceBytesInRange:NSMakeRange(kFRQCmdHeadLen, 4) withBytes:baseAddrData.bytes];
    
    return cmdData;
}


-(NSData *)buildCmdUpdateData:(NSData *)subPackage fromAddr:(NSString *)addressHex{
    
    NSData *cmdHead = [self buildCMDHeaderDataWithOpcode:@"0x05" len:@"0x0241"];
    NSMutableData *cmdData = [NSMutableData data];
    [cmdData appendData:cmdHead]; //add head
    
    //base addr
    NSData *baseAddrData = [FRIConvert prexHexStrToData:addressHex];
    [cmdData appendBytes:baseAddrData.bytes length:kFRQUpdateAddressLen]; // 4 bytes
    
    //content len
    NSString *lenHexStr = [FRIConvert noPrexHexStrFromDecimal:235];
    NSString *newHexStr = [FRIConvert addString:@"0" length:2*2 onString:lenHexStr]; //补位
    NSString *bigEndianLenStr = [FRIConvert convertHexEndianToEndian:newHexStr];
    NSData *contentLenData = [FRIConvert prexHexStrToData:bigEndianLenStr];
    [cmdData appendBytes:contentLenData.bytes length:2]; //2 bytes
    
    //content
    [cmdData appendData:subPackage]; //package data
    
    return cmdData;
}

-(NSData *)buildRebootCmdData{
    
//    NSData *cmdHead = [self buildCMDHeaderDataWithOpcode:@"0x09" len:@"0x0000"];
    
    //此处需要特殊处理
    uint32_t crc32 = [FRIBinFileCheck crc32ForBinFile:self.binData];
    uint32_t length = (uint32_t)self.binData.length;
    
    Byte rebootCmd[11];
    rebootCmd[0] = (Byte) (9 & 0xff);
    rebootCmd[1] = 0xa;
    rebootCmd[2] = 0x00;
    rebootCmd[3] = (Byte) (length & 0xff);
    rebootCmd[4] = (Byte) ((length & 0xff00) >> 8);
    rebootCmd[5] = (Byte) ((length & 0xff0000) >> 16);
    rebootCmd[6] = (Byte) ((length & 0xff000000) >> 24);
    rebootCmd[7] = (Byte) (crc32 & 0xff);
    rebootCmd[8] = (Byte) ((crc32 & 0xff00) >> 8);
    rebootCmd[9] = (Byte) ((crc32 & 0xff0000) >> 16);
    rebootCmd[10] = (Byte) ((crc32 & 0xff000000) >> 24);
    
//    [cmdData replaceBytesInRange:NSMakeRange(0, kFRQCmdHeadLen) withBytes:cmdHead.bytes]; //replace 3 bytes
    return [NSData dataWithBytes:rebootCmd length:11];
}

#pragma mark --check bin data

#define FRICHECKHEXSTR @"0x0167"
#define FRIFlAGHEXSTR @"0x51525251"

-(BOOL)checkBinValidate:(NSData *)binData{
    
    //data empty
    if (binData.length <= 0) {
        return NO;
    }
    
    int flagByteSize = 4;
    
    //convert 16 to 10
    uint32_t checkByteIndex = 0;
    NSScanner* scanner = [NSScanner scannerWithString:FRICHECKHEXSTR];
    [scanner scanHexInt:&checkByteIndex];
    
    if (binData.length > checkByteIndex + flagByteSize) {
        //read last 4 Bytes data
        NSData *flagData = [binData subdataWithRange:NSMakeRange(checkByteIndex, flagByteSize)];
        NSString *flagHexStr = [FRIConvert prexHexStrFromData:flagData];
        if ([flagHexStr isEqualToString:FRIFlAGHEXSTR]) { //check flag byte
            //bin is validate
            return YES;
        }
    }

    return NO;
}


#pragma mark -- handle response data
- (void)_sendOTARebootCmd {
    
    NSData *rebootData = [self buildRebootCmdData];
    [self _writeDataToPeripheral:self.curPeripheral characteristic:self.writeCharacteristic value:rebootData];
    
}

- (void)_sendOTAFileDataCmd {
    
    NSData *packageData = nil;
    // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
    int fromDataOffset = self.otaTrunk.update_addr - self.otaTrunk.base_addr;
    if (self.otaTrunk.update_addr+OTA_SUBPACKAGE_LEN < self.otaTrunk.base_addr + self.binData.length) {
        packageData = [self.binData subdataWithRange:NSMakeRange(fromDataOffset, OTA_SUBPACKAGE_LEN)];
    }
    else {
        packageData = [self.binData subdataWithRange:NSMakeRange(fromDataOffset, self.otaTrunk.base_addr + self.binData.length - self.otaTrunk.update_addr)];
    }
    
    
    NSString *baseAddrHexStr = [FRIConvert noPrexHexStrFromDecimal:self.otaTrunk.update_addr];
    NSString *newHexStr = [FRIConvert addString:@"0" length:kFRQUpdateAddressLen*2 onString:baseAddrHexStr]; //补位
    //数据大小端转化
    NSString *bigEndianStr = [FRIConvert convertHexEndianToEndian:newHexStr];
    
    NSData *otaPackageData = [self buildCmdUpdateData:packageData fromAddr:bigEndianStr];
    [self _writeDataToPeripheral:self.curPeripheral characteristic:self.writeCharacteristic value:otaPackageData];
    
    self.otaTrunk.update_addr += OTA_SUBPACKAGE_LEN;
    
}

- (void)_sendOTAEraseCmd {
    
    NSData *eraseCmd = [self buildCmdDataForErase];
    [self _writeDataToPeripheral:self.curPeripheral characteristic:self.writeCharacteristic value:eraseCmd];
    
    self.otaTrunk.erase_base_addr += ERASE_PAGE_SIZE;

}

- (void)_sendBaseAddrCmd {

    NSData *baseAddrCmd = [self buildCmdDataForBaseAddress];
    [self _writeDataToPeripheral:self.curPeripheral characteristic:self.writeCharacteristic value:baseAddrCmd];
}


-(void)_handleCharacteristicResponseData:(NSData *)rspData{
    
    FRILog(@">>> handle rsp hexString = %@ in thread: %@!!!",[FRIConvert prexHexStrFromData:rspData],[NSThread currentThread].name);
    
    //base address data
    if (rspData.length >= kFRQRspHeadLen + kFRQBaseAddressResultLen  && (self.otaStatus == FRIOTAStatusGetBaseAddr || self.otaStatus == FRIOTAStatusEraseOut || self.otaStatus == FRIOTAStatusFileTransform || self.otaStatus == FRIOTAStatusReboot)) {
        self.otaTrunk.rsp_data = [rspData subdataWithRange:NSMakeRange(kFRQRspHeadLen, kFRQBaseAddressResultLen)];
        
        NSData *newRsp = [rspData subdataWithRange:NSMakeRange(0, 1)];
        FRQRspHeadCode resultCode = [FRIConvert decimalFromData:newRsp].integerValue;
        if (resultCode == FRQRspHeadCodeFail) { //success
            FRILog(@"!!!!!!!!! %@ -> %@ !!!!!!",newRsp,[FRIConvert decimalFromData:newRsp]);
            
            [self postErrorWithCode:FRQErrorCode_ota msg:@"response data code failed"];
            return;
        }
    }
    else{
        self.otaTrunk.rsp_data = nil;
    }
    
    switch (self.otaStatus) {
        case FRIOTAStatusNotStart:
        {
            [self postOTAUpdateProgressChanged:5.0];
            
            FRILog(@"🏆🏆 开始获取基地址操作 ！！");
            [self _sendBaseAddrCmd];
            self.otaStatus = FRIOTAStatusGetBaseAddr;
            
        }
            break;
        case FRIOTAStatusGetBaseAddr://step 1 get baseAddr
        {
            
            //基地址进行大端转小端
            NSString *bigEndianHex = [FRIConvert noPrexHexStrFromData:self.otaTrunk.rsp_data];
            NSString *fillEndianHexStr = [FRIConvert addString:@"0" length:kFRQBaseAddressResultLen*2 onString:bigEndianHex];
            NSString *littleEndianHex = [FRIConvert convertHexEndianToEndian:fillEndianHexStr];
            
            self.otaTrunk.base_addr =  (uint32_t)[FRIConvert decimalFromHexStr:littleEndianHex].integerValue;
            self.otaTrunk.erase_base_addr = self.otaTrunk.base_addr;
            self.otaTrunk.update_addr = self.otaTrunk.base_addr;
            
            
            [self postOTAUpdateProgressChanged:10.0];
            
            FRILog(@"🥇 已获取基地址: %@",littleEndianHex);
            
            self.otaStatus = FRIOTAStatusEraseOut;
            
            //send erase cmd
            FRILog(@"🏆🏆 开始擦除操作 ！！");
            
            [self _sendOTAEraseCmd];
            
        }
            break;
        case FRIOTAStatusEraseOut: //step 2 erase data
        {
            if(self.otaTrunk.erase_base_addr < self.otaTrunk.base_addr + self.binData.length) {
                
                float eraseProgress = (float)self.otaTrunk.erase_base_addr/(self.otaTrunk.base_addr + self.binData.length);
                [self postOTAUpdateProgressChanged:eraseProgress * 20.0 + 10.0];
                FRILog(@"🥈 开始擦除地址: %@, 进度 %.2f",[FRIConvert noPrexHexStrFromDecimal:self.otaTrunk.erase_base_addr],eraseProgress);

                [self _sendOTAEraseCmd]; //每次擦除后增加4096个偏移
                
            }
            else{
                
                //发送文件传输操作
                self.otaStatus =FRIOTAStatusFileTransform;
                
                FRILog(@"🏆🏆 开始传输文件操作 ！！");
                [self _sendOTAFileDataCmd];
            }
        }
            break;
        case FRIOTAStatusFileTransform://step 3 transform file data
        {
            //分块传输
            if (self.otaTrunk.update_addr < self.otaTrunk.base_addr + self.binData.length) {
                
                
                FRILog(@"🥉 已传输文件传输大小 %d byte, bin文件总大小 %ld ",self.otaTrunk.update_addr - self.otaTrunk.base_addr,self.binData.length);
                float transformProgress = (float)(self.otaTrunk.update_addr - self.otaTrunk.base_addr)/self.binData.length;
                [self postOTAUpdateProgressChanged:transformProgress * 60.0 + 30.0];
                
                [self _sendOTAFileDataCmd];
                
            }
            else{
                self.otaStatus = FRIOTAStatusReboot;
                
                FRILog(@"🏆🏆 开始重启操作 ！！");
                [self postOTAUpdateProgressChanged:100.0];
                
                //send reboot cmd
                [self _sendOTARebootCmd];
            }

        }
            break;
        case FRIOTAStatusReboot: //step 4 reboot
        {
            //completion
            self.otaStatus = FRIOTAStatusFinish;
            
            [self postOTAUpdateProgressChanged:100.0];
            
            FRILog(@"🏆🏆 重启完成 ！！");
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(onOTAUpdateStatusCompletion:)]) {
                    [self.delegate onOTAUpdateStatusCompletion:self];
                }
            });
        }
            break;
        default:
            
            break;
    }
    
    
}

#pragma mark --- 错误处理
-(void)postErrorWithCode:(FRQErrorCode)errCode msg:(NSString *)errMsg{
    
    self.otaStatus = FRIOTAStatusFailure;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(onOTAUpdateStatusFailure:error:)]) {
            [self.delegate onOTAUpdateStatusFailure:self error:[self errorWithCode:errCode msg:errMsg]];
        }
    });
    
}


-(NSError *)errorWithCode:(NSInteger)code msg:(NSString *)errMsg{
    
    NSString *localDescriptionStr = [NSString stringWithFormat:@"Code: %@, %@",@(code),errMsg];
    return [NSError errorWithDomain:errMsg code:code userInfo:@{NSLocalizedFailureReasonErrorKey:errMsg,NSLocalizedDescriptionKey:localDescriptionStr}];
}

-(void)postOTAUpdateProgressChanged:(float)progress{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(onOTAUpdateStatusDidChange:withProgress:)]) {
            [self.delegate onOTAUpdateStatusDidChange:self withProgress:progress];
        }
    });
    
}


#pragma mark -- public
-(void)startUpdateOTA:(CBPeripheral *)peripheral writeCharacteristic:(CBCharacteristic *)writeCharacteristic readCharacteristic:(CBCharacteristic *)readCharacteristic{
    
    self.writeCharacteristic = writeCharacteristic;
    self.readCharacteristic = readCharacteristic;
    
    if ([self isPeripheralConnected:peripheral]) {

        self.otaStatus = FRIOTAStatusNotStart;
        self.curPeripheral = peripheral;
        
        if ([self.delegate respondsToSelector:@selector(onOTAUpdateStart:)]) {
            [self.delegate onOTAUpdateStart:self];
        }
        //启动线程
        if (![self otaThread].isExecuting) {
            [[self otaThread] start];
        }
        
        //设置notify
        __weak typeof(self) weakSelf = self;
        [self.friBLE notify:self.curPeripheral characteristic:self.readCharacteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }

            if (error) {
                FRILog(@"on readvalue for characteristic %@, error %@ !!!",characteristics.UUID.UUIDString,error);
            }
            else{
                //接收数据并处理
                [strongSelf performSelector:@selector(_handleCharacteristicResponseData:) onThread:[strongSelf otaThread] withObject:characteristics.value waitUntilDone:NO];
            }
        }];
        
        //获取详情
        
        [self performSelector:@selector(_handleCharacteristicResponseData:) onThread:[self otaThread] withObject:nil waitUntilDone:NO];
    }
    else{
        
        [self postErrorWithCode:FRQErrorCode_connect msg:[NSString stringWithFormat:@"蓝牙设备<%@>未连接，请重试~",peripheral.name?:peripheral.identifier]];
    }
}

-(void)cancelOTAUpdate{
    
    if (self.otaStatus != FRIOTAStatusNotStart
        && self.otaStatus != FRIOTAStatusFailure
        && self.otaStatus != FRIOTAStatusCanceled
        && self.otaStatus != FRIOTAStatusFinish)  {
        
        self.otaStatus = FRIOTAStatusCanceled; //状态设置后otaThread线程退出
    }
    
}

@end
