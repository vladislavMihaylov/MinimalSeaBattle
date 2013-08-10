//
//  IntroLayer.m
//  Sea Battle
//
//  Created by Vlad on 10.07.13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "GameLayer.h"
#import "GameConfig.h"

#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) dealloc
{
    [super dealloc];
}

- (id) init
{
    if(self = [super init])
    {
        CCLayerColor *layer = [CCLayerColor layerWithColor: ccc4(239, 235, 231, 255) width: 1024 height: 786];
        layer.position = ccp(0, 0);
        [self addChild: layer];
        
        CCMenuItemImage *singleBtn = [CCMenuItemImage itemWithNormalImage: @"mainMenuBtn.png"
                                                            selectedImage: @"mainMenuBtnTap.png"
                                                                   target: self
                                                                 selector: @selector(goToSingleGame)];
        
        singleBtn.position = ccp(GameCenterX, 0.6 * kGameHeight);
        
        CCMenuItemImage *bluetoothBtn = [CCMenuItemImage itemWithNormalImage: @"mainMenuBtn.png"
                                                               selectedImage: @"mainMenuBtnTap.png"
                                                                      target: self
                                                                    selector: @selector(goToBluetoothGame)];
        
        bluetoothBtn.position = ccp(GameCenterX, 0.45 * kGameHeight);
        
        CCMenu *mainMenu = [CCMenu menuWithItems: singleBtn, bluetoothBtn, nil];
        mainMenu.position = ccp(0, 0);
        [self addChild: mainMenu];
        
        CCLabelTTF *singleLabel = [CCLabelTTF labelWithString: @"Single player" fontName: @"Arial" fontSize: 18];
        singleLabel.position = ccp(singleBtn.contentSize.width / 2, singleBtn.contentSize.height / 2);
        
        CCLabelTTF *bluetoothLabel = [CCLabelTTF labelWithString: @"Bluetooth game" fontName: @"Arial" fontSize: 18];
        bluetoothLabel.position = ccp(bluetoothBtn.contentSize.width / 2, bluetoothBtn.contentSize.height / 2);
        
        [singleBtn addChild: singleLabel];
        [bluetoothBtn addChild: bluetoothLabel];
    }
    
    return self;
}

- (void) goToBluetoothGame
{
    GameMode = kBluetoothMode;
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 1 scene: [GameLayer scene]]];
}

- (void) goToSingleGame
{
    GameMode = kSingleMode;
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 1 scene: [GameLayer scene]]];
}

//
 @end
