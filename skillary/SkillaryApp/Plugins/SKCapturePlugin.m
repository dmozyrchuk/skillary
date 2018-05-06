//
//  SKCapturePlugin.m
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 06/05/2018.
//

#import "SKCapturePlugin.h"
#import "AppDelegate.h"
#import "SKCaptureController.h"

@implementation SKCapturePlugin

-(void)openCaptureScreen:(CDVInvokedUrlCommand*) command {
    NSString* duration = [command.arguments objectAtIndex:0];
    NSString* text = [command.arguments objectAtIndex:1];
    if(duration != nil && text != nil) {
        NSLog(@"Open Capture Screen: duration %@ text: %@", duration, text);
        SKCaptureController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SKCaptureController"];
        controller.duration = duration;
        controller.text = text;
        UINavigationController *navigation = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [navigation showViewController:controller sender:self];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

@end
