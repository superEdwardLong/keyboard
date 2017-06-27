//
//  ContactList.m
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/20.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "ContactList.h"

@implementation ContactList

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"ContactList" owner:self options:nil]lastObject];
    if(self){
        self.frame = frame;
        BoardDB *db = [BoardDB new];
        _ContactArr = [db FindContactsWithFilter:nil];
        
        
        
        self.NavBar.barTintColor = [UIColor colorWithWhite:.9 alpha:1];
        
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        backBtn.frame = CGRectMake(0, 0, 46, 30);
        [backBtn setTitle:@"Back" forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(didCancel) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
        self.NavBarItems.leftBarButtonItem = leftItem;
        
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        doneBtn.frame = CGRectMake(0, 0, 46, 30);
        [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(didDone) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
        self.NavBarItems.rightBarButtonItem = rightItem;
        
        [_ContactCollection registerClass:[ContactViewCell class] forCellWithReuseIdentifier:@"CELL"];
        _ContactCollection.delegate = self;
        _ContactCollection.dataSource = self;
    }
    return self;
}

-(void)didCancel{
    if(self.delegate && [self.delegate respondsToSelector:@selector(ContactListDidBack:)]){
        [self.delegate ContactListDidBack:self];
    }
}
-(void)didDone{
    if((senderOBJ || receiveOBJ) && self.delegate && [self.delegate respondsToSelector:@selector(ContactList:withSender:withReceive:)]){
        [self.delegate ContactList:self withSender:senderOBJ withReceive:receiveOBJ];
    }else{
        [self.delegate ContactListDidBack:self];
    }
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _ContactArr.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ContactViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    if(cell){
        ContactModel *itemdb = [_ContactArr objectAtIndex:indexPath.item];
        cell.CellIndex = indexPath.item;
        cell.NameLabel.text = itemdb.strName;
        cell.PohoneLabel.text = itemdb.strPhone;
        cell.ProvinceLabel.text = itemdb.strProv;
        cell.CityLabel.text = itemdb.strCity;
        cell.AddressLabel.text = itemdb.strAddress;
        cell.CellState = itemdb.state;
        cell.delegate = self;
    }
    
    return cell;
}

-(void)ContactViewCellDidClickedReciepientButton:(NSInteger)index{
    //如果寄件人 与 收件人 为同一人。 撤销寄件人
    if( (senderOBJ && receiveOBJ) && senderOBJ.contactId == receiveOBJ.contactId){
        senderOBJ = nil;
    }else{
        receiveOBJ = [_ContactArr objectAtIndex:index];
    }
    
    for(NSInteger i=0; i< _ContactArr.count;i++){
        ContactModel *itemdb = [_ContactArr objectAtIndex:i];
        if(index == i){
            itemdb.state = 2;
        }else{
            if(itemdb.state == 2){
                itemdb.state = 0;
            }
        }
    }
    [_ContactCollection reloadData];
}

-(void)ContactViewCellDidClickedSenderButton:(NSInteger)index{
    if( (senderOBJ && receiveOBJ) && senderOBJ.contactId == receiveOBJ.contactId){
        receiveOBJ = nil;
    }else{
        senderOBJ = [_ContactArr objectAtIndex:index];
    }
    
    //如果寄件人 与 收件人 为同一人。 撤销收件人
    for(NSInteger i=0; i< _ContactArr.count;i++){
        ContactModel *itemdb = [_ContactArr objectAtIndex:i];
        if(index == i){
            itemdb.state = 1;
        }else{
            if(itemdb.state == 1){
                itemdb.state = 0;
            }
        }
    }
    [_ContactCollection reloadData];
    
}
@end
