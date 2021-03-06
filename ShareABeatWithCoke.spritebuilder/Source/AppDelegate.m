/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 * Copyright (c) 2013 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "cocos2d.h"
#import <Spotify/Spotify.h>
#import "AppDelegate.h"
#import "CCBuilderReader.h"
#import "MainScene.h"
#import "SpotifyEchoNestDriver.h"
static NSString * const kClientId = @"aeb4dafe32e0434d8347bc9d4abf09cd";
static NSString * const kCallbackURL = @"ShareABeatWithCoke://callback";
static NSString * const kTokenSwapURL = @"http://localhost:1234/swap";
@implementation AppController
{
}
- (NSString *)apiKey {
    return [[[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)consumerKey {
    return [[[NSUserDefaults standardUserDefaults] stringForKey:@"consumerKey"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)sharedSecret {
    return [[[NSUserDefaults standardUserDefaults] stringForKey:@"sharedSecret"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
- (void)initializeSettingsToSettingsDefaults {
    NSLog(@"initializing settings to the settings defaults");
    
    NSString *pathStr = [[NSBundle mainBundle] bundlePath];
    NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
    NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
    
    NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *appDefaults = [NSMutableDictionary new];
    
    NSDictionary *prefItem;
    for (prefItem in prefSpecifierArray) {
        NSString *keyValueStr = [prefItem objectForKey:@"Key"];
        id defaultValue = [prefItem objectForKey:@"DefaultValue"];
        
        if (keyValueStr != nil && defaultValue != nil) {
            [appDefaults setObject:defaultValue forKey:keyValueStr];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeSettingsToSettingsDefaults];
    // Configure Cocos2d with the options set in SpriteBuilder
    NSString* configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Published-iOS"]; // TODO: add support for Published-Android support
    configPath = [configPath stringByAppendingPathComponent:@"configCocos2d.plist"];
    
    NSMutableDictionary* cocos2dSetup = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
    
    // Note: this needs to happen before configureCCFileUtils is called, because we need apportable to correctly setup the screen scale factor.
#ifdef APPORTABLE
    if([cocos2dSetup[CCSetupScreenMode] isEqual:CCScreenModeFixed])
        [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenAspectFitEmulationMode];
    else
        [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenScaledAspectFitEmulationMode];
#endif
    
    // Configure CCFileUtils to work with SpriteBuilder
    [CCBReader configureCCFileUtils];
    
    // Do any extra configuration of Cocos2d here (the example line changes the pixel format for faster rendering, but with less colors)
    //[cocos2dSetup setObject:kEAGLColorFormatRGB565 forKey:CCConfigPixelFormat];
    
    [self setupCocos2dWithOptions:cocos2dSetup];
    
    //ECHONEST STUFF
    [ENAPIRequest setApiKey:@"3XDU9UD8ACYFXQQG1"];
    
    //Create SPTAuth instance; create login URL and open it
//    SPTAuth *auth = [SPTAuth defaultInstance];
//    NSURL *loginURL = [auth loginURLForClientId:kClientId
//                            declaredRedirectURL:[NSURL URLWithString:kCallbackURL]
//                                         scopes:@[SPTAuthStreamingScope]];
//    
//    // Opening a URL in Safari close to application launch may trigger
//    // an iOS bug, so we wait a bit before doing so.
//    [application performSelector:@selector(openURL:)
//                      withObject:loginURL afterDelay:0.1];
//
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    [[NSUserDefaults standardUserDefaults] synchronize];
    [ENAPIRequest setApiKey:self.apiKey  andConsumerKey:self.consumerKey  andSharedSecret:self.sharedSecret];
}

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    
    //Ask SPTAuth if the URL given is a Spotify authentication callback
//    if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:kCallbackURL]]) {
//    
        // Call the token swap service to get a logged in session
        [[SPTAuth defaultInstance]
         handleAuthCallbackWithTriggeredAuthURL:url
         tokenSwapServiceEndpointAtURL:[NSURL URLWithString:kTokenSwapURL]
         callback:^(NSError *error, SPTSession *session) {
             
             if (error != nil) {
                 NSLog(@"*** Auth error: %@", error);
                 return;
             }
             
             [self setupSession:session];
         }];
//        return YES;
//    }

    return NO;
}
-(void) setupSession: (SPTSession*) session
{
    MyManager* manager = [MyManager sharedManager];
    manager.session = session;
}

//-(void)playUsingSession:(SPTSession *)session {
//    
//    // Create a new player if needed
//    if (self.player == nil) {
//        self.player = [SPTAudioStreamingController new];
//    }
//    
//    [self.player loginWithSession:session callback:^(NSError *error) {
//        
//        if (error != nil) {
//            NSLog(@"*** Enabling playback got error: %@", error);
//            return;
//        }
//        
//        [SPTRequest requestItemAtURI:[NSURL URLWithString:@"spotify:album:4L1HDyfdGIkACuygktO7T7"]
//                         withSession:nil
//                            callback:^(NSError *error, SPTAlbum *album) {
//                                
//                                if (error != nil) {
//                                    NSLog(@"*** Album lookup got error %@", error);
//                                    return;
//                                }
//                                [self.player playTrackProvider:album callback:nil];
//                                
//                            }];
//    }];
//    
//}


- (CCScene*) startScene
{
    return [CCBReader loadAsScene:@"MainScene"];
}

@end
