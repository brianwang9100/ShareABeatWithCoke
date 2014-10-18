//
//  SpotifyEchoNestDriver.m
//  ShareABeatWithCoke
//
//  Created by Brian Wang on 10/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "SpotifyEchoNestDriver.h"

@implementation SpotifyEchoNestDriver
{
    NSMutableArray* _playList;
    NSDictionary* _currentSong;
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
                   [self loadPlayListWithSong:request];
               }];
}
-(NSString*) extractAnalysisURL: (ENAPIRequest*) request
{
    
}

-(void) loadNextSong
{
    [_playList removeObjectAtIndex:0];
    _currentSong = _playList[0];
}

-(NSDictionary*) retrieveSongData: (NSString*) songURL
{
    
}

-(void) playSongFromURL: (NSString*) url
{
    
}

@end
