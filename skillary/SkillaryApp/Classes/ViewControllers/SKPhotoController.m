//
//  SKPhotoController.m
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 22/05/2018.
//

#import "SKPhotoController.h"
#import "SKCameraHelper.h"
#import <Photos/Photos.h>

@interface SKPhotoController ()

@property (weak, nonatomic) IBOutlet UIView *vwPhoto;
@property (nonatomic, strong) SKCameraHelper *cameraHelper;

@end

@implementation SKPhotoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cameraHelper = [[SKCameraHelper alloc] init];
    [self.cameraHelper prepare:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.cameraHelper displayPreviewOn:self.vwPhoto];
            });
        }
    }];


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
            NSError *error;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                if (error != nil) {
                    NSLog(@"%@", error.localizedDescription);
                }
            } error:&error];
        }
    }];
}


@end
