//
//  SKCaptureController.m
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 06/05/2018.
//

#import "SKCaptureController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface SKCaptureController () <AVCaptureFileOutputRecordingDelegate>

@end

@implementation SKCaptureController {
    AVCaptureMovieFileOutput *movieFileOutput;
    AVCaptureSession *captureSession;
    NSURL *fileURL;
    NSInteger currentCounterValiue;
    NSTimer *timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self instantiateVideoRecorder];
    currentCounterValiue = [self.duration integerValue];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupPreview];
    if ([captureSession isRunning]== NO) {
        [captureSession startRunning];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)btStartTapped:(id)sender {
    [self startCapturing];
}

#pragma mark - Custom Accessors

- (void)instantiateVideoRecorder {
    captureSession = [AVCaptureSession new];

    AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:cameraDevice error:&error];
    if ([captureSession canAddInput:cameraDeviceInput]) {
        [captureSession addInput:cameraDeviceInput];
    }
    // Configure the audio session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];

    // Find the desired input port
    NSArray* inputs = [audioSession availableInputs];
    AVAudioSessionPortDescription *builtInMic = nil;
    for (AVAudioSessionPortDescription* port in inputs) {
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
            builtInMic = port;
            break;
        }
    }

    // Find the desired microphone
    for (AVAudioSessionDataSourceDescription* source in builtInMic.dataSources) {
        if ([source.orientation isEqual:AVAudioSessionOrientationFront]) {
            [builtInMic setPreferredDataSource:source error:nil];
            [audioSession setPreferredInput:builtInMic error:&error];
            break;
        }
    }
    movieFileOutput = [AVCaptureMovieFileOutput new];
    if([captureSession canAddOutput:movieFileOutput]){
        [captureSession addOutput:movieFileOutput];
    }
    fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"1.mp4"]];
}

- (void)setupPreview {
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    previewLayer.frame = self.vwVideo.bounds;
    [self.vwVideo.layer addSublayer:previewLayer];
}

- (void)setupTimer {
    if (timer != nil) {
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(timerFire)
                                           userInfo:nil
                                            repeats:YES];
}

- (void)updateCounterLabel {
    self.lbCounter.text = [NSString stringWithFormat:@"%d", currentCounterValiue];
}

- (void)startCapturing {
    if ([movieFileOutput isRecording] == NO) {
        [movieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
        [self setupTimer];
    }
}

- (void)endCapturing {
    if ([movieFileOutput isRecording]) {
        [movieFileOutput stopRecording];
    }
}

- (void)timerFire {
    currentCounterValiue -= 1;
    [self updateCounterLabel];
    if (currentCounterValiue == 0) {
        [self endCapturing];
        [timer invalidate];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
    [self.btStart setHidden:YES];
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    [self.btStart setHidden:NO];
    if (error) {
        NSLog(@"%@", error.description);
    } else {
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum ([fileURL path])) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileURL];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    PHFetchOptions *options = [[PHFetchOptions alloc] init];
                    options.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]];
                    PHAsset *asset = [[PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:options] firstObject];
                    if (self.delegate != nil) {
                        [self.delegate videoCaptureFinishedWith:self.duration path:asset.localIdentifier];
                    }

                }
            }];

        }
    }
}


@end
