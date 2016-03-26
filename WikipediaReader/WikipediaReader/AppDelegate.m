//
//  AppDelegate.m
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import "AppDelegate.h"
#import "Tools.h"
#import "OfflineService.h"
#import <GoogleSignIn/GoogleSignIn.h>


@interface AppDelegate ()

#define GOOGLE_CLIENT_KEY @"605389506276-0slisvkudomh7d8isg9rmtm9pfjmgf59.apps.googleusercontent.com"

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GIDSignIn sharedInstance].clientID = GOOGLE_CLIENT_KEY;
    [GIDSignInButton class];
    
    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    signIn.shouldFetchBasicProfile = YES;
    
    [GIDSignIn sharedInstance].allowsSignInWithWebView = YES;
    
    [[OfflineService sharedService] copyBundleFileToDocumentsFolder:@"Bookmarks" withExtension:@"db"];
    
    NSString *lang = [SettingsManager valueForKey:kUserDefaultsCurrentLanguage];
    NSString *prefLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    BOOL isDevPrefLangSupported = [[LocalizationSystem sharedLocalSystem] isLanguageSupportedByApplication:prefLanguage];
    
    if (!lang) {
        lang = isDevPrefLangSupported ? prefLanguage : kLocalizationSystemCurrentLanguageDefaultValue;
    }
    
    if (![lang isEqualToString:AMLocalizationLanguage]) {
        [Tools changeLanguageTo:lang withNotification:NO];
    }
    
    [[GIDSignIn sharedInstance] signInSilently];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}

@end
