//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "HelloWorldScene.h"
#import "GameOverScene.h"
#import "SimpleAudioEngine.h"

@implementation HelloWorldHud
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

// HelloWorld implementation
@implementation HelloWorld
@synthesize tileMap = _tileMap;
@synthesize background = _background;
@synthesize foreground = _foreground;
@synthesize meta = _meta;
@synthesize player = _player;
@synthesize numCollected = _numCollected;
@synthesize hud = _hud;

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
    
    HelloWorldHud *hud = [HelloWorldHud node];    
    [scene addChild: hud];
    
    layer.hud = hud;
    hud.gameLayer = layer;
	
	// return the scene
	return scene;
}

-(void)setViewpointCenter:(CGPoint) position {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    int x = MAX(position.x, winSize.width / 2);
    int y = MAX(position.y, winSize.height / 2);
    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width) - winSize.width / 2);
    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height) - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;
    
}

-(void) animateEnemy:(CCSprite*)enemy
{
  //speed of the enemy
  ccTime actualDuration = .1;
 
  // Create the actions
  id actionMove = [CCMoveBy actionWithDuration:actualDuration 
    position:ccpMult(ccpNormalize(ccpSub(_player.position,enemy.position)),10)];
  id actionMoveDone = [CCCallFuncN actionWithTarget:self 
    selector:@selector(enemyMoveFinished:)];
  [enemy runAction:[CCSequence actions:actionMove, actionMoveDone, nil]]; 
}

-(void)enemyMoveFinished:(id)sender {
	CCSprite *enemy = (CCSprite *)sender;
    
    // Check enemy type, flying ones rotate to face player.
    int enemyKind = (int)[(NSNumber *)enemy.userData intValue];
    if ( enemyKind == 1 ) {
    
  	  CGPoint diff = ccpSub(_player.position,enemy.position);
	  float angleRadians = atanf((float)diff.y / (float)diff.x);
	  float angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
	  float cocosAngle = -1 * angleDegrees;
	  if (diff.x < 0){
		cocosAngle += 180;
	  }
	  enemy.rotation = cocosAngle;
    // Walking enemies flip horizontally to face player.
    } else {
        CGPoint diff = ccpSub(_player.position,enemy.position);
        if (diff.x < 0){
            enemy.flipX = NO;
        } else {
            enemy.flipX = YES;
        }        
    }
    
    [self animateEnemy: enemy]; 
}

-(void)addEnemyAtX:(int)x y:(int)y kindIndex:(int)kindIndex {
  CCSprite *enemy = [CCSprite spriteWithFile:[NSString stringWithFormat:@"enemy%d.png", kindIndex]]; 
  enemy.position = ccp(x, y);
  enemy.userData = [NSNumber numberWithInt:kindIndex];
  [self addChild:enemy];
  [_enemies addObject:enemy];
  [self animateEnemy: enemy]; 
NSLog(@"%@", enemy);
}

- (void)lose {
	GameOverScene *gameOverScene = [GameOverScene node];
	[gameOverScene.layer.label setString:@"You Lose!"];
	[[CCDirector sharedDirector] replaceScene:gameOverScene];
}

- (void)win {
	GameOverScene *gameOverScene = [GameOverScene node];
	[gameOverScene.layer.label setString:@"You Win!"];
	[[CCDirector sharedDirector] replaceScene:gameOverScene];
}

- (void)testCollisions:(ccTime)dt {
  for (CCSprite *target in _enemies) {
    CGRect targetRect = CGRectMake(
	  target.position.x - (target.contentSize.width/2), 
	  target.position.y - (target.contentSize.height/2), 
	  target.contentSize.width, 
	  target.contentSize.height);
	if (CGRectContainsPoint(targetRect, _player.position)) {
	  [self lose];
	}
  }
  
  NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
  // iterate through projectiles
  for (CCSprite *projectile in _projectiles) {
	NSLog(@"projectile: %d enemies", [_enemies count]);
    CGRect projectileRect = CGRectMake(
      projectile.position.x - (projectile.contentSize.width/2), 
      projectile.position.y - (projectile.contentSize.height/2), 
      projectile.contentSize.width, 
      projectile.contentSize.height);
 
    NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
	// iterate through enemies, see if any intersect with currnet projectile
    for (CCSprite *target in _enemies) {
	  NSLog(@"enemy");
      CGRect targetRect = CGRectMake(
        target.position.x - (target.contentSize.width/2), 
        target.position.y - (target.contentSize.height/2), 
        target.contentSize.width, 
        target.contentSize.height);
 
      if (CGRectIntersectsRect(projectileRect, targetRect)) {
        [targetsToDelete addObject:target];
		NSLog(@"collision");
      }
    }
 
    // delete all hit enemies
	for (CCSprite *target in targetsToDelete) {
      [_enemies removeObject:target];
      [self removeChild:target cleanup:YES];									
    }
 
    if (targetsToDelete.count > 0) {
      // add the projectile to the list of ones to remove
	  [projectilesToDelete addObject:projectile];
    }
    [targetsToDelete release];
  }
  // remove all the projectiles that hit.
  for (CCSprite *projectile in projectilesToDelete) {
    [_projectiles removeObject:projectile];
    [self removeChild:projectile cleanup:YES];
  }
  [projectilesToDelete release];
}

// on "init" you need to initialize your instance
-(id) init
{
    if( (self=[super init] )) {
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pickup.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"move.caf"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"TileMap.caf"];
        
        self.isTouchEnabled = YES;
        
        self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMap.tmx"];
        self.background = [_tileMap layerNamed:@"Background"];
        self.foreground = [_tileMap layerNamed:@"Foreground"];
        self.meta = [_tileMap layerNamed:@"Meta"];
        _meta.visible = NO;

        // Find spawn point x,y coordinates
        CCTMXObjectGroup *objects = [_tileMap objectGroupNamed:@"Objects"];
        NSMutableDictionary *spawnPoints = [objects objectNamed:@"SpawnPoint"];
        NSAssert(spawnPoints.count > 0, @"SpawnPoint object missing");
        int x = [[spawnPoints valueForKey:@"x"] intValue];
        int y = [[spawnPoints valueForKey:@"y"] intValue];

        // Create a player sprite at the x,y coordinates
        self.player = [CCSprite spriteWithFile:@"Player.png"];
        _player.position = ccp(x, y);
        [self addChild:_player]; 
		
		
		//after creating the player
		//iterate through objects, finding all enemy spawn points and creating enemies.
		NSMutableDictionary * spawnPoint;
		
		_enemies = [[NSMutableArray alloc] init];
		_projectiles = [[NSMutableArray alloc] init];
		for (spawnPoint in [objects objects]) {
            int enemyKind = [[spawnPoint valueForKey:@"Enemy"] intValue];
			if (enemyKind >= 1){
				x = [[spawnPoint valueForKey:@"x"] intValue];
				y = [[spawnPoint valueForKey:@"y"] intValue];
				[self addEnemyAtX:x y:y kindIndex:enemyKind];
			}
		}

        // Center the view on the player (or as close as we can!)
        [self setViewpointCenter:_player.position];
                    
        [self addChild:_tileMap z:-1];
		
		[self schedule:@selector(testCollisions:)];
    }
    return self;
}

- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
    return ccp(x, y);
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void)setPlayerPosition:(CGPoint)position {

    CGPoint tileCoord = [self tileCoordForPosition:position];
    int tileGid = [_meta tileGIDAt:tileCoord];
    if (tileGid) {
        NSDictionary *properties = [_tileMap propertiesForGID:tileGid];
        if (properties) {
            NSString *collision = [properties valueForKey:@"Collidable"];
            if (collision && [collision compare:@"True"] == NSOrderedSame) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"hit.caf"];
                return;
            }
            NSString *collectable = [properties valueForKey:@"Collectable"];
            if (collectable && [collectable compare:@"True"] == NSOrderedSame) {
                [_meta removeTileAt:tileCoord];
                [_foreground removeTileAt:tileCoord];
                self.numCollected++;
                [_hud numCollectedChanged:_numCollected];
                [[SimpleAudioEngine sharedEngine] playEffect:@"pickup.caf"];
				if (_numCollected == 2){ // put the number of melons on your map in place of the '2'
					[self win];
				}
            }
        }
    }
    [[SimpleAudioEngine sharedEngine] playEffect:@"move.caf"];
    _player.position = position;

}

-(void)projectileMoveFinished:(id)sender {
  CCSprite *sprite = (CCSprite *)sender;
  [self removeChild:sprite cleanup:YES];
  [_projectiles removeObject:sprite];
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ( _hud.isInMoveMode )
	{
		CGPoint touchLocation = [touch locationInView: [touch view]];		
		touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
		touchLocation = [self convertToNodeSpace:touchLocation];
		
		CGPoint playerPos = _player.position;
		CGPoint diff = ccpSub(touchLocation, playerPos);
		if (abs(diff.x) > abs(diff.y)) {
			if (diff.x > 0) {
				playerPos.x += _tileMap.tileSize.width;
			} else {
				playerPos.x -= _tileMap.tileSize.width; 
			}    
		} else {
			if (diff.y > 0) {
				playerPos.y += _tileMap.tileSize.height;
			} else {
				playerPos.y -= _tileMap.tileSize.height;
			}
		}
		//player.position = playerPos; // Todo: Trymove
		[self setPlayerPosition:playerPos];
		
		[self setViewpointCenter:_player.position];
	} else if ( _hud.isInProjectileMode ) {
		// Find where the touch is
		CGPoint touchLocation = [touch locationInView: [touch view]];		
		touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
		touchLocation = [self convertToNodeSpace:touchLocation];

		// Create a projectile and put it at the player's location
		CCSprite *projectile = [CCSprite spriteWithFile:@"bullet.png"];
		projectile.position = _player.position;
		[self addChild:projectile];

		// Determine where we wish to shoot the projectile to
		int realX;
		
		// Are we shooting to the left or right?
		CGPoint diff = ccpSub(touchLocation, _player.position);
		if (diff.x > 0)
		{
			realX = (_tileMap.mapSize.width * _tileMap.tileSize.width) + (projectile.contentSize.width/2);
		}else{
			realX = -(_tileMap.mapSize.width * _tileMap.tileSize.width) - (projectile.contentSize.width/2);
		}
		float ratio = (float) diff.y / (float) diff.x;
		int realY = ((realX - projectile.position.x) * ratio) + projectile.position.y;
		CGPoint realDest = ccp(realX, realY);
		
		// Determine the length of how far we're shooting
		int offRealX = realX - projectile.position.x;
		int offRealY = realY - projectile.position.y;
		float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
		float velocity = 480/1; // 480pixels/1sec
		float realMoveDuration = length/velocity;

		// Move projectile to actual endpoint
		id actionMoveDone = [CCCallFuncN actionWithTarget:self 
			selector:@selector(projectileMoveFinished:)];
		[projectile runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:realMoveDuration position:realDest] two: actionMoveDone]];
		[_projectiles addObject:projectile];
	} else if ( _hud.isInBuildMode ) {
        
        // Find where the touch is
		CGPoint touchLocation = [touch locationInView: [touch view]];		
		touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
		touchLocation = [self convertToNodeSpace:touchLocation]; 
        
        CGPoint tileCoord = [self tileCoordForPosition:touchLocation];
        [_foreground setTileGID:51 at:tileCoord];
        [_meta setTileGID:57 at:tileCoord];
        
    } else if ( _hud.isInNetMode ) {
        
        // Find where the touch is
		CGPoint touchLocation = [touch locationInView: [touch view]];		
		touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
		touchLocation = [self convertToNodeSpace:touchLocation]; 
        
        CGPoint tileCoord = [self tileCoordForPosition:touchLocation];
        [_foreground setTileGID:49 at:tileCoord];
        [_meta setTileGID:57 at:tileCoord];
        
    } else if ( _hud.isInHoleMode ) {
        
        // Find where the touch is
		CGPoint touchLocation = [touch locationInView: [touch view]];		
		touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
		touchLocation = [self convertToNodeSpace:touchLocation]; 
        
        CGPoint tileCoord = [self tileCoordForPosition:touchLocation];
        [_foreground setTileGID:50 at:tileCoord];
        [_meta setTileGID:57 at:tileCoord];
        
    }
    
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	self.tileMap = nil;
    self.background = nil;
    self.foreground = nil;
    self.meta = nil;
    self.player = nil;
    self.hud = nil;
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
