//
//  BubbleBeat.h
//  ShareABeatWithCoke
//
//  Created by Brian Wang on 10/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface BubbleBeat : CCNode
@property (strong, nonatomic) NSString *typeOfSlapNeeded;
@property (assign, nonatomic) float timeStamp;
-(id) initWithTime: (float) givenTimeStamp andType: (NSString*) type;
@end