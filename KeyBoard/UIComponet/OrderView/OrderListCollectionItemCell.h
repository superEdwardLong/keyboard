//
//  OrderListCollectionItemCell.h
//  SMRT Board V3
//
//  Created by john long on 2017/5/23.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderListCollectionItemCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImage;
@property (weak, nonatomic) IBOutlet UILabel *label_sender_city;
@property (weak, nonatomic) IBOutlet UILabel *label_sender_user;
@property (weak, nonatomic) IBOutlet UILabel *label_state;
@property (weak, nonatomic) IBOutlet UILabel *label_reveice_city;
@property (weak, nonatomic) IBOutlet UILabel *label_reveice_user;
@property (weak, nonatomic) IBOutlet UILabel *label_order_number;
@property (weak, nonatomic) IBOutlet UILabel *label_order_assing;
@property (weak, nonatomic) IBOutlet UIView *col_2;
@property (weak, nonatomic) IBOutlet UILabel *label_order_paymodel;
@property (weak, nonatomic) IBOutlet UILabel *label_order_insurance;

@property(nonatomic,retain) NSArray* OrderData;
@end
