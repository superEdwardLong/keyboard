//
//  ContactList.h
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/20.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BoardDB.h"
#import "ContactViewCell.h"

@protocol ContactListDelegate;
@interface ContactList : UIView<UICollectionViewDelegate,UICollectionViewDataSource,ContactViewCellDelegate>{
    ContactModel*senderOBJ;
    ContactModel*receiveOBJ;
}
@property (weak, nonatomic) IBOutlet UINavigationBar *NavBar;
@property(nonatomic,assign)id<ContactListDelegate> delegate;
@property (weak, nonatomic) IBOutlet UINavigationItem *NavBarItems;
@property (weak, nonatomic) IBOutlet UICollectionView *ContactCollection;
@property(nonatomic,retain)NSMutableArray *ContactArr;
@end

@protocol ContactListDelegate <NSObject>
-(void)ContactListDidBack:(ContactList*)contactList;
-(void)ContactList:(ContactList *)contactList withSender:(ContactModel*)sender withReceive:(ContactModel*)receive;
@end
