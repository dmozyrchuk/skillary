//
//  SKCapturePlugin.h
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 06/05/2018.
//

#import <Cordova/CDVPlugin.h>

@interface SKCapturePlugin : CDVPlugin

- (void)openCaptureScreen:(CDVInvokedUrlCommand*) command;

@end
