
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@class HelloWorldHud;

// HelloWorld Layer
@interface HelloWorld : CCLayer
{
    CCTMXTiledMap *_tileMap;
    CCTMXLayer *_background;
    CCTMXLayer *_foreground;
    CCTMXLayer *_meta;
    CCSprite *_player;
    int _numCollected;
    HelloWorldHud *_hud;
    
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
@property (nonatomic, retain) HelloWorldHud *hud;

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
