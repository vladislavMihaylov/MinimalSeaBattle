//
//  Field.m
//  Sea Battle
//
//  Created by Vlad on 13.07.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Field.h"

#import "GameConfig.h"
#import "Cell.h"
#import "Ship.h"

const int sizeOfField = kSizeOfField;

@implementation Field

- (void) dealloc
{
    [cellsArray release];
    [super dealloc];
}

- (id) init
{
    if(self = [super init])
    {
        
        cellsArray = [[NSMutableArray alloc] init];
        
        int array[sizeOfField][sizeOfField];
        
        for (int j = 0; j < sizeOfField; j++)
        {
            for(int i = 0; i < sizeOfField; i++)
            {
                array[i][j] = 0;
                
                Cell *cell = [Cell createWithPositionI: i andJ: j value: array[i][j]];
                //cell.anchorPoint = ccp(0.5, 0.5);
                cell.position = ccp(kWidthOfCell * i, - kWidthOfCell * j);
                
                
                [self addChild: cell];
                
                [cellsArray addObject: cell];
            }
        }
    }
    
    return self;
}

- (void) markEmpty_i: (int) i and_j: (int) j
{
    for(Cell *curCell in cellsArray)
    {
        if(curCell.i == i && curCell.j == j && curCell.value == 0)
        {
            curCell.value = 3;
            [curCell changeBg: 3];
        }
    }
}

+ (Field *) create
{
    Field *field = [[[Field alloc] init] autorelease];
    
    return field;
}

- (void) update
{
    for(Cell *curCell in cellsArray)
    {
        //curCell.numm.string = [NSString stringWithFormat: @"%i", curCell.value];
        //curCell.cellBg.opacity = 100;
    }
}

- (void) random
{
    
}

- (void) changeValuesOnOldCell_i: (int) i j: (int) j andNewCell_i: (int) new_i new_j: (int) new_j
{
    for(Cell *curCell in cellsArray)
    {
        if(curCell.i == i && curCell.j == j)
        {
            curCell.value = 0;
        }
        if(curCell.i == new_i && curCell.j == new_j)
        {
            curCell.value = 1;
        }
    }
}

- (void) rotateValuesForShip: (Ship *) ship
{
    int i, j, new_i, new_j;
    
    if(ship.isHorizontal)
    {
        for(int k = 0; k < ship.cells; k++)
        {
            i = (ship.position.x - kYourFieldPosX + (kWidthOfCell / 2) + kWidthOfCell * k) / kWidthOfCell;
            j = (kYourFieldPosY - ship.position.y + (kWidthOfCell / 2)) / kWidthOfCell;
            
            new_i = (ship.position.x - kYourFieldPosX + (kWidthOfCell / 2)) / kWidthOfCell;
            new_j = (kYourFieldPosY - ship.position.y + (kWidthOfCell / 2) - kWidthOfCell * k) / kWidthOfCell;
            
            [self changeValuesOnOldCell_i: i j: j andNewCell_i: new_i new_j: new_j];
        }
    }
    else
    {
        for(int k = 0; k < ship.cells; k++)
        {
            i = (ship.position.x - kYourFieldPosX + (kWidthOfCell / 2)) / kWidthOfCell;
            j = (kYourFieldPosY - ship.position.y + (kWidthOfCell / 2) - kWidthOfCell * k) / kWidthOfCell;
            
            new_i = (ship.position.x - kYourFieldPosX + (kWidthOfCell / 2) + kWidthOfCell * k) / kWidthOfCell;
            new_j = (kYourFieldPosY - ship.position.y + (kWidthOfCell / 2)) / kWidthOfCell;
            
            [self changeValuesOnOldCell_i: i j: j andNewCell_i: new_i new_j: new_j];
        }
    }
}

- (NSString *) shotToCoords_i: (int) i and_j: (int) j
{
    BOOL isHit = NO;
    
    int newValue = 0;
    
    for(Cell *curCell in cellsArray)
    {
        if(curCell.i == i && curCell.j == j && curCell.value == 1)
        {
            newValue = 2;
            
            curCell.value = newValue;
            
            [curCell changeBg: newValue];
            
            isHit = YES;
        }
        if(curCell.i == i && curCell.j == j && curCell.value == 0)
        {
            newValue = 3;
            
            curCell.value = newValue;
            
            [curCell changeBg: newValue];
        }
    }
    
    NSString *str = @"";
    
    if(newValue != 0)
    {
        str = [NSString stringWithFormat: @"%i,%i", isHit, newValue];
    }
    
    return str;
}

- (BOOL) canShotToCell: (int) i and_j: (int) j
{
    BOOL isCanShot = YES;
    
    for(Cell *curCell in cellsArray)
    {
        if(curCell.i == i && curCell.j == j)
        {
            if(curCell.value == 2 || curCell.value == 3)
            {
                isCanShot = NO;
            }
        }
    }
    
    return isCanShot;
}

- (void) checkToCoords_i: (int) i and_j: (int) j value: (int) value
{
    for(Cell *curCell in cellsArray)
    {
        if(curCell.i == i && curCell.j == j)
        {
            curCell.value = value;
            
            [curCell changeBg: value];
        }
    }
}

- (BOOL) isFullField
{
    BOOL isFull = NO;
    
    int count = 0;
    
    for(Cell *curCell in cellsArray)
    {
        if(curCell.value == 1)
        {
            count++;
        }
    }
    
    if(count == kCountOfCells)
    {
        isFull = YES;
    }
    
    return isFull;
}

- (BOOL) isFreeZone: (CGPoint) posOne andPosTwo: (CGPoint) posTwo
{
    BOOL isFreeZone = YES;
    
    for(Cell *curCell in cellsArray)
    {
        for(int i = posOne.x; i <= posTwo.x; i++)
        {
            for(int j = posOne.y; j <= posTwo.y; j++)
            {
                if (curCell.i == i && curCell.j == j)
                {
                    if(curCell.value == 1)
                    {
                        isFreeZone = NO;
                    }
                }
            }
        }
    }
    
    return isFreeZone;
}

- (BOOL) isFreeCell_i: (int) i j: (int) j
{
    BOOL isFreeCell = NO;
    
    for(Cell *curCell in cellsArray)
    {
        if (curCell.i == i && curCell.j == j)
        {
            if(curCell.value == 1 || curCell.value == 0)
            {
                isFreeCell = YES;
            }
        }
        
    }
    
    return isFreeCell;
}

- (void) doBusyCell_i: (int) i and_j: (int) j
{
    for(Cell *curCell in cellsArray)
    {
        if(curCell.i == i && curCell.j == j)
        {
            curCell.value = 1;
        }
    }
}

- (void) doFreeCell_i: (int) i and_j: (int) j
{
    for(Cell *curCell in cellsArray)
    {
        if(curCell.i == i && curCell.j == j)
        {
            curCell.value = 0;
        }
    }
}

- (void) doDeadCell_i: (int) i and_j: (int) j
{
    for(Cell *curCell in cellsArray)
    {
        if(curCell.i == i && curCell.j == j)
        {
            curCell.value = 2;
        }
    }
}


@end
