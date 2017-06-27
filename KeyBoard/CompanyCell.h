//
//  CompanyCell.h
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/20.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompanyCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property(nonatomic,assign)NSInteger companyId;
@end
