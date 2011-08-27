//
//  PlayGameHudLayer.h
//  ZomFort
//
//  Created by Lance Nanek on 6/28/11.
//  Copyright h4labs 2011. All rights reserved.
//

#import "cocos2d.h"

@class PlayGameWorldLayer;

typedef enum {
    kBuild,
    kMove,
    kProjectile,
    kNet,
    kHole
} SelectedMenuItemToggleType;

@interface PlayGameHudLayer : CCLayer
{   
    CCLabelBMFont *magicPowerCollectedLabel;
    CCLabelBMFont *scoreLabel;
	PlayGameWorldLayer *_gameLayer;
    
    CCMenuItemToggle *buildToggleItem;
    CCMenuItemToggle *moveToggleItem;
    CCMenuItemToggle *projectileToggleItem;
    CCMenuItemToggle *netToggleItem;
    CCMenuItemToggle *holeToggleItem;
    
    SelectedMenuItemToggleType _selectedMenuItemToggle;
}

@property (nonatomic, retain) PlayGameWorldLayer *gameLayer;
@property (nonatomic, assign) SelectedMenuItemToggleType selectedMenuItemToggle;

-(CCMenuItemToggle*)createToggleItem:(NSString*)onImageFile withOffImageFile:(NSString*)offImageFile withDisabledImageFile:(NSString*)disabledImageFile withCallback:(SEL)callback;
- (void)magicPowerCollectedChanged:(int)magicPowerCollected;
- (void)scoreChanged:(int)score;
- (void)deselectAllToggleButtons;
@end
