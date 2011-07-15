//
//  PlayGameHudLayer.h
//  ZomFort
//
//  Created by Lance Nanek on 6/28/11.
//  Copyright h4labs 2011. All rights reserved.
//

#import "cocos2d.h"

@class PlayGameWorldLayer;

@interface PlayGameHudLayer : CCLayer
{   
    CCLabel *melonsCollectedLabel;
    CCLabel *scoreLabel;
	PlayGameWorldLayer *_gameLayer;
    
    CCMenuItemToggle *buildToggleItem;
    CCMenuItemToggle *moveToggleItem;
    CCMenuItemToggle *projectileToggleItem;
    CCMenuItemToggle *netToggleItem;
    CCMenuItemToggle *holeToggleItem;
    
    BOOL _isInMoveMode;
    BOOL _isInProjectileMode;
    BOOL _isInBuildMode;
    BOOL _isInHoleMode;
    BOOL _isInNetMode;
}

@property (nonatomic, retain) PlayGameWorldLayer *gameLayer;
@property (nonatomic, assign) BOOL isInMoveMode;
@property (nonatomic, assign) BOOL isInProjectileMode;
@property (nonatomic, assign) BOOL isInBuildMode;
@property (nonatomic, assign) BOOL isInHoleMode;
@property (nonatomic, assign) BOOL isInNetMode;

-(CCMenuItemToggle*)createToggleItem:(NSString*)onImageFile withOffImageFile:(NSString*)offImageFile withCallback:(SEL)callback;
- (void)melonsCollectedChanged:(int)melonsCollected;
- (void)scoreChanged:(int)score;
- (void)disableAllToggleButtons;
@end
