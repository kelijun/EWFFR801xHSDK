/*
//
 
 @brief  fribluetooth Rhythm用于检测蓝牙的任务执行情况，处理复杂的蓝牙流程操作
 
 */
//
//
//

#import <Foundation/Foundation.h>
#import "FRIDefine.h"


@interface FRIRhythm : NSObject


typedef void (^BBBeatsBreakBlock)(FRIRhythm *bry);
typedef void (^BBBeatsOverBlock)(FRIRhythm *bry);

//timer for beats
@property (nonatomic, strong) NSTimer *beatsTimer;

//beat interval
@property NSInteger beatsInterval;



#pragma mark beats
//心跳
- (void)beats;
//主动中断心跳
- (void)beatsBreak;
//结束心跳，结束后会进入BlockOnBeatOver，并且结束后再不会在触发BlockOnBeatBreak
- (void)beatsOver;
//恢复心跳，beatsOver操作后可以使用beatsRestart恢复心跳，恢复后又可以进入BlockOnBeatBreak方法
- (void)beatsRestart;

//心跳中断的委托
- (void)setBlockOnBeatsBreak:(void(^)(FRIRhythm *bry))block;
//心跳结束的委托
- (void)setBlockOnBeatsOver:(void(^)(FRIRhythm *bry))block;

@end
