//
//  Monster.h
//  ZomFort
//
//  Created by Lance Nanek on 7/5/11.
//  Copyright h4labs 2011. All rights reserved.
//

#import "cocos2d.h"

@interface Monster : CCSprite {
    int _curHp;
    int _minMoveDuration;
    int _maxMoveDuration;
    BOOL _isFlying;
}

@property (nonatomic, assign) int hp;
@property (nonatomic, assign) int minMoveDuration;
@property (nonatomic, assign) int maxMoveDuration;
@property (nonatomic, assign) BOOL isFlying;

@end

@interface WeakAndFastMonster : Monster {
}
+(id)monster;
@end

@interface StrongAndSlowMonster : Monster {
}
+(id)monster;
@end

@interface FlyingMonster : Monster {
}
+(id)monster;
@end