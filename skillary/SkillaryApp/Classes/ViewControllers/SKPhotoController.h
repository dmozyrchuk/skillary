//
//  SKPhotoController.h
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 22/05/2018.
//

#import <UIKit/UIKit.h>

@protocol SKPhotoControllerDelegate

- (void)photosCaptureDidFinishWith:(NSArray *)photos;
- (void)photosCaptureAborted;

@end

@interface SKPhotoController : UIViewController

@property (nonatomic, assign) NSInteger photosCount;

@property (nonatomic, weak) id<SKPhotoControllerDelegate> delegate;

@end
