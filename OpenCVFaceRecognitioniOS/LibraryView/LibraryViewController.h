//
//  LibraryViewController.h
//  PingDataScanningExample
//
//  Created by Erkan SIRIN on 6.09.2018.
//  Copyright © 2018 PingData. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerHeader.h"
#import <MobileCoreServices/UTCoreTypes.h>

@protocol LibraryViewControllerDelegate <NSObject>

- (void)didFinishSelectingImages:(NSArray *)images andType:(BOOL)trainType andPersonId:(NSString*)personId;
- (void)didFinishSelectingRecognitionImage:(UIImage *)image;

@end

@interface LibraryViewController : UIViewController<ELCImagePickerControllerDelegate>
- (IBAction)cancelButtonEvent:(id)sender;
- (IBAction)stitchButtonEvent:(id)sender;
- (IBAction)selectImagesButtonEvent:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *personIdTextField;



@property (weak, nonatomic) id <LibraryViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, copy) NSArray *selectedImages;
@end






