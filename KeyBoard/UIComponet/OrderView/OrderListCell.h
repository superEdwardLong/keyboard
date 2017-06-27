//
//  OrderListCell.h
//  SMRT Board V3
//
//  Created by john long on 2017/5/3.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image_qrcode;
@property (weak, nonatomic) IBOutlet UILabel *label_orderNo;
@property (weak, nonatomic) IBOutlet UILabel *label_makeOrderTime;
@property (weak, nonatomic) IBOutlet UILabel *label_sender_city;
@property (weak, nonatomic) IBOutlet UILabel *label_sender_name;
@property (weak, nonatomic) IBOutlet UILabel *label_receive_city;
@property (weak, nonatomic) IBOutlet UILabel *label_recevie_name;
@property (weak, nonatomic) IBOutlet UIView *col_2;
@property (weak, nonatomic) IBOutlet UILabel *label_state;
@property(nonatomic,assign)NSInteger orderId;
@property (weak, nonatomic) IBOutlet UILabel *label_desc;
@end
