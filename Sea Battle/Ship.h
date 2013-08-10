//
//  Ship.h
//  Sea Battle
//
//  Created by Vlad on 10.07.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Ship: CCNode
{
    int cells;
    BOOL isHorizontal;
    BOOL isTapped;
    BOOL isDead;
    BOOL isSetted;
    
    CGPoint oldPosition;
    
    NSMutableArray *cellsArray;
}

@property (nonatomic, assign) int cells;
@property (nonatomic, assign) BOOL isHorizontal;
@property (nonatomic, assign) BOOL isTapped;
@property (nonatomic, assign) BOOL isDead;
@property (nonatomic, assign) BOOL isSetted;

@property (nonatomic, assign) CGPoint oldPosition;


+ (Ship *) createWithSize: (int) countOfCells;

- (void) rotate;
- (BOOL) isTapped: (CGPoint) location;

- (void) enableFullOpacity;

- (void) markCellWithNumber: (int) k set_i: (int) i set_j: (int) j;//andSetValue: (int) value;

- (BOOL) shotToCell_i: (int) i and_j: (int) j;

- (BOOL) isMyCell_i: (int) i and_j: (int) j;


@end
