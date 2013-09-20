//
//  PPAppDelegate.m
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/5/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import "PPAppDelegate.h"
#import "PPHomeViewController.h"
#import "PPAFNetworkManager.h"
#import <PhotoPayCloud/PhotoPayCloud.h>
#import <AFNetworking/AFNetworking.h>
#import "PPAlertView.h"

@interface PPAppDelegate ()

- (void)configureApp;
- (void)configureLogger;
- (void)checkPhotoPayCloudUploads;

- (void)photoPayCloudLogin;
- (void)photoPayCloudLogout;

+ (AFHTTPClient*)httpclient;

@end

@implementation PPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // These should be called before crearing view controllers, so that they have
    // correct values set in their lifecycle methods
    [self configureApp];
    [self photoPayCloudLogin];
    
    PPHomeViewController *homeViewController = [[PPHomeViewController alloc] initWithNibName:[PPHomeViewController defaultXibName]
                                                                                  bundle:nil];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    
    // This is where registration for push notifications will be done.
    // For now, this is only a demonstration, push notifications still don't work in demo app
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
    
    return YES;
}

- (void)configureApp {
    [self configureLogger];
    [[PPApp sharedApp] setLanguage:@"hr"];
}

- (void)configureLogger {
    // we're using cocoa lumberjack
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    DDLogInfo(@"Registered for push notify");
    [[PPPhotoPayCloudService sharedService] setDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogError(@"Failed to register for push notify");
    [[PPPhotoPayCloudService sharedService] setDeviceToken:nil];
}

/** Hack to test logging out */
static bool loggedIn = false;

- (void)applicationWillResignActive:(UIApplication *)application
{
    static NSTimeInterval logoutInterval = 8.0f;
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    loggedIn = false;
    // Delay execution of my block for 10 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, logoutInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self photoPayCloudLogout];
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)photoPayCloudLogout {
    if (!loggedIn) {
        [[PPPhotoPayCloudService sharedService] uninitialize];
    }
}

- (void)photoPayCloudLogin {
    loggedIn = true;
    
    PPNetworkManager* networkManager = [[PPAFNetworkManager alloc] initWithHttpClient:[PPAppDelegate httpclient]];
//    PPUser* user = [[PPUser alloc] initWithUserId:[[PPApp sharedApp] userId]
//                                   organizationId:@"EBS"];
    
    PPUser* user = [[PPUser alloc] initWithUserId:@"dev@photopay"
                                   organizationId:@"PhotoPay"];
    
    [[PPPhotoPayCloudService sharedService] initializeForUser:user withNetworkManager:networkManager];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // call configure photopaycloud because it's possible
    // that PhotoPayCloudService was deallocated in the meantime
    [self photoPayCloudLogin];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self checkPhotoPayCloudUploads];
}

+ (AFHTTPClient*)httpclient {
    static AFHTTPClient* httpclient = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        httpclient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://169.254.22.143:8080"]];
//        httpclient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://cloudbeta.photopay.net/"]];
        NSString* osString = [NSString stringWithFormat:@"%@: %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
        [httpclient setDefaultHeader:@"X-OS" value:osString];
        
        NSString* buildNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString* versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString* appVersion = [NSString stringWithFormat:@"Build: %@, Version: %@", buildNumber, versionNumber];
        [httpclient setDefaultHeader:@"X-app-version" value:appVersion];
    });
    return httpclient;
}

- (void)checkPhotoPayCloudUploads {
    // check if PhotoPayCloudService was paused
    if ([[PPPhotoPayCloudService sharedService] state] == PPPhotoPayCloudServiceStatePaused) {
        // if true, ask user to continue or abort paused requests
        PPAlertView* alertView = [[PPAlertView alloc] initWithTitle:_(@"PhotoPayPendingUploadsAlertViewTitle")
                                                            message:_(@"PhotoPayPendingUploadsAlertViewMessage")
                                                         completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                                             NSError* __autoreleasing error = nil;
                                                             if (buttonIndex == 0) {
                                                                 [[PPPhotoPayCloudService sharedService] deletePendingDocumentsWithError:&error];
                                                             } else if (buttonIndex == 1) {
                                                                 [[PPPhotoPayCloudService sharedService] uploadPendingDocuments];
                                                             }
                                                         }
                                                  cancelButtonTitle:_(@"PhotoPayPendingUploadsAlertViewAbort")
                                                  otherButtonTitles:_(@"PhotoPayPendingUploadsAlertViewContinue"), nil];
        [alertView show];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
