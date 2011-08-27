//
//  TitleScene.m
//  ZomFort
//
//  Created by Lance Nanek on 8/10/11.
//  Copyright 2011 h4labs. All rights reserved.
//

#import "TitleScene.h"
#import "PlayGameWorldLayer.h"
#import "CCSpriteExtensions.h"

@implementation TitleScene
@synthesize layer = _layer;

- (id)init {
    
    if ((self = [super init])) {
        self.layer = [TitleSceneLayer node];
        [self addChild:_layer];
    }
    return self;
}

- (void)dealloc {
    [_layer release];
    _layer = nil;
    [super dealloc];
}

@end

@implementation TitleSceneLayer

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    [[CCDirector sharedDirector] replaceScene:[PlayGameWorldLayer scene]];
    
	return YES;
}

-(id) init
{
    if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {

        CGSize winSize = [[CCDirector sharedDirector] winSize];

        CCSprite *background = [CCSprite spriteWithFile:@"abergelecastle.jpg"];
		background.position = ccp(0, 0);
		background.anchorPoint = ccp(0, 0);
        [background resizeTo:CGSizeMake(winSize.width, winSize.height)];
		[self addChild:background];
        
        CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"Wizards vs. Zombies" fntFile:@"red_outline_font.fnt"];        
        label.color = ccc3(255,255,255);
        label.position = ccp(winSize.width/2, winSize.height/2 + 60);
        [self addChild:label];

        CCLabelBMFont *prompt = [CCLabelBMFont labelWithString:@"Tap to Start" fntFile:@"white_outline_font.fnt"];        
        prompt.color = ccc3(255,255,255);
        prompt.position = ccp(winSize.width/2, winSize.height/2 - 50);
        [self addChild:prompt];
        
        [self registerWithTouchDispatcher];
        
    }	
    return self;
}

- (void)dealloc {
    [super dealloc];
}

@end