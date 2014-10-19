//
//  ComboBar.m
//  ShareABeatWithCoke
//
//  Created by Brian Wang on 10/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ComboBar.h"

@implementation ComboBar

-(void) didLoadFromCCB
{
    self.totalSize = 100;
    self.currentSize = 50;
}

-(void) update:(CCTime)delta
{
    self.comboSize.contentSize = CGSizeMake(self.currentSize/self.totalSize, self.comboSize.contentSize.height);
    
    if (self.currentSize <= 33)
    {
        self.comboSize.color = [CCColor redColor];
    }
    else
    {
        self.comboSize.color = [CCColor whiteColor];
    }
    if (self.currentSize <=10)
    {
        self.currentSize = 10;
    }
    
}

-(void)loadParticleExplosionWithParticleName: (NSString *) particleName withPosition: (CGPoint) position withColor: (CCColor*) color
{
        CCParticleSystem *explosion = (CCParticleSystem*)[CCBReader load: [NSString stringWithFormat:@"Particles/%@Particle", particleName]];
        explosion.autoRemoveOnFinish = TRUE;
        explosion.position = position;
        explosion.startColor = color;
        explosion.endColor = color;
        [self.comboSize addChild: explosion];
}

@end
