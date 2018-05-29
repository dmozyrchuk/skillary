//
//  SKCordovaController.m
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 06/05/2018.
//

#import "SKCordovaController.h"
#import "SKCaptureController.h"
#import "SKPhotoController.h"

@interface SKCordovaController () <SKCaptureControllerDelegate, SKPhotoControllerDelegate>

@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) NSInteger photosCount;

@end

@implementation SKCordovaController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toCaptureScreen"]) {
        SKCaptureController *controller = segue.destinationViewController;
        controller.duration = self.duration;
        controller.text = self.text;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"toPhotoScreen"]) {
        SKPhotoController *controller = segue.destinationViewController;
        controller.photosCount = self.photosCount;
        controller.delegate = self;
    }
}


#pragma mark - Custom accessors

- (void)goToCaptureScreen:(NSString *)duration text:(NSString *)text {
    self.duration = duration;
    self.text = text;
    [self performSegueWithIdentifier:@"toCaptureScreen" sender:self];
}

- (void)goToPhotoScreen:(NSInteger)photosCount {
    self.photosCount = photosCount;
    [self performSegueWithIdentifier:@"toPhotoScreen" sender:self];
}

#pragma mark - SKCaptureControllerDelegate

- (void)videoCaptureFinishedWith:(NSString *)duration path:(NSString *)path {
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.navigationController popViewControllerAnimated:YES];
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"app.finishCapturingScreen(\"%@\", \"%@\")", duration, path]];
    });

}

#pragma mark - SKPhotoControllerDelegate

- (void)photosCaptureDidFinishWith:(NSArray *)photos {
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.navigationController popViewControllerAnimated:YES];
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"app.finishAuthenticationWithPhoto(%@)", photos]];
    });
}

@end

@implementation SKCordovaCommandDelegate

/* To override the methods, uncomment the line in the init function(s)
 in MainViewController.m
 */

#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

- (NSString*)pathForResource:(NSString*)resourcepath
{
    return [super pathForResource:resourcepath];
}

@end

@implementation SKCordovaCommandQueue

/* To override, uncomment the line in the init function(s)
 in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

@end
