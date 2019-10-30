//
//  PersonCell.h
//  ThinkerFarmExample
//
//  Created by Erkan SIRIN on 17.12.2018.
//  Copyright © 2018 Erkan Sirin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PersonCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *personImage;
@property (weak, nonatomic) IBOutlet UILabel *personId;

@end

NS_ASSUME_NONNULL_END
