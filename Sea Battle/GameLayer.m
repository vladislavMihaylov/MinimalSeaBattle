//
//  HelloWorldLayer.m
//  Sea Battle
//
//  Created by Vlad on 10.07.13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"

#import "Cell.h"
#import "Field.h"
#import "GameConfig.h"
#import "Ship.h"

#import "IntroLayer.h"

#import "SimpleAudioEngine.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"



@implementation GameLayer

@synthesize guiLayer;
@synthesize currentSession;

#pragma mark -
#pragma mark Bluetooth methods

GKPeerPickerController *picker;

- (void) peerPickerController: (GKPeerPickerController *) picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    self.currentSession = session;
    session.delegate = self;
    [session setDataReceiveHandler: self withContext: nil];
    picker.delegate = nil;
    
    [picker dismiss];
    [picker autorelease];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    picker.delegate = nil;
    [picker autorelease];
    
    [guiLayer doDisconnectBtnUnvisible];
}

- (void)session: (GKSession *) session peer: (NSString *) peerID didChangeState: (GKPeerConnectionState) state
{
    switch (state)
    {
        case GKPeerStateConnected:
            NSLog(@"connected");
            isBluetoothConnected = YES;
            [self startGame: kBluetoothMode];
            
            break;
        case GKPeerStateDisconnected:
            NSLog(@"disconnected");
            isBluetoothConnected = NO;
            [self.currentSession release];
            currentSession = nil;
            
            [guiLayer doDisconnectBtnUnvisible];
            
            break;
    }
}

- (void) mySendDataToPeers:(NSData *) data
{
    if (currentSession)
        [self.currentSession sendDataToAllPeers:data
                                   withDataMode:GKSendDataReliable
                                          error:nil];
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    //---convert the NSData to NSString---
    NSString* str;
    str = [[NSString alloc] initWithData: data encoding:NSASCIIStringEncoding];
    
    //label.string = str;
    
    NSArray *array = [str componentsSeparatedByString: @","];
    int type = [[array objectAtIndex: 0] intValue];
    
    if(type == kBTconnectionType)
    {
        int signal = [[array objectAtIndex: 1] intValue];
        
        [self confirmReadinessWithSignal: signal];
    }
    if(type == kAttackType)
    {
        int tap_x = [[array objectAtIndex: 1] intValue];
        int tap_y = [[array objectAtIndex: 2] intValue];
        
        
        
        if([self isTapOnAnotherField_i: tap_x and_j: tap_y])
        {
        
            int i = [self getIndexNumberFromPosition: tap_x onAfield: anotherField andIndexParameter: GET_I];
            int j = [self getIndexNumberFromPosition: tap_y onAfield: anotherField andIndexParameter: GET_J];
        
        
            NSString *answer = [yourField shotToCoords_i: i and_j: j];
            
            BOOL isDead;
            
            BOOL globalDead = NO;
            
            BOOL isHor;
            
            int ship_i, ship_j, ship_cells;
            
            for(Ship *curShip in shipsArray)
            {
                isDead = [curShip shotToCell_i: i and_j: j];
                
                if(isDead)
                {
                    globalDead = YES;
                    
                    
                    ship_i = [self getIndexNumberFromPosition: curShip.position.x onAfield: yourField andIndexParameter: GET_I];
                    ship_j = [self getIndexNumberFromPosition: curShip.position.y onAfield: yourField andIndexParameter: GET_J];
                    
                    //ship_i = fabs(curShip.position.x - yourField.position.x + (kWidthOfCell / 2)) / kWidthOfCell;
                    //ship_j = fabs(yourField.position.y - curShip.position.y + (kWidthOfCell / 2)) / kWidthOfCell;
                    
                    ship_cells = curShip.cells;
                    
                    isHor = curShip.isHorizontal;
                    
                    curShip.isDead = YES;
                    
                    [removedShipsArray addObject: curShip];
                    
                    if(curShip.isHorizontal)
                    {
                        int i1,i2,j1,j2;
                        
                        int q = fabs(curShip.position.x - yourField.position.x + (kWidthOfCell / 2)) / kWidthOfCell;
                        int w = fabs(yourField.position.y - curShip.position.y + (kWidthOfCell / 2)) / kWidthOfCell;
                        
                        i1 = [self correctValueOfIndex: q - 1];
                        i2 = [self correctValueOfIndex: q + curShip.cells];
                        
                        j1 = [self correctValueOfIndex: w - 1];
                        j2 = [self correctValueOfIndex: w + 1];
                        
                        for(int i = i1; i <= i2; i++)
                        {
                            for(int j = j1; j <= j2; j++)
                            {
                                [yourField markEmpty_i: i and_j: j];
                            }
                        }

                    }
                    else
                    {
                        int i1,i2,j1,j2;
                        
                        int q = fabs(curShip.position.x - yourField.position.x + (kWidthOfCell / 2)) / kWidthOfCell;
                        int w = fabs(yourField.position.y - curShip.position.y + (kWidthOfCell / 2)) / kWidthOfCell;
                        
                        i1 = [self correctValueOfIndex: q - 1];
                        i2 = [self correctValueOfIndex: q + 1];
                        
                        j1 = [self correctValueOfIndex: w - curShip.cells];
                        j2 = [self correctValueOfIndex: w + 1];
                        
                        for(int i = i1; i <= i2; i++)
                        {
                            for(int j = j1; j <= j2; j++)
                            {
                                [yourField markEmpty_i: i and_j: j];
                            }
                        }

                    }
                }
            }
            
            if(![answer isEqual: @""])
            {
                NSArray *arr = [answer componentsSeparatedByString: @","];
                
                BOOL isHit = [[arr objectAtIndex: 0] boolValue];
                int newValue = [[arr objectAtIndex: 1] intValue];
                
                [self sendAnswerShot_i: i and_j: j value: newValue isHit: isHit isDead: globalDead ship_i: ship_i ship_j: ship_j ship_cells: ship_cells isHor: isHor];
                
                if(!isHit)
                {
                    youIsFirst = !youIsFirst;
                    
                    [[SimpleAudioEngine sharedEngine] playEffect: @"lose.wav"];
                }
                else
                {
                    [[SimpleAudioEngine sharedEngine] playEffect: @"hit.wav"];
                }
            }
            
            BOOL youIsLose = YES;
            
            for(Ship *curShip in shipsArray)
            {
                if(!curShip.isDead)
                {
                    youIsLose = NO;
                }
            }
            
            if(youIsLose)
            {
                //[[CCDirector sharedDirector] replaceScene: [IntroLayer scene]];
                [guiLayer stopGame: @"Enemy"];
            }
            
            for(Ship *curShip in removedShipsArray)
            {
                [shipsArray removeObject: curShip];
            }
        }
    }
    if(type == kAnswerType)
    {
        int i = [[array objectAtIndex: 1] intValue];
        int j = [[array objectAtIndex: 2] intValue];
        int value = [[array objectAtIndex: 3] intValue];
        BOOL isHit = [[array objectAtIndex: 4] boolValue];
        BOOL isDeadly = [[array objectAtIndex: 5] boolValue];
        
        int i_coords = [[array objectAtIndex: 6] intValue];
        int j_coords = [[array objectAtIndex: 7] intValue];
        int s_cells = [[array objectAtIndex: 8] intValue];
        BOOL isH = [[array objectAtIndex: 9] intValue];
        
        
        if(isDeadly)
        {
            
            deadedShips++;
            
            if(isH)
            {
                int i1,i2,j1,j2;
                
                i1 = [self correctValueOfIndex: i_coords - 1];
                i2 = [self correctValueOfIndex: i_coords + s_cells];
                
                j1 = [self correctValueOfIndex: j_coords - 1];
                j2 = [self correctValueOfIndex: j_coords + 1];
                
                for(int i = i1; i <= i2; i++)
                {
                    for(int j = j1; j <= j2; j++)
                    {
                        [anotherField markEmpty_i: i and_j: j];
                    }
                }
                
            }
            else
            {
                int i1,i2,j1,j2;
                
                i1 = [self correctValueOfIndex: i_coords - 1];
                i2 = [self correctValueOfIndex: i_coords + 1];
                
                j1 = [self correctValueOfIndex: j_coords - s_cells];
                j2 = [self correctValueOfIndex: j_coords + 1];
                
                for(int i = i1; i <= i2; i++)
                {
                    for(int j = j1; j <= j2; j++)
                    {
                        [anotherField markEmpty_i: i and_j: j];
                    }
                }
                
            }
        }
        
        if(!isHit)
        {
            youIsFirst = !youIsFirst;
            
            [[SimpleAudioEngine sharedEngine] playEffect: @"lose.wav"];
        }
        else
        {
            [[SimpleAudioEngine sharedEngine] playEffect: @"hit.wav"];
        }
        
        [anotherField checkToCoords_i: i and_j: j value: value];
        
        if(deadedShips == kCountOfShips)
        {
            //[[CCDirector sharedDirector] replaceScene: [IntroLayer scene]];
            [guiLayer stopGame: @"You"];
        }
    }
    
    [guiLayer rotateYourArrow: (([shipsArray count]) * 18 - 90) andAnotherArrow: ((10 - deadedShips) * 18 - 90)];
    
    [self changeStatusLabel];
    
}

- (void) sendDataPosX: (int) posX andPosY: (int) posY type: (int) type
{
    NSString *stringWithCoords = [NSString stringWithFormat: @"%i,%i,%i", type, posX, posY];
    NSData *data = [stringWithCoords dataUsingEncoding: NSASCIIStringEncoding];
    [self mySendDataToPeers: data];
}

- (void) connect
{
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    
    [guiLayer doConnectBtnUnvisible];
    
    [picker show];
}

- (void) disconnect
{
    [self.currentSession disconnectFromAllPeers];
    [self.currentSession release];
    currentSession = nil;
    
    [guiLayer doDisconnectBtnUnvisible];
}

#pragma mark -
#pragma mark Send methods

- (void) sendAnswerShot_i: (int) i and_j: (int) j value: (int) value isHit: (BOOL) isHit isDead: (BOOL) isDead ship_i: (int) s_i ship_j: (int) s_j ship_cells: (int) s_c isHor: (BOOL) isHorizontal
{
    int type = kAnswerType;
    
    NSString *stringWithParameters = [NSString stringWithFormat: @"%i,%i,%i,%i,%i,%i,%i,%i,%i,%i", type, i, j, value, isHit, isDead, s_i, s_j, s_c, isHorizontal];
    
    NSData *data = [stringWithParameters dataUsingEncoding: NSASCIIStringEncoding];
    
    [self mySendDataToPeers: data];
}

- (void) sendReadySignal
{
    int type = kBTconnectionType;
    
    int signal = 1;
    
    NSString *stringWithParameters = [NSString stringWithFormat: @"%i,%i", type, signal];
    
    NSData *data = [stringWithParameters dataUsingEncoding: NSASCIIStringEncoding];
    
    [self mySendDataToPeers: data];
    
    [guiLayer changeStatusLabel: @"Ждите противника!"];
}

- (void) sendAnswerReadySignal
{
    int type = kBTconnectionType;
    
    int signal = 2;
    
    NSString *stringWithParameters = [NSString stringWithFormat: @"%i,%i", type, signal];
    
    NSData *data = [stringWithParameters dataUsingEncoding: NSASCIIStringEncoding];
    
    [self mySendDataToPeers: data];
    
    [guiLayer changeStatusLabel: @"Ждите приказа!"];
}

- (void) confirmReadinessWithSignal: (int) signal
{
    if(signal == 1)
    {
        [guiLayer changeStatusLabel: @"Противник готов!"];
        youIsFirst = NO;
    }
    else
    {
        [guiLayer changeStatusLabel: @"Ждите приказа!"];
    }
}


#pragma mark -
#pragma mark Init's methods

- (void) dealloc
{
    if(GameMode == kSingleMode)
    {
        [enemyShipsArray release];
        [removedEnemyShipsArray release];
    }
    
    [shipsArray release];
    [removedShipsArray release];
	[super dealloc];
}

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
    
	GameLayer *layer = [GameLayer node];
	
	[scene addChild: layer];
    
    GuiLayer *gui = [GuiLayer node];
    [scene addChild: gui];
    
    
    layer.guiLayer = gui;
    gui.gameLayer = layer;
	
	return scene;
}

- (void) restart
{
    youIsFirst = !youIsFirst;
    
    [self removeChild: yourField cleanup: YES];
    [self removeChild: anotherField cleanup: YES];
    
    for(Ship *ship in shipsArray)
    {
        [self removeChild: ship cleanup: YES];
    }
    
    for(Ship *ship in removedShipsArray)
    {
        [self removeChild: ship cleanup: YES];
    }
    
    [shipsArray removeAllObjects];
    [removedShipsArray removeAllObjects];
    
    if(kSingleMode)
    {
        for(Ship *ship in enemyShipsArray)
        {
            [self removeChild: ship cleanup: YES];
        }
        
        for(Ship *ship in removedEnemyShipsArray)
        {
            [self removeChild: ship cleanup: YES];
        }
        
        [enemyShipsArray removeAllObjects];
        [removedEnemyShipsArray removeAllObjects];
    }
    
    [self startGame];
}

- (void) startGame
{
    isCanMoveShips = YES;
    
    [self releaseVariables];
    
    yourField = [Field create];
    yourField.position = ccp(100, 600);
    [self addChild: yourField];
    
    anotherField = [Field create];
    anotherField.position = ccp(564, 600);
    [self addChild: anotherField];
    
    [self createShips: shipsArray];
    
    if(GameMode == kSingleMode)
    {
        enemyShipsArray = [[NSMutableArray alloc] init];
        removedEnemyShipsArray = [[NSMutableArray alloc] init];
        
        [self createShips: enemyShipsArray];
        
        [self placeShipsFrom: enemyShipsArray onAfield: anotherField];
        
        [self startGame: kSingleMode];
        
        for(Ship *curShip in enemyShipsArray)
        {
            curShip.visible = NO;
        }
        
        [guiLayer showGuiButtons];
    }
    else
    {
        if(!isBluetoothConnected)
        {
            [self connect];
        }
        else
        {
            [self startGame: kBluetoothMode];
        }
    }
    
    deadedShips = 0;
}

-(id) init
{
	if( (self=[super init]) )
    {
        CCLayerColor *layer = [CCLayerColor layerWithColor: ccc4(239, 235, 231, 255) width: 1024 height: 786];
        layer.position = ccp(0, 0);
        [self addChild: layer];
        
        [[SimpleAudioEngine sharedEngine] preloadEffect: @"hit.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect: @"lose.wav"];
        
        shipsArray = [[NSMutableArray alloc] init];
        removedShipsArray = [[NSMutableArray alloc] init];
        
        CCSprite *background = [CCSprite spriteWithFile: @"bg.png"];
        background.position = ccp(GameCenterX, GameCenterY);
        [self addChild: background];
        
        back = [CCSprite spriteWithFile: @"back.png"];
        back.position = ccp(302, -160);
        [self addChild: back];
        
        CCSprite *bg = [CCSprite spriteWithFile: @"fieldsBg.png"];
        bg.position = ccp(GameCenterX, GameCenterY + 35);
        [self addChild: bg];
        
        self.isTouchEnabled = YES;
        
        [self startGame];
        
        
        
        
        
    }
	return self;
}

- (void) showAllShips
{
    for(Ship *ship in enemyShipsArray)
    {
        ship.visible = YES;
    }
}

- (void) placeYourShipsRandom
{
    for(Ship *ship in shipsArray)
    {
        [self removeChild: ship cleanup: YES];
    }
    
    [shipsArray removeAllObjects];
    
    [self removeChild: yourField cleanup: YES];
    
    yourField = [Field create];
    yourField.position = ccp(100, 600);
    [self addChild: yourField];
    
    [self createShips: shipsArray];
    
    
    
    for(Ship *ship in shipsArray)
    {
        ship.oldPosition = ccp(ship.position.x, 35);
    }
    
    [self placeShipsFrom: shipsArray onAfield: yourField];
    
    if([yourField isFullField])
    {
        [guiLayer enableReadyBtn];
    }
}

- (void) placeShipsFrom: (NSMutableArray *) arrayWithShips onAfield: (Field *) field
{
    
    int i = 0;
    int q = 0;
    
    while (i != 10)
    {
        q++;
        
        //CCLOG(@"count: %i", q);
        
        Ship *curShip = [arrayWithShips objectAtIndex: i];
        
        int x = arc4random() % kSizeOfField;
        int y = arc4random() % kSizeOfField;
        
        if(arc4random() % 2 == 0)
        {
            [curShip rotate];
        }
        
        BOOL isOk = NO;
        
        int i1,i2,j1,j2;
        
        if(curShip.isHorizontal)
        {
            i1 = [self correctValueOfIndex: x - 1];
            i2 = [self correctValueOfIndex: x + curShip.cells];
            
            j1 = [self correctValueOfIndex: y - 1];
            j2 = [self correctValueOfIndex: y + 1];
            
            int last_i = x + curShip.cells - 1;
            
            if(last_i <= kMaxIndex)
            {
                if([field isFreeZone: ccp(i1, j1) andPosTwo: ccp(i2, j2)])
                {
                    
                    curShip.position = ccp(field.position.x + x * kWidthOfCell, field.position.y - y * kWidthOfCell);
                    
                    for(int k = 0; k < curShip.cells; k++)
                    {
                        [field doBusyCell_i: x + k and_j: y];
                        [curShip markCellWithNumber: k set_i: x + k set_j: y ];//andSetValue: 1];
                        curShip.isSetted = YES;
                        
                    }
                    
                    
                    
                    isOk = YES;
                }
            }
        }
        else
        {
            i1 = [self correctValueOfIndex: x - 1];
            i2 = [self correctValueOfIndex: x + 1];
            
            j1 = [self correctValueOfIndex: y - curShip.cells];
            j2 = [self correctValueOfIndex: y + 1];
            
            int last_j = y - curShip.cells + 1;
            
            if(last_j >= kMinIndex)
            {
                if([field isFreeZone: ccp(i1, j1) andPosTwo: ccp(i2, j2)])
                {
                    
                    curShip.position = ccp(field.position.x + x * kWidthOfCell, field.position.y - y * kWidthOfCell);
                    
                    for(int k = 0; k < curShip.cells; k++)
                    {
                        [field doBusyCell_i: x and_j: y - k];
                        [curShip markCellWithNumber: k set_i: x set_j: y - k ];
                        curShip.isSetted = YES;
                        
                    }
                    
                    isOk = YES;
                }
            }
        }
        
        if(isOk) i++;
        
        
    }
    
    
    
}

#pragma mark -
#pragma mark Touche's methods

- (void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate: self priority: 0 swallowsTouches: YES];
}

- (NSString *) getNearValues: (int) i j: (int) j
{
    NSString *coordinats = @"";
    
    int new_min_i = [self correctValueOfIndex: i - 1];
    int new_min_j = [self correctValueOfIndex: j - 1];
    
    int new_max_i = [self correctValueOfIndex: i + 1];
    int new_max_j = [self correctValueOfIndex: j + 1];
    
    coordinats = [NSString stringWithFormat: @"%i,%i/%i,%i/%i,%i/%i,%i", new_min_i, j, new_max_i, j, i, new_max_j, i, new_min_j];
    
    
    
    return  coordinats;
    
    //[coordinats release];
}

- (BOOL) isHaveNewCellForAttack_i: (int) i j: (int) j
{
    BOOL isHave = NO;
    
    NSArray *allCoords = [[self getNearValues: i j: j] componentsSeparatedByString: @"/"];
    
    NSMutableArray *possibleCoords = [[NSMutableArray alloc] init];
    NSMutableArray *coordsForAttack = [[NSMutableArray alloc] init];
    
    for(int k = 0; k < [allCoords count]; k++)
    {
        NSString *curCoords = [allCoords objectAtIndex: k];
        
        NSArray *arrayWithCoords = [curCoords componentsSeparatedByString: @","];
        
        
        
        int new_i = [[arrayWithCoords objectAtIndex: 0] integerValue];
        int new_j = [[arrayWithCoords objectAtIndex: 1] integerValue];
        
        //CCLOG(@"coordinats %i, %i", new_i, new_j);
        
        if(new_i == i && new_j == j)
        {
            CCLOG(@"OOPS!");
        }
        else
        {
            NSString *coordsForArray = [NSString stringWithFormat: @"%i,%i", new_i, new_j];
            
            [possibleCoords addObject: coordsForArray];
        }
    }
    
    for(int k = 0; k < [possibleCoords count]; k++)
    {
        
        
        NSString *curCoords = [possibleCoords objectAtIndex: k];
        
        NSArray *arrayWithCoords = [curCoords componentsSeparatedByString: @","];
        
        int new_i = [[arrayWithCoords objectAtIndex: 0] integerValue];
        int new_j = [[arrayWithCoords objectAtIndex: 1] integerValue];
        
        if([yourField canShotToCell: new_i and_j: new_j])
        {
            NSString *coordsForArray = [NSString stringWithFormat: @"%i,%i", new_i, new_j];
            
            [coordsForAttack addObject: coordsForArray];
            
            CCLOG(@"curItem %@", coordsForArray);
        }
    }
    
    if([coordsForAttack count] == 0)
    {
        [self attackOfEnemy];
        
        lastcell = ccp(badLastCell, badLastCell);
    }
    else
    {
        int rand_i = arc4random() % [coordsForAttack count];
        
        CCLOG(@"curRandomNum %i count %i", rand_i, [coordsForAttack count]);
        
        NSString *changedCoords = [coordsForAttack objectAtIndex: rand_i];
        
        NSArray *coordsArray = [changedCoords componentsSeparatedByString: @","];
        
        int coord_i = [[coordsArray objectAtIndex: 0] integerValue];
        int coord_j = [[coordsArray objectAtIndex: 1] integerValue];
        
        lastcell = ccp(coord_i, coord_j);
        
        isHave = YES;
        
        //[self attackOfEnemy];
    }
    
    [possibleCoords release];
    [coordsForAttack release];
    
    return isHave;
}

- (NSString *) separateCoordinatsAndReturnOnePare: (NSString *) stringWithCoords
{
    NSMutableArray *coordsForAttack = [[NSMutableArray alloc] init];
    
    NSArray *possibleCoords = [stringWithCoords componentsSeparatedByString: @"/"];
    
    for(int q = 0; q < [possibleCoords count]; q++)
    {
        NSString *curCoords = [possibleCoords objectAtIndex: q];
        
        NSArray *arrWithCurCoords = [curCoords componentsSeparatedByString: @","];
        
        int i = [[arrWithCurCoords objectAtIndex: 0] integerValue];
        int j = [[arrWithCurCoords objectAtIndex: 1] integerValue];
        
        if([yourField isFreeCell_i: i j: j])
        {
            [coordsForAttack addObject: curCoords];
        }
    }
    
    CCLOG(@"CoordsForAttack %@", coordsForAttack);
    
    int rand_num = arc4random() % [coordsForAttack count];
    
    NSString *resultStr = [coordsForAttack objectAtIndex: rand_num];
    
    CCLOG(@"ResultStr = %@", resultStr);
    
    [coordsForAttack release];
    
    return resultStr;
}

- (NSArray *) getNextIndexForAttack: (CGPoint) lastCell direction: (NSString *) dir
{
    NSString *coordinats = @"";
    
    if([dir isEqualToString: @""])
    {
        int new_min_i = [self correctValueOfIndex: lastcell.x - 1];
        int new_min_j = [self correctValueOfIndex: lastcell.y - 1];
        
        int new_max_i = [self correctValueOfIndex: lastcell.x + 1];
        int new_max_j = [self correctValueOfIndex: lastcell.y + 1];
        
        NSString *tempStr = [NSString stringWithFormat: @"%i,%f/%i,%f/%f,%i/%f,%i", new_min_i, lastcell.y, new_max_i, lastcell.y, lastcell.x, new_max_j, lastcell.x, new_min_j];
        
        coordinats = [self separateCoordinatsAndReturnOnePare: tempStr];
    }
    else
    {
        if([dir isEqualToString: dUp])
        {
            int new_i = lastcell.x;
            int new_j = [self correctValueOfIndex: lastcell.y - 1];
            
            if(new_j == lastcell.y || ![yourField isFreeCell_i: new_i j: new_j])
            {
                new_j = firstCell.y + 1;
                
                direction = dDown;
                lastcell = ccp(new_i, new_j);
            }
            
            coordinats = [NSString stringWithFormat: @"%i,%i", new_i, new_j];
        }
        else if([dir isEqualToString: dRight])
        {
            int new_i = [self correctValueOfIndex: lastcell.x + 1];
            int new_j = lastcell.y;
            
            if(new_i == lastcell.x || ![yourField isFreeCell_i: new_i j: new_j])
            {
                new_i = firstCell.x - 1;
                
                direction = dLeft;
                lastcell = ccp(new_i, new_j);
            }
            
            coordinats = [NSString stringWithFormat: @"%i,%i", new_i, new_j];
        }
        else if([dir isEqualToString: dDown])
        {
            int new_i = lastcell.x;
            int new_j = [self correctValueOfIndex: lastcell.y + 1];
            
            if(new_j == lastcell.y || ![yourField isFreeCell_i: new_i j: new_j])
            {
                new_j = firstCell.y - 1;
                
                direction = dUp;
                lastcell = ccp(new_i, new_j);
            }
            
            coordinats = [NSString stringWithFormat: @"%i,%i", new_i, new_j];
        }
        else if ([dir isEqualToString: dLeft])
        {
            int new_i = [self correctValueOfIndex: lastcell.x - 1];
            int new_j = lastcell.y;
            
            if(new_i == lastcell.x || ![yourField isFreeCell_i: new_i j: new_j])
            {
                new_i = firstCell.x + 1;
                
                direction = dRight;
                lastcell = ccp(new_i, new_j);
            }
            
            coordinats = [NSString stringWithFormat: @"%i,%i", new_i, new_j];
        }
    }
    
    NSArray *arrWithCoords = [coordinats componentsSeparatedByString: @","];
    
    return arrWithCoords;
}

- (NSArray *) getRandomIndexesForAttackOfAI
{
    NSInteger i, j;
    BOOL isOkIndexes = NO;
    
    do
    {
        i = arc4random() % kSizeOfField;
        j = arc4random() % kSizeOfField;
        
        if([yourField isFreeCell_i: i j: j])
        {
            isOkIndexes = YES;
        }
    }
    while (!isOkIndexes);
    
    NSString *strWithIndexes = [NSString stringWithFormat: @"%i,%i", i, j];
    
    NSArray *indexes = [strWithIndexes componentsSeparatedByString: @","];
    
    return indexes;
}

- (void) releaseVariables
{
    isNeedToContinue = NO;
    isHaveDirection = NO;
    isSuccessAttack = NO;
    isKilled = NO;
    isFirstHit = YES;
    isLock = NO;
    
    direction = @"";
    firstCell = ccp(badLastCell, badLastCell);
    lastcell = ccp(badLastCell, badLastCell);
}

- (void) getDirection
{
    if(lastcell.x - firstCell.x < 0)
    {
        direction = @"left";
    }
    if(lastcell.x - firstCell.x > 0)
    {
        direction = @"right";
    }
    if(lastcell.y - firstCell.y < 0)
    {
        direction = @"up";
    }
    if(lastcell.y - firstCell.y > 0)
    {
        direction = @"down";
    }
}

- (void) attackOfEnemy
{
    NSInteger i,j;
    
    if(isNeedToContinue)
    {
        NSArray *result = [self getNextIndexForAttack: lastcell direction: direction];
        
        i = [[result objectAtIndex: 0] integerValue];
        j = [[result objectAtIndex: 1] integerValue];
    }
    else
    {
        NSArray *tempArr = [self getRandomIndexesForAttackOfAI];
        
        i = [[tempArr objectAtIndex: 0] integerValue];
        j = [[tempArr objectAtIndex: 1] integerValue];
    }
    
    CCLOG(@"III: %i JJJ: %i", i, j);
    
    NSString *resultOfAttack = [yourField shotToCoords_i: i and_j: j];
    
    if(![resultOfAttack isEqualToString: @""])
    {
        NSArray *arrayWithResults = [resultOfAttack componentsSeparatedByString: @","];
        
        isSuccessAttack = [[arrayWithResults objectAtIndex: 0] boolValue];
        
        if(isSuccessAttack)
        {
            [[SimpleAudioEngine sharedEngine] playEffect: @"hit.wav"];
            
            CCLOG(@"IS SUCCESS!");
            
            [yourField doDeadCell_i: i and_j: j];
            
            lastcell = ccp(i, j);
            isNeedToContinue = YES;
            
            if(isFirstHit)
            {
                firstCell = ccp(i, j);
                isFirstHit = NO;
            }
            else
            {
                if(!isHaveDirection)
                {
                    isHaveDirection = YES;
                    
                    [self getDirection];
                }
                
            }
            
            for(Ship *curShip in shipsArray)
            {
                isKilled = [curShip shotToCell_i: i and_j: j];
                
                if(isKilled)
                {
                    
                    [removedShipsArray addObject: curShip];
                    
                    if(curShip.isHorizontal)
                    {
                        int i1,i2,j1,j2;
                        
                        int q = fabs(curShip.position.x - yourField.position.x + (kWidthOfCell / 2)) / kWidthOfCell;
                        int w = fabs(yourField.position.y - curShip.position.y + (kWidthOfCell / 2)) / kWidthOfCell;
                        
                        i1 = [self correctValueOfIndex: q - 1];
                        i2 = [self correctValueOfIndex: q + curShip.cells];
                        
                        j1 = [self correctValueOfIndex: w - 1];
                        j2 = [self correctValueOfIndex: w + 1];
                        
                        for(int i = i1; i <= i2; i++)
                        {
                            for(int j = j1; j <= j2; j++)
                            {
                                [yourField markEmpty_i: i and_j: j];
                            }
                        }
                        
                    }
                    else
                    {
                        int i1,i2,j1,j2;
                        
                        int q = fabs(curShip.position.x - yourField.position.x + (kWidthOfCell / 2)) / kWidthOfCell;
                        int w = fabs(yourField.position.y - curShip.position.y + (kWidthOfCell / 2)) / kWidthOfCell;
                        
                        i1 = [self correctValueOfIndex: q - 1];
                        i2 = [self correctValueOfIndex: q + 1];
                        
                        j1 = [self correctValueOfIndex: w - curShip.cells];
                        j2 = [self correctValueOfIndex: w + 1];
                        
                        for(int i = i1; i <= i2; i++)
                        {
                            for(int j = j1; j <= j2; j++)
                            {
                                [yourField markEmpty_i: i and_j: j];
                            }
                        }
                        
                    }
                    
                    [self releaseVariables];
                }
            }
            
            for(Ship *curShip in removedShipsArray)
            {
                [shipsArray removeObject: curShip];
                [self removeChild: curShip cleanup: YES];
            }
            
            [removedShipsArray removeAllObjects];
            
            if([shipsArray count] == 0)
            {
                [guiLayer stopGame: @"Machine"];
                
                youIsFirst = YES;
            }
        }
        else
        {
            youIsFirst = !youIsFirst;
            
            [[SimpleAudioEngine sharedEngine] playEffect: @"lose.wav"];
        }
        
        
        
        CCLOG(@"i: %i j: %i youAreFirst: %i", i,j, youIsFirst);
        CCLOG(@"lastCell.x: %f lastCell.y: %f", lastcell.x, lastcell.y);
        CCLOG(@"FirstCell.x: %f FirstCell.y: %f", firstCell.x, firstCell.y);
        CCLOG(@"isNeedContinue: %i isHaveDirection: %i isSuccessAttack: %i", isNeedToContinue, isHaveDirection, isSuccessAttack);
        CCLOG(@"isKilled: %i isFirstHit: %i Direction: %@", isKilled, isFirstHit, direction);
        CCLOG(@"count of ships: %i", [shipsArray count]);
        
        [yourField update];
        
        if(!youIsFirst)
        {
            [self runAction:
                    [CCSequence actions:
                                [CCDelayTime actionWithDuration: 1],
                                [CCCallFunc actionWithTarget: self selector:@selector(attackAgain)],
                     nil]
            ];
        }
    }
}

- (void) attackAgain
{
    [self attackOfEnemy];
}


- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    
    if(isCanMoveShips)
    {
        for(Ship *curShip in shipsArray)
        {
            curShip.isTapped = [curShip isTapped: location];
            
            if(curShip.isTapped)
            {
                int i = fabs(curShip.position.x - yourField.position.x + (kWidthOfCell / 2)) / kWidthOfCell;
                int j = fabs(curShip.position.y - yourField.position.y - (kWidthOfCell / 2)) / kWidthOfCell;
                
                [self setShip: curShip OnYourFieldPosition_i: i and_j: j];
            }
        }
        
        if(![yourField isFullField])
        {
            [guiLayer disableReadyBtn];
        }
    }
    else
    {
        if(youIsFirst)
        {
            if(GameMode == kSingleMode)
            {
                if((location.x > anotherField.position.x - kWidthOfCell / 2) && (location.x < anotherField.position.x + kWidthOfField - kWidthOfCell / 2) &&
                   (location.y < anotherField.position.y + kWidthOfCell / 2) && (location.y > anotherField.position.y - kWidthOfField + kWidthOfCell / 2))
                {
                    int i = fabs(location.x - anotherField.position.x + (kWidthOfCell / 2)) / kWidthOfCell;
                    int j = fabs(location.y - anotherField.position.y - (kWidthOfCell / 2)) / kWidthOfCell;
                    
                    NSString *str = [anotherField shotToCoords_i: i and_j: j];
                    
                    if(![str isEqualToString: @""])
                    {
                        NSArray *array = [str componentsSeparatedByString: @","];
                        BOOL isHit = [[array objectAtIndex: 0] boolValue];
                        
                        for(Ship *curShip in enemyShipsArray)
                        {
                            BOOL shipDead = [curShip shotToCell_i: i and_j: j];
                            
                            if(shipDead)
                            {
                                [removedEnemyShipsArray addObject: curShip];
                                
                                if(curShip.isHorizontal)
                                {
                                    int i1,i2,j1,j2;
                                    
                                    int q = fabs(curShip.position.x - anotherField.position.x + (kWidthOfCell / 2)) / kWidthOfCell;
                                    int w = fabs(anotherField.position.y - curShip.position.y + (kWidthOfCell / 2)) / kWidthOfCell;
                                    
                                    i1 = [self correctValueOfIndex: q - 1];
                                    i2 = [self correctValueOfIndex: q + curShip.cells];
                                    
                                    j1 = [self correctValueOfIndex: w - 1];
                                    j2 = [self correctValueOfIndex: w + 1];
                                    
                                    for(int i = i1; i <= i2; i++)
                                    {
                                        for(int j = j1; j <= j2; j++)
                                        {
                                            [anotherField markEmpty_i: i and_j: j];
                                        }
                                    }
                                    
                                }
                                else
                                {
                                    int i1,i2,j1,j2;
                                    
                                    int q = fabs(curShip.position.x - anotherField.position.x + (kWidthOfCell / 2)) / kWidthOfCell;
                                    int w = fabs(anotherField.position.y - curShip.position.y + (kWidthOfCell / 2)) / kWidthOfCell;
                                    
                                    i1 = [self correctValueOfIndex: q - 1];
                                    i2 = [self correctValueOfIndex: q + 1];
                                    
                                    j1 = [self correctValueOfIndex: w - curShip.cells];
                                    j2 = [self correctValueOfIndex: w + 1];
                                    
                                    for(int i = i1; i <= i2; i++)
                                    {
                                        for(int j = j1; j <= j2; j++)
                                        {
                                            [anotherField markEmpty_i: i and_j: j];
                                        }
                                    }
                                    
                                }
                            }
                        }
                        
                        if(!isHit)
                        {
                            [[SimpleAudioEngine sharedEngine] playEffect: @"lose.wav"];
                            
                            youIsFirst = !youIsFirst;
                            
                            [self runAction:
                                        [CCSequence actions:
                                                    [CCDelayTime actionWithDuration: 0.3],
                                                    [CCCallFunc actionWithTarget: self selector:@selector(attackAgain)],
                                                    nil]
                             ];
                        }
                        else
                        {
                            [[SimpleAudioEngine sharedEngine] playEffect: @"hit.wav"];
                        }
                    }
                    
                    for(Ship *curShip in removedEnemyShipsArray)
                    {
                        [enemyShipsArray removeObject: curShip];
                        [self removeChild: curShip cleanup: YES];
                    }
                    
                    [removedEnemyShipsArray removeAllObjects];
                    
                    if(enemyShipsArray.count == 0)
                    {
                        [guiLayer stopGame: @"You"];
                    }
                }
            }
            else
            {
                [self sendDataPosX: location.x andPosY: location.y type: kAttackType];
            }
        }
    }
    
    return YES;
}



- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    
    if(isCanMoveShips)
    {
        for(Ship *curShip in shipsArray)
        {
            if(curShip.isTapped)
            {
                curShip.position = location;
            }
        }
    }
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    
    if(isCanMoveShips)
    {
        if(location.x < yourField.position.x + 380 && location.x > yourField.position.x - 20)
        {
            if(location.y < yourField.position.y + 20 && location.y > yourField.position.y - 380)
            {
                int i = fabs(location.x - yourField.position.x + (kWidthOfCell / 2)) / kWidthOfCell;
                int j = fabs(location.y - yourField.position.y - (kWidthOfCell / 2)) / kWidthOfCell;
                
                int i1, i2, j1, j2;
                
                for(Ship *curShip in shipsArray)
                {
                    if(curShip.isTapped)
                    {
                        if(curShip.isHorizontal)
                        {
                            i1 = [self correctValueOfIndex: i - 1];
                            i2 = [self correctValueOfIndex: i + curShip.cells];
                            
                            j1 = [self correctValueOfIndex: j - 1];
                            j2 = [self correctValueOfIndex: j + 1];
                            
                            CGPoint lastCellPosition = ccp(curShip.position.x  + kWidthOfCell * (curShip.cells - 1), curShip.position.y);
                            
                            int last_i = (lastCellPosition.x - yourField.position.x + (kWidthOfCell / 2)) / kWidthOfCell;
                            
                            if(last_i <= kMaxIndex)
                            {
                                if([yourField isFreeZone: ccp(i1, j1) andPosTwo: ccp(i2, j2)])
                                {
                                    
                                    curShip.position = ccp(yourField.position.x + i * kWidthOfCell, yourField.position.y - j * kWidthOfCell);
                                    //curShip.oldPosition = curShip.position;
                                    
                                    for(int k = 0; k < curShip.cells; k++)
                                    {
                                        [yourField doBusyCell_i: i + k and_j: j];
                                        [curShip markCellWithNumber: k set_i: i + k set_j: j ];//andSetValue: 1];
                                        curShip.isSetted = YES;
                                    }
                                }
                                else
                                {
                                    [curShip runAction: [CCMoveTo actionWithDuration: 0.5 position: curShip.oldPosition]];
                                }
                            }
                        }
                        else
                        {
                            i1 = [self correctValueOfIndex: i - 1];
                            i2 = [self correctValueOfIndex: i + 1];
                            
                            j1 = [self correctValueOfIndex: j - curShip.cells];
                            j2 = [self correctValueOfIndex: j + 1];
                            
                            CGPoint lastCellPosition = ccp(curShip.position.x, curShip.position.y + kWidthOfCell * (curShip.cells - 1));
                            
                            int last_j = (yourField.position.y - lastCellPosition.y - (kWidthOfCell / 2)) / kWidthOfCell;
                            
                            if(last_j >= kMinIndex)
                            {
                                if([yourField isFreeZone: ccp(i1, j1) andPosTwo: ccp(i2, j2)])
                                {
                                    curShip.position = ccp(yourField.position.x + i * kWidthOfCell, yourField.position.y - j * kWidthOfCell);
                                    
                                    for(int k = 0; k < curShip.cells; k++)
                                    {
                                        [yourField doBusyCell_i: i and_j: j - k];
                                        [curShip markCellWithNumber: k set_i: i set_j: j - k ];
                                        curShip.isSetted = YES;
                                    }
                                }
                                else
                                {
                                    [curShip runAction: [CCMoveTo actionWithDuration: 0.5 position: curShip.oldPosition]];
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if([yourField isFullField])
        {
            [guiLayer enableReadyBtn];
        }
    }
}

#pragma mark -
#pragma mark Ship methods

- (void) createShips: (NSMutableArray *) arrayForShip
{
    int sum = 5;
    
    int countOfShip = 1;
    
    int commonCountOfShips = 0;
    
    for(int i = 0; i < sum; i++)
    {
        for(int j = 0; j < countOfShip; j++)
        {
            if(sum - countOfShip > 0)
            {
                Ship *ship = [Ship createWithSize: sum - countOfShip];
                ship.anchorPoint = ccp(0.5, 0.5);
                ship.position = ccp(100 + 45 * commonCountOfShips, 30 - 250);
                ship.oldPosition = ship.position;
                [self addChild: ship];
                
                [arrayForShip addObject: ship];
                
                commonCountOfShips++;
            }
        }
        
        countOfShip++;
    }
}

- (void) setShip: (Ship *) curShip OnYourFieldPosition_i: (int) i and_j: (int) j
{
    if (curShip.isHorizontal)
    {
        for(int k = 0; k < curShip.cells; k++)
        {
            [yourField doFreeCell_i: i + k and_j: j];
            curShip.isSetted = NO;
        }
    }
    else
    {
        for(int k = 0; k < curShip.cells; k++)
        {
            [yourField doFreeCell_i: i and_j: j - k];
            curShip.isSetted = NO;
        }
    }
}


- (void) rotateShip
{
    for(Ship *curShip in shipsArray)
    {
        if(curShip.isTapped)
        {
            int i1, i2, j1, j2;
            
            int i = fabs(curShip.position.x - yourField.position.x + (kWidthOfCell / 2)) / kWidthOfCell;
            int j = fabs(curShip.position.y - yourField.position.y - (kWidthOfCell / 2)) / kWidthOfCell;
            
            if(curShip.isHorizontal)
            {
                BOOL isError = NO;
                
                i1 = i - 1;
                i2 = i + 1;
                
                j1 = j - curShip.cells;
                j2 = j - 1;
                
                if(i1 <= 0) i1 = 0;
                if(i2 >= 9) i2 = 9;
                
                if(j1 < -1) isError = YES;
                if(j2 >= 9) j2 = 9;
                
                BOOL isFreeField = [yourField isFreeZone: ccp(i1, j1) andPosTwo: ccp(i2, j2)];
                
                if(isFreeField && !isError)
                {
                    [yourField rotateValuesForShip: curShip];
                    [curShip rotate];
                    
                    for(int k = 0; k < curShip.cells; k++)
                    {
                        [curShip markCellWithNumber: k set_i: i set_j: j - k ];
                    }
                }
            }
            else
            {
                
                
                BOOL isError = NO;
                
                i1 = i + 1;
                i2 = i + curShip.cells;
                
                j1 = j - 1;
                j2 = j + 1;
                
                if(i2 > 10) isError = YES;
                if(j1 <= 0) j1 = 0;
                
                if(j2 >= 9) j2 = 9;
                
                
                BOOL isFreeField = [yourField isFreeZone: ccp(i1, j1) andPosTwo: ccp(i2, j2)];
                
                if(isFreeField && !isError)
                {
                    [yourField rotateValuesForShip: curShip];
                    [curShip rotate];
                    
                    for(int k = 0; k < curShip.cells; k++)
                    {
                        [curShip markCellWithNumber: k set_i: i + k set_j: j ];
                    }
                }
            }
            
            
        }
    }
}

#pragma mark -
#pragma mark Other methods

- (void) startGame: (int) gameMode
{
    if(gameMode == kSingleMode)
    {
        [back runAction: [CCMoveTo actionWithDuration: 0.5 position: ccp(302, 85)]];
        
        for(Ship *curShip in shipsArray)
        {
            if(!curShip.isSetted)
            {
                curShip.oldPosition = ccp(curShip.position.x, 30);
                [curShip runAction: [CCMoveTo actionWithDuration: 0.5 position: curShip.oldPosition]];
            }
        }
    }
    else
    {
        if(!isGuiEnable)
        {
            [back runAction: [CCMoveTo actionWithDuration: 0.5 position: ccp(302, 85)]];
        }
        
        for(Ship *curShip in shipsArray)
        {
            if(!curShip.isSetted)
            {
                curShip.oldPosition = ccp(curShip.position.x, 30);
                [curShip runAction: [CCMoveTo actionWithDuration: 0.5 position: curShip.oldPosition]];
            }
        }
        
        [guiLayer showGuiButtons];
    
        [guiLayer changeStatusLabel: @"Расставляйте \n корабли!"];
    }
}

- (int) getIndexNumberFromPosition: (int) position onAfield: (Field *) field andIndexParameter: (int) parameter
{
    int curIndex = 0;
    
    if(parameter == GET_I) curIndex = fabs(position - field.position.x + (kWidthOfCell / 2)) / kWidthOfCell;
    else curIndex = fabs(field.position.y - position + (kWidthOfCell / 2)) / kWidthOfCell;
    
    return curIndex;
}

- (void) changeStatusLabel
{
    if(youIsFirst)
    {
        [guiLayer changeStatusLabel: @"Ваш ход!"];
    }
    else
    {
        [guiLayer changeStatusLabel: @"Ход противника!"];
    }
}

- (int) correctValueOfIndex: (int) curValueOfIndex
{
    int newValueOfIndex = curValueOfIndex;
    
    if(curValueOfIndex <= kMinIndex) newValueOfIndex = kMinIndex;
    
    if(curValueOfIndex >= kMaxIndex) newValueOfIndex = kMaxIndex;
    
    return newValueOfIndex;
}





//







- (void) showAnotherField
{
    [guiLayer disableReadyBtn];
    isCanMoveShips = NO;
    
    for(Ship *curShip in shipsArray)
    {
        [curShip enableFullOpacity];
    }
    
    if(youIsFirst)
    {
        [self sendReadySignal];
    }
    else
    {
        [self sendAnswerReadySignal];
    }
    
    [back runAction: [CCMoveTo actionWithDuration: 0.5 position: ccp(300, -160)]];
}



- (BOOL) isTapOnAnotherField_i: (int) i and_j: (int) j
{
    BOOL isTap = NO;
    
    if(i >= anotherField.position.x - (kWidthOfCell / 2) && i <= anotherField.position.x + kWidthOfField &&
       j >= anotherField.position.y - kWidthOfField && j <= anotherField.position.y + (kWidthOfCell / 2))
    {
        isTap = YES;
    }
    
    return isTap;
}


@end
