//
//  CameraView.m
//  HandGesture
//
//  Created by Pambudi on 17/11/20.
//

#import "CameraView.h"

@interface CameraView()
{
    CAShapeLayer *overlayLayer;
    UIBezierPath *pointsPath;
}


@end

@implementation CameraView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupOverlay];
    }
    
    return self;
}


-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupOverlay];
    }
    
    return self;
}

-(AVCaptureVideoPreviewLayer*)previewLayer
{
    return (AVCaptureVideoPreviewLayer*)self.layer;
}

+(Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

-(void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    if ([layer isEqual:self.layer]) {
        overlayLayer.frame = layer.bounds;
    }
}

-(void)setupOverlay
{
    self.layer.backgroundColor = [UIColor yellowColor].CGColor;
    overlayLayer = [CAShapeLayer new];
    pointsPath = [UIBezierPath new];
    [self.layer addSublayer:overlayLayer];
}

-(void)showPoints:(NSArray <NSValue*> *)points withColor:(UIColor*)color
{
    [pointsPath removeAllPoints];
    for(NSValue *val in points)
    {
        CGPoint point = [val CGPointValue];
        [pointsPath moveToPoint:point];
        [pointsPath addArcWithCenter:point radius:5 startAngle:0 endAngle:2*M_PI clockwise:YES];
    }
    
    overlayLayer.fillColor=color.CGColor;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    overlayLayer.path = pointsPath.CGPath;
    [CATransaction commit];
}
@end
