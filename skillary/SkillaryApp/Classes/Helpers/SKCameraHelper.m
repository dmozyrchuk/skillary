//
//  SKCameraHelper.m
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 24/05/2018.
//

#import "SKCameraHelper.h"

@implementation SKCameraHelper

#pragma mark - Public methods

- (void)prepare:(PrepareCallback)callback {
    [self createCaptureSession];
    [self configureCaptureDevices];
    NSError *error = [self configureDeviceInputs];
    [self configurePhotoOutput];
    [self configureMetadataOutput];
    [self configureFaceDetector];
    callback(error);
}

- (void)displayPreviewOn:(UIView *)view {
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    self.previewLayer.frame = view.bounds;
    [view.layer addSublayer:self.previewLayer];

    if ([self.captureSession isRunning] == NO) {
        [self.captureSession startRunning];
    }
}

- (void)captureImage:(CaptureCallback)callback {
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings new];
    [self.photoOutput capturePhotoWithSettings:settings delegate:self];
    self.photoCaptureCompletionBlock = callback;
}



#pragma mark - Private methods

- (void)createCaptureSession {
    self.captureSession = [[AVCaptureSession alloc] init];
}

- (void)configureCaptureDevices {
    if (self.frontCamera == nil) {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices) {
            if (device.position == AVCaptureDevicePositionFront) {
                self.frontCamera = device;
                break;
            }
        }
    }
    if (self.frontCamera == nil) {
        self.frontCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
}

- (NSError *)configureDeviceInputs {
    NSError *error;
    self.frontCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.frontCamera error:&error];
    if ([self.captureSession canAddInput:self.frontCameraInput]) {
        [self.captureSession addInput:self.frontCameraInput];
    }
    return error;
}

- (void)configurePhotoOutput {
    self.photoOutput = [AVCapturePhotoOutput new];
    [self.photoOutput setPreparedPhotoSettingsArray:@[[AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey : AVVideoCodecJPEG}]] completionHandler:nil];
    if ([self.captureSession canAddOutput:self.photoOutput]) {
        [self.captureSession addOutput:self.photoOutput];
    }
}

- (void)configureMetadataOutput {
    self.metadataOutput = [AVCaptureMetadataOutput new];
    if ([self.captureSession canAddOutput:self.metadataOutput]) {
        [self.captureSession addOutput:self.metadataOutput];
        dispatch_queue_t queue = dispatch_queue_create("output.queue", 0);
        [self.metadataOutput setMetadataObjectsDelegate:self queue:queue];
        NSLog(@"%@", [self.metadataOutput availableMetadataObjectTypes]);
        [self.metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
    }
}

- (void)configureFaceDetector {
    self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
}


#pragma mark - AVCapturePhotoCaptureDelegate

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(nonnull AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error {
    if (error != nil) {
        self.photoCaptureCompletionBlock(nil, error);
    } else {
        NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:nil];
        UIImage *image = [UIImage imageWithData:data];
        self.photoCaptureCompletionBlock(image, nil);
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for (AVMetadataObject *metadataObject in metadataObjects) {
        NSLog(@"%@", metadataObject);
    }

}



@end
