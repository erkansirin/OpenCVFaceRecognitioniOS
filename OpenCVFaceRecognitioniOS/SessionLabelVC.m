//
//  SessionLabelVC.m
//  ThinkerFarmExample
//
//  Created by Erkan SIRIN on 17.12.2018.
//  Copyright © 2018 Erkan Sirin. All rights reserved.
//

#import "SessionLabelVC.h"

@interface SessionLabelVC ()

@end

@implementation SessionLabelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButtonEvent:(id)sender {
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}
- (IBAction)startSession:(id)sender {
    
    //sessionFileName =  self.sessionNameTextView.text;
}
@end
