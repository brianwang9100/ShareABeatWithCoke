//
//  BubbleBeat.m
//  ShareABeatWithCoke
//
//  Created by Brian Wang on 10/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "BubbleBeat.h"

@implementation BubbleBeat

-(id) initWithTime: (float) givenTimeStamp andDelay: (float) givenDelayStamp andType: (NSString*) type
{
    self.timeStamp = givenTimeStamp;
    self.delay = givenDelayStamp;
    self.typeOfSlapNeeded = type;
    return self;
}

@end
