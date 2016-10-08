//
//  ViewController.m
//  ProgressiveViewDemo
//
//  Created by daiyi on 2016/10/8.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Progressive.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)topProgressive:(id)sender {
    [_imageView showProgressiveWithDirection:ProgressiveDirectionTop];
}

- (IBAction)centerProgressive:(id)sender {
    [_imageView showProgressiveWithDirection:ProgressiveDirectionVerticalCenter];
}

- (IBAction)leftProgressive:(id)sender {
    [_imageView showProgressiveWithDirection:ProgressiveDirectionLeft];
}

- (IBAction)roundProgressive:(id)sender {
    [_imageView showProgressiveWithDirection:ProgressiveDirectionRoundSpread];
}

- (IBAction)hideProgressive:(id)sender {
    [_imageView hideProgressiveWithDirection:ProgressiveDirectionBottom complete:^{
        NSLog(@"动画完成");
        _imageView.hidden = YES;
    }];
}

@end
