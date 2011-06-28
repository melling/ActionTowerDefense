//
//  PlayGameWorldLayer.h
//  ZomFort
//
//  Created by Lance Nanek on 6/28/11.
//  Copyright h4labs 2011. All rights reserved.
//

#import "cocos2d.h"

@class PlayGameHudLayer;

// PlayGameWorldLayer Layer
@interface PlayGameWorldLayer : CCLayer
{
    CCTMXTiledMap *_tileMap;
    CCTMXLayer *_background;
    CCTMXLayer *_foreground;
    CCTMXLayer *_meta;
    CCSprite *_player;
    int _numCollected;
    PlayGameHudLayer *_hud;
    
	NSMutableArray *_enemies;
	NSMutableArray *_projectiles;
	NSMutableArray *_holes;
	NSMutableArray *_nets;
}

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CCTMXLayer *background;
@property (nonatomic, retain) CCTMXLayer *foreground;
@property (nonatomic, retain) CCTMXLayer *meta;
@property (nonatomic, retain) CCSprite *player;
@property (nonatomic, assign) int numCollected;
@property (nonatomic, retain) PlayGameHudLayer *hud;

// returns a Scene that contains the PlayGameWorldLayer and PlayGameHudLayer as children
+(id) scene;

@end
