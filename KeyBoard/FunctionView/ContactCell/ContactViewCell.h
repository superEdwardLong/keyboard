//
//  ContactViewCell.h
//  SMRT Keyborad
//
//  Created by BOT01 on 17/2/22.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ContactViewCellDelegate;
@interface ContactViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *PohoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *ProvinceLabel;
@property (weak, nonatomic) IBOutlet UILabel *CityLabel;
@property (weak, nonatomic) IBOutlet UILabel *AddressLabel;
@property (weak, nonatomic) IBOutlet UIButton *btn_edit;


//@property (weak, nonatomic) IBOutlet UIButton *SenderBtn;
//@property (weak, nonatomic) IBOutlet UIButton *ReciepientBtn;
//@property (weak, nonatomic) IBOutlet UIButton *DelBtn;
//@property (weak, nonatomic) IBOutlet UIButton *EditBtn;

@property(nonatomic,assign)NSInteger CellIndex;
@property(nonatomic,assign)NSInteger CellState;//0:none 1:center 2:reciepient

@property(nonatomic,assign)id<ContactViewCellDelegate>delegate;
@end

@protocol ContactViewCellDelegate <NSObject>
@optional
-(void)ContactViewCell:(ContactViewCell*)cell didClickedEditButton:(UIButton*)sender withItemIndex:(NSInteger)index;
//-(void)ContactViewCellDidClickedRemoveButton:(NSInteger)index;
//-(void)ContactViewCellDidClickedSenderButton:(NSInteger)index;
//-(void)ContactViewCellDidClickedReciepientButton:(NSInteger)index;
@end
