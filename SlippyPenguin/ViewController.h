//
//  ViewController.h
//  SlippyPenguin
//

//  Copyright (c) 2014 SlippyPenguin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>

@interface ViewController : UIViewController<ADBannerViewDelegate>
{
    ADBannerView *adView;
    //GADBannerView *bannerView_;
}

@property (nonatomic) BOOL bannerIsVisible;
@end
