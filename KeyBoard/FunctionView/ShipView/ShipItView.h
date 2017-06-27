//
//  ShipItView.h
//  SMRT Keyborad
//
//  Created by BOT01 on 17/2/23.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactViewCell.h"
#import "BoardDB.h"
#import "AlertView.h"
#import "UILoadingView.h"

@protocol ShipItViewDelegate;

@interface ShipItView : UIView<UICollectionViewDelegate,UICollectionViewDataSource,ContactViewCellDelegate,AlertViewDelegate>
@property(nonatomic,strong)AlertView *alertView;
@property(nonatomic,strong)UILoadingView *loadingView;

@property (weak, nonatomic) IBOutlet UICollectionView *ContactListView;
@property (weak, nonatomic) IBOutlet UICollectionView *ServiceListView;

@property (weak, nonatomic) IBOutlet UIButton *ShipBtn;
@property (weak, nonatomic) IBOutlet UIButton *SwitchBtn;
@property (weak, nonatomic) IBOutlet UIButton *TokenBtn;


@property(nonatomic,assign)NSInteger C_CenterIndex; //寄件卡片索引
@property(nonatomic,assign)NSInteger C_ReceiveIndex;//收件卡片索引

@property(nonatomic,assign)NSInteger C_SelectedIndex;//选中的卡片索引，用于编辑
@property(nonatomic,assign)NSInteger S_SelectedIndex;//选中的服务商索引

@property(nonatomic,strong)NSArray *S_DataSource;
@property(nonatomic,strong)NSMutableArray *C_DataSource;

@property(nonatomic,assign)id<ShipItViewDelegate>delegate;
@end

@protocol ShipItViewDelegate <NSObject>
-(void)shipItView:(ShipItView*)shipItView didClickedTokenButton:(UIButton*)sender;
-(void)shipItView:(ShipItView *)shipItView willbeEditData:(ContactModel*)data;
@end
