//
//  Cell.m
//  SeaBattleIphone
//
//  Created by Vlad on 10.07.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Cell.h"
#import "GameConfig.h"

@implementation Cell

@synthesize i;
@synthesize j;
@synthesize value;

@synthesize numm;
@synthesize cellBg;

- (void) dealloc
{
    [super dealloc];
}

- (id) initWithPositionI: (int) _i andJ: (int) _j value: (int) num
{
    if(self = [super init])
    {
        cellBg =    [CCSprite spriteWithFile: [NSString stringWithFormat: @"cell_%i.png", num]];

        i = _i;
        j = _j;
        value = num;
        
        [self addChild: cellBg];
        
        numm = [CCLabelTTF labelWithString: [NSString stringWithFormat: @"%i", value] fontName: @"Arial" fontSize: 16];
        numm.position = cellBg.position;
        numm.color = ccc3(0, 0, 0);
        //[self addChild: numm];
        
        spriteSize = [cellBg contentSize];
        self.contentSize = spriteSize;
    }
    
    return  self;
}

+ (Cell *) createWithPositionI: (int) _i andJ: (int) _j value: (int) num
{
    Cell *cell = [[[Cell alloc] initWithPositionI: _i andJ: _j value: num] autorelease];
    
    return cell;
}

- (void) changeBg: (int) newParam
{
    [self removeChild: cellBg cleanup: YES];
    
    cellBg = [CCSprite spriteWithFile: [NSString stringWithFormat: @"cell_%i.png", newParam]];
    [self addChild: cellBg];
}

- (BOOL) isTapped: (CGPoint) location direction: (BOOL) isHorizontal num: (int) num
{
    CGPoint newPos = [self convertToWorldSpace: self.position];
    
    float Ax = spriteSize.width / 2;
    float Ay = spriteSize.height / 2;
    
    float Tx, Ty;
    
    if(isHorizontal)
    {
        Tx = fabs(newPos.x - location.x - kWidthOfCell * num); 
        Ty = fabsf(newPos.y - location.y);
    }
    else
    {
        Tx = fabs(newPos.x - location.x);
        Ty = fabsf(newPos.y - location.y - kWidthOfCell * num);
    }
    
    BOOL isTapped = Tx <= Ax && Ty <= Ay;
    
    return isTapped;
}

- (void) toHidden
{
    cellBg.opacity = 100;
}

- (void) toShow
{
    cellBg.opacity = 200;
}

@end
