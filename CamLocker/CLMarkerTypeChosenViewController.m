//
//  CLMarkerTypeChosenViewController.m
//  CamLocker
//
//  Created by Jiaqi Liu on 3/21/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLUtilities.h"
#import "CLMarkerTypeChosenViewController.h"
#import "UIColor+MLPFlatColors.h"

@interface CLMarkerTypeChosenViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIButton *textButton;
@property (weak, nonatomic) IBOutlet UIButton *voiceButton;

@end

@implementation CLMarkerTypeChosenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [CLUtilities addBackgroundImageToView:self.view withImageName:@"bg_4.jpg"];
    
    [self.imageButton.layer addSublayer:[CLUtilities addDashedBorderToView:self.imageButton
                                                                 withColor:[UIColor flatWhiteColor].CGColor]];
    [self.textButton.layer addSublayer:[CLUtilities addDashedBorderToView:self.textButton
                                                                withColor:[UIColor flatWhiteColor].CGColor]];
    [self.voiceButton.layer addSublayer:[CLUtilities addDashedBorderToView:self.voiceButton
                                                                withColor:[UIColor flatWhiteColor].CGColor]];
}

@end
