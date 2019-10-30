//
//  ViewController.m
//  ThinkerFarmExample
//
//  Created by Erkan SIRIN on 28.11.2018.
//  Copyright © 2018 Erkan Sirin. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   //
    
   [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
 
}





-(void)performSegue
{
    [self performSegueWithIdentifier:@"LiveSession" sender:self];
}
- (IBAction)startSession:(id)sender {
}
@end
