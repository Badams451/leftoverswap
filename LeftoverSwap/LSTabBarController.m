//
//  LSTabBarController.m
//  LeftoverSwap
//
//  Created by Bryan Summersett on 8/17/13.
//  Copyright (c) 2013 LeftoverSwap. All rights reserved.
//

#import "LSTabBarController.h"
#import "LSLoginSignupViewController.h"
#import "LSLoginViewController.h"
#import "LSMapViewController.h"
#import "LSPostTabPlaceholderController.h"
#import "LSConversationSummaryViewController.h"
#import "LSMeViewController.h"
#import "PFObject+PrivateChannelName.h"
#import "LSConstants.h"
#import "LSSignupViewController.h"
#import "LSAppDelegate.h"

@interface LSTabBarController ()

@property (nonatomic) LSMapViewController *mapViewController;
@property (nonatomic) LSPostTabPlaceholderController *cameraController;
@property (nonatomic) UINavigationController *conversationNavigationController;
@property (nonatomic) LSConversationSummaryViewController *conversationSummaryController;

@end

@implementation LSTabBarController

@synthesize cameraController;
@synthesize conversationNavigationController;
@synthesize conversationSummaryController;

- (id)init
{
  self = [super init];
  if (self) {

    // It makes sense, right?
    self.delegate = self;

    self.mapViewController = [[LSMapViewController alloc] initWithNibName:nil bundle:nil];
    self.cameraController = [[LSPostTabPlaceholderController alloc] init];
    
    self.conversationSummaryController = [[LSConversationSummaryViewController alloc] init];
    self.conversationNavigationController = [[UINavigationController alloc] initWithRootViewController:self.conversationSummaryController];

    LSMeViewController *meController = [[LSMeViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *meNavigationController = [[UINavigationController alloc] initWithRootViewController:meController];

    self.viewControllers = @[self.mapViewController, self.cameraController, self.conversationNavigationController, meNavigationController];
  }
  return self;
}

#pragma mark - instance methods

- (void)selectConversations
{
  self.selectedViewController = self.conversationNavigationController;
}

-(void)presentSignInView:(BOOL)animated
{
  LSLoginSignupViewController *signInViewController = [[LSLoginSignupViewController alloc] initWithNibName:nil bundle:nil];
  signInViewController.delegate = self;
  [self presentViewController:signInViewController animated:animated completion:nil];
}

#pragma mark - LSLoginControllerDelegate

-(void)signupControllerDidFinish:(LSSignupViewController*)signupController
{
  [self loginDidFinish:signupController];
}

-(void)loginControllerDidFinish:(LSLoginViewController*)loginController
{
  [self loginDidFinish:loginController];
}

- (void)loginDidFinish:(UIViewController*)loginController
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLSUserLogInNotification object:nil userInfo:nil];
  });

  PFUser *user = [PFUser currentUser];
  [[PFInstallation currentInstallation] addUniqueObject:[user privateChannelName] forKey:kLSInstallationChannelsKey];
  [[PFInstallation currentInstallation] saveEventually];
  
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITabBarControllerDelegate

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)aViewController
{
  // Intercept tab event, and trigger its own modal UI instead
  if ([aViewController isKindOfClass:[LSPostTabPlaceholderController class]]) {
    UIImagePickerController *cameraPicker = [((LSPostTabPlaceholderController*)aViewController) imagePickerController];
    [self presentViewController:cameraPicker animated:YES completion:nil];
    return NO;
  }
  return YES;
}

#pragma mark - LSNewConversationDelegate

- (void)conversationController:(LSNewConversationViewController *)conversation didSendText:(NSString *)text forPost:(PFObject *)post
{
  // TODO: set conversation view controller w/ conversation summary controller
  // and present this to the end of a view.

  self.selectedViewController = self.conversationNavigationController;
  [self.conversationSummaryController addNewConversation:text forPost:post];

  self.presentedViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - LSPostDetailViewController

- (void)postDetailControllerDidContact:(LSPostDetailViewController *)postDetailController forPost:(PFObject*)post
{
  LSNewConversationViewController *conversationController = [[LSNewConversationViewController alloc] initWithPost:post];
  conversationController.conversationDelegate = self;
  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:conversationController];
  [postDetailController presentViewController:navigationController animated:YES completion:nil];
}

- (void)postDetailControllerDidMarkAsTaken:(LSPostDetailViewController *)postDetailController forPost:(PFObject *)post
{
}

@end
