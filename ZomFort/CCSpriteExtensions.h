//
//  CCSpriteExtensions.h
//  SpanishApp
//
//  Created by Lance Nanek on 7/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface CCSprite (Xtensions)

// Resize to the specified size by setting the scale factors correctly.
-(void)resizeTo:(CGSize) theSize;

@end