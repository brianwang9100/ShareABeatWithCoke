//
//  MyManager.h
//  ShareABeatWithCoke
//
//  Created by Brian Wang on 10/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "ENAPI.h"
#import <Spotify/Spotify.h>
@interface MyManager : CCNode
@property (strong, nonatomic) SPTSession* session;
+ (id)sharedManager;
@end
