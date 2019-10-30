//
//  TrainingSessionVC.m
//  ThinkerFarmExample
//
//  Created by Erkan SIRIN on 17.12.2018.
//  Copyright © 2018 Erkan Sirin. All rights reserved.
//

#import "TrainingSessionVC.h"

@interface TrainingSessionVC ()

@end

@implementation TrainingSessionVC{
    
    //TFFaceTrainer * faceTrainer;
    int faceID;
    
    NSMutableArray * collectedData;
    
    NSString * memText;
    NSString * cpuText;
    
    processor_info_array_t cpuInfo, prevCpuInfo;
    mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
    unsigned numCPUs;
    NSTimer *updateTimer;
    NSLock *CPUUsageLock;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    collectedData = [[NSMutableArray alloc] init];
    self.recognizedDataCollection.dataSource = self;
    self.recognizedDataCollection.delegate = self;
    
    self.modelDataView.hidden = YES;
   

 
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *filePathStr = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"trainedfaces_at.xml"]];
    
    
    NSString *fileContent = [[NSString alloc] initWithContentsOfFile:filePathStr];
    
    NSLog(@"fileContent : %@",fileContent);
    
    //faceTrainer = [[TFFaceTrainer alloc] initWithTrainingMode:FaceTrainerWithLBPHFace];
    //faceTrainer.delegate = self;
    
    
    /*
     //Use for sending pretrained model to offlineFaceRecognizer
     
     NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
     NSString *filePathStr = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"trainedfaces_at.xml"]];
     std::string modelFilePath = std::string([filePathStr UTF8String]);
     */
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"faceID"] != nil) {
        
        faceID = [[[NSUserDefaults standardUserDefaults] valueForKey:@"faceID"] intValue];
        
    }
    
    
 
    
    int mib[2U] = { CTL_HW, HW_NCPU };
    size_t sizeOfNumCPUs = sizeof(numCPUs);
    int status = sysctl(mib, 2U, &numCPUs, &sizeOfNumCPUs, NULL, 0U);
    if(status)
        numCPUs = 1;
    
    CPUUsageLock = [[NSLock alloc] init];
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                    target:self
                                                  selector:@selector(updateInfo:)
                                                  userInfo:nil
                                                   repeats:YES];
    
    
    [self.camView startRecognitionWithMode:FaceRecognizerLiveWithLBPHFace];
           self.camView.delegate = self;
           [self.camView startCameraWithDevicePosition:BACK_CAMERA];
           
    
               
               // check if flashlight available
               Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
               if (captureDeviceClass != nil) {
                   AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                   if ([device hasTorch] && [device hasFlash]){
                       
                       [device lockForConfiguration:nil];
                     
                           [device setTorchMode:AVCaptureTorchModeOn];
                           [device setFlashMode:AVCaptureFlashModeOn];
                           //torchIsOn = YES; //define as a variable/property if you need to know status
                       
                       [device unlockForConfiguration];
                   }
                   
               }
           
    
    
}

- (IBAction)camButton:(id)sender {
    self.startButton.hidden = YES;
    UIButton * button = sender;
    if (button.tag == 0) {
        [self.camView startRecognitionWithMode:FaceRecognizerLiveWithLBPHFace];
        self.camView.delegate = self;
        [self.camView startCameraWithDevicePosition:BACK_CAMERA];
        
 
            
            // check if flashlight available
            Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
            if (captureDeviceClass != nil) {
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                if ([device hasTorch] && [device hasFlash]){
                    
                    [device lockForConfiguration:nil];
                  
                        [device setTorchMode:AVCaptureTorchModeOn];
                        [device setFlashMode:AVCaptureFlashModeOn];
                        //torchIsOn = YES; //define as a variable/property if you need to know status
                    
                    [device unlockForConfiguration];
                }
                
            }
        
        
    }else if (button.tag == 1) {
        // [self.camView startCamera:FRONT_CAMERA andMode:EigenFace];
    }else if (button.tag == 2) {
        // [self.camView startCamera:BACK_CAMERA andMode:LBPHFace];
    }else if (button.tag == 3) {
        /* [self.camView faceTrainingWithUIImage:[UIImage imageNamed:@"DSC_0630.jpeg"]];
         NSString *str=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"DSC_0630.jpeg"];
         
         UIImage*ima = [UIImage imageWithContentsOfFile:str];*/
        // [self.camView faceTrainingWithFilePath:@"DSC_0630.jpeg"];
        
        LibraryViewController* libraryViewController = [[LibraryViewController alloc] init];
        libraryViewController.delegate = self;
        [self presentViewController:libraryViewController animated:YES completion:^{
        }];
        
        
    }
    
}

-(void)didFinishColorizing:(UIImage *)resultImage{
    NSLog(@"finished colorizing :");
}

-(void)didFinishUnRecognized:(UIImage *)unknownPersonImage andFullFrame:(UIImage* )fullFrame isUpdate:(BOOL)isUpdate{
    self.unRecognizedPerson.image = unknownPersonImage;
    NSArray* trainingData = @[@{
                                  @"imageLabelId": [NSString stringWithFormat:@"%d",faceID+1],
                                  @"imageData": fullFrame
                                  }];
    [self.camView trainFaceWithImages:trainingData isUpdate:isUpdate];
    faceID ++;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",faceID] forKey:@"faceID"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


-(void)didFinishTrainingFace:(NSDictionary *)trainedData{
    NSLog(@"trainedData : ",trainedData);
    
    
   
    NSArray *serilizedData = trainedData[@"serializedtrainedData"];
    NSDictionary *faceData = [serilizedData objectAtIndex:0];
    NSString * faceID = faceData[@"serializedFaceId"];
    NSData * faceNSData = faceData[@"serializedFace"];
    UIImage * tmpImage = [UIImage imageWithData:faceNSData];
    
    NSMutableDictionary * finalData = [[NSMutableDictionary alloc] init];
    [finalData setObject:tmpImage forKey:@"faceDataImg"];
    [finalData setObject:faceID forKey:@"faceID"];
    
    [collectedData addObject:finalData];
    [self.recognizedDataCollection reloadData];
    
    [self.recognizedDataCollection scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:collectedData.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
   // [self updateMemCpu];
}
-(void)didFinishSelectingRecognitionImage:(UIImage *)image {
    
    
    //
    
}

-(void)didFinishRecognizingFace:(NSDictionary *)recognizerData
{
    
    
   
    NSString * faceID = [NSString stringWithFormat:@"%@",recognizerData[@"faceID"]];
    NSData * faceNSData = recognizerData[@"predictedImage"];
    UIImage * tmpImage = [UIImage imageWithData:faceNSData];
    
    NSMutableDictionary * finalData = [[NSMutableDictionary alloc] init];
    [finalData setObject:tmpImage forKey:@"faceDataImg"];
    [finalData setObject:faceID forKey:@"faceID"];
    
    BOOL faceIdFound = NO;
    int indexFound = 0;
    for (int i = 0; i < collectedData.count; i++){
        
        NSDictionary *mainData = [collectedData objectAtIndex:i];
        
        if (faceID == mainData[@"faceID"]){
            faceIdFound = YES;
            indexFound = i;
        }
        
        
    }
    
    if (!faceIdFound){
        [collectedData addObject:finalData];
        [self.recognizedDataCollection reloadData];
    }else{
        [self.recognizedDataCollection scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:indexFound inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
    
    
    
    NSLog(@"recognizerData : ",recognizerData);
    
    //[self updateMemCpu];
    
    
}


- (void)didFinishSelectingImages:(NSArray *)images andType:(BOOL)trainType andPersonId:(NSNumber*)personId{
    
    
    if (trainType == YES){
        
        NSMutableArray * imagesAndLabels = [[NSMutableArray alloc ] init];
        
        for (int i = 0; i < images.count; i++){
            
            NSMutableDictionary * imageAndLabel = [[NSMutableDictionary alloc] init];
            
            [imageAndLabel setObject:images[i] forKey:@"imageData"];
            [imageAndLabel setObject:personId forKey:@"imageLabelId"];
            [imagesAndLabels addObject:imageAndLabel];
        }
        // [faceTrainer trainFaceWithImages:imagesAndLabels];
        
    }else{
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *imageSubdirectory = [documentsDirectory stringByAppendingPathComponent:@"ThinkerFarmImages"];
        
        NSMutableArray * imagesAndLabels = [[NSMutableArray alloc ] init];
        
        for (int i = 0; i < images.count; i++){
            
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"trainImage%d.png",i]];
            NSData *imageData = UIImagePNGRepresentation(images[i]);
            [imageData writeToFile:filePath atomically:YES];
            UIImage * imageInData = [UIImage imageWithData:imageData];
            NSMutableDictionary * imageAndLabel = [[NSMutableDictionary alloc] init];
            
            UIImage * imageInPath = [UIImage imageWithContentsOfFile:filePath];
            
            [imageAndLabel setObject:filePath forKey:@"imagePath"];
            [imageAndLabel setObject:personId forKey:@"imageLabelId"];
            [imagesAndLabels addObject:imageAndLabel];
        }
        // [faceTrainer trainFaceWithFilePaths:imagesAndLabels];
    }
    
    
    
}

-(void) finishedTraining {
    NSLog(@"finished");
}

-(void)returnSerializedFaceData:(NSData *)serializedFaceData {
    //NSLog(@"serializedFaceData : %@",serializedFaceData);
}

- (IBAction)modelDataButton:(id)sender {
    self.modelDataView.hidden = NO;
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePathStr = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"trainedfaces_at.xml"]];
  
    NSString *fileContent = [[NSString alloc] initWithContentsOfFile:filePathStr];
    self.modelDataTextView.text = [NSString stringWithFormat:@"%@",fileContent];
    
    
}
- (IBAction)modelDataCloseButton:(id)sender {
    self.modelDataView.hidden = YES;
}




#pragma UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return collectedData.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PersonCell";
    PersonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // get the track
    NSDictionary *mainData = [collectedData objectAtIndex:indexPath.row];

    cell.personImage.image = mainData[@"faceDataImg"];
    cell.personId.text = mainData[@"faceID"];
    
    // populate the cell
    //cell.label.text = text;
    //cell.backgroundColor = [UIColor blueColor];
    // return the cell
    return cell;
}

#pragma UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   // NSString *selected = [self.tracks objectAtIndex:indexPath.row];
   // NSLog(@"selected=%@", selected);
}

-(void)updateInfo:(NSTimer *)timer{
    memText = report_memory();
    //cpuText = [self updateInfo];
    
    cpuText = [NSString stringWithFormat:@"%f",cpu_usage()];
    self.memoryText.text = [NSString stringWithFormat:@"Mem : %@mb - CPU :%% %@",memText,cpuText];
}


- (NSString*)updateInfox
{
    
    NSString* cpufinal;
    natural_t numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
    if(err == KERN_SUCCESS) {
        [CPUUsageLock lock];
        
        for(unsigned i = 0U; i < numCPUs; ++i) {
            float inUse, total;
            if(prevCpuInfo) {
                inUse = (
                         (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                         );
                total = inUse + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                total = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            
            NSLog(@"Core: %u Usage: %f",i,inUse / total);
            
            cpufinal = [NSString stringWithFormat:@"Core: %u Usage: %f",i,inUse / total];
        }
        [CPUUsageLock unlock];
        
        if(prevCpuInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
        }
        
        prevCpuInfo = cpuInfo;
        numPrevCpuInfo = numCpuInfo;
        
        cpuInfo = NULL;
        numCpuInfo = 0U;
    } else {
        NSLog(@"Error!");
        
    }
    
    return cpufinal;
}

- (NSString *)cputotalUsage
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS)
    {
        return @"NA";
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS)
    {
        return @"NA";
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_idle = 0;
    long tot_user = 0;
    long tot_kernel = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS)
        {
            return nil;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (basic_info_th->flags & TH_FLAGS_IDLE)
        {
            //This is idle
            tot_idle = tot_idle + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
        } else {
            //This is user
            tot_user = tot_user + basic_info_th->user_time.microseconds;
            
            //This is kernel
            tot_kernel = tot_kernel + basic_info_th->system_time.microseconds;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    long tot_cpu = tot_idle + tot_user + tot_kernel;
    
    return [NSString stringWithFormat:@"Idle: %.2ld, User: %.2ld, Kernel: %.2ld", tot_idle/(tot_cpu), (tot_user/tot_cpu), (tot_kernel/tot_cpu)];
}


float cpu_usage()
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < (int)thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}





NSString* report_memory(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in bytes): %lu", info.resident_size);
        NSLog(@"Memory in use (in MB): %f", ((CGFloat)info.resident_size / 1048576));
        
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
    
    return [NSString stringWithFormat:@"%f",((CGFloat)info.resident_size / 1048576)];
}
@end
