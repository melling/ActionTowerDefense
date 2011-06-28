//
//  GameOverScene.h
//  ZomFort
//
//  Created by Lance Nanek on 6/28/11.
//  Copyright h4labs 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
 
@interface GameOverLayer : CCColorLayer {
  CCLabel *_label;
}
@property (nonatomic, retain) CCLabel *label;
@end
 
@interface GameOverScene : CCScene {
  GameOverLayer *_layer;
}
@property (nonatomic, retain) GameOverLayer *layer;
@end