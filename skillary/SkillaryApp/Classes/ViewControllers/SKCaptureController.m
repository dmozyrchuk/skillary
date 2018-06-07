//
//  SKCaptureController.m
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 06/05/2018.
//

#import "SKCaptureController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "DPVideoMerger.h"

typedef enum : NSUInteger {
    prepared,
    started,
    paused,
    finished
} CaptureState;

@interface SKCaptureController () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic) CaptureState currentState;

@end

@implementation SKCaptureController {
    AVCaptureMovieFileOutput *movieFileOutput;
    AVCaptureSession *captureSession;
    NSURL *fileURL;
    NSInteger currentCounterValiue;
    NSTimer *timer;
    BOOL isSubtitlesHidden;
    BOOL userScrolled;
    CGFloat scrollSpeed;
    CGFloat fontSize;
    NSMutableArray *pathes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self instantiateVideoRecorder];
    currentCounterValiue = [self.duration integerValue];
    [self setupUI];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    pan.cancelsTouchesInView = NO;
    [self.vwGestures addGestureRecognizer:pan];
    pathes = [[NSMutableArray alloc] init];
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
    if (self.currentState == prepared) {
        [self startCapturing];
    } else if (self.currentState == started) {
        [self.btStart setImage:[UIImage imageNamed:@"camera-off"] forState:UIControlStateNormal];
        if (timer != nil) {
            [timer invalidate];
        }
        [self pauseCapturing];
    } else if (self.currentState == paused) {
        [self setupTimer];
        [self subtitleAnimationScrolling];
        [self resumeCapturing];
    }

}

- (IBAction)btSubtitlesTapped:(id)sender {
    isSubtitlesHidden = !isSubtitlesHidden;
    self.vwSubtitles.hidden = isSubtitlesHidden;
    UIImage *subtitlesImage = [UIImage imageNamed:isSubtitlesHidden ? @"subtitles-off" : @"subtitles-on"];
    [self.btSubtitles setImage:subtitlesImage forState:UIControlStateNormal];
}

- (IBAction)btSpeedUpButtonTapped:(id)sender {
    scrollSpeed = scrollSpeed + 10;
    self.lbSpeed.text = [NSString stringWithFormat:@"%.0f", scrollSpeed];
}

- (IBAction)btSpeedDownButtonTapped:(id)sender {
    scrollSpeed = scrollSpeed > 10 ? scrollSpeed - 10 : scrollSpeed;
    self.lbSpeed.text = [NSString stringWithFormat:@"%.0f", scrollSpeed];
}

- (IBAction)btFontUpButtonTapped:(id)sender {
    fontSize = fontSize + 1;
    self.lbFont.text = [NSString stringWithFormat:@"%.0f", fontSize];
    [self.tvSubtitles setFont:[UIFont systemFontOfSize:fontSize]];
    [self.tvSubtitles setContentOffset:CGPointMake(0, 0)];
    userScrolled = NO;
    self.vwGestures.userInteractionEnabled = YES;
}

- (IBAction)btFontDownButtonTapped:(id)sender {
    fontSize = fontSize > 1 ? fontSize - 1 : fontSize;
    self.lbFont.text = [NSString stringWithFormat:@"%.0f", fontSize];
    [self.tvSubtitles setFont:[UIFont systemFontOfSize:fontSize]];
    [self.tvSubtitles setContentOffset:CGPointMake(0, 0)];
    userScrolled = NO;
    self.vwGestures.userInteractionEnabled = YES;
}

#pragma mark - Custom Accessors

- (void)setupUI {
    [self.navigationController.navigationBar setHidden:YES];
    self.tvSubtitles.contentOffset = CGPointMake(0, 0);
    scrollSpeed = 100.0f;
    fontSize = 44.0f;
    [self.tvSubtitles setFont:[UIFont systemFontOfSize:fontSize]];
    [self.tvSubtitles setText:self.text];
    self.currentState = prepared;
    [self updateCounterLabel];
    isSubtitlesHidden = YES;
    self.vwSubtitles.hidden = isSubtitlesHidden;
    [self.btStart setImage:[UIImage imageNamed:@"camera-off"] forState:UIControlStateNormal];
    [self.btSubtitles setImage:[UIImage imageNamed:@"subtitles-off"] forState:UIControlStateNormal];
    self.lbSpeed.text = [NSString stringWithFormat:@"%.0f", scrollSpeed];
    self.lbFont.text = [NSString stringWithFormat:@"%.0f", fontSize];
    self.vwLoading.hidden = YES;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    self.vwLeftVerticalSepratorTrailingConstraint.constant = screenWidth / 6;
    self.vwRightVerticalSepratorLeadingConstraint.constant = screenWidth / 6;
    self.vwTopHorizontalSepratorBottomConstraint.constant = screenHeight / 6;
    self.vwBottomHorizontalSepratorTopConstraint.constant = screenHeight / 6;
    [self.view layoutIfNeeded];
}

- (void)panGesture:(UIPanGestureRecognizer *)pan {
    if (self.vwSubtitles.hidden == NO) {
        userScrolled = YES;
        self.vwGestures.userInteractionEnabled = NO;
    }
}

- (void)instantiateVideoRecorder {
    captureSession = [AVCaptureSession new];
    AVCaptureDevice *cameraDevice;
    if (cameraDevice == nil) {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices) {
            if (device.position == AVCaptureDevicePositionFront) {
                cameraDevice = device;
                break;
            }
        }
    }
    if (cameraDevice == nil) {
        cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
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
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput * audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    if ([captureSession canAddInput:audioInput]) {
        [captureSession addInput:audioInput];
    }
    movieFileOutput = [AVCaptureMovieFileOutput new];
    if([captureSession canAddOutput:movieFileOutput]){
        [captureSession addOutput:movieFileOutput];
    }
    fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"0.mov"]];
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
    self.lbCounter.text = [NSString stringWithFormat:@"%ld", (long)currentCounterValiue];
}

- (void)startCapturing {
    if ([movieFileOutput isRecording] == NO) {
        [movieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
        [self setupTimer];
        [self subtitleAnimationScrolling];
    }
}

- (void)pauseCapturing {
    if ([movieFileOutput isRecording] == YES) {
        self.currentState = paused;
        [movieFileOutput stopRecording];
    }
}

- (void)resumeCapturing {
    if ([movieFileOutput isRecording] == NO) {
        [movieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
        [self subtitleAnimationScrolling];
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
    } else if (userScrolled == NO) {
        CGFloat offset = self.tvSubtitles.contentOffset.y + scrollSpeed;
        if (self.tvSubtitles.contentSize.height - offset < self.tvSubtitles.frame.size.height) {
            offset = self.tvSubtitles.contentSize.height - self.tvSubtitles.frame.size.height;
        }
        [UIView animateWithDuration:1.0f animations:^{
            [self.tvSubtitles setContentOffset:CGPointMake(self.tvSubtitles.contentOffset.x, offset)];
        }];
    }
}

- (void)subtitleAnimationScrolling {
    if (userScrolled == NO && self.currentState == started) {
        CGFloat offset = self.tvSubtitles.contentOffset.y + scrollSpeed;
        if (self.tvSubtitles.contentSize.height - offset < self.tvSubtitles.frame.size.height) {
            offset = self.tvSubtitles.contentSize.height - self.tvSubtitles.frame.size.height;
        }
        [UIView animateWithDuration:1.0f animations:^{
            [self.tvSubtitles setContentOffset:CGPointMake(self.tvSubtitles.contentOffset.x, offset)];
        } completion:^(BOOL finished) {
            if (finished) {
                [self subtitleAnimationScrolling];
            }
        }];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
    self.currentState = started;
    [self.btStart setImage:[UIImage imageNamed:@"camera-on"] forState:UIControlStateNormal];
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    [pathes addObject:fileURL];
    if (self.currentState == started) {
        self.vwLoading.hidden = NO;
        self.currentState = finished;
        if (error) {
            self.vwLoading.hidden = YES;
            NSLog(@"%@", error.description);
            if (self.delegate != nil) {
                [self.delegate videoCaptureAborted];
            }
        } else {
            [DPVideoMerger mergeVideosWithFileURLs:pathes completion:^(NSURL *mergedVideoURL, NSError *error) {
                if (error) {
                    self.vwLoading.hidden = YES;
                    if (self.delegate != nil) {
                        [self.delegate videoCaptureAborted];
                    }
                    NSString *errorMessage = [NSString stringWithFormat:@"Could not merge videos: %@", [error localizedDescription]];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
                    [self presentViewController:alert animated:YES completion:nil];
                    return;

                } else {
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum ([mergedVideoURL path])) {
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:mergedVideoURL];
                        } completionHandler:^(BOOL success, NSError * _Nullable error) {
                            if (success) {
                                self.vwLoading.hidden = YES;
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
            }];
        }
    } else {
        fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.mov", (unsigned long)pathes.count]]];
    }
}


@end
