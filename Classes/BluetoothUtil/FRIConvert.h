
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>



@interface FRIConvert : NSObject

//小端转化到大端
+(NSString *)convertHexEndianToEndian:(NSString *)littleHex;

//16进制字符转(带0x),转NSData
+ (NSData *)prexHexStrToData:(NSString *)str;

/**
 NSData转16进制NSString(无0x)
 
 @param data data数据
 @return string数据
 */
+(NSString *)noPrexHexStrFromData:(NSData *)data;

/**
 NSData转16进制NSString(有0x)
 
 @param data data数据
 @return string数据
 */
+(NSString *)prexHexStrFromData:(NSData *)data;

/**
 10进制转16进制
 @param decimal 10进制数字
 @return 16进制字符串
 */
+ (NSString *)noPrexHexStrFromDecimal:(NSInteger)decimal;


+ (NSNumber *)decimalFromData:(NSData *)data;

/**
 16进制转10进制
 @param aHexString 16进制字符串
 */
+ (NSNumber *)decimalFromHexStr:(NSString *)aHexString;

//补位的方法
+(NSString*)addString:(NSString*)string length:(NSInteger)length onString:(NSString*)str;

/**
 10进制数据转data
 @param decimal 10进制数字
 */
+ (NSData *)dataForDecimal:(NSInteger)decimal;

/**
 转换大端数据到小端
 */
+(NSData *)littleEndianDataFrom:(NSData *)data;

/**
 转换部分data数据到本地小端模式
 @param bigEndianData 大端数据
 @param location 位置
 @param offset 偏移
 */
+(NSData *)littleEndianDataFrom:(NSData *)bigEndianData location:(NSInteger)location offset:(NSInteger)offset;

@end
