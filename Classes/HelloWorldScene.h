
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@class HelloWorld;
@interface HelloWorldHud : CCLayer
{   
    CCLabel *label;
	HelloWorld *_gameLayer;
    
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

@property (nonatomic, retain) HelloWorld *gameLayer;
@property (nonatomic, assign) BOOL isInMoveMode;
@property (nonatomic, assign) BOOL isInProjectileMode;
@property (nonatomic, assign) BOOL isInBuildMode;
@property (nonatomic, assign) BOOL isInHoleMode;
@property (nonatomic, assign) BOOL isInNetMode;

-(CCMenuItemToggle*)createToggleItem:(NSString*)onImageFile withOffImageFile:(NSString*)offImageFile withCallback:(SEL)callback;
- (void)numCollectedChanged:(int)numCollected;
- (void)disableAllToggleButtons;
@end

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
