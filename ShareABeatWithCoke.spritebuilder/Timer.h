//
//  Timer.h
//  ShareABeatWithCoke
//
//  Created by Brian Wang on 10/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Timer : CCNode
@property (assign, nonatomic) float currentTime;
@property (assign, nonatomic) float comboTimeKeeper;
@property (assign, nonatomic) float beatLength;
@property (assign, nonatomic) float bubbleSpawnTime;
@end
