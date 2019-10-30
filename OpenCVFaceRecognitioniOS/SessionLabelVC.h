//
//  SessionLabelVC.h
//  ThinkerFarmExample
//
//  Created by Erkan SIRIN on 17.12.2018.
//  Copyright © 2018 Erkan Sirin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SessionLabelVC : UIViewController
- (IBAction)backButtonEvent:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *sessionNameTextView;
- (IBAction)startSession:(id)sender;

@end

NS_ASSUME_NONNULL_END
