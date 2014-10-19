//
//  Bubble.h
//  ShareABeatWithCoke
//
//  Created by Brian Wang on 10/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "BubbleBeat.h"

@interface Bubble : CCNode
@property (strong, nonatomic) CCLabelTTF* timeLabel;
@property (assign, nonatomic) double beatTime;
@property (strong, nonatomic) BubbleBeat* thisBeat;
@property (strong, nonatomic) CCSprite* bubbleSpriteFrame;

-(void)loadParticleExplosionWithParticleName: (NSString *) particleName withPosition: (CGPoint) position withColor: (CCColor*) color;
-(void) burstWithColor: (CCColor*) color;
@end
