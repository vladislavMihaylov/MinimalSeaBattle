//
//  HelloWorldLayer.h
//  Sea Battle
//
//  Created by Vlad on 10.07.13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

#import "GuiLayer.h"

@class Field;
@class Ship;

@interface GameLayer: CCLayer
{
    // BlueTooth
    
    GKSession *currentSession;
    
    // Fields
    
    Field *yourField;
    Field *anotherField;
    
    // Arrays
    
    NSMutableArray *shipsArray;
    NSMutableArray *removedShipsArray;
    
    NSMutableArray *enemyShipsArray;
    NSMutableArray *removedEnemyShipsArray;
    
    // Others
    
    GuiLayer *gui;
    
    int deadedShips;
    
    CCSprite *back;
    
    // For AI

    BOOL isNeedToContinue;
    BOOL isHaveDirection;
    BOOL isSuccessAttack;
    BOOL isKilled;
    BOOL isFirstHit;
    BOOL isLock;
    
    NSString *direction;
    
    CGPoint lastcell;
    CGPoint firstCell;
}

@property (nonatomic, retain) GuiLayer *guiLayer;
@property (nonatomic, retain) GKSession *currentSession;

+(CCScene *) scene;

- (void) placeYourShipsRandom;
- (void) showAllShips;

- (void) restart;

- (void) connect;
- (void) disconnect;

- (void) rotateShip;
- (void) showAnotherField;

@end
