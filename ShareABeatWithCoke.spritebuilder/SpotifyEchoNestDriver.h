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
#import "MyManager.h"


@interface SpotifyEchoNestDriver : CCNode
@property (strong, nonatomic) ENAPIRequest *request;
//@property (readonly) NSString *apiKey;
//@property (readonly) NSString *consumerKey;
//@property (readonly) NSString *sharedSecret;

@property (strong,nonatomic) NSString* currentAnalysisURL;
@property (strong,nonatomic) NSString* currentSongURL;

@property (nonatomic, strong) SPTAudioStreamingController *player;

-(void)playUsingSession:(SPTSession *)session andURL: (NSString*) url;
-(void) playSongFromURL: (NSString*) url;
-(NSArray*) retrieveSongDataBeats: (NSString*) analysisURL;
-(NSArray*) retrieveSongDataSegments: (NSString*) analysisURL;
-(void) loadNextSong;
-(void) extractAnalysisURL: (ENAPIRequest*) request;
-(void) requestAnalaysisURL: (NSString*) song;
-(void) requestSongFromEchoNestRadio;
-(void) loadPlayListWithSong: (ENAPIRequest*)request;
-(double) retrieveSongDataTempo: (NSString*) analysisURL;

@end
