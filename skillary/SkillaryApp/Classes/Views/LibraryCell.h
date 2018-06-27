//
//  LibraryCell.h
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 26/06/2018.
//

#import <UIKit/UIKit.h>

@interface LibraryCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ivPreview;
@property (weak, nonatomic) IBOutlet UIView *vwGradient;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UIImageView *ivCheckbox;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@end
