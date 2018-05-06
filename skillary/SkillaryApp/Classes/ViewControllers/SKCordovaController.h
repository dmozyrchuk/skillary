//
//  SKCordovaController.h
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 06/05/2018.
//

#import <UIKit/UIKit.h>
#import <Cordova/CDVViewController.h>
#import <Cordova/CDVCommandDelegateImpl.h>
#import <Cordova/CDVCommandQueue.h>

@interface SKCordovaController : CDVViewController
@end

@interface SKCordovaCommandDelegate : CDVCommandDelegateImpl
@end

@interface SKCordovaCommandQueue : CDVCommandQueue
@end
