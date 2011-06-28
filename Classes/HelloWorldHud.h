
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
