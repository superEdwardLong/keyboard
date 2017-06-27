//
//  OrderCallView.h
//  SMRT Board V3
//
//  Created by john long on 2017/5/3.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "BoardDB.h"
@protocol OrderCallViewDelegate;
@interface OrderCallView : UIView<UITabBarDelegate>
@property(nonatomic,assign)id<OrderCallViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UITabBar *tabbar;
@property (weak, nonatomic) IBOutlet UIButton *btn_edit;

@property (weak, nonatomic) IBOutlet UILabel *label_sender_city;
@property (weak, nonatomic) IBOutlet UILabel *label_sender_name;

@property (weak, nonatomic) IBOutlet UILabel *label_receive_city;
@property (weak, nonatomic) IBOutlet UILabel *label_receive_name;

@property (weak, nonatomic) IBOutlet UIImageView *img_face;

@property (weak, nonatomic) IBOutlet UIView *col_2;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imgTimers;
@property (weak, nonatomic) IBOutlet UILabel *label_start;

@property (weak, nonatomic) IBOutlet UILabel *label_assign;
@property(nonatomic,assign)NSInteger OrderId;
-(id)initWithFrame:(CGRect)frame withOrderId:(NSInteger)OrderId;

-(UIImage*)makeQRCodeImage;
@end

@protocol OrderCallViewDelegate <NSObject>

-(void)orderCallView:(OrderCallView*)orderCallView didSelectedTabItem:(NSInteger)itemId;
-(void)orderCallView:(OrderCallView*)orderCallView didClickedEdit:(UIButton*)sender;
@end
