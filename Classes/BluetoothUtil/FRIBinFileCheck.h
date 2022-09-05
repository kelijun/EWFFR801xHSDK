//
//  FRIBinFileCheck.h
//  FRQBluetoothKit
//
//  Created by chunhai xu on 2021/1/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FRIBinFileCheck : NSObject

+(uint32_t)crc32ForBinFile:(NSData *)binData;

@end

NS_ASSUME_NONNULL_END
