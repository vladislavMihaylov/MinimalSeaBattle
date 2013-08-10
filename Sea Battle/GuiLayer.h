//
//  GuiLayer.h
//  Sea Battle
//
//  Created by Vlad on 13.07.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class GameLayer;

@interface GuiLayer: CCNode
{
    // Buttons
    
    CCMenuItemImage *connectBtn;
    CCMenuItemImage *disconnectBtn;
    
    CCMenuItemImage *readyBtn;
    CCMenuItemImage *rotateBtn;
    CCMenuItemImage *randomBtn;
    
    CCMenuItemImage *pauseBtn;
    
    CCMenuItemImage *exitButton;
    
    // Other
    
    CCSprite *yourArrow;
    CCSprite *enemyArrow;
    
    CCSprite *tvBox;
    
    CCLabelTTF *statusLabel;
    
    CCLayerColor *pauseLayer;
    
    GameLayer *gameLayer;
}

@property (nonatomic, retain) GameLayer *gameLayer;

- (void) pauseGame;
- (void) stopGame: (NSString *) winner;

- (void) doConnectBtnUnvisible;
- (void) doDisconnectBtnUnvisible;

- (void) enableReadyBtn;
- (void) disableReadyBtn;

- (void) showGuiButtons;
- (void) rotateYourArrow: (int) degrees andAnotherArrow: (int) degreesAnother;

- (void) changeStatusLabel: (NSString *) newString;

@end
