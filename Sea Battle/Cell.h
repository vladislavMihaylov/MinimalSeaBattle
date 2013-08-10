//
//  Cell.h
//  SeaBattleIphone
//
//  Created by Vlad on 10.07.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Cell: CCNode
{
    int i;
    int j;
    
    int value;
    
    CCSprite    *cellBg;
    CGSize      spriteSize;
    
    CCLabelTTF *numm;
}

@property (nonatomic, assign) int i;
@property (nonatomic, assign) int j;
@property (nonatomic, assign) int value;

@property (nonatomic, retain) CCLabelTTF *numm;
@property (nonatomic, retain) CCSprite    *cellBg;

+ (Cell *) createWithPositionI: (int) _i andJ: (int) _j value: (int) num;

- (BOOL) isTapped: (CGPoint) location direction: (BOOL) isHorizontal num: (int) num;
- (void) toHidden;
- (void) toShow;
- (void) changeBg: (int) newParam;

@end
