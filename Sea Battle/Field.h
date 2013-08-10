//
//  Field.h
//  Sea Battle
//
//  Created by Vlad on 13.07.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Ship;

@interface Field: CCNode
{
    NSMutableArray *cellsArray;
}

+ (Field *) create;

- (void) update;
- (void) random;
- (void) doBusyCell_i: (int) i and_j: (int) j;
- (void) doFreeCell_i: (int) i and_j: (int) j;
- (void) doDeadCell_i: (int) i and_j: (int) j;
- (void) rotateValuesForShip: (Ship *) ship;
- (void) checkToCoords_i: (int) i and_j: (int) j value: (int) value;
- (void) markEmpty_i: (int) i and_j: (int) j;

- (BOOL) isFullField;
- (BOOL) isFreeZone: (CGPoint) posOne andPosTwo: (CGPoint) posTwo;
- (BOOL) isFreeCell_i: (int) i j: (int) j;
- (BOOL) canShotToCell: (int) i and_j: (int) j;

- (NSString *) shotToCoords_i: (int) i and_j: (int) j;

@end
