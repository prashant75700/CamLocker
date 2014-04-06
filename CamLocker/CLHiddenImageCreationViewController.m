//
//  CLHiddenImageCreationViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLUtilities.h"
#import "CLMarkerManager.h"
#import "CLDataHandler.h"
#import "CLHiddenImageCreationViewController.h"
#import "SWSnapshotStackView.h"
#import "JDStatusBarNotification.h"
#import "ETActivityIndicatorView.h"
#import "UIColor+MLPFlatColors.h"
#import "SIAlertView.h"
#import "PhotoStackView.h"
#import "TSMessage.h"
#import "FBShimmeringView.h"
#import "ANBlurredImageView.h"
#import "URBMediaFocusViewController.h"
#import "MHNatGeoViewControllerTransition.h"
#import "CHTumblrMenuView.h"
#import "UIView+Genie.h"
#import <MessageUI/MessageUI.h>


@interface CLHiddenImageCreationViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoStackViewDataSource, PhotoStackViewDelegate, URBMediaFocusViewControllerDelegate, CHTumblrMenuViewDelegate, MFMessageComposeViewControllerDelegate> {
    BOOL isEncrypting;
    BOOL canExit;
}

@property (nonatomic) NSMutableArray *hiddenImages;
@property (nonatomic) NSMutableArray *photos;
@property (nonatomic) URBMediaFocusViewController *mediaFocusController;
@property (nonatomic) CHTumblrMenuView *menuView;

@property (weak, nonatomic) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet ANBlurredImageView *imageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet PhotoStackView *photoStack;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addMoreButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;

@end

@implementation CLHiddenImageCreationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.mediaFocusController = [[URBMediaFocusViewController alloc] init];
	self.mediaFocusController.delegate = self;
    
    [CLUtilities addBackgroundImageToView:self.masterView withImageName:@"bg_4.jpg"];
    
    canExit = NO;
    isEncrypting = NO;
    
    _hiddenImages = [[NSMutableArray alloc]init];
    _photos = [[NSMutableArray alloc]init];
    
    //_photoStack.center = CGPointMake(self.view.center.x, 170);
    _photoStack.dataSource = self;
    _photoStack.delegate = self;
    self.photoStack.hidden = YES;
    self.pageControl.hidden = YES;
    self.trashButton.enabled = NO;
    self.addMoreButton.enabled = NO;
    
    [_imageView setHidden:YES];
    [_imageView setFramesCount:8];
    [_imageView setBlurAmount:1];
    
    self.addImageButton.layer.cornerRadius = 15;
    if (!DEVICE_IS_4INCH_IPHONE) {
        self.addImageButton.frame = CGRectMake(50, 160, 220, 237);
    }
    [self.addImageButton.layer addSublayer:[CLUtilities addDashedBorderToView:self.addImageButton
                                                                    withColor:[UIColor flatWhiteColor].CGColor]];

}

- (IBAction)trashButtonPressed:(id)sender {
    
    self.photoStack.userInteractionEnabled = NO;
    self.addMoreButton.enabled = NO;
    self.doneButton.enabled = NO;
    
    if (self.photos.count == 1) {
        [UIView animateWithDuration:1.0f animations:^{
            self.pageControl.alpha = 0.0f;
        } completion:^(BOOL finished){
            self.pageControl.hidden = YES;
        }];
    }
    [[self.photoStack topPhoto] genieInTransitionWithDuration:0.7
                                              destinationRect:CGRectMake(135, self.view.frame.size.height - 40, 1, 1)
                                              destinationEdge:BCRectEdgeTop
                                                   completion:^{
                                                      
                                                       [self.photos removeObjectAtIndex:self.pageControl.currentPage];
                                                       [self.hiddenImages removeObjectAtIndex:self.pageControl.currentPage];

                                                       [self.photoStack reloadData];
                                                       
                                                       if (self.pageControl.currentPage == self.pageControl.numberOfPages - 1) {
                                                           self.pageControl.numberOfPages--;
                                                           self.pageControl.currentPage = 0;
                                                       } else {
                                                           self.pageControl.numberOfPages--;
                                                       }
                                                       
                                                       self.photoStack.userInteractionEnabled = YES;
                                                       self.addMoreButton.enabled = YES;
                                                       self.doneButton.enabled = YES;
                                                       
                                                       if (self.hiddenImages.count == 0) {
                                                           
                                                           self.photoStack.hidden = YES;
                                                           self.trashButton.enabled = NO;
                                                           self.addMoreButton.enabled = NO;
                                                           self.pageControl.alpha = 0.3f;
                                                           self.addImageButton.alpha = 0.0f;
                                                           self.addImageButton.hidden = NO;
                                                           
                                                           [UIView animateWithDuration:1.0f animations:^{
                                                               self.addImageButton.alpha = 0.5f;
                                                           } completion:nil];
                                                       }
                                                   }];

}

- (IBAction)addImageButtonPressed:(id)sender {
    
    if (isEncrypting) return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)addMoreButtonPressed:(id)sender {
    
    if (isEncrypting || self.hiddenImages.count == 0) return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:picker animated:YES completion:nil];
}


- (IBAction)doneButtonPressed:(id)sender {
    
    if (canExit) {
        [CLMarkerManager sharedManager].tempMarkerImage = nil;
        [self.navigationController dismissNatGeoViewController];
        self.navigationController.navigationBar.userInteractionEnabled = YES;
    }
    if (isEncrypting) return;
    if (self.photos.count == 0) {
        
        [TSMessage showNotificationInViewController:self title:@"Oops"
                                           subtitle:@"Please add some images!"
                                               type:TSMessageNotificationTypeError
                                           duration:1.5f
                               canBeDismissedByUser:YES];
        return;
    }
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Almost there" andMessage:@"Are you ready to create this marker?"];
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              
                              if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                                  self.navigationController.interactivePopGestureRecognizer.enabled = NO;
                              }
                              self.navigationController.navigationBar.userInteractionEnabled = NO;
                              self.trashButton.enabled = NO;
                              self.doneButton.enabled = NO;
                              self.addMoreButton.enabled = NO;
                              
                              isEncrypting = YES;
                              self.imageView.hidden = NO;
                              self.imageView.image = [CLUtilities snapshotViewForView:self.masterView];
                              self.imageView.baseImage = self.imageView.image;
                              
                              [self.imageView setBlurTintColor:[UIColor colorWithWhite:0.f alpha:0.5]];
                              [self.imageView generateBlurFramesWithCompletionBlock:^{
                                  
                                  [self.imageView blurInAnimationWithDuration:0.3f];
                                  
                                  self.photoStack.userInteractionEnabled = NO;
                                  ETActivityIndicatorView *etActivity = [[ETActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 30, self.view.frame.size.height/2 -30, 60, 60)];
                                  etActivity.color = [UIColor flatWhiteColor];
                                  [etActivity startAnimating];
                                  [self.view addSubview:etActivity];
                                  [JDStatusBarNotification showWithStatus:@"Encrypting Data..." styleName:JDStatusBarStyleError];
                                  
                                  [[CLMarkerManager sharedManager] addImageMarkerWithMarkerImage:[CLMarkerManager sharedManager].tempMarkerImage
                                                                                    hiddenImages:self.hiddenImages
                                                                             withCompletionBlock:^{
                                                                                 
                                                                                     [JDStatusBarNotification dismiss];
                                                                                     [self uploadMarker];
                                                                                     [etActivity removeFromSuperview];
                                                                             }];
                              }];

                              
    }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
    alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
    alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
    
    [alertView show];
}

- (void)uploadMarker
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Share" andMessage:@"Would you like to share this marker with your friends? You can upload it to our server and share it with your friends!"];
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                              [JDStatusBarNotification showWithStatus:@"New marker created!" dismissAfter:1.5f styleName:JDStatusBarStyleSuccess];
                              [CLMarkerManager sharedManager].tempMarkerImage = nil;
                              [self.navigationController dismissNatGeoViewController];
                              self.navigationController.navigationBar.userInteractionEnabled = YES;
                              
                          }];
    [alertView addButtonWithTitle:@"Upload"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              
                              ETActivityIndicatorView *etActivity = [[ETActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 30, self.view.frame.size.height/2 -30, 60, 60)];
                              etActivity.color = [UIColor flatWhiteColor];
                              [etActivity startAnimating];
                              [self.view addSubview:etActivity];
                              
                              [JDStatusBarNotification showWithStatus:@"Uploading marker..." styleName:JDStatusBarStyleError];
                              [CLDataHandler uploadMarker:[[CLMarkerManager sharedManager].markers lastObject]  completionBlock:^(CLDataHandlerOption option, NSURL *markerURL, NSError *error){
                                  
                                  [etActivity removeFromSuperview];
                                  [JDStatusBarNotification showWithStatus:@"Marker uploaded!" dismissAfter:1.5f styleName:JDStatusBarStyleSuccess];
                                  
                                  if (option == CLDataHandlerOptionSuccess) {
                                      
                                      NSLog(@"%@", markerURL);
                                  } else {
                                      NSLog(@"%@", error.localizedDescription);
                                  }
                                  
                                  [self showShareMenu:markerURL];
                              }];
                              
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
    alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
    alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
    
    [alertView show];
}

- (void)executeAnimation
{
    self.photoStack.userInteractionEnabled = NO;
    UIView *targetView =  [self.photoStack topPhoto];
    targetView.alpha = 0.0f;
    [UIView animateWithDuration:0.7f animations:^{
        targetView.alpha = 1.0f;
    } completion:^(BOOL finished){
        self.photoStack.userInteractionEnabled = YES;
    }];
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)tumblrMenuViewDidDismiss
{
    [CLMarkerManager sharedManager].tempMarkerImage = nil;
    [self.navigationController dismissNatGeoViewController];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

- (void)showShareMenu:(NSURL *)markerURL
{
    canExit = YES;
    self.doneButton.enabled = YES;
    
    NSString *downloadCode = [[[markerURL absoluteString] componentsSeparatedByString:@"/"] lastObject];
    
    self.menuView = [[CHTumblrMenuView alloc] init];
    self.menuView.delegate = self;
    self.menuView.backgroundImgView.image = self.imageView.image;
    
    __weak typeof(self) weakSelf = self;
    [self.menuView addMenuItemWithTitle:@"Text" andIcon:[UIImage imageNamed:@"post_type_bubble_text.png"] andSelectedBlock:^{
        NSLog(@"Text selected");
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            controller.body = [NSString stringWithFormat:@"I just created a marker using CamLocker App. The download code is: %@, check it out!", downloadCode];
            controller.messageComposeDelegate = weakSelf;
            [weakSelf presentViewController:controller animated:YES completion:nil];
        }
        
    }];
    [self.menuView addMenuItemWithTitle:@"Photo" andIcon:[UIImage imageNamed:@"post_type_bubble_photo.png"] andSelectedBlock:^{
        NSLog(@"Photo selected");
    }];
    [self.menuView addMenuItemWithTitle:@"Quote" andIcon:[UIImage imageNamed:@"post_type_bubble_quote.png"] andSelectedBlock:^{
        NSLog(@"Quote selected");
        
    }];
    [self.menuView addMenuItemWithTitle:@"Link" andIcon:[UIImage imageNamed:@"post_type_bubble_link.png"] andSelectedBlock:^{
        NSLog(@"Link selected");
        
    }];
    [self.menuView addMenuItemWithTitle:@"Chat" andIcon:[UIImage imageNamed:@"post_type_bubble_chat.png"] andSelectedBlock:^{
        NSLog(@"Chat selected");
        
    }];
    [self.menuView addMenuItemWithTitle:@"Video" andIcon:[UIImage imageNamed:@"post_type_bubble_video.png"] andSelectedBlock:^{
        NSLog(@"Video selected");
        
    }];
    
    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(20, 100, 280, 150)];
    UILabel *downloadCodeLabel = [[UILabel alloc] initWithFrame:shimmeringView.bounds];
    downloadCodeLabel.textAlignment = NSTextAlignmentCenter;
    downloadCodeLabel.font = [UIFont fontWithName:@"OpenSans" size:28];
    downloadCodeLabel.numberOfLines = 3;
    downloadCodeLabel.textColor = [UIColor flatWhiteColor];
    downloadCodeLabel.text = [@"Your CamLocker download code is:\n" stringByAppendingString:downloadCode];
    shimmeringView.contentView = downloadCodeLabel;
    shimmeringView.shimmering = YES;
    shimmeringView.alpha = 0.0f;
    [self.menuView addSubview:shimmeringView];
    
    [self.menuView showInView:self.imageView];
    
    [UIView animateWithDuration:0.7f animations:^{
        shimmeringView.alpha = 1.0f;
    }];
}


#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [self.hiddenImages insertObject:chosenImage atIndex:self.pageControl.currentPage];
    
    UIImage *croppedImage = [CLUtilities imageWithImage:chosenImage scaledToWidth:220 + arc4random() % 35];
    if (croppedImage.size.height > self.photoStack.frame.size.height) {
        croppedImage = [CLUtilities imageWithImage:croppedImage scaledToHeight:self.photoStack.frame.size.height - 10];
    }
    [self.photos insertObject:croppedImage atIndex:self.pageControl.currentPage];
    [self.photoStack reloadData];
     self.pageControl.numberOfPages = [self.photos count];
    // self.photoStack.alpha = 0.0f;
    self.photoStack.hidden = NO;
    self.pageControl.hidden = NO;
    self.addImageButton.hidden = YES;
    self.trashButton.enabled = YES;
    self.addMoreButton.enabled = YES;
    
    [self executeAnimation];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark -
#pragma mark Deck DataSource Protocol Methods

-(NSUInteger)numberOfPhotosInPhotoStackView:(PhotoStackView *)photoStack {
    return [self.photos count];
}

-(UIImage *)photoStackView:(PhotoStackView *)photoStack photoForIndex:(NSUInteger)index {
    return [self.photos objectAtIndex:index];
}



#pragma mark -
#pragma mark Deck Delegate Protocol Methods

-(void)photoStackView:(PhotoStackView *)photoStackView willStartMovingPhotoAtIndex:(NSUInteger)index {
    // User started moving a photo
}

-(void)photoStackView:(PhotoStackView *)photoStackView willFlickAwayPhotoFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    // User flicked the photo away, revealing the next one in the stack
}

-(void)photoStackView:(PhotoStackView *)photoStackView didRevealPhotoAtIndex:(NSUInteger)index {
    self.pageControl.currentPage = index;
}

-(void)photoStackView:(PhotoStackView *)photoStackView didSelectPhotoAtIndex:(NSUInteger)index {
    NSLog(@"selected %d", index);
    [self.mediaFocusController showImage:self.hiddenImages[index] fromView:photoStackView];
}


@end
