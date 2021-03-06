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

@implementation PlayGameHudLayer
@synthesize gameLayer = _gameLayer;
@synthesize selectedMenuItemToggle = _selectedMenuItemToggle;

-(id) init
{
    if ((self = [super init])) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // Setup score.
        magicPowerCollectedLabel = [CCLabelBMFont labelWithString:@"Magic Power: 0" fntFile:@"white_outline_font.fnt"]; 
        magicPowerCollectedLabel.color = ccc3(255,255,255);
        magicPowerCollectedLabel.anchorPoint = ccp(1, 1);
        magicPowerCollectedLabel.position = ccp(winSize.width, winSize.height);
        [self addChild:magicPowerCollectedLabel];
        
        scoreLabel = [CCLabelBMFont labelWithString:@"Score: 0" fntFile:@"white_outline_font.fnt"]; 
        scoreLabel.color = ccc3(255,255,255);
        scoreLabel.anchorPoint = ccp(0, 1);
        scoreLabel.position = ccp(0, winSize.height);
        [self addChild:scoreLabel];
        
        // Setup projectile button.
		projectileToggleItem = [self 
                                createToggleItem: @"projectile-button-on.png" 
                                withOffImageFile: @"projectile-button-off.png"
                                withDisabledImageFile: @"projectile-button-disabled.png"
                                withCallback: @selector(projectileButtonTapped:)
                                ];
        
        self.selectedMenuItemToggle = kProjectile;
        projectileToggleItem.selectedIndex = 1;
        
        // Setup move button.
		moveToggleItem = [self 
                          createToggleItem: @"move-button-on.png" 
                          withOffImageFile: @"move-button-off.png"
                          withDisabledImageFile: @"move-button-disabled.png"
                          withCallback: @selector(moveButtonTapped:)
                          ];
        
        // Setup build button.
		buildToggleItem = [self 
                           createToggleItem: @"build-button-on.png" 
                           withOffImageFile: @"build-button-off.png"
                           withDisabledImageFile: @"build-button-disabled.png"
                           withCallback: @selector(buildButtonTapped:)
                           ];
        
        // Setup net button.
		netToggleItem = [self 
                         createToggleItem: @"net-button-on.png" 
                         withOffImageFile: @"net-button-off.png"
                         withDisabledImageFile: @"net-button-disabled.png"
                         withCallback: @selector(netButtonTapped:)
                         ];
        
        // Setup hole button.
		holeToggleItem = [self 
                          createToggleItem: @"hole-button-on.png" 
                          withOffImageFile: @"hole-button-off.png"
                          withDisabledImageFile: @"hole-button-disabled.png"
                          withCallback: @selector(holeButtonTapped:)
                          ];
        
        CCMenu *toggleMenu = [CCMenu menuWithItems:projectileToggleItem, moveToggleItem, buildToggleItem, netToggleItem, holeToggleItem, nil];
        [toggleMenu alignItemsHorizontally];
		toggleMenu.position = ccp(150, 25);
		[self addChild:toggleMenu];    
    }
    return self;
}

-(CCMenuItemToggle*)createToggleItem:(NSString*)onImageFile withOffImageFile:(NSString*)offImageFile withDisabledImageFile:(NSString*)disabledImageFile withCallback:(SEL)callback
{
    CCMenuItem *buildOn = [[CCMenuItemImage itemFromNormalImage:onImageFile 
                                                  selectedImage:onImageFile target:nil selector:nil] retain];
    CCMenuItem *buildOff = [[CCMenuItemImage itemFromNormalImage:offImageFile 
                                                   selectedImage:offImageFile target:nil selector:nil] retain];
    CCMenuItem *buildDisabled = [[CCMenuItemImage itemFromNormalImage:disabledImageFile 
                                                   selectedImage:disabledImageFile target:nil selector:nil] retain];
    CCMenuItemToggle *createdToggleItem = [CCMenuItemToggle itemWithTarget:self 
                                                                  selector:callback items:buildOff, buildOn, buildDisabled, nil];  
    return createdToggleItem;
}

- (void)deselectAllToggleButtons
{
    buildToggleItem.selectedIndex = 0;
    projectileToggleItem.selectedIndex = 0;
    moveToggleItem.selectedIndex = 0;
    holeToggleItem.selectedIndex = 0;
    netToggleItem.selectedIndex = 0;
}

- (void)projectileButtonTapped:(id)sender
{
    [self deselectAllToggleButtons];
    self.selectedMenuItemToggle = kProjectile;
    projectileToggleItem.selectedIndex = 1;
}

- (void)buildButtonTapped:(id)sender
{
    [self deselectAllToggleButtons];
    self.selectedMenuItemToggle = kBuild;
    buildToggleItem.selectedIndex = 1;
}

- (void)moveButtonTapped:(id)sender
{
    [self deselectAllToggleButtons];
    self.selectedMenuItemToggle = kMove;
    moveToggleItem.selectedIndex = 1;
}

- (void)netButtonTapped:(id)sender
{
    [self deselectAllToggleButtons];
    self.selectedMenuItemToggle = kNet;
    netToggleItem.selectedIndex = 1;
}

- (void)holeButtonTapped:(id)sender
{
    [self deselectAllToggleButtons];
    self.selectedMenuItemToggle = kHole;
    holeToggleItem.selectedIndex = 1;
}

- (void)magicPowerCollectedChanged:(int)magicPowerCollected {
    [magicPowerCollectedLabel setString:[NSString stringWithFormat:@"Magic Power: %d", magicPowerCollected]];
    
    if ( magicPowerCollected <= 0 ) {
        [self moveButtonTapped:nil];
        
        [buildToggleItem setIsEnabled:FALSE];
        [projectileToggleItem setIsEnabled:FALSE];
        [holeToggleItem setIsEnabled:FALSE];
        [netToggleItem setIsEnabled:FALSE];    
        buildToggleItem.selectedIndex = 2;
        projectileToggleItem.selectedIndex = 2;
        holeToggleItem.selectedIndex = 2;
        netToggleItem.selectedIndex = 2;
    } else {
        
        [buildToggleItem setIsEnabled:TRUE];
        [projectileToggleItem setIsEnabled:TRUE];
        [holeToggleItem setIsEnabled:TRUE];
        [netToggleItem setIsEnabled:TRUE];
        buildToggleItem.selectedIndex = 0;
        projectileToggleItem.selectedIndex = 0;
        holeToggleItem.selectedIndex = 0;
        netToggleItem.selectedIndex = 0;
    }
}

- (void)scoreChanged:(int)score {
    [scoreLabel setString:[NSString stringWithFormat:@"Score: %d", score]];
}

@end

