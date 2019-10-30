//
//  TrainingSessionVC.h
//  ThinkerFarmExample
//
//  Created by Erkan SIRIN on 17.12.2018.
//  Copyright © 2018 Erkan Sirin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <mach/mach.h>
#import <ThinkerFarm/TFFaceRecognizerLive.h>
#import <ThinkerFarm/TFFaceTrainer.h>
#import "LibraryViewController.h"
#import "PersonCell.h"

#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/mach.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * _Nonnull const sessionFileName = @"trainedfaces_at.xml";

@interface TrainingSessionVC : UIViewController<TFFaceRecognizerLiveDelegate,LibraryViewControllerDelegate,TFFaceTrainerDelegate,UICollectionViewDataSource, UICollectionViewDelegate>{
  
}
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UITextField *memoryText;

@property (weak, nonatomic) IBOutlet TFFaceRecognizerLive *camView;
@property (weak, nonatomic) IBOutlet UIImageView *unRecognizedPerson;
@property (weak, nonatomic) IBOutlet UITextView *modelDataTextView;

@property (weak, nonatomic) IBOutlet UICollectionView *recognizedDataCollection;
- (IBAction)modelDataCloseButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *modelDataView;
- (IBAction)modelDataButton:(id)sender;
@end

NS_ASSUME_NONNULL_END
