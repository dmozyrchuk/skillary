//
//  SKCapturePlugin.m
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 06/05/2018.
//

#import "SKCapturePlugin.h"
#import "AppDelegate.h"
#import "SKCaptureController.h"
#import "SKCordovaController.h"

@implementation SKCapturePlugin

-(void)openCaptureScreen:(CDVInvokedUrlCommand*) command {
    NSString* duration = [command.arguments objectAtIndex:0];
    NSString* text = [command.arguments objectAtIndex:1];
    if(duration != nil && text != nil) {
        NSLog(@"Open Capture Screen: duration %@ text: %@", duration, text);
        UINavigationController *navigation = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        if ([navigation.topViewController isMemberOfClass:[SKCordovaController classForKeyedArchiver]]) {
            [(SKCordovaController *)navigation.topViewController goToCaptureScreen:duration text:text];
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

@end
