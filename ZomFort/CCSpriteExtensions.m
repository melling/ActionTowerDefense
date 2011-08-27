//
//  CCSpriteExtensions.m
//  SpanishApp
//
//  Created by Lance Nanek on 7/16/11.
//  Copyright 2011 h4labs. All rights reserved.
//

#import "CCSpriteExtensions.h"

@implementation CCSprite (Xtensions)

-(void)resizeTo:(CGSize) theSize
{
    CGFloat newWidth = theSize.width;
    CGFloat newHeight = theSize.height;
    
    
    float startWidth = self.contentSize.width;
    float startHeight = self.contentSize.height;
    
    float newScaleX = newWidth/startWidth;
    float newScaleY = newHeight/startHeight;
    
    self.scaleX = newScaleX;
    self.scaleY = newScaleY;
    
}

@end