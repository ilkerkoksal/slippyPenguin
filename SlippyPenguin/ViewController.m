//
//  ViewController.m
//  SlippyPenguin
//
//  Created by Mac on 23/02/14.
//  Copyright (c) 2014 SlippyPenguin. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"


@implementation ViewController

-(void)viewDidLoad
{
    //self.adView.delegate = self;
    //self.adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    
    //[self.view addSubview:_adView];
    
    //adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    //adView.frame = CGRectOffset(adView.frame, 0, self.view.frame.size.height + 50);
    //adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
    //adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    //[self.view addSubview:adView];
    //adView.delegate = self;
    
    //self.bannerIsVisible = NO;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *)self.view;
    
    if (!skView.scene) {
        //skView.showsFPS = YES;
        //skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

//when banner is loaded successfully
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // banner is invisible now and moved out of the screen on 50 px
        CGRect adFrame = banner.frame;
        adFrame.origin.y = self.view.frame.size.height-banner.frame.size.height;
        banner.frame = adFrame;
        //banner.frame = CGRectOffset(banner.frame, 0, 50);
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
    }
}

//no ad comes
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.bannerIsVisible)
    {
        NSLog(@"İF GĞRER");
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
}

@end