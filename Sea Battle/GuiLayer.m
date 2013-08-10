//
//  GuiLayer.m
//  Sea Battle
//
//  Created by Vlad on 13.07.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GuiLayer.h"

#import "GameConfig.h"
#import "GameLayer.h"
#import "IntroLayer.h"

@implementation GuiLayer

@synthesize gameLayer;

- (void) dealloc
{
    [super dealloc];
}

- (void) initButtons
{
    connectBtn =    [CCMenuItemImage itemWithNormalImage: @"linkBtn.png"
                                           selectedImage: @"linkBtnTap.png"
                                                  target: self
                                                selector: @selector(bluetoothConnect)];
    
    disconnectBtn = [CCMenuItemImage itemWithNormalImage: @"linkBtn.png"
                                           selectedImage: @"linkBtnTap.png"
                                                  target: self
                                                selector: @selector(bluetoothDisconnect)];
    
    rotateBtn =     [CCMenuItemImage itemWithNormalImage: @"btn.png"
                                           selectedImage: @"btnOn.png"
                                                  target: self
                                                selector: @selector(rotateShip)];
    
    randomBtn =     [CCMenuItemImage itemWithNormalImage: @"btn.png"
                                           selectedImage: @"btnOn.png"
                                                  target: self
                                                selector: @selector(random)];
    
    readyBtn =      [CCMenuItemImage itemWithNormalImage: @"btn.png"
                                           selectedImage: @"btnOn.png"
                                                  target: self
                                                selector: @selector(toGiveReadySignal)];
    
    pauseBtn =      [CCMenuItemImage itemWithNormalImage: @"pauseBtn.png"
                                           selectedImage: @"pauseBtnTap.png"
                                                  target: self
                                                selector: @selector(pauseGame)];
    
    exitButton =    [CCMenuItemImage itemWithNormalImage: @"backBtn.png"
                                           selectedImage: @"backBtnTap.png"
                                                  target: self
                                                selector: @selector(goToMainMenu)];
    
    connectBtn.position =       ccp(0.074 * kGameWidth,  0.93 * kGameHeight);
    disconnectBtn.position =    ccp(0.930 * kGameWidth,  0.93 * kGameHeight);
    rotateBtn.position =        ccp(0.600 * kGameWidth, -160);
    randomBtn.position =        ccp(0.735 * kGameWidth, -160);
    readyBtn.position =         ccp(0.870 * kGameWidth, -160);
    pauseBtn.position =         ccp(GameCenterX, -pauseBtn.contentSize.height/2);
    
    exitButton.position = ccp(30, GameCenterY + 35);
    exitButton.opacity = 150;
    
    CCLabelTTF *rotateLabel = [CCLabelTTF labelWithString: @"Rotate" fontName: @"Arial" fontSize: 22];
    rotateLabel.position = ccp(rotateBtn.contentSize.width / 2, rotateBtn.contentSize.height * 0.5);
    [rotateBtn addChild: rotateLabel];
    
    CCLabelTTF *randomLabel = [CCLabelTTF labelWithString: @"Random" fontName: @"Arial" fontSize: 22];
    randomLabel.position = ccp(rotateBtn.contentSize.width / 2, rotateBtn.contentSize.height * 0.5);
    [randomBtn addChild: randomLabel];
    
    CCLabelTTF *readyLabel = [CCLabelTTF labelWithString: @"Play" fontName: @"Arial" fontSize: 22];
    readyLabel.position = ccp(rotateBtn.contentSize.width / 2, rotateBtn.contentSize.height * 0.5);
    [readyBtn addChild: readyLabel];
    
    disconnectBtn.isEnabled =   NO;
    readyBtn.isEnabled =        NO;
    
    CCMenu *buttonsMenu;
    
    if(GameMode == kSingleMode)
    {
        buttonsMenu = [CCMenu menuWithItems: rotateBtn, readyBtn, pauseBtn, randomBtn, exitButton, nil];
    }
    else
    {
        buttonsMenu = [CCMenu menuWithItems: connectBtn, disconnectBtn, rotateBtn, readyBtn, pauseBtn, randomBtn, exitButton, nil];
    }
    buttonsMenu.position = ccp(0, 0);
    [self addChild: buttonsMenu];
    
    CCLabelTTF *connectLabel = [CCLabelTTF labelWithString: @"Connect" fontName: @"Arial" fontSize: 18];
    connectLabel.position = ccp(connectBtn.contentSize.width/2, connectBtn.contentSize.height/2);
    
    CCLabelTTF *disconnectLabel = [CCLabelTTF labelWithString: @"Disconnect" fontName: @"Arial" fontSize: 18];
    disconnectLabel.position = ccp(disconnectBtn.contentSize.width / 2,  disconnectBtn.contentSize.height / 2);
    
    [connectBtn addChild: connectLabel];
    [disconnectBtn addChild: disconnectLabel];
}

- (void) random
{
    [gameLayer placeYourShipsRandom];
}

- (id) init
{
    if(self = [super init])
    {
        statusLabel =   [CCLabelTTF labelWithString: @"Подключение..." fontName: @"Arial" fontSize: 18];
        
        tvBox =         [CCSprite spriteWithFile: @"upBox.png"];
        yourArrow =     [CCSprite spriteWithFile: @"arrow.png"];
        enemyArrow =    [CCSprite spriteWithFile: @"arrow.png"];
        
        statusLabel.position =  ccp(GameCenterX, kGameHeight - 60);
        tvBox.position =        ccp(GameCenterX, kGameHeight - tvBox.contentSize.height / 1.8);
        yourArrow.position =    ccp(0.271 * kGameWidth, 0.859 * kGameHeight);
        enemyArrow.position =   ccp(0.759 * kGameWidth, 0.859 * kGameHeight);
        
        yourArrow.anchorPoint =     ccp(0.5, -0.1);
        enemyArrow.anchorPoint =    ccp(0.5, -0.1);
        
        yourArrow.visible = NO;
        enemyArrow.visible = NO;
        
        [self addChild: tvBox];
        [self addChild: statusLabel];
        [self initButtons];
        [self addChild: yourArrow];
        [self addChild: enemyArrow];
        
        [self rotateYourArrow: 90 andAnotherArrow: 90];
        [self disableReadyBtn];
        [self doConnectBtnUnvisible];
        
        if(GameMode == kSingleMode)
        {
            [self showGuiButtons];
            [self changeStatusLabel: @"Расставляйте\nкорабли!"];
        }
    }
    
    return self;
}

- (void) pauseGame
{
    [pauseBtn runAction: [CCMoveTo actionWithDuration: 0.5 position: ccp(GameCenterX, -pauseBtn.contentSize.height * 0.5)]];
    
    pauseBtn.isEnabled = NO;
    gameLayer.isTouchEnabled = NO;
    
    pauseLayer = [CCLayerColor layerWithColor: ccc4(0, 0, 0, 128)];
    [self addChild: pauseLayer];
    
    CCSprite *pauseBg = [CCSprite spriteWithFile: @"pauseBg.png"];
    pauseBg.position = ccp(GameCenterX, -pauseBg.contentSize.height / 2);
    [pauseLayer addChild: pauseBg];
    
    CCMenuItemImage *exitBtn = [CCMenuItemImage itemWithNormalImage: @"exitBtn.png"
                                                      selectedImage: @"exitBtnTap.png"
                                                             target: self
                                                           selector: @selector(goToMainMenu)];
    
    CCMenuItemImage *replayBtn = [CCMenuItemImage itemWithNormalImage: @"replayBtn.png"
                                                        selectedImage: @"replayBtnTap.png"
                                                               target: self
                                                             selector: @selector(restart)];
    
    CCMenuItemImage *continueBtn = [CCMenuItemImage itemWithNormalImage: @"playBtn.png"
                                                          selectedImage: @"playBtnTap.png"
                                    target: self selector: @selector(resumeGame)];
    
    exitBtn.position =      ccp(pauseBg.contentSize.width * 0.25, pauseBg.contentSize.height/2);
    replayBtn.position =    ccp(pauseBg.contentSize.width/2, pauseBg.contentSize.height/2);
    continueBtn.position =  ccp(pauseBg.contentSize.width * 0.75, pauseBg.contentSize.height/2);
    
    CCMenu *pauseMenu = [CCMenu menuWithItems: exitBtn, replayBtn, continueBtn, nil];
    pauseMenu.position = ccp(0, 0);
    [pauseBg addChild: pauseMenu];
    
    [pauseBg runAction: [CCMoveTo actionWithDuration: 0.3 position: ccp(GameCenterX, pauseBg.contentSize.height * 0.4)]];
}

- (void) stopGame: (NSString *) winner
{
    [pauseBtn runAction: [CCMoveTo actionWithDuration: 0.5 position: ccp(GameCenterX, -pauseBtn.contentSize.height * 0.5)]];
    
    pauseBtn.isEnabled = NO;
    gameLayer.isTouchEnabled = NO;
    
    [gameLayer showAllShips];
    
    pauseLayer = [CCLayerColor layerWithColor: ccc4(0, 0, 0, 128)];
    [self addChild: pauseLayer];
    
    CCSprite *pauseBg = [CCSprite spriteWithFile: @"pauseBg.png"];
    pauseBg.position = ccp(GameCenterX, -pauseBg.contentSize.height / 2);
    [pauseLayer addChild: pauseBg];
    
    CCLabelTTF *finalLabel = [CCLabelTTF labelWithString: [NSString stringWithFormat: @"%@ won!", winner] fontName: @"Arial" fontSize: 24];
    finalLabel.position = ccp(pauseBg.contentSize.width * 0.5, pauseBg.contentSize.height * 0.7);
    [pauseBg addChild: finalLabel];
    
    CCMenuItemImage *exitBtn = [CCMenuItemImage itemWithNormalImage: @"exitBtn.png"
                                                      selectedImage: @"exitBtnTap.png"
                                                             target: self
                                                           selector: @selector(goToMainMenu)];
    
    CCMenuItemImage *replayBtn = [CCMenuItemImage itemWithNormalImage: @"replayBtn.png"
                                                        selectedImage: @"replayBtnTap.png"
                                                               target: self
                                                             selector: @selector(restart)];
    
    exitBtn.position =      ccp(pauseBg.contentSize.width * 0.25, pauseBg.contentSize.height/2);
    replayBtn.position =    ccp(pauseBg.contentSize.width * 0.75, pauseBg.contentSize.height/2);
    
    CCMenu *pauseMenu = [CCMenu menuWithItems: exitBtn, replayBtn, nil];
    pauseMenu.position = ccp(0, 0);
    [pauseBg addChild: pauseMenu];
    
    [pauseBg runAction: [CCMoveTo actionWithDuration: 0.3 position: ccp(GameCenterX, pauseBg.contentSize.height * 0.4)]];
}

- (void) restart
{
    exitButton.visible = YES;
    exitButton.isEnabled = YES;
    
    isGuiEnable = NO;
    
    pauseBtn.isEnabled = YES;
    gameLayer.isTouchEnabled = YES;
    
    [self removeChild: pauseLayer cleanup: YES];
    
    [gameLayer restart];
    
    rotateBtn.isEnabled = YES;
    randomBtn.isEnabled = YES;
}

- (void) resumeGame
{
    [pauseBtn runAction: [CCMoveTo actionWithDuration: 0.5 position: ccp(GameCenterX, pauseBtn.contentSize.height * 0.8)]];
    
    pauseBtn.isEnabled = YES;
    gameLayer.isTouchEnabled = YES;
    
    [self removeChild: pauseLayer cleanup: YES];
}

- (void) goToMainMenu
{
    if(GameMode == kBluetoothMode)
    {
        [gameLayer disconnect];
        
        isBluetoothConnected = NO;
        youIsFirst = YES;
    }
    
    isGuiEnable = NO;
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration: 1.0 scene: [IntroLayer scene]]];
}

- (void) changeStatusLabel: (NSString *) newString
{
    statusLabel.string = newString;
}

- (void) rotateYourArrow: (int) degrees andAnotherArrow: (int) degreesAnother
{
    [yourArrow runAction:   [CCRotateTo actionWithDuration: 0.5 angle: degrees]];
    [enemyArrow runAction:  [CCRotateTo actionWithDuration: 0.5 angle: degreesAnother]];
}

- (void) showGuiButtons
{
    if(!isGuiEnable)
    {
        isGuiEnable = YES;
        
        [rotateBtn runAction:   [CCMoveTo actionWithDuration: 0.5 position: ccp(rotateBtn.position.x, 85)]];
        
        [randomBtn runAction:   [CCMoveTo actionWithDuration: 0.5 position: ccp(randomBtn.position.x, 85)]];
    }
}

- (void) enableReadyBtn
{
    readyBtn.isEnabled =    YES;
   [readyBtn runAction:   [CCMoveTo actionWithDuration: 0.5 position: ccp(readyBtn.position.x, 85)]];
}

- (void) disableReadyBtn
{
    readyBtn.isEnabled =    NO;
    [readyBtn runAction:   [CCMoveTo actionWithDuration: 0.5 position: ccp(readyBtn.position.x, -160)]];
}

- (void) toGiveReadySignal
{
    exitButton.visible = NO;
    exitButton.isEnabled = NO;
    
    [pauseBtn runAction: [CCMoveTo actionWithDuration: 0.5 position: ccp(GameCenterX, pauseBtn.contentSize.height * 0.8)]];
    
    rotateBtn.isEnabled =   NO;
    randomBtn.isEnabled =   NO;
    
    [rotateBtn runAction:   [CCMoveTo actionWithDuration: 0.5 position: ccp(rotateBtn.position.x, -160)]];
    [randomBtn runAction:   [CCMoveTo actionWithDuration: 0.5 position: ccp(randomBtn.position.x, -160)]];
    
    [gameLayer showAnotherField];
}

- (void) rotateShip
{
    [gameLayer rotateShip];
}

- (void) doConnectBtnUnvisible
{
    disconnectBtn.isEnabled =   YES;
    [disconnectBtn runAction:   [CCMoveTo actionWithDuration: 0.5 position: ccp(kGameWidth - disconnectBtn.contentSize.width * 0.4, disconnectBtn.position.y)]];
    
    connectBtn.isEnabled =      NO;
    [connectBtn runAction:      [CCMoveTo actionWithDuration: 0.5 position: ccp(-0.2 * kGameWidth, connectBtn.position.y)]];
}

- (void) doDisconnectBtnUnvisible
{
    disconnectBtn.isEnabled =   NO;
    [disconnectBtn runAction:   [CCMoveTo actionWithDuration: 0.5 position: ccp( 1.2 * kGameWidth, disconnectBtn.position.y)]];
    
    connectBtn.isEnabled =      YES;
    [connectBtn runAction:      [CCMoveTo actionWithDuration: 0.5 position: ccp(connectBtn.contentSize.width * 0.4, connectBtn.position.y)]];
}

- (void) bluetoothConnect
{
    [gameLayer connect];
}

- (void) bluetoothDisconnect
{
    [gameLayer disconnect];
}

@end
