//
//

#import "FRIConvert.h"

@implementation FRIConvert

//小端转化到大端
+(NSString *)convertHexEndianToEndian:(NSString *)littleHex
{
    littleHex = [littleHex stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    littleHex = [littleHex stringByReplacingOccurrencesOfString:@"0X" withString:@""];
    
    NSMutableArray *tempArr = [NSMutableArray array];
    for (int i = 0; i < littleHex.length; i +=2) {
        [tempArr addObject:[littleHex substringWithRange:NSMakeRange(i, 2)]];
    }
    
    NSMutableString *reverseHexStr = [NSMutableString string];
    [tempArr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *hexWord, NSUInteger idx, BOOL * _Nonnull stop) {
        [reverseHexStr appendString:hexWord];
    }];
    return reverseHexStr;
}

+(NSData*)noPrexHexStrToData:(NSString*)str
{
    NSString *command = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < command.length/2; i++) {
        byte_chars[0] = [command characterAtIndex:i*2];
        byte_chars[1] = [command characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    return commandToSend;
}


+ (NSData *)prexHexStrToData:(NSString *)str{
    if (!str || [str length] == 0||str.length<=2) {
        return nil;
    }
    
    str = [str stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"0X" withString:@""];
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range = NSMakeRange(0, 2);
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    return hexData;
}

+ (NSString *)noPrexHexStrFromDecimal:(NSInteger)decimal
{
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", (long)number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    if (hex.length == 1) {
        hex = [NSString stringWithFormat:@"0%@",hex];
    }
    return hex;
}


+ (NSNumber *)decimalFromData:(NSData *)data{
    
    NSString *noPrexHexStr = [FRIConvert noPrexHexStrFromData:data];
    return [FRIConvert decimalFromHexStr:noPrexHexStr];
}

+(NSData *)dataForDecimal:(NSInteger)decimal{
    NSString *conentHexStr = [FRIConvert noPrexHexStrFromDecimal:decimal];
    return [FRIConvert noPrexHexStrToData:conentHexStr];
}

+ (NSString *)noPrexHexStrFromData:(NSData *)data
{
    Byte *bytes = (Byte *)[data bytes];
    //下面是Byte 转换为16进制
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1){
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }else{
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    return hexStr;
}


//补位的方法
+(NSString*)addString:(NSString*)string length:(NSInteger)length onString:(NSString*)str{
    
    NSMutableString * nullStr = [[NSMutableString alloc] initWithString:@""];
    if (length > str.length) {
        for (int i = 0; i< (length-str.length); i++) {
            [nullStr appendString:string];
        }
    }
    return [NSString stringWithFormat:@"%@%@",nullStr,str];
}

+(NSString *)prexHexStrFromData:(NSData *)data{
    return [NSString stringWithFormat:@"0x%@",[self noPrexHexStrFromData:data]];
    
}

+ (NSNumber *)decimalFromHexStr:(NSString *)aHexString{
    // 为空,直接返回.
    if (!aHexString){
        return nil;
    }

    NSScanner * scanner = [NSScanner scannerWithString:aHexString];
    unsigned long long longlongValue;
    [scanner scanHexLongLong:&longlongValue];
    return @(longlongValue);
    
}

+(NSData *)littleEndianDataFrom:(NSData *)data{
    
    NSMutableData *newCopyData = [NSMutableData dataWithLength:data.length];
    @autoreleasepool {
        int intLen = 4;
        int idx = 0;
        BOOL needLoop = YES;
        do {
            int needClipLen = intLen;
            if (idx + intLen > data.length) {
                needClipLen = data.length - idx;
                needLoop = NO;
            }
            
            NSData *tempData = [self littleEndianDataFrom:data location:idx offset:needClipLen];
            if (tempData) {
                [newCopyData appendData:tempData];
            }
            
        } while (needLoop);
    }
    return newCopyData;
}


+(NSData *)littleEndianDataFrom:(NSData *)data location:(NSInteger)location offset:(NSInteger)offset{
    
    NSData *intdata= [data subdataWithRange:NSMakeRange(location, offset)];
    if (offset == 2 ) {
        uint16_t value=CFSwapInt16BigToHost(*(int*)([intdata bytes]));
        return [NSData dataWithBytes:&value length:offset];
    }
    else if (offset == 4) {
        uint32_t value = CFSwapInt32BigToHost(*(int*)([intdata bytes]));
        return [NSData dataWithBytes:&value length:offset];
    }
    else if (offset == 1) {
        unsigned char *bs = (unsigned char *)[[data subdataWithRange:NSMakeRange(location, 1) ] bytes];
        return [NSData dataWithBytes:bs length:offset];
    }
    return nil;
}

@end


