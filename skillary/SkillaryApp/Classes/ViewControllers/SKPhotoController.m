//
//  SKPhotoController.m
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 22/05/2018.
//

#import "SKPhotoController.h"
#import "SKCameraHelper.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

@interface SKPhotoController () <SKCameraHelperDelegate>

@property (weak, nonatomic) IBOutlet UIView *vwNavigation;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btBack;
@property (weak, nonatomic) IBOutlet UIView *vwPhoto;
@property (weak, nonatomic) IBOutlet UIView *vwControls;
@property (weak, nonatomic) IBOutlet UIView *vwFaces;
@property (weak, nonatomic) IBOutlet UIButton *btCapture;
@property (nonatomic, strong) SKCameraHelper *cameraHelper;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vwLeftVerticalSepratorTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vwRightVerticalSepratorLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vwTopHorizontalSepratorBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vwBottomHorizontalSepratorTopConstraint;

@end

@implementation SKPhotoController {
    NSMutableArray *photos;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    photos = [[NSMutableArray alloc] init];
    self.cameraHelper = [[SKCameraHelper alloc] init];
    self.cameraHelper.delegate = self;
    [self.cameraHelper prepare:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.cameraHelper displayPreviewOn:self.vwPhoto];
            });
        }
    }];
    [self setupUI];

    // Do any additional setup after loading the view.
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

#pragma mark - Actions

- (IBAction)captureButtonTapped:(id)sender {
    [self.cameraHelper captureImage:^(UIImage *image, NSError *error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            [photos addObject:image];
            if (photos.count < self.photosCount) {
                self.lbTitle.text = [NSString stringWithFormat:@"Face Control: фото %lu из %ld", photos.count + 1, (long)self.photosCount];
            } else {
                if (self.delegate) {
                    NSArray *pathes = [self saveImagesToDocuments:photos];
                    [self.delegate photosCaptureDidFinishWith:pathes];
                }
            }
        }
    }];
}

- (IBAction)backButtonTapped:(id)sender {
    if (self.delegate) {
        [self.delegate photosCaptureAborted];
    }
}

#pragma mark - Custom Accessors

- (void)setupUI {
    [self.navigationController.navigationBar setHidden:YES];
    self.lbTitle.text = [NSString stringWithFormat:@"Face Control: фото %u из %ld", photos.count + 1, (long)self.photosCount];
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    self.vwLeftVerticalSepratorTrailingConstraint.constant = screenWidth / 6;
    self.vwRightVerticalSepratorLeadingConstraint.constant = screenWidth / 6;
    self.vwTopHorizontalSepratorBottomConstraint.constant = screenHeight / 6;
    self.vwBottomHorizontalSepratorTopConstraint.constant = screenHeight / 6;
    self.btCapture.hidden = YES;
    [self.view layoutIfNeeded];
}

- (NSArray *)saveImagesToDocuments:(NSArray *)images {
    NSMutableArray *pathes = [[NSMutableArray alloc] init];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/MyFolder"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:dataPath error:&error];
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    for (int i = 0; i < images.count; i++) {
        UIImage *image = images[i];
        NSString *filePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d.png", i]];
        NSData *pngData = UIImagePNGRepresentation(image);
        [pngData writeToFile:filePath atomically:YES];
        [pathes addObject:filePath];
    }
    return pathes;
}

#pragma mark = SKCameraHelperDelegate

- (void)facesDidRecognized:(NSArray<__kindof AVMetadataObject *> *)metadataObjects {
    dispatch_async(dispatch_get_main_queue(), ^ {
        [[self.vwFaces subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    });

    for (AVMetadataObject *faceObject in metadataObjects) {
        UIView * faceView = [[UIView alloc] initWithFrame:faceObject.bounds];
        faceView.backgroundColor = UIColor.clearColor;
        faceView.layer.borderColor = [UIColor colorWithRed:254.0/ 255.0 green:205.0 / 255.0 blue:20.0 / 255.0 alpha:1.0f].CGColor;
        faceView.layer.borderWidth = 2.0f;
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self.vwFaces addSubview:faceView];
        });

    }
    if (metadataObjects.count != 1) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            self.btCapture.hidden = YES;
        });
    } else {
        AVMetadataObject *faceObject = [metadataObjects firstObject];
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height - [[UIApplication sharedApplication] statusBarFrame].size.height - self.vwNavigation.frame.size.height;
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        if (faceObject.bounds.size.width < 0.5 * screenWidth || faceObject.bounds.size.height < 0.5 * screenHeight) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                self.btCapture.hidden = YES;
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^ {
                self.btCapture.hidden = NO;
            });
        }
    }
}

@end
