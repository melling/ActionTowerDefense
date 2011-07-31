//
//  PlayGameHudLayer.m
//  ZomFort
//
//  Created by Lance Nanek on 6/28/11.
//  Copyright h4labs 2011. All rights reserved.
//

// Import the interfaces
#import "PlayGameWorldLayer.h"
#import "PlayGameHudLayer.h"
#import "GameOverScene.h"
#import "SimpleAudioEngine.h"

//TODO code cleanup: separate files for classes, rename classes as needed, enums instead of numbers and multiple bools

@implementation PlayGameHudLayer
@synthesize gameLayer = _gameLayer;
@synthesize selectedMenuItemToggle = _selectedMenuItemToggle;

-(id) init
{
    if ((self = [super init])) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // Setup score.
        melonsCollectedLabel = [CCLabel labelWithString:@"Melons: 0" fontName:@"Verdana-Bold" fontSize:18.0];
        melonsCollectedLabel.color = ccc3(255,255,255);
        melonsCollectedLabel.anchorPoint = ccp(1, 1);
        melonsCollectedLabel.position = ccp(winSize.width, winSize.height);
        [self addChild:melonsCollectedLabel];
        
        scoreLabel = [CCLabel labelWithString:@"Score: 0" fontName:@"Verdana-Bold" fontSize:18.0];
        scoreLabel.color = ccc3(255,255,255);
        scoreLabel.anchorPoint = ccp(0, 1);
        scoreLabel.position = ccp(0, winSize.height);
        [self addChild:scoreLabel];
               
        // Setup projectile button.
		projectileToggleItem = [self 
                           createToggleItem: @"projectile-button-on.png" 
                           withOffImageFile: @"projectile-button-off.png"
                           withCallback: @selector(projectileButtonTapped:)
                           ];

        self.selectedMenuItemToggle = kProjectile;
        projectileToggleItem.selectedIndex = 1;
        
        // Setup move button.
		moveToggleItem = [self 
                           createToggleItem: @"move-button-on.png" 
                           withOffImageFile: @"move-button-off.png"
                           withCallback: @selector(moveButtonTapped:)
                           ];
        
        // Setup build button.
		buildToggleItem = [self 
                           createToggleItem: @"build-button-on.png" 
                           withOffImageFile: @"build-button-off.png"
                           withCallback: @selector(buildButtonTapped:)
                           ];
        
        // Setup net button.
		netToggleItem = [self 
                           createToggleItem: @"net-button-on.png" 
                           withOffImageFile: @"net-button-off.png"
                           withCallback: @selector(netButtonTapped:)
                           ];
        
        // Setup hole button.
		holeToggleItem = [self 
                           createToggleItem: @"hole-button-on.png" 
                           withOffImageFile: @"hole-button-off.png"
                           withCallback: @selector(holeButtonTapped:)
                           ];

        CCMenu *toggleMenu = [CCMenu menuWithItems:projectileToggleItem, moveToggleItem, buildToggleItem, netToggleItem, holeToggleItem, nil];
        [toggleMenu alignItemsHorizontally];
		toggleMenu.position = ccp(150, 25);
		[self addChild:toggleMenu];    
     }
    return self;
}

-(CCMenuItemToggle*)createToggleItem:(NSString*)onImageFile withOffImageFile:(NSString*)offImageFile withCallback:(SEL)callback
{
    CCMenuItem *buildOn = [[CCMenuItemImage itemFromNormalImage:onImageFile 
                                                  selectedImage:onImageFile target:nil selector:nil] retain];
    CCMenuItem *buildOff = [[CCMenuItemImage itemFromNormalImage:offImageFile 
                                                   selectedImage:offImageFile target:nil selector:nil] retain];
    CCMenuItemToggle *createdToggleItem = [CCMenuItemToggle itemWithTarget:self 
                                              selector:callback items:buildOff, buildOn, nil];  
    return createdToggleItem;
}

- (void)disableAllToggleButtons
{
    buildToggleItem.selectedIndex = 0;
    projectileToggleItem.selectedIndex = 0;
    moveToggleItem.selectedIndex = 0;
    holeToggleItem.selectedIndex = 0;
    netToggleItem.selectedIndex = 0;
}

- (void)projectileButtonTapped:(id)sender
{
    [self disableAllToggleButtons];
    self.selectedMenuItemToggle = kProjectile;
    projectileToggleItem.selectedIndex = 1;
}

- (void)buildButtonTapped:(id)sender
{
    [self disableAllToggleButtons];
    self.selectedMenuItemToggle = kBuild;
    buildToggleItem.selectedIndex = 1;
}

- (void)moveButtonTapped:(id)sender
{
    [self disableAllToggleButtons];
    self.selectedMenuItemToggle = kMove;
    moveToggleItem.selectedIndex = 1;
}

- (void)netButtonTapped:(id)sender
{
    [self disableAllToggleButtons];
    self.selectedMenuItemToggle = kNet;
    netToggleItem.selectedIndex = 1;
}

- (void)holeButtonTapped:(id)sender
{
    [self disableAllToggleButtons];
    self.selectedMenuItemToggle = kHole;
    holeToggleItem.selectedIndex = 1;
}

- (void)melonsCollectedChanged:(int)melonsCollected {
    [melonsCollectedLabel setString:[NSString stringWithFormat:@"Melons: %d", melonsCollected]];
}

- (void)scoreChanged:(int)score {
    [scoreLabel setString:[NSString stringWithFormat:@"Score: %d", score]];
}

@end

