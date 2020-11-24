//
//  HandGestureProcessor.m
//  HandGesture
//
//  Created by Pambudi on 18/11/20.
//

#import "HandGestureProcessor.h"
@import CoreGraphics;

@interface HandGestureProcessor()
{
    NSInteger pinchEvidenceCounter;
    NSInteger apartEvidenceCounter;
    
}
@property(nonatomic) CGFloat pinchMaxDistance;
@property(nonatomic) NSInteger evidenceCounterStateTrigger;

@end

@implementation HandGestureProcessor

-(instancetype)init
{
    self = [super init];
    if (self) {
        _pinchMaxDistance = 40;
        _evidenceCounterStateTrigger = 3;
    }
    return self;
}
-(instancetype)initWithPinchMaxDistance:(CGFloat)maxDistance evidenceCounterStateTrigger:(NSInteger)counter
{
    self = [super init];
    if (self) {
        _pinchMaxDistance = maxDistance;
        _evidenceCounterStateTrigger = counter;
    }
    return self;
}

-(void)reset
{
    self.state = HandGestureStateUnknown;
    pinchEvidenceCounter = 0;
    apartEvidenceCounter = 0;
}

-(void)processPointsPair:(PointsPair*)pointsPair
{
    _lastProcessedPointsPair = pointsPair;
    
    CGFloat distance = hypot(pointsPair.thumbTip.x-pointsPair.indexTip.x,
                             pointsPair.thumbTip.y-pointsPair.indexTip.y);

    if (distance<self.pinchMaxDistance) {
        pinchEvidenceCounter++;
        apartEvidenceCounter = 0;
        self.state = (pinchEvidenceCounter>=self.evidenceCounterStateTrigger)?HandGestureStatePinched:HandGestureStatePossiblePinch;
        
    }
    else
    {
        apartEvidenceCounter++;
        pinchEvidenceCounter = 0;
        self.state = (apartEvidenceCounter>=self.evidenceCounterStateTrigger)?HandGestureStateApart:HandGestureStatePossibleApart;
    }
}

-(void)setState:(HandGestureState)state
{
//    if (_state==state) return;
    _state = state;
    if([self.delegate respondsToSelector:@selector(didChangeStateClosure:)])
    {
        [self.delegate didChangeStateClosure:state];
    }
}

@end
