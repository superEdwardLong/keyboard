//
//  OrderListImageCell.h
//  SMRT Board V3
//
//  Created by BOT01 on 2017/5/10.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderListImageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImage;
@property(nonatomic,retain) NSArray *QRCodeDatas;
@property (weak, nonatomic) IBOutlet UILabel *label_from;
@property (weak, nonatomic) IBOutlet UILabel *label_to;
@end
