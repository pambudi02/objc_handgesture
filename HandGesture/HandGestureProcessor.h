//
//  HandGestureProcessor.h
//  HandGesture
//
//  Created by Pambudi on 18/11/20.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "PointsPair.h"

typedef NS_ENUM(NSInteger, HandGestureState)
{
    HandGestureStatePossiblePinch=0,
    HandGestureStatePinched,
    HandGestureStatePossibleApart,
    HandGestureStateApart,
    HandGestureStateUnknown
};

NS_ASSUME_NONNULL_BEGIN
@protocol HandGestureProcessorDelegate;
@interface HandGestureProcessor : NSObject

@property(nonatomic) id <HandGestureProcessorDelegate> delegate;
@property (nonatomic) HandGestureState state;
@property (nonatomic) PointsPair *lastProcessedPointsPair;
@property(nonatomic) BOOL busyDetecting;

-(void)processPointsPair:(PointsPair*)pointsPair;
@end

@protocol HandGestureProcessorDelegate <NSObject>
@optional
-(void)didChangeStateClosure:(HandGestureState)state;

@end
NS_ASSUME_NONNULL_END
