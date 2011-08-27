//
//  TitleScene.h
//  ZomFort
//
//  Created by Lance Nanek on 8/10/11.
//  Copyright 2011 h4labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TitleSceneLayer : CCLayerColor {
}
@end

@interface TitleScene : CCScene {
    TitleSceneLayer *_layer;
}
@property (nonatomic, retain) TitleSceneLayer *layer;
@end