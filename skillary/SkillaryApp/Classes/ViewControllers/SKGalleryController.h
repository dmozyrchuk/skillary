//
//  SKGalleryController.h
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 26/06/2018.
//

#import <UIKit/UIKit.h>

@protocol SKGalleryControllerDelegate

- (void)videoSelectedWith:(NSString *)duration path:(NSString *)path;

@end

@interface SKGalleryController : UIViewController

@property (nonatomic, weak) id<SKGalleryControllerDelegate> delegate;

@end
