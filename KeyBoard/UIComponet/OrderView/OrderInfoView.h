//
//  OrderInfoView.h
//  SMRT Board V3
//
//  Created by john long on 2017/5/3.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardDB.h"
@protocol OrderInfoViewDelegate;
@interface OrderInfoView : UIView<UITabBarDelegate>
@property(nonatomic,assign)NSInteger OrderId;
@property (weak, nonatomic) IBOutlet UILabel *label_sender_city;
@property (weak, nonatomic) IBOutlet UILabel *label_sender_name;
@property (weak, nonatomic) IBOutlet UILabel *label_infoTip;

@property (weak, nonatomic) IBOutlet UILabel *label_receive_city;
@property (weak, nonatomic) IBOutlet UILabel *label_receive_name;

@property (weak, nonatomic) IBOutlet UIImageView *qr_image;

@property (weak, nonatomic) IBOutlet UITabBar *tabbar;
@property (weak, nonatomic) IBOutlet UIView *col_2;

@property(nonatomic,assign)id<OrderInfoViewDelegate>delegate;

-(id)initWithFrame:(CGRect)frame withOrderId:(NSInteger)OrderId;
@end

@protocol OrderInfoViewDelegate <NSObject>

-(void)orderInfoView:(OrderInfoView*)orderInfoView didSelectTabbarItem:(NSInteger)itemTag;

@end
