//
//  BubbleBeat.m
//  ShareABeatWithCoke
//
//  Created by Brian Wang on 10/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "BubbleBeat.h"

@implementation BubbleBeat

-(id) initWithTime: (float) givenTimeStamp andType: (NSString*) type
{
    self.timeStamp = givenTimeStamp;
    self.typeOfSlapNeeded = type;
    return self;
}

@end
