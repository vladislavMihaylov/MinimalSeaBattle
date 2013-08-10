
// Magic numbers

#define kGameWidth          1024
#define kGameHeight         768

#define kSizeOfField        10
#define kCountOfShips       10
#define kCountOfCells       20
#define kWidthOfCell        40
#define kWidthOfField       400

#define kMinIndex           0
#define kMaxIndex           9

#define kBTconnectionType   1
#define kAttackType         2
#define kAnswerType         3

#define GET_I               0
#define GET_J               1

#define badLastCell         -1

#define kSingleMode         0
#define kBluetoothMode      1

#define kYourFieldPosX      100
#define kYourFieldPosY      600

#define kAnotherFieldPosX   564
#define kAnotherFieldPosY   600

#define dRight              @"right"
#define dLeft               @"left"
#define dUp                 @"up"
#define dDown               @"down"

extern float GameCenterX;
extern float GameCenterY;

extern BOOL isCanMoveShips;
extern BOOL youIsFirst;

extern NSInteger GameMode;

extern BOOL isBluetoothConnected;

extern BOOL isGuiEnable;