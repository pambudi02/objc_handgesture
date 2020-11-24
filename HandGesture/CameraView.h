//
//  CameraView.h
//  HandGesture
//
//  Created by Pambudi on 17/11/20.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface CameraView : UIView
@property(nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
-(void)showPoints:(NSArray <NSValue*> *)points withColor:(UIColor*)color;
@end

NS_ASSUME_NONNULL_END
