//
//  FRIBeats.m
//  FRIBluetoothAppDemo
//
//
//

#import "FRIRhythm.h"
#import "FRIDefine.h"

@implementation FRIRhythm {
    BOOL isOver;
    BBBeatsBreakBlock blockOnBeatBreak;
    BBBeatsOverBlock blockOnBeatOver;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //beatsInterval
        _beatsInterval = KFRIRHYTHM_BEATS_DEFAULT_INTERVAL;
    }
    return  self;
}

- (void)beats {
    
    if (isOver) {
        FRILog(@">>>beats isOver");
        return;
    }
    
    FRILog(@">>>beats at :%@",[NSDate date]);
    if (self.beatsTimer) {
        [self.beatsTimer setFireDate: [[NSDate date]dateByAddingTimeInterval:self.beatsInterval]];
    }
    else {
       self.beatsTimer = [NSTimer timerWithTimeInterval:self.beatsInterval target:self selector:@selector(beatsBreak) userInfo:nil repeats:YES];
        [self.beatsTimer setFireDate: [[NSDate date]dateByAddingTimeInterval:self.beatsInterval]];
        [[NSRunLoop currentRunLoop] addTimer:self.beatsTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)beatsBreak {
     FRILog(@">>>beatsBreak :%@",[NSDate date]);
    [self.beatsTimer setFireDate:[NSDate distantFuture]];
    if (blockOnBeatBreak) {
        blockOnBeatBreak(self);
    }
}

- (void)beatsOver {
    FRILog(@">>>beatsOver :%@",[NSDate date]);
    [self.beatsTimer setFireDate:[NSDate distantFuture]];
    isOver = YES;
    if (blockOnBeatOver) {
        blockOnBeatOver(self);
    }
    
}

- (void)beatsRestart {
    FRILog(@">>>beatsRestart :%@",[NSDate date]);
    isOver = NO;
    [self beats];
}

- (void)setBlockOnBeatsBreak:(void(^)(FRIRhythm *bry))block {
    blockOnBeatBreak = block;
}

- (void)setBlockOnBeatsOver:(void(^)(FRIRhythm *bry))block {
    blockOnBeatOver = block;
}

@end
