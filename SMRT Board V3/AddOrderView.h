//
//  AddOrderView.h
//  SMRT Board V3
//
//  Created by john long on 2017/5/3.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDAutoLayout.h"
#import "BoardDB.h"
#import "ContactModel.h"
#import "UILoadingView.h"

@protocol  AddOrderViewDelegate;
@interface AddOrderView : UIView
@property(nonatomic,assign)id<AddOrderViewDelegate>delegate;
@property(nonatomic,retain)ContactModel *senderAddress;
@property(nonatomic,retain)ContactModel *receiveAddress;

-(void)setAddressWithSender:(ContactModel*)sender withReceive:(ContactModel*)receive;
@end

@protocol  AddOrderViewDelegate <NSObject>
-(void)addOrderViewdidOpenAddressBook;
-(void)addOrderView:(AddOrderView*)addOrderView didSaveData:(NSInteger)updateId;
@end
