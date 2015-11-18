//
//  MyScene.m
//  SlippyPenguin
//
//  Created by Mac on 23/02/14.
//  Copyright (c) 2014 SlippyPenguin. All rights reserved.
//

#import "MyScene.h"
#import "GameOverScene.h"

@import AVFoundation;

static const uint32_t birdCategory =  0x1 << 0;
static const uint32_t obstacleCategory =  0x1 << 1;

static const float BG_VELOCITY = 130.0; //Velocity with which our background is going to move
static const float OBJECT_VELOCITY = 135.0;

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)

{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}
@implementation MyScene
{
    SKSpriteNode *bird;
    SKSpriteNode *floor;
    SKSpriteNode *staticBackground;
    SKSpriteNode *scrollingBackground;
    SKSpriteNode *blockTop;
    SKSpriteNode *blockDown;
    SKSpriteNode *bg;
    SKSpriteNode *tap;
    SKAction *actionMoveUp;
    SKAction *actionMoveDown;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    NSTimeInterval _lastBlockAdded;
    NSInteger score;
    NSInteger highScore;
    SKLabelNode *scoreLabel;
    AVAudioPlayer *jumpEffect;
    UITouch *touch;
    BOOL check;
    BOOL startBlocks;
}


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        score = 0;
        
        [[NSUserDefaults standardUserDefaults]
         setObject:[NSNumber numberWithInteger:score] forKey:@"currentScore"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //Removes the HighScore
        //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HighScore"];
        
        /* Setup your scene here */
        
        //Add Background
        [self addStaticBackground];
        
        //Add the bird
        [self addBird];
        
        //Add unchanged floor
        [self addFloor];
        
        //Add scrolling blueFloor
        [self initalizingScrollingBackground];
        
        //Making self delegate of physics World
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        //Add score label
        [self addScoreLabel];
        
        //Add tap to continue
        [self addTap];
    }
    return self;
}


-(void)initalizingScrollingBackground
{
    for (int i = 0; i < 2; i++) {
        scrollingBackground = [SKSpriteNode spriteNodeWithImageNamed:@"blueFloor"];
        scrollingBackground.position = CGPointMake(i * scrollingBackground.size.width, floor.size.height);
        scrollingBackground.anchorPoint = CGPointZero;
        scrollingBackground.name = @"scrollingbg";
        scrollingBackground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:scrollingBackground.size];
        scrollingBackground.zPosition = 1.0;
        scrollingBackground.physicsBody.dynamic = false;
        [self addChild:scrollingBackground];
    }
    
}
-(void)addTap
{
    tap = [SKSpriteNode spriteNodeWithImageNamed:@"tap.png"];
    tap.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:tap.size];
    tap.physicsBody.categoryBitMask = birdCategory;
    tap.physicsBody.dynamic = FALSE;
    tap.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    tap.name = @"tap";
    [self addChild:tap];
}
-(void)addScoreLabel
{
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    NSString *someString = [NSString stringWithFormat:@"%d", (int)score];
    scoreLabel.text = someString;
    scoreLabel.fontSize = 50;
    scoreLabel.fontColor = [SKColor whiteColor];
    scoreLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - self.frame.size.height/6);
    scoreLabel.name = @"scoreLabel";
    [self addChild:scoreLabel];
}
-(void)addBird
{
    //self.physicsWorld.gravity = CGVectorMake(0, -1.f);
    
    bird = [SKSpriteNode spriteNodeWithImageNamed:@"slippyPenguin.png"];
    bird.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bird.size];
    bird.physicsBody.categoryBitMask = birdCategory;
    bird.physicsBody.dynamic = YES;
    //bird.zRotation = - M_PI / 2;
    bird.physicsBody.contactTestBitMask = obstacleCategory;
    bird.physicsBody.collisionBitMask = 0;
    bird.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/1.6);
    bird.name = @"bird";
    [self addChild:bird];
    
}


-(void)addFloor
{
    floor = [SKSpriteNode spriteNodeWithImageNamed:@"normalFloor.png"];
    
    floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(floor.size.width, floor.size.height)];
    floor.physicsBody.dynamic = false;
    floor.name = @"floorbg";
    floor.position = CGPointMake(self.frame.size.width/2,floor.size.height/2);
    floor.zPosition = 1.0;
    [self addChild:floor];
    
}
-(void)addStaticBackground
{
    staticBackground = [SKSpriteNode spriteNodeWithImageNamed:@"backgroundFix.png"];
    
    //staticBackground.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    staticBackground.position = CGPointMake(230,440);
    staticBackground.name = @"staticbg";
    [self addChild:staticBackground];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins
     self.physicsWorld.gravity = CGVectorMake(0, 14.f);*/
    
    //touch = [touches anyObject];
    /*if (touch.tapCount == 1)
     {
     NSLog(@"sadsad");
     }*/
    
    [tap removeFromParent];
    [self runAction:[SKAction playSoundFileNamed:@"wing.wav" waitForCompletion:YES]];
    
    startBlocks = true;
    bird.physicsBody.velocity = CGVectorMake(0, 240.f);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //self.physicsWorld.gravity = CGVectorMake(0, -4.f);
    bird.physicsBody.velocity = CGVectorMake(0, -240.f);
}

-(void)update:(CFTimeInterval)currentTime {
    
    if (_lastUpdateTime)
    {
        _dt = currentTime - _lastUpdateTime;
    }
    else
    {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    if( currentTime - _lastBlockAdded > 0.5)
    {
        _lastBlockAdded = currentTime + 0.5;
        if (startBlocks)
        {
            [self addBlock];
        }
    }
    
    if (startBlocks)
    {
        [self moveObstacle];
    }
    if(bird.position.y > self.frame.size.height)
    {
        bird.physicsBody.velocity = CGVectorMake(0, -240.f);
    }
    [self moveBg];
    
}


- (void)moveBg
{
    [self enumerateChildNodesWithName:@"scrollingbg" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-BG_VELOCITY, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (bg.position.x <= -bg.size.width)
         {
             bg.position = CGPointMake(bg.position.x + bg.size.width*2,
                                       bg.position.y);
         }
     }];
}

-(void)addBlock
{
    blockTop = [SKSpriteNode spriteNodeWithImageNamed:@"blockTopNew.png"];
    
    blockTop.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:blockTop.size];
    blockTop.physicsBody.categoryBitMask = obstacleCategory;
    blockTop.physicsBody.dynamic = YES;
    blockTop.physicsBody.contactTestBitMask = birdCategory;
    blockTop.physicsBody.collisionBitMask = 0;
    blockTop.physicsBody.usesPreciseCollisionDetection = YES;
    blockTop.name = @"blockTop";
    
    
    blockDown = [SKSpriteNode spriteNodeWithImageNamed:@"blockDownNew.png"];
    
    blockDown.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:blockDown.size];
    blockDown.physicsBody.categoryBitMask = obstacleCategory;
    blockDown.physicsBody.dynamic = YES;
    blockDown.physicsBody.contactTestBitMask = birdCategory;
    blockDown.physicsBody.collisionBitMask = 0;
    blockDown.physicsBody.usesPreciseCollisionDetection = YES;
    blockDown.name = @"blockDown";
    
    check = true;//check for blocks
    
    //selecting random y position for missile
    int r = arc4random() % 170;
    
    if([[UIScreen mainScreen] bounds].size.height == 568)
    {
        blockTop.position = CGPointMake(self.frame.size.width + 400, self.frame.size.height + r + 50);
        blockDown.position = CGPointMake(self.frame.size.width + 400, r - 50);
        
    }
    else
    {
        blockTop.position = CGPointMake(self.frame.size.width + 400, self.frame.size.height + r + 90);
        blockDown.position = CGPointMake(self.frame.size.width + 400, r - 90);
    }
    
    
    [self addChild:blockTop];
    [self addChild:blockDown];
    
}

- (void)moveObstacle
{
    NSArray *nodes = self.children;//1
    
    for(SKNode * node in nodes){
        if (![node.name  isEqual: @"floorbg"] && ![node.name  isEqual: @"bird"] && ![node.name  isEqual: @"scoreLabel"] && ![node.name  isEqual: @"scrollingbg"] && ![node.name  isEqual: @"staticbg"])
        {
            SKSpriteNode *ob = (SKSpriteNode *) node;
            CGPoint obVelocity = CGPointMake(-OBJECT_VELOCITY, 0);
            CGPoint amtToMove = CGPointMultiplyScalar(obVelocity,_dt);
            
            ob.position = CGPointAdd(ob.position, amtToMove);
            if(ob.position.x < -10)
            {
                [ob removeFromParent];
            }
            if((ob.position.x + ob.size.width < bird.position.x) && check)
            {
                check =false;
                score = score + 1;
                
                [self runAction:[SKAction playSoundFileNamed:@"plus.wav" waitForCompletion:YES]];
                [[NSUserDefaults standardUserDefaults]
                 setObject:[NSNumber numberWithInteger:score] forKey:@"currentScore"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"HighScore"])
                {
                    highScore =  [(NSNumber *)[[NSUserDefaults standardUserDefaults]
                                               objectForKey:@"HighScore"] intValue];
                }
                else
                {
                    highScore = 0;
                }
                
                if(score > highScore)
                {
                    
                    [[NSUserDefaults standardUserDefaults]
                     setObject:[NSNumber numberWithInteger:score] forKey:@"HighScore"];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                //NSLog(@"score:, %ld", score);
                [scoreLabel removeFromParent];
                [self addScoreLabel];
            }
        }
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & birdCategory) != 0 &&
        (secondBody.categoryBitMask & obstacleCategory) != 0)
    {
        [bird removeFromParent];
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
        [self.view presentScene:gameOverScene transition: reveal];
    }
}

@end

