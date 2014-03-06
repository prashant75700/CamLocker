//
//  CLTextViewController.h
//  CamLocker
//
//  Created by FlyinGeek on 3/4/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLTextViewControllerDelegate;

@interface CLTextViewController : UIViewController
@property (nonatomic, weak) id<CLTextViewControllerDelegate> delegate;
@end

@protocol CLTextViewControllerDelegate <NSObject>

@required
- (void) dismissViewController;

@end