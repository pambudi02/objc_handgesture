//
//  ViewController.m
//  HandGesture
//
//  Created by Pambudi on 17/11/20.
//

#import "ViewController.h"
@import AVFoundation;
@import Vision;
#import "CameraView.h"
#import "HandGestureProcessor.h"

#define CGFNotFount 111.11

@interface ViewController ()
<AVCaptureVideoDataOutputSampleBufferDelegate, HandGestureProcessorDelegate>
{
    dispatch_queue_t videoDataOutputQueue;
    AVCaptureSession *cameraFeedSession;
//    VNDetectHumanHandPoseRequest *handPoseRequest;
    
    CAShapeLayer *drawOverlay;
    UIBezierPath *drawPath;
    CGPoint lastDrawPoint;
    BOOL isFirstSegment;
    NSTimeInterval lastObservationTimeStamp;
    
    NSMutableArray <PointsPair *> *evidenceBuffer;
    
    CGPoint thumbTipPrev, indexTipPrev;
    BOOL busyDrawing;
}

@property(nonatomic) HandGestureProcessor *gestureProcessor;
@property(nonatomic) CameraView *cameraView;

@end

@implementation ViewController

-(CameraView*)cameraView
{
    return (CameraView*)self.view;
}

-(HandGestureProcessor*)gestureProcessor
{
    if (!_gestureProcessor) {
        _gestureProcessor = [HandGestureProcessor new];
        _gestureProcessor.delegate = self;
    }
    return _gestureProcessor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    drawOverlay = [CAShapeLayer layer];
    drawOverlay.frame = self.view.frame;
    drawOverlay.lineWidth = 5;
//    drawOverlay.backgroundColor = [UIColor grayColor].CGColor;
    drawOverlay.strokeColor = [UIColor redColor].CGColor;
    drawOverlay.fillColor = NULL;//[UIColor blackColor].CGColor;
    drawOverlay.lineCap = kCALineCapRound;
    [self.view.layer addSublayer:drawOverlay];

    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    recognizer.numberOfTouchesRequired = 1;
    recognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:recognizer];
    
//    videoDataOutputQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
    videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", NULL);
    evidenceBuffer = [NSMutableArray new];
    
    drawPath = [UIBezierPath new];
    lastDrawPoint.x = CGFNotFount;
    lastDrawPoint.y = CGFNotFount;
    
    thumbTipPrev = CGPointMake(CGFNotFount, CGFNotFount);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (cameraFeedSession==nil) {
        self.cameraView.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self setupAVSession];
        self.cameraView.previewLayer.session = cameraFeedSession;
        [cameraFeedSession startRunning];
    }
    
//    UIBezierPath *path = [UIBezierPath new];
//    [path moveToPoint:CGPointMake(2.0, 2.0)];
//    [path addLineToPoint:CGPointMake(10.0, 12.0)];
//    [path addLineToPoint:CGPointMake(16, 8)];
//
//    drawOverlay.path = path.CGPath;
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [cameraFeedSession stopRunning];
    [super viewDidDisappear:animated];
}

-(void)setupAVSession
{
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                                      mediaType:AVMediaTypeVideo
                                                                       position:AVCaptureDevicePositionFront];
    NSError *err;
    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:&err];
    
    AVCaptureSession *session = [AVCaptureSession new];
    [session beginConfiguration];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
        
        AVCaptureVideoDataOutput *dataOutput = [AVCaptureVideoDataOutput new];
        if ([session canAddOutput:dataOutput]) {
            [session addOutput:dataOutput];
            dataOutput.alwaysDiscardsLateVideoFrames = YES;
            dataOutput.videoSettings = @{
                (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            };

            [dataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];

            [session commitConfiguration];
            cameraFeedSession = session;
        }
    }
}

-(IBAction)handleGesture:(id)sender
{
    [drawPath removeAllPoints];
    drawOverlay.path = drawPath.CGPath;
}

-(void)processPoints:(PointsPair*)pairPoint
{
    CGPoint thumbPointConverted = [self.cameraView.previewLayer pointForCaptureDevicePointOfInterest:pairPoint.thumbTip];
    CGPoint indexPointConverted = [self.cameraView.previewLayer pointForCaptureDevicePointOfInterest:pairPoint.indexTip];

    NSMutableArray *points = [NSMutableArray new];
    [points addObject:[NSValue valueWithCGPoint:thumbPointConverted]];
    [points addObject:[NSValue valueWithCGPoint:indexPointConverted]];
    [self.cameraView showPoints:points withColor:[UIColor redColor]];
    
    [self.gestureProcessor processPointsPair:
     [PointsPair pointsPairWithThumbTip:thumbPointConverted
                               indexTip:indexPointConverted]
    ];
}

-(void)updatePathWith:(PointsPair*)points
     isLastPointsPair:(BOOL)isLastPointsPair
{
    busyDrawing = YES;
    CGPoint thumbTip = points.thumbTip;
    CGPoint indexTip = points.indexTip;
    CGPoint drawPoint = CGPointMake((thumbTip.x + indexTip.x) / 2.0, (thumbTip.y + indexTip.y) / 2.0);
    
//    NSLog(@"%s", __FUNCTION__);
//    NSLog(@"isLastPointsPair %li", (long)isLastPointsPair);
//    NSLog(@"drawPoint %@", NSStringFromPoint(drawPoint));
    
    if (isLastPointsPair)
    {
        CGPoint lastPoint = lastDrawPoint;
        if(lastPoint.x!=CGFNotFount)
        {
            [drawPath addLineToPoint:lastPoint];
            
            //LastDrawPoint
            lastDrawPoint.x = CGFNotFount;
            lastDrawPoint.y = CGFNotFount;
        }
    }
    else
    {
        if ((lastDrawPoint.x==CGFNotFount)||(lastDrawPoint.y==CGFNotFount)) {
            [drawPath moveToPoint:drawPoint];
            isFirstSegment = YES;
        }
        else
        {
            CGPoint lastPoint = lastDrawPoint;
            CGPoint midPoint = CGPointMake((drawPoint.x + lastPoint.x) / 2.0, (drawPoint.y + lastPoint.y) / 2.0);
            if(isFirstSegment)
            {
                [drawPath addLineToPoint:midPoint];
                isFirstSegment = NO;
            }
            else
            {
                [drawPath addQuadCurveToPoint:midPoint controlPoint:lastPoint];
            }
        }
        
        lastDrawPoint = drawPoint;
    }
    
    drawOverlay.path = drawPath.CGPath;
    busyDrawing = NO;
}

#pragma mark - Delegation
-(void)didChangeStateClosure:(HandGestureState)state
{
    PointsPair *pointsPair = self.gestureProcessor.lastProcessedPointsPair;
    switch (state)
    {
        case HandGestureStatePossibleApart:
        case HandGestureStatePossiblePinch:
        {
            [evidenceBuffer addObject:pointsPair];
            break;
        }
        case HandGestureStatePinched:
        {
            for(PointsPair *bufferedPoints in evidenceBuffer)
            {
                [self updatePathWith:bufferedPoints isLastPointsPair:NO];
            }
            
            [evidenceBuffer removeAllObjects];
            [self updatePathWith:pointsPair isLastPointsPair:NO];
            break;
        }
        default:
        {
            [evidenceBuffer removeAllObjects];
            [self updatePathWith:pointsPair isLastPointsPair:YES];
            break;
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    if(busyDrawing)return;
    if(self.gestureProcessor.busyDetecting)return;
    self.gestureProcessor.busyDetecting = YES;
    
    VNDetectHumanHandPoseRequest *handPoseRequest = [[VNDetectHumanHandPoseRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        
        VNHumanHandPoseObservation *observation = (VNHumanHandPoseObservation*)request.results.firstObject;
        NSError *err;
        NSDictionary <VNHumanHandPoseObservationJointName, VNRecognizedPoint *> *thumbPoints = [observation recognizedPointsForJointsGroupName:VNHumanHandPoseObservationJointsGroupNameThumb
                                                                              error:&err];
        NSDictionary <VNHumanHandPoseObservationJointName, VNRecognizedPoint *> *indexFingerPoints = [observation recognizedPointsForJointsGroupName:VNHumanHandPoseObservationJointsGroupNameIndexFinger
                                                                              error:&err];
        
        VNRecognizedPoint *thumbTipPoint = [thumbPoints objectForKey:VNHumanHandPoseObservationJointNameThumbTip];
        VNRecognizedPoint *indexTipPoint = [indexFingerPoints objectForKey:VNHumanHandPoseObservationJointNameIndexTip];
        
        if((thumbTipPoint.confidence>0.3)&&(indexTipPoint.confidence>0.3))
        {
            CGPoint thumbTip = CGPointMake(thumbTipPoint.location.x, 1-thumbTipPoint.location.y);
            CGPoint indexTip = CGPointMake(indexTipPoint.location.x, 1-indexTipPoint.location.y);
            
            if(self->thumbTipPrev.x == CGFNotFount)
            {
                self->thumbTipPrev = thumbTip;
                self->indexTipPrev = indexTip;
            }
            
            CGFloat thumbDistance = hypot(thumbTip.x - self->thumbTipPrev.x,
                                          thumbTip.y - self->thumbTipPrev.y);
//            NSLog(@"thumbDistance %f", thumbDistance);
            
            CGFloat indexDistance = hypot(indexTip.x - self->indexTipPrev.x,
                                          indexTip.y - self->indexTipPrev.y);
//            NSLog(@"indexDistance %f", indexDistance);
            
            CGFloat minDistance = 0.01;
            if((thumbDistance>=minDistance)||(indexDistance>=minDistance))
            {
                self->thumbTipPrev = thumbTip;
                self->indexTipPrev = indexTip;
            }
            else
            {
                self.gestureProcessor.busyDetecting = NO;
                return;
            }
            
            PointsPair *pair = [PointsPair pointsPairWithThumbTip:thumbTip indexTip:indexTip];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self processPoints:pair];
            });
        }
        
        self.gestureProcessor.busyDetecting = NO;
//        CMSampleBufferInvalidate(sampleBuffer);
    }];
    
    handPoseRequest.maximumHandCount = 1;
    
    NSError *err;
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCMSampleBuffer:sampleBuffer
                                                                               orientation:kCGImagePropertyOrientationUp
                                                                                   options:@{}];
    if(![handler performRequests:@[handPoseRequest]
                           error:&err])
    {
        NSLog(@"%s Error %@", __FUNCTION__, err.localizedDescription);
    }
}

@end
