//
//  PointsPair.h
//  HandGesture
//
//  Created by Pambudi on 21/11/20.
//

#import <Foundation/Foundation.h>
@import UIKit;
#define kPointPairThumbTip @"thumbTip"
#define kPointPairIndexTip @"indexTip"

NS_ASSUME_NONNULL_BEGIN

@interface PointsPair : NSDictionary
@property (nonatomic) CGPoint thumbTip;
@property (nonatomic) CGPoint indexTip;

+(instancetype)pointsPairWithThumbTip:(CGPoint)thumbTip indexTip:(CGPoint)indexTip;
@end

NS_ASSUME_NONNULL_END
