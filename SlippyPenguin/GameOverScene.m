//
//  GameOverScene.m
//  SlippyPenguin
//
//  Created by Mac on 23/02/14.
//  Copyright (c) 2014 SlippyPenguin. All rights reserved.
//

#import "GameOverScene.h"
#import "MyScene.h"

@implementation GameOverScene
{
    NSString *retrymessage;
    NSString *message;
    SKLabelNode *scoreLabel;
    SKLabelNode *highScoreLabel;
    SKLabelNode *scoreLabelText;
    SKLabelNode *highScoreLabelText;
    NSInteger score;
    NSInteger highScore;
    SKSpriteNode *background;
}
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        //Add Background
        [self addBackground];
        
        //High Score
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"HighScore"])
        {
            highScore =  [(NSNumber *)[[NSUserDefaults standardUserDefaults]
                                       objectForKey:@"HighScore"] intValue];
        }
        else
        {
            highScore = 0;
        }
        
       
        //Score
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"currentScore"])
        {
            score =  [(NSNumber *)[[NSUserDefaults standardUserDefaults]
                                   objectForKey:@"currentScore"] intValue];
        }
        else
        {
            score = 0;
        }
        
        if(score > highScore || score == highScore)
        {
            if (score != 0)
            {
                [self runAction:[SKAction playSoundFileNamed:@"victory.wav" waitForCompletion:YES]];
            }
            else
            {
                [self runAction:[SKAction playSoundFileNamed:@"crash.wav" waitForCompletion:YES]];
            }
            
        }
        else
        {
            [self runAction:[SKAction playSoundFileNamed:@"crash.wav" waitForCompletion:YES]];
        }
        
        
        //Add High Score Label
        [self addHighScoreLabel];
        
        //Add Score Label
        [self addScoreLabel];
        
        // Set Game Over Message
        [self gameOver];
        
        //Set Retry button to start the game
        [self retry];
        
    }
    return self;
}

-(void)addBackground
{
    background = [SKSpriteNode spriteNodeWithImageNamed:@"gameover.png"];
    
    //staticBackground.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    background.position = CGPointMake(self.frame.size.width/2,self.frame.size.height/1.66);
    background.name = @"background";
    [self addChild:background];
}

-(void)addHighScoreLabel
{
    highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    NSString *someString = [NSString stringWithFormat:@"%d", (int)highScore];
    highScoreLabel.text = [@"High Score: " stringByAppendingString:someString];
    highScoreLabel.fontSize = 40;
    highScoreLabel.fontColor = [SKColor whiteColor];
    highScoreLabel.position = CGPointMake(self.frame.size.width/2, self.size.height/2);
    highScoreLabel.name = @"highScoreLabel";
    [self addChild:highScoreLabel];
}

-(void)addScoreLabel
{
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    NSString *someString2 = [NSString stringWithFormat:@"%d", (int)score];
    scoreLabel.text = [@"Score: " stringByAppendingString:someString2];
    scoreLabel.fontSize = 40;
    scoreLabel.fontColor = [SKColor whiteColor];
    scoreLabel.position = CGPointMake(self.size.width/2, self.size.height/1.7);
    scoreLabel.name = @"scoreLabel";
    [self addChild:scoreLabel];
    
}

-(void)gameOver
{
    message = @"Game Over";
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    label.text = message;
    label.fontSize = 40;
    label.fontColor = [SKColor whiteColor];
    label.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - self.frame.size.height/4);
    [self addChild:label];
}

-(void)retry
{
    retrymessage = @"Replay Game";
    SKLabelNode *retryButton = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    retryButton.text = retrymessage;
    retryButton.fontColor = [SKColor whiteColor];
    retryButton.position = CGPointMake(self.size.width/2, self.size.height/9);
    retryButton.name = @"retry";
    [self addChild:retryButton];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"retry"]) {
        
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        MyScene * scene = [MyScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition: reveal];
        
    }
}
@end