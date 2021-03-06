//
//  LSSignupViewController.h
//  LeftoverSwap
//
//  Created by Bryan Summersett on 9/13/13.
//  Copyright (c) 2013 LeftoverSwap. All rights reserved.
//

//
//  PAWNewUserViewController.h
//  Anywall
//
//  Created by Christopher Bowns on 2/1/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSLoginSignupViewController.h"

@interface LSSignupViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UITextField *passwordAgainField;
@property (nonatomic, strong) IBOutlet UITextField *emailField;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@property (nonatomic, weak) id<LSLoginControllerDelegate> delegate;

@end
