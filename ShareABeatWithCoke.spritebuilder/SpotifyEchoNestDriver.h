//
//  SpotifyEchoNestDriver.h
//  ShareABeatWithCoke
//
//  Created by Brian Wang on 10/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "ENAPI.h"
#import <Spotify/Spotify.h>

@interface SpotifyEchoNestDriver : CCNode
@property (strong, nonatomic) ENAPIRequest *request;
@property (readonly) NSString *apiKey;
@property (readonly) NSString *consumerKey;
@property (readonly) NSString *sharedSecret;
@end
