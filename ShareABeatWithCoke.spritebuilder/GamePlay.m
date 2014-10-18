//
//  GamePlay.m
//  ShareABeatWithCoke
//
//  Created by Brian Wang on 10/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GamePlay.h"

@implementation GamePlay
{
    Timer *_timer;
    ComboBar *_comboBar;
    CCNodeGradient *_glowNodeGradientNode;
    CCNodeColor *_glowNode;
    CCLabelTTF *_bubbleBeatMessage;
    CCLabelTTF *_comboModeLabel;
    NSUserDefaults *_defaults;
    
    float _currentNumOfBeats;
    int _waveNumOfBeats;
    
    int _pointMultiplier;
    int _totalScore;
    
    CCLabelTTF *_totalScoreLabel;
    CCLabelTTF *_tutorialLabel;
    
    BOOL _gameCountdownMode;
    int _gameCountdown;
    
    BOOL _gameStarted;
    BOOL _gameEnded;
    BOOL _tutorialMode;
    BOOL _comboMode;
    
    NSMutableArray *_queue;
    
    int _comboBarSize;
    
    BubbleBeat*_currentBubbleBeat;
    int _totalPoints;
    float _bubbleBeatTimeStamp;
    BOOL _bubbleBeatRecognized;
    BOOL _allowBubbleBeat;
    float _beatLength;
    BOOL _percentageAlreadySubtracted;
    
}

-(void) didLoadFromCCB
{
    self.userInteractionEnabled = FALSE;
    _bubbleBeatMessage.string = @"";
    _defaults = [NSUserDefaults standardUserDefaults];
    
    _timer = [Timer alloc];
    
    _gameCountdownMode = TRUE;
    _gameCountdown = 4;
    _gameStarted = FALSE;
    _gameEnded = FALSE;
    _comboMode = FALSE;
    
    _totalPoints = 0;
    
    _bubbleBeatTimeStamp = 0;
    _bubbleBeatRecognized = FALSE;
    _beatLength = .7;
    _percentageAlreadySubtracted = FALSE;
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
                else if (_gameCountdown == 4)
                {
                    _bubbleBeatMessage.string = @"TAP THE BUBBLES TO THE BEAT!";
                }
                else if (_gameCountdown < 4 && _gameCountdown > 0)
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
//            _gameCountdown = 4;
//            _timer.currentTime = 0;
//            _bubbleBeatTimeStamp = 0;
//        }
        
        _currentBubbleBeat = _queue[0];
        
        if (_timer.currentTime >= _currentBubbleBeat.timeStamp * _beatLength && [_currentBubbleBeat.typeOfSlapNeeded isEqual:@"PAUSE"])
        {
            
            [self performSelector:@selector(delayAllowanceOfBubbleBeat) withObject:nil afterDelay: .2 * _beatLength];
            _currentNumOfBeats+=_currentBubbleBeat.timeStamp;
            _timer.currentTime = 0;
            _bubbleBeatTimeStamp = 0;
        }
        else
        {
            if (!_bubbleBeatRecognized && _timer.currentTime >= (_currentBubbleBeat.timeStamp + .2) * _beatLength)
            {
                _bubbleBeatTimeStamp = .2*_beatLength;
                _timer.currentTime = .2*_beatLength;
                _currentNumOfBeats +=_currentBubbleBeat.timeStamp;
                _bubbleBeatRecognized = FALSE;
                _allowBubbleBeat = TRUE;
                
                _bubbleBeatMessage.string = @"TOO LATE!";
                [self setPercentage: -6* _currentBubbleBeat.timeStamp];
                
                
            }
            else if (_bubbleBeatRecognized && _timer.currentTime >= _currentBubbleBeat.timeStamp * _beatLength)
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

-(void) delayWaveMessage
{
    if (_tutorialMode)
    {
        _bubbleBeatMessage.string = @"TUTORIAL COMPLETE";
    }
    else
    {
        _bubbleBeatMessage.string = @"WAVE COMPLETE";
    }
}

-(void) delayAllowanceOfBubbleBeat
{
    _bubbleBeatRecognized  = FALSE;
    _allowBubbleBeat = TRUE;
}

-(void) popBubble: (Bubble*) bubble
{
    if (!_bubbleBeatRecognized && _allowBubbleBeat)
    {
        float convertedTime = _currentBubbleBeat.timeStamp * _beatLength;
        if (bubble.thisBeat == _queue[0])
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
            [_comboBar loadParticleExplosionWithParticleName:@"ComboBar" withPosition:ccp(-1, .5) withColor:[CCColor cyanColor]];
        }
    }
    
    if (_comboBar.currentSize>= 100)
    {
        _comboBar.currentSize = 100;
        _comboMode = TRUE;
        _glowNodeGradientNode.visible = TRUE;
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
        _glowNodeGradientNode.visible = FALSE;
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
    
}

-(void) loadNewBubbleBeat
{
    [_queue removeObjectAtIndex: 0];
    NSArray *generatedBubbleBeat = nil;
    switch (arc4random()%4)
    {
        case 0: generatedBubbleBeat = _fourSlap;
            break;
        case 1: generatedBubbleBeat = _threeSlapOneDouble;
            break;
        case 2: generatedBubbleBeat = _twoDoubleOneTriple;
            break;
        case 3: generatedBubbleBeat = _twoSlapOneDown;
            break;
    }
    [_queue addObject: generatedBubbleBeat];

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

@end
