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

#define kMelonsNeededToWin 2

//TODO code cleanup: separate files for classes, rename classes as needed, enums instead of numbers and multiple bools

@implementation PlayGameHudLayer
@synthesize gameLayer = _gameLayer;
@synthesize isInMoveMode = _isInMoveMode;
@synthesize isInProjectileMode = _isInProjectileMode;
@synthesize isInBuildMode = _isInBuildMode;
@synthesize isInHoleMode = _isInHoleMode;
@synthesize isInNetMode = _isInNetMode;

-(id) init
{
    if ((self = [super init])) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // Setup score.
        label = [CCLabel labelWithString:@"0" dimensions:CGSizeMake(50, 20) alignment:UITextAlignmentRight fontName:@"Verdana-Bold" fontSize:18.0];
        label.color = ccc3(0,0,0);
        int margin = 10;
        label.position = ccp(winSize.width - (label.contentSize.width/2) - margin, label.contentSize.height/2 + margin);
        [self addChild:label];
        
        // Setup projectile button.
		projectileToggleItem = [self 
                           createToggleItem: @"projectile-button-on.png" 
                           withOffImageFile: @"projectile-button-off.png"
                           withCallback: @selector(projectileButtonTapped:)
                           ];

        self.isInProjectileMode = YES;
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
    self.isInMoveMode = NO;
    self.isInProjectileMode = NO;
    self.isInBuildMode = NO;
    self.isInHoleMode = NO;
    self.isInNetMode = NO;
    buildToggleItem.selectedIndex = 0;
    projectileToggleItem.selectedIndex = 0;
    moveToggleItem.selectedIndex = 0;
    holeToggleItem.selectedIndex = 0;
    netToggleItem.selectedIndex = 0;
}

- (void)projectileButtonTapped:(id)sender
{
    [self disableAllToggleButtons];
    self.isInProjectileMode = YES;
    projectileToggleItem.selectedIndex = 1;
}

- (void)buildButtonTapped:(id)sender
{
    [self disableAllToggleButtons];
    self.isInBuildMode = YES;
    buildToggleItem.selectedIndex = 1;
}

- (void)moveButtonTapped:(id)sender
{
    [self disableAllToggleButtons];
    self.isInMoveMode = YES;
    moveToggleItem.selectedIndex = 1;
}

- (void)netButtonTapped:(id)sender
{
    [self disableAllToggleButtons];
    self.isInNetMode = YES;
    netToggleItem.selectedIndex = 1;
}

- (void)holeButtonTapped:(id)sender
{
    [self disableAllToggleButtons];
    self.isInHoleMode = YES;
    holeToggleItem.selectedIndex = 1;
}

- (void)numCollectedChanged:(int)numCollected {
    [label setString:[NSString stringWithFormat:@"%d", numCollected]];
}

@end

