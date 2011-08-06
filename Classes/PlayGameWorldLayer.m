//
//  PlayGameWorldLayer.m
//  ZomFort
//
//  Created by Lance Nanek on 6/28/11.
//  Copyright h4labs 2011. All rights reserved.
//

#import "PlayGameWorldLayer.h"
#import "PlayGameHudLayer.h"
#import "GameOverScene.h"
#import "SimpleAudioEngine.h"


#import "Monster.h"

// Values for the Enemy property on a spawn point in the map to indicate a kind of enemy.
// TODO cleaner to just use class name as property value?
#define kEnemyValueInMapForFlyingMonster 1
#define kEnemyValueInMapForWeakAndFastMonster 2
#define kEnemyValueInMapForStrongAndSlowMonster 3

#define kMapGIDForNet 49
#define kMapGIDForHole 50
#define kMapGIDForBlock 51
#define kMapGIDForCollidable 57

#define kPointsForCollectingMagicPower 1000
#define kPointsForKillingMonster 100
#define kMonstersRemainingToWin 1
#define kStartingMagicPower 15
#define kSecondsConjuredBlocksLast 5

@interface PlayGameWorldLayer (Private)
    - (void)setPlayerPosition:(CGPoint)position;
@end

// PlayGameWorldLayer implementation
@implementation PlayGameWorldLayer
@synthesize tileMap = _tileMap;
@synthesize background = _background;
@synthesize foreground = _foreground;
@synthesize traps = _traps;
@synthesize meta = _meta;
@synthesize player = _player;
@synthesize magicPowerCollected = _magicPowerCollected;
@synthesize score = _score;
@synthesize hud = _hud;

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PlayGameWorldLayer *layer = [PlayGameWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
    
    PlayGameHudLayer *hud = [PlayGameHudLayer node];    
    [scene addChild: hud];
    
    layer.hud = hud;
    hud.gameLayer = layer;
    
    [hud magicPowerCollectedChanged:layer.magicPowerCollected];
	
	// return the scene
	return scene;
}

- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
    return ccp(x, y);
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
    
    // Smoother screen scrolling than immediate self.position = viewPoint;
    [self runAction: [CCMoveTo actionWithDuration: 0.25 position: viewPoint]];
    
}

-(bool) isCollidable:(CGPoint)tileCoord
{
    int tileGid = [_meta tileGIDAt:tileCoord];
    if (tileGid) {
        NSDictionary *properties = [_tileMap propertiesForGID:tileGid];
        if (properties) {
            NSString *collision = [properties valueForKey:@"Collidable"];
            if (collision && [collision compare:@"True"] == NSOrderedSame) {
                return TRUE;
            }
        }
    }    
    return FALSE;
}

-(bool) isOnMap:(CGPoint)tileCoord
{
    return tileCoord.x < _tileMap.mapSize.width 
        && tileCoord.y < _tileMap.mapSize.height 
        && tileCoord.x >=0 
        && tileCoord.y >=0;
        
}

-(void) animateEnemy:(Monster*)enemy
{ 
    // Move toward the player
    CGPoint newPositionDelta = ccpMult(ccpNormalize(ccpSub(_player.position,enemy.position)),5);
    
    // If this isn't a flying enemy type it can collide with obstacles.
    if ( !enemy.isFlying ) {
        // TODO later on maybe monsters should be able to break down blocks eventually (make them sand bags or dirt walls?) or path find around them?
        
        CGPoint newPosition = ccp(enemy.position.x + newPositionDelta.x, enemy.position.y + newPositionDelta.y);
        CGPoint tileCoord = [self tileCoordForPosition:newPosition];
        
        // If the enemy is on the map.
        if ([self isOnMap:tileCoord]) {
            
            // If not a hole trap at this map location
            int tileGid = [_traps tileGIDAt:tileCoord];
            if (kMapGIDForHole != tileGid) {        
                
                // If the move is into a collidable, don't move.              
                if ( [self isCollidable:tileCoord] ) {
                    newPositionDelta = ccp(0,0);
                }
            }
        }
    }
    
    //speed of the enemy
    int rangeDuration = enemy.maxMoveDuration - enemy.minMoveDuration;
    int actualDurationFactor = (arc4random() % rangeDuration) + enemy.minMoveDuration;
    ccTime actualDuration = .015 * actualDurationFactor;  
    
    id actionMove = [CCMoveBy actionWithDuration:actualDuration 
                                        position:newPositionDelta];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self 
                                             selector:@selector(enemyMoveFinished:)];
    [enemy runAction:[CCSequence actions:actionMove, actionMoveDone, nil]]; 
}

-(void)enemyMoveFinished:(id)sender {
	Monster *enemy = (Monster *)sender;
    
    // Check enemy type, flying ones rotate to face player.
    if ( enemy.isFlying ) {
        
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

-(void)removeBlockAt:(id)sender data:(id)tileCoordValue {

    CGPoint tileCoord = [tileCoordValue CGPointValue];
    [_traps removeTileAt:tileCoord];
    [_meta removeTileAt:tileCoord];
    
    [tileCoordValue release];
}

-(void)addEnemyAtSpawnPoint:(id)sender data:(id)spawnPoint {
    int enemyKind = [[spawnPoint valueForKey:@"Enemy"] intValue];
    if (enemyKind < 1) {
        return;
    }
    
    int x = [[spawnPoint valueForKey:@"x"] intValue];
    int y = [[spawnPoint valueForKey:@"y"] intValue];
    
    Monster *enemy;
    if ( kEnemyValueInMapForFlyingMonster == enemyKind ) {
        enemy = [FlyingMonster monster];
    } else if ( kEnemyValueInMapForWeakAndFastMonster == enemyKind ) {
        enemy = [WeakAndFastMonster monster];
    } else {
        enemy = [StrongAndSlowMonster monster];
    }
    
    enemy.position = ccp(x, y);
    enemy.userData = [NSNumber numberWithInt:enemyKind];
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

- (void)killMonster:(CCSprite *)target  {
    [_enemies removeObject:target];
    [self removeChild:target cleanup:YES];	
    
    self.score += kPointsForKillingMonster;
    [_hud scoreChanged:_score];
    _monstersLeftToKill--;
    
    if (_monstersLeftToKill - kMonstersRemainingToWin <= 0){
        [self win];
    }    
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
        
        BOOL monsterHit = FALSE;      
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
                NSLog(@"collision");
                monsterHit = TRUE;
                Monster *monster = (Monster *)target;
                monster.hp--;
                if (monster.hp <= 0) {
                    [targetsToDelete addObject:target];
                }
                
                break;
            }
        }
        
        // delete all hit enemies
        for (CCSprite *target in targetsToDelete) {
            [self killMonster: target];
        }
        
        if (monsterHit) {    
            [[SimpleAudioEngine sharedEngine] playEffect:@"explosion.caf"];
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
    
    
    NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
	// iterate through enemies, see if any intersect with hole or net
    for (Monster *target in _enemies) {
        //NSLog(@"enemy");
        
        //TODO check each corner of the target rect instead of just target.position?
        CGRect targetRect = CGRectMake(
                                       target.position.x - (target.contentSize.width/2), 
                                       target.position.y - (target.contentSize.height/2), 
                                       target.contentSize.width, 
                                       target.contentSize.height);
        
        CGPoint enemyTileCoord = [self tileCoordForPosition:target.position];
        int tileGid = [_traps tileGIDAt:enemyTileCoord];
        if (tileGid) {
            BOOL isCaughtInNet = target.isFlying && kMapGIDForNet == tileGid;
            BOOL isStuckInHole = !target.isFlying && kMapGIDForHole == tileGid;
            if ( isCaughtInNet || isStuckInHole ) {
                NSLog(@"enemy ran into trap");   
                
                [targetsToDelete addObject:target];    
                
                [_traps removeTileAt:enemyTileCoord];
                [_meta removeTileAt:enemyTileCoord];
                
                continue;
            }
        }       
    }
    
    // delete all trapped enemies
	for (CCSprite *target in targetsToDelete) {
        [self killMonster: target];
    }    
    [targetsToDelete release];
    
    
    
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
        self.traps = [_tileMap layerNamed:@"Traps"];
        self.meta = [_tileMap layerNamed:@"Meta"];
        _meta.visible = NO;
        
        _magicPowerCollected = kStartingMagicPower;
        
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
        _monstersLeftToKill = 0;
		for (spawnPoint in [objects objects]) {
            
            // Read optional number of enemies to spawn property.
            int numberOfEnemiesToSpawn = [[spawnPoint valueForKey:@"NumberOfEnemiesToSpawn"] intValue];
            if ( numberOfEnemiesToSpawn <= 0 ) {
                // Spawn 1 enemy if nothing set.
                numberOfEnemiesToSpawn = 1;
            }
            _monstersLeftToKill += numberOfEnemiesToSpawn;
            
            // Read optional property for how long to wait before spawning each enemy.
            float SpawnDelaySeconds = [[spawnPoint valueForKey:@"SpawnDelaySeconds"] intValue];
            if ( SpawnDelaySeconds < 0.0f ) {
                // Spawn instantly if nothing set.
                SpawnDelaySeconds = 0.0f;
            }
            
            // Action for adding 1 enemy.
            id actionAddEnemy = [CCCallFuncND actionWithTarget:self
                                                      selector:@selector(addEnemyAtSpawnPoint:data:) data:spawnPoint];
            
            id actionDelay = [CCDelayTime actionWithDuration:SpawnDelaySeconds];
            
            id actionAddEnemyDelayed = [CCSequence actions: actionDelay, actionAddEnemy, nil];
            
            // Action for adding all enemies specified by this spawn point.
            id actionAddEnemies = [CCRepeat actionWithAction:actionAddEnemyDelayed times:numberOfEnemiesToSpawn];
            
            // Run the action.
            [_player runAction:actionAddEnemies]; 
		}
        
        // Center the view on the player (or as close as we can!)
        [self setViewpointCenter:_player.position];
        
        [self addChild:_tileMap z:-1];
		
		[self schedule:@selector(testCollisions:)];
    }
    return self;
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(void)processMoveTouchIfNeeded {
    // If there isn't any touch in progress, or if the player is already moving, don't move more.
    if ( !_isTouchInProgress || _isPlayerMoving ) {
        return;
    }
    
    CGPoint touchLocation = _currentTouchLocation;
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    CGPoint playerPos;
    CGPoint diff;
    
    switch ( _hud.selectedMenuItemToggle ) {      
        case kMove:
            
		    playerPos = _player.position;
		    diff = ccpSub(touchLocation, playerPos);
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
            
		    [self setPlayerPosition:playerPos];
            
		    [self setViewpointCenter:_player.position];
            
            break;
        default:
            break;
    }
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // Keep track of the current touch, so that the user can move by holding a finger down.
    _isTouchInProgress = TRUE;
    _currentTouchLocation = [touch locationInView: [touch view]];		

    [self processMoveTouchIfNeeded];
    
	return YES;
}

-(void)setPlayerPosition:(CGPoint)position {
    
    if ( _isPlayerMoving ) {
        return;
    }
    
    CGPoint tileCoord = [self tileCoordForPosition:position];
    // Fix crash when player moved off map.
    if (![self isOnMap:tileCoord]) {
        return;
    }
    
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
                
                self.score += kPointsForCollectingMagicPower;
                [_hud scoreChanged:_score];
                
                self.magicPowerCollected += 1;
                [_hud magicPowerCollectedChanged:_magicPowerCollected];
                [[SimpleAudioEngine sharedEngine] playEffect:@"pickup.caf"];

            }
        }
    }
    [[SimpleAudioEngine sharedEngine] playEffect:@"move.caf"];
    
    // Smoother player movement than immediate _player.position = position;
    
    id actionMove = [CCMoveTo actionWithDuration: 0.25 position: position];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(playerMoveFinished:)];
    id actionSequence = [CCSequence actions:actionMove, actionMoveDone, nil];     
    _isPlayerMoving = TRUE;
    [_player runAction: actionSequence];
}

-(void)playerMoveFinished:(id)sender {
    _isPlayerMoving = FALSE;
    
    // Move again if the user still has their finger down.
    [self processMoveTouchIfNeeded];
}

-(void)projectileMoveFinished:(id)sender {
    CCSprite *sprite = (CCSprite *)sender;
    [self removeChild:sprite cleanup:YES];
    [_projectiles removeObject:sprite];
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    // Keep track of the current touch, so that the user can move by holding a finger down.
    _isTouchInProgress = TRUE;
    _currentTouchLocation = [touch locationInView: [touch view]];		
    
    [self processMoveTouchIfNeeded];    
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    _isTouchInProgress = FALSE;   
    
    CGPoint touchLocation = [touch locationInView: [touch view]];		
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    CGPoint tileCoord = [self tileCoordForPosition:touchLocation];
    
    CCSprite *projectile;
        
    switch ( _hud.selectedMenuItemToggle ) {      
        case kMove:
            
            // Already handled during the touch.
            return;
            
        case kBuild:   
            
            if ( ![self isCollidable:tileCoord] ) {
                [_traps setTileGID:kMapGIDForBlock at:tileCoord];
                [_meta setTileGID:kMapGIDForCollidable at:tileCoord];
            }
            
            //Remove block after a delay
            NSValue *tileCoordValue = [NSValue valueWithCGPoint:tileCoord];
            [tileCoordValue retain];
            id actionRemoveBlock = [CCCallFuncND actionWithTarget:self
                                                      selector:@selector(removeBlockAt:data:) data:tileCoordValue];
            id actionDelay = [CCDelayTime actionWithDuration:kSecondsConjuredBlocksLast];
            id actionRemoveBlockDelayed = [CCSequence actions: actionDelay, actionRemoveBlock, nil];
            
            // Run the action.
            [_player runAction:actionRemoveBlockDelayed]; 
            
            break;
            
        case kProjectile:
            
            // Create a projectile and put it at the player's location
            projectile = [CCSprite spriteWithFile:@"bullet.png"];
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
            
            break;
            
        case kNet:
            
            if ( ![self isCollidable:tileCoord] ) {
                [_traps setTileGID:kMapGIDForNet at:tileCoord];
                [_meta setTileGID:kMapGIDForCollidable at:tileCoord];
            }
            
            break;
            
        case kHole:
            
            if ( ![self isCollidable:tileCoord] ) {
                [_traps setTileGID:kMapGIDForHole at:tileCoord];
                [_meta setTileGID:kMapGIDForCollidable at:tileCoord];
            }      
            break;
    }
	
    // Moving player option returned by this part of the code. 
    // Expend magic power to cast spells.
    _magicPowerCollected--;
    [_hud magicPowerCollectedChanged:_magicPowerCollected];
    
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// cocos2d will automatically release all the children of its objects
	self.tileMap = nil;
    self.background = nil;
    self.foreground = nil;
    self.meta = nil;
    self.player = nil;
    self.hud = nil;
    
    [_enemies release];
    [_projectiles release];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
