//
//  SKCaptureController.h
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 06/05/2018.
//

#import <UIKit/UIKit.h>

@protocol SKCaptureControllerDelegate

- (void)videoCaptureAborted;

@end

@interface SKCaptureController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *vwVideo;
@property (weak, nonatomic) IBOutlet UIButton *btStart;
@property (weak, nonatomic) IBOutlet UIButton *btSubtitles;
@property (weak, nonatomic) IBOutlet UILabel *lbCounter;
@property (weak, nonatomic) IBOutlet UIView *vwControls;
@property (weak, nonatomic) IBOutlet UIView *vwSubtitles;
@property (weak, nonatomic) IBOutlet UITextView *tvSubtitles;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *vwBlur;
@property (weak, nonatomic) IBOutlet UIView *vwGestures;
@property (weak, nonatomic) IBOutlet UILabel *lbSpeed;
@property (weak, nonatomic) IBOutlet UILabel *lbFont;
@property (weak, nonatomic) IBOutlet UIView *vwLoading;
@property (weak, nonatomic) IBOutlet UIButton *btGallery;
@property (weak, nonatomic) IBOutlet UIImageView *ivGallery;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vwLeftVerticalSepratorTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vwRightVerticalSepratorLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vwTopHorizontalSepratorBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vwBottomHorizontalSepratorTopConstraint;

@property (nonatomic, weak) id<SKCaptureControllerDelegate> delegate;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *text;

@end
