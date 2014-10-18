//
//  SpotifyEchoNestDriver.m
//  ShareABeatWithCoke
//
//  Created by Brian Wang on 10/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "SpotifyEchoNestDriver.h"
static NSString * const kClientId = @"aeb4dafe32e0434d8347bc9d4abf09cd";
static NSString * const kCallbackURL = @"ShareABeatWithCoke://callback";
static NSString * const kTokenSwapURL = @"http://localhost:1234/swap";
@implementation SpotifyEchoNestDriver
{
    NSMutableArray* _playList;
}

-(void) loadPlayListWithSong: (ENAPIRequest*)request
{
    _playList = [request.response valueForKey:@"songs"];
    _currentSong = _playList[0];
}

-(void) requestSongFromEchoNestRadio
{
    
    if (_playList == nil || _playList.count == 0)
    {
        NSMutableDictionary* params = [NSMutableDictionary new];
        [params setValue:[NSNumber numberWithInteger:15] forKey:@"results"];
        [params setValue:@"pop" forKey:@"genre"];
        [params setValue: @"id:spotify" forKey:@"bucket"];
        [params setValue:@"genre-radio" forKey: @"type"];
        [params setValue:@"tracks" forKey: @"bucket"];
        [params setValue: @"true" forKey:@"limit"];

        [ENAPIRequest GETWithEndpoint:@"playlist/static"
                        andParameters:params
                   andCompletionBlock:^(ENAPIRequest *request) {
                       [self loadPlayListWithSong:request];
                   }];
    }
    
}

-(NSString*) extractSpotifySongFromRequest
{
    NSString* songURL = [[_currentSong valueForKey: @"tracks"][0] valueForKey:@"foreign_id"];
    return songURL;
}

-(void) requestAnalaysisURL: (NSString*) song
{
    NSMutableDictionary* params = [NSMutableDictionary new];
    [params setValue:song forKey:@"id"];
    [params setValue:@"audio_summary" forKey:@"bucket"];
    [ENAPIRequest GETWithEndpoint:@"track/profile"
                andParameters:params
               andCompletionBlock:^(ENAPIRequest *request) {
                   [self extractAnalysisURL: request];
               }];
}

-(void) extractAnalysisURL: (ENAPIRequest*) request
{
    _currentAnalysisURL = [[[request.response valueForKey:@"track"] valueForKey:@"audio_summary"] valueForKey:@"analysis_url"];
}

-(void) loadNextSong
{
    [_playList removeObjectAtIndex:0];
}

-(NSArray*) retrieveSongDataSegments: (NSString*) analysisURL
{
    NSURL* url=[NSURL URLWithString: analysisURL];   // pass your URL  Here.
    NSData* data=[NSData dataWithContentsOfURL:url];
    NSError* error;
    NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
    return [json valueForKey:@"segments"];
}

-(NSArray*) retrieveSongDataBeats: (NSString*) analysisURL
{
    NSURL* url=[NSURL URLWithString: analysisURL];   // pass your URL  Here.
    NSData* data=[NSData dataWithContentsOfURL:url];
    NSError* error;
    NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
    return [json valueForKey:@"beats"];
}


-(void) playSongFromURL: (NSString*) url
{
    MyManager* manager = [MyManager sharedManager];
    [self playUsingSession:manager.session andURL:url];
}

-(void)playUsingSession:(SPTSession *)session andURL: (NSString*) url
{
    
    // Create a new player if needed
    if (self.player == nil) {
        self.player = [SPTAudioStreamingController new];
    }
    
    [self.player loginWithSession:session callback:^(NSError *error)
    {
        
        if (error != nil) {
            NSLog(@"*** Enabling playback got error: %@", error);
            return;
        }
        
        [SPTRequest requestItemAtURI:[NSURL URLWithString:url] withSession:nil callback:^(NSError *error, SPTTrack* track)
        {
                                
            if (error != nil)
            {
                NSLog(@"*** Album lookup got error %@", error);
                return;
            }
            [self.player playTrackProvider:track callback:nil];
        }];
    }];
    
}

@end
