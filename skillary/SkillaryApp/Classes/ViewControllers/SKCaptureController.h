//
//  SKCaptureController.h
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 06/05/2018.
//

#import <UIKit/UIKit.h>

@interface SKCaptureController : UIViewController

@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *text;

@property (weak, nonatomic) IBOutlet UIView *vwVideo;
@property (weak, nonatomic) IBOutlet UIButton *btStart;
@property (weak, nonatomic) IBOutlet UILabel *lbCounter;

@end
