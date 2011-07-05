//
//  Monster.m
//  ZomFort
//
//  Created by Lance Nanek on 7/5/11.
//  Copyright h4labs 2011. All rights reserved.
//

#import "Monster.h"

@implementation Monster

@synthesize hp = _curHp;
@synthesize minMoveDuration = _minMoveDuration;
@synthesize maxMoveDuration = _maxMoveDuration;
@synthesize isFlying = _isFlying;

@end

@implementation WeakAndFastMonster

+ (id)monster {
 
    WeakAndFastMonster *monster = nil;
    if ((monster = [[[super alloc] initWithFile:@"enemy2.png"] autorelease])) {
        monster.hp = 1;
        monster.minMoveDuration = 3;
        monster.maxMoveDuration = 5;
        monster.isFlying = FALSE;
    }
    return monster;
    
}

@end

@implementation StrongAndSlowMonster

+ (id)monster {
    
    StrongAndSlowMonster *monster = nil;
    if ((monster = [[[super alloc] initWithFile:@"enemy3.png"] autorelease])) {
        monster.hp = 2;
        monster.minMoveDuration = 6;
        monster.maxMoveDuration = 12;
        monster.isFlying = FALSE;
    }
    return monster;
    
}

@end

@implementation FlyingMonster

+ (id)monster {
    
    FlyingMonster *monster = nil;
    if ((monster = [[[super alloc] initWithFile:@"enemy1.png"] autorelease])) {
        monster.hp = 1;
        monster.minMoveDuration = 3;
        monster.maxMoveDuration = 5;
        monster.isFlying = TRUE;
    }
    return monster;
    
}

@end