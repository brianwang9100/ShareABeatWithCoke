//
//  GamePlay.m
//  ShareABeatWithCoke
//
//  Created by Brian Wang on 10/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GamePlay.h"
#define ARC4RANDOM_MAX 0x100000000

@implementation GamePlay
{
    Timer *_timer;
    ComboBar *_comboBar;
    CCNodeColor *_glowNode;
    CCLabelTTF *_bubbleBeatMessage;
    CCLabelTTF *_comboModeLabel;
    CCNode* _comboContainerNode;
    NSUserDefaults *_defaults;
    
    float _currentNumOfBeats;
    int _waveNumOfBeats;
    
    int _pointMultiplier;
    int _totalScore;
    
    float _delay;
    int _defaultCountDown;
    
    CCLabelTTF *_totalScoreLabel;
    CCLabelTTF *_tutorialLabel;
    
    BOOL _gameCountdownMode;
    int _gameCountdown;
    
    BOOL _gameStarted;
    BOOL _gameEnded;
    BOOL _tutorialMode;
    BOOL _comboMode;
    
    NSMutableArray *_queue;
    NSMutableArray *_bubbleArray;
    
    int _comboBarSize;
    
    BubbleBeat*_currentBubbleBeat;
    int _totalPoints;
    float _bubbleBeatTimeStamp;
    BOOL _bubbleBeatRecognized;
    BOOL _allowBubbleBeat;
    float _beatLength;
    BOOL _percentageAlreadySubtracted;
    
    SpotifyEchoNestDriver *_soundDriver;
    
}

-(void) didLoadFromCCB
{
    self.userInteractionEnabled = FALSE;
    _bubbleBeatMessage.string = @"";
    _defaults = [NSUserDefaults standardUserDefaults];
    
    _queue = [NSMutableArray arrayWithObjects: nil];
    _bubbleArray = [NSMutableArray arrayWithObjects: nil];
    
    _timer = [Timer alloc];
    
    _gameCountdownMode = TRUE;
    _defaultCountDown = 4;
    _gameCountdown = _defaultCountDown;
    _gameStarted = FALSE;
    _gameEnded = FALSE;
    _comboMode = FALSE;
    
    _defaultCountDown = 4;
    
    _totalPoints = 0;
    
    _bubbleBeatTimeStamp = 0;
    _bubbleBeatRecognized = FALSE;
    _beatLength = 1;
    _percentageAlreadySubtracted = FALSE;
    
    _soundDriver = [SpotifyEchoNestDriver alloc];
    
    [self generateBeatForSong];
}


-(void) update:(CCTime)delta
{
    _timer.currentTime += delta;
    _bubbleBeatTimeStamp += delta;
    _timer.comboTimeKeeper += delta;
    
    if (!_gameStarted)
    {
        if (_gameCountdownMode)
        {
            if (_timer.currentTime >= 2*_beatLength)
            {
                if (_gameCountdown == 0)
                {
                    _bubbleBeatMessage.string = @"START!";
                    [self performSelector:@selector(startGame) withObject:nil afterDelay:_beatLength];
                    //[self startGame];
                }
                else if (_gameCountdown == _defaultCountDown)
                {
                    _bubbleBeatMessage.string = @"TAP THE BUBBLES TO THE BEAT!";
                }
                else if (_gameCountdown < _defaultCountDown && _gameCountdown > 0)
                {
                    _bubbleBeatMessage.string = [NSString stringWithFormat:@"%i", _gameCountdown];
                }
                _timer.currentTime = 0;
                _gameCountdown--;
            }
        }
    }
    else if (!_gameEnded)
    {
        
        if (_comboMode && _timer.comboTimeKeeper >= _beatLength)
        {
            _pointMultiplier++;
            if (_pointMultiplier > 5)
            {
                _pointMultiplier = 5;
            }
            _timer.comboTimeKeeper = 0;
            _comboModeLabel.string = [NSString stringWithFormat:@"COMBO MODE x%i", _pointMultiplier];
        }
        
//        if (_currentNumOfBeats >= _waveNumOfBeats)
//        {
//            
//            [self performSelector:@selector(delayWaveMessage) withObject:nil afterDelay:2 * _beatLength];
//            _beatLength -= .05;
//            
//            _bubbleBeatRecognized = TRUE;
//            _allowBubbleBeat = FALSE;
//            
//            _gameStarted = FALSE;
//            _gameCountdownMode = TRUE;
//            _gameCountdown = _defaultCountDown;
//            _timer.currentTime = 0;
//            _bubbleBeatTimeStamp = 0;
//        }
        
        _currentBubbleBeat = _queue[0];
        
        if (_timer.currentTime >= _currentBubbleBeat.timeStamp * _beatLength && [_currentBubbleBeat.typeOfSlapNeeded isEqual:@"Bubble"])
        {
            [self delayAllowanceOfBubbleBeat];
            [self launchBubbleWithBeat:_currentBubbleBeat];
        }
        else
        {
            if (!_bubbleBeatRecognized && _timer.currentTime >= (_currentBubbleBeat.timeStamp*1.2))
            {
                _bubbleBeatTimeStamp = .2*_currentBubbleBeat.delay;
                _timer.currentTime = .2*_currentBubbleBeat.delay;
                _bubbleBeatRecognized = FALSE;
                _allowBubbleBeat = TRUE;
                
                _bubbleBeatMessage.string = @"TOO LATE!";
                [_bubbleArray[0] burst];
                [_bubbleArray removeObjectAtIndex:0];
                [self setPercentage: -6* _currentBubbleBeat.timeStamp];
                
                
            }
            else if (_bubbleBeatRecognized && _timer.currentTime >= _currentBubbleBeat.timeStamp)
            {
                _bubbleBeatTimeStamp = 0;
                _timer.currentTime = 0;
                _currentNumOfBeats +=_currentBubbleBeat.timeStamp;
                _bubbleBeatRecognized = FALSE;
                _allowBubbleBeat = TRUE;
                
            }
        }
        [self loadNewBubbleBeat];
    }
}

//TODO: FIX LAUNCHING OF BUBBLE
-(void) launchBubbleWithBeat: (BubbleBeat*) beat
{
    Bubble* currentBubble = (Bubble*)[CCBReader load:@"Bubble"];
    currentBubble.thisBeat = [[BubbleBeat alloc] initWithTime: (1.2 * beat.delay) andDelay: beat.delay andType:@"Beat"];
    currentBubble.beatTime = .2 * beat.delay;
    [_bubbleArray addObject: currentBubble];
    //currentBubble.position = ccp(,0);
    
}

-(void) loadNextSong
{
    [_queue removeAllObjects];
    [_soundDriver loadNextSong];
    [self generateBeatForSong];
    _gameCountdownMode = TRUE;
    _gameStarted = FALSE;
    _gameCountdown = _defaultCountDown;
    _timer.currentTime = 0;
    _bubbleBeatTimeStamp = 0;
    _currentNumOfBeats = 0;
    [_soundDriver performSelector:@selector(playSongFromURL:) withObject:_soundDriver.currentSongURL afterDelay: (_defaultCountDown + 1)*_beatLength];
}

-(void) delayAllowanceOfBubbleBeat
{
    _bubbleBeatRecognized  = FALSE;
    _allowBubbleBeat = TRUE;
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    for (Bubble* e in _bubbleArray)
    {
        if ([self containsExactTouchLocation:[touch locationInNode:self] withObject:e])
        {
            [self popBubble: e];
            break;
        }
    }
}

-(BOOL) containsExactTouchLocation: (CGPoint)location withObject: (CCNode*) object
{
    CGPoint p = [object convertToNodeSpaceAR: location];
    CGSize size =  object.contentSize;
    CGRect r = CGRectMake (-size.width*.5, -size.height*.5, size.width, size.height);
    return CGRectContainsPoint(r,p);
}

-(void) popBubble: (Bubble*) bubble
{
    if (!_bubbleBeatRecognized && _allowBubbleBeat)
    {
        float convertedTime = bubble.thisBeat.delay;
        if (bubble.thisBeat.timeStamp == ((BubbleBeat*) _queue[0]).timeStamp)
        {
            [self checkForAccuracy:convertedTime];
        }
        else
        {
            _bubbleBeatMessage.string = @"WRONG BUBBLE";
            [self setPercentage: -6 * _currentBubbleBeat.timeStamp];
            [self addScore: -25];
        }
        _bubbleBeatRecognized = TRUE;
        _allowBubbleBeat = FALSE;
    }
    [_bubbleArray removeObject:bubble];
    [bubble burst];
}

-(void) checkForAccuracy: (float) convertedTime
{
    if (_bubbleBeatTimeStamp < 1.05 * convertedTime && _bubbleBeatTimeStamp > .95 * convertedTime)
    {
        _bubbleBeatMessage.string = @"PERFECT!";
        [self setPercentage: 6 * _currentBubbleBeat.timeStamp];
        [self addScore: 50];
    }
    else if (_bubbleBeatTimeStamp < 1.10 * convertedTime && _bubbleBeatTimeStamp > .9 * convertedTime)
    {
        _bubbleBeatMessage.string = @"GOOD";
        [self setPercentage: 4 * _currentBubbleBeat.timeStamp];
        [self addScore: 25];
    }
    else if (_bubbleBeatTimeStamp < 1.20 * convertedTime && _bubbleBeatTimeStamp > .8 * convertedTime)
    {
        _bubbleBeatMessage.string = @"OK";
        [self setPercentage: 2 * _currentBubbleBeat.timeStamp];
        [self addScore: 10];
    }
    else if (_bubbleBeatTimeStamp <= .8 * convertedTime)
    {
        _bubbleBeatMessage.string = @"TOO EARLY!";
        [self setPercentage: -6 * _currentBubbleBeat.timeStamp];
        [self addScore: -25];
    }
}

-(void) setPercentage: (int) percent
{
    _comboBar.currentSize += percent;
    if (percent < 0)
    {
        if (_comboMode)
        {
            [_comboBar loadParticleExplosionWithParticleName:@"ComboBar" withPosition:ccp(-1, .5) withColor:[CCColor whiteColor]];
        }
        else if (_comboBar.currentSize <33)
        {
            [_comboBar loadParticleExplosionWithParticleName:@"ComboBar" withPosition:ccp(-1, .5) withColor:[CCColor redColor]];
        }
        else
        {
            [_comboBar loadParticleExplosionWithParticleName:@"ComboBar" withPosition:ccp(-1, .5) withColor:[CCColor whiteColor]];
        }
    }
    
    if (_comboBar.currentSize>= 100)
    {
        _comboBar.currentSize = 100;
        _comboMode = TRUE;
        _glowNode.visible = TRUE;
        _comboBar.comboBarGradient.visible = TRUE;
        _comboBar.comboGlowNode.visible = TRUE;
        _comboModeLabel.visible = TRUE;
        _totalScoreLabel.color = [CCColor whiteColor];
        _bubbleBeatMessage.color = [CCColor whiteColor];
    }
    else
    {
        _comboMode = FALSE;
        _pointMultiplier = 1;
        _glowNode.visible = FALSE;
        _comboBar.comboBarGradient.visible = FALSE;
        _comboBar.comboGlowNode.visible = FALSE;
        _comboModeLabel.visible = FALSE;
        _totalScoreLabel.color = [CCColor blackColor];
        _bubbleBeatMessage.color = [CCColor blackColor];
    }
    
    if (_comboBar.currentSize <= 0)
    {
        _comboBar.currentSize = 0;
        _gameEnded = TRUE;
        _gameStarted = FALSE;
        
        //put in information about
        _bubbleBeatMessage.string = @"";
        _totalScoreLabel.string = @"";
        
        id move = [CCActionMoveTo actionWithDuration:2 position:ccp(.5, -50)];
        id moveElastic = [CCActionEaseElasticInOut actionWithAction: move period:.3];
        [_comboBar runAction: moveElastic];

        
        [self performSelector:@selector(endGame) withObject:nil afterDelay:2];
    }
}

-(void) startGame
{
    _gameCountdownMode = FALSE;
    _gameStarted = TRUE;
    _timer.currentTime = 0;
    _bubbleBeatTimeStamp = 0;
    _currentNumOfBeats = 0;
    _waveNumOfBeats = 32;
}

-(void) endGame
{
//    self.userInteractionEnabled = FALSE;
//    PostGamePopUp *postGamePopUp = (PostGamePopUp*)[CCBReader load: @"PostGamePopUp"];
//    postGamePopUp.userInteractionEnabled = TRUE;
//    postGamePopUp.positionType = CCPositionTypePoints;
//    postGamePopUp.position = ccp(self.contentSizeInPoints.width*.5,self.contentSizeInPoints.height * .5);
//    
//    postGamePopUp.yourScoreNum.string = [NSString stringWithFormat:@"%i", _totalScore];
//    if ([_defaults objectForKey:@"highScore"] == nil || _totalScore > [[_defaults objectForKey:@"highScore"] intValue])
//    {
//        postGamePopUp.highScoreTitle.string = @"NEW HIGH SCORE";
//        [_defaults setObject:[NSNumber numberWithInt: _totalScore] forKey:@"highScore"];
//        [_defaults synchronize];
//    }
//    postGamePopUp.highScoreNum.string = [NSString stringWithFormat:@"%i",[[_defaults objectForKey:@"highScore"] intValue]];
//    [self addChild:postGamePopUp];
    
}
-(void) generateBeatForSong
{
    [_soundDriver requestSongFromEchoNestRadio];
    [_soundDriver requestAnalaysisURL:_soundDriver.currentSongURL];
    NSString* analysisURL = _soundDriver.currentAnalysisURL;
    //NSArray* beatArray = [_soundDriver retrieveSongDataBeats:analysisURL];
    NSArray* segmentArray =[_soundDriver retrieveSongDataSegments:analysisURL];
    double tempo = [_soundDriver retrieveSongDataTempo:analysisURL];
    _beatLength = tempo;
    _delay = -1;
    for (NSDictionary* e in segmentArray)
    {
        if (_delay == -1)
        {
            _delay++;
        }
        else if ([[e valueForKey:@"confidence"] doubleValue] >= .6)
        {
            double bubbleTapTime = .2 * _delay;
            BubbleBeat* thisBeat = [[BubbleBeat alloc] initWithTime:_delay andDelay:_delay andType:@"Beat"];
            [_queue addObject: thisBeat];
            BubbleBeat* bubbleSpawnBeat = [[BubbleBeat alloc] initWithTime:(_delay - bubbleTapTime) andDelay:_delay andType:@"BubbleSpawn"];
            [_queue addObject: bubbleSpawnBeat];
            [_queue addObject: thisBeat];
            _delay = 0;
        }
        _delay += [[e valueForKey:@"duration"] doubleValue];
    
    }
}

-(void) loadNewBubbleBeat
{
    [_queue removeObjectAtIndex: 0];

}

-(void) addScore: (int) score
{
    _totalScore += score * _pointMultiplier *_currentBubbleBeat.timeStamp;
    _totalScoreLabel.string = [NSString stringWithFormat:@"%i", _totalScore];
}
-(void) resetDefaults
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

-(void) skip
{
    [self loadNextSong];
}

-(void) pause
{
    
}

@end
