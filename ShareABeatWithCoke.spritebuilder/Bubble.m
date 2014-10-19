//
//  Bubble.m
//  ShareABeatWithCoke
//
//  Created by Brian Wang on 10/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Bubble.h"

@implementation Bubble


-(void) burstWithColor:(CCColor*) color
{
    [self loadParticleExplosionWithParticleName: @"BubbleBurst" withPosition:ccp(self.contentSizeInPoints.width/2,self.contentSizeInPoints.height/2) withColor:color];
    [self removeFromParent];
}

-(void)loadParticleExplosionWithParticleName: (NSString *) particleName withPosition: (CGPoint) position withColor: (CCColor*) color
{
    
    @synchronized(self)
    {
        CCParticleSystem *explosion = (CCParticleSystem*)[CCBReader load: [NSString stringWithFormat:@"Particles/%@Particle", particleName]];
        explosion.autoRemoveOnFinish = TRUE;
        explosion.position = position;
        explosion.startColor = color;
        explosion.endColor = color;
        [self addChild: explosion];
    }
}

-(void) update:(CCTime)delta
{
    if (self.beatTime > 0)
    {
        self.beatTime -= delta;
        self.timeLabel.string = [NSString stringWithFormat:@"%.1f", self.beatTime];
    }
    else if (self.beatTime <=0)
    {
        self.beatTime = 0;
        self.timeLabel.string = @"0";
    }
}
@end
