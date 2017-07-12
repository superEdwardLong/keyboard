//
//  SimpleShiptView.h
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/22.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardDB.h"
#import "ContactModel.h"
#import "ContactViewCell2.h"
#import "SDAutoLayout.h"
#import "BOT3DOptionView.h"
#import "FlexButtonView2.h"
#import "AlertView.h"

@protocol SimpleShiptViewDelegate;
@interface SimpleShiptView : UIView

@property(nonatomic,assign)id<SimpleShiptViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIButton *MakeOrderButton;
@property (weak, nonatomic) IBOutlet UIButton *btn_QRCode;
@property (weak, nonatomic) IBOutlet UIButton *btn_Apointment;

@property (weak, nonatomic) IBOutlet UIView *row_sender;
@property (weak, nonatomic) IBOutlet UIView *row_receive;

@property (weak, nonatomic) IBOutlet UIView *label_sender;
@property (weak, nonatomic) IBOutlet UIView *label_receive;

@property(nonatomic,retain)BOT3DOptionView *senderList;
@property(nonatomic,retain)BOT3DOptionView *recevieList;
@property(nonatomic,retain)NSMutableArray *arr;


@property(nonatomic,retain)FlexButtonView2 *left_flex;
@property(nonatomic,retain)FlexButtonView2 *right_flex;
@property(nonatomic,retain)FlexButtonView2 *center_flex;

@property(nonatomic,copy)NSString *orderNumber;
@property(nonatomic,assign)NSInteger orderId;

-(void)SelectedReceiveItemAtId:(NSInteger)ReceiveId;
@end

@protocol SimpleShiptViewDelegate <NSObject>
-(void)simpleShiptViewAddressIsNull:(SimpleShiptView*)simpleShiptView;
@end
