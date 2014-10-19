//
//  MainScene.h
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "ENAPI.h"
#import <Spotify/Spotify.h>
#import "MyManager.h"

@interface MainScene : CCNode
@property (nonatomic, strong) SPTAudioStreamingController *player;

@end
