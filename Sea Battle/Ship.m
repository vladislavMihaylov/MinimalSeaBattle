//
//  Ship.m
//  Sea Battle
//
//  Created by Vlad on 10.07.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Ship.h"
#import "Cell.h"

@implementation Ship

@synthesize cells;
@synthesize isHorizontal;
@synthesize isTapped;
@synthesize isDead;
@synthesize isSetted;
@synthesize oldPosition;

- (void) dealloc
{
    [cellsArray release];
    [super dealloc];
}

- (id) initWithSize: (int) countOfCells
{
    if(self = [super init])
    {
        cellsArray = [[NSMutableArray alloc] init];
        cells = countOfCells;
        isHorizontal = NO;
        isDead = NO;
        
        for(int i = 0; i < countOfCells; i++)
        {
            Cell *cell = [Cell createWithPositionI: 0 andJ: i value: 1];
            cell.position = ccp(0, 40 * i);
            [self addChild: cell];
            [cellsArray addObject: cell];
        }
        
        
    }
    
    return self;
}

+ (Ship *) createWithSize: (int) countOfCells
{
    Ship *ship = [[[Ship alloc] initWithSize: countOfCells] autorelease];
    
    return ship;
}

- (BOOL) isTapped: (CGPoint) location
{
    isTapped = NO;
    
    int count = 0;
    
    for(Cell *curCell in cellsArray)
    {
        if(!isTapped)
        {
            isTapped = [curCell isTapped: location direction: isHorizontal num: count];
        }
        
        count++;
    }
    
    for(Cell *curCell in cellsArray)
    {
        if(isTapped)
        {
            [curCell toHidden];
        }
        else
        {
            [curCell toShow];
        }
    }
    
    return isTapped;
}

- (void) rotate
{
    if(isHorizontal)
    {
        isHorizontal = NO;
        
        int count = 0;
        
        for(Cell *curCell in cellsArray)
        {
            curCell.position = ccp(curCell.position.y, curCell.position.y + 40 * count);
            
            count++;
        }
    }
    else
    {
        isHorizontal = YES;
        
        int count = 0;
        
        for(Cell *curCell in cellsArray)
        {
            curCell.position = ccp(curCell.position.x + 40 * count, curCell.position.x);
            
            //CCLOG(@"NewPosX: %f newPosY: %f", curCell.position.x, curCell.position.y);
            
            count++;
        }
    }
}

- (void) markCellWithNumber: (int) k set_i: (int) i set_j: (int) j //andSetValue: (int) value
{
    /*int count = 0;
    
    for(Cell *curCell in cellsArray)
    {
        if(count == k)
        {
            curCell.i = i;
            curCell.j = j;
            //curCell.value = value;
        }
        
        count++;
    }*/
    
    Cell *newCell = [cellsArray objectAtIndex: k];
    
    newCell.i = i;
    newCell.j = j;
    
}

- (BOOL) shotToCell_i: (int) i and_j: (int) j
{
    BOOL isDead1 = YES;
    
    for(Cell *curCell in cellsArray)
    {
        if(curCell.i == i && curCell.j == j)
        {
            curCell.value = 2;
            [curCell changeBg: 2];
        }
        
        if(curCell.value != 2)
        {
            isDead1 = NO;
        }
    }
    
    return isDead1;
}

- (BOOL) isMyCell_i: (int) i and_j: (int) j
{
    BOOL isMy = NO;
    
    for(Cell *curCell in cellsArray)
    {
        if(curCell.i == i && curCell.j == j)
        {
            isMy = YES;
        }
    }
    
    return isMy;
}

- (void) enableFullOpacity
{
    for(Cell *curCell in cellsArray)
    {
        [curCell toShow];
    }
}

@end
