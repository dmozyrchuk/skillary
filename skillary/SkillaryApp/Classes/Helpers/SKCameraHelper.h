//
//  SKCameraHelper.h
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 24/05/2018.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SKCameraHelper : NSObject <AVCapturePhotoCaptureDelegate, AVCaptureMetadataOutputObjectsDelegate>

typedef void (^PrepareCallback)(NSError *error);
typedef void (^CaptureCallback)(UIImage *image, NSError *error);

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *frontCamera;
@property (nonatomic, strong) AVCaptureDeviceInput *frontCameraInput;
@property (nonatomic , strong) AVCapturePhotoOutput *photoOutput;
@property (nonatomic , strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) CIDetector *faceDetector;


@property (nonatomic, strong) CaptureCallback photoCaptureCompletionBlock;


- (void)prepare:(PrepareCallback)callback;
- (void)displayPreviewOn:(UIView *)view;
- (void)captureImage:(CaptureCallback)callback;

@end
