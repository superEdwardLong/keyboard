//
//  ShipItView.m
//  SMRT Keyborad
//
//  Created by BOT01 on 17/2/23.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//
#define markViewTag 202

#import "ShipItView.h"

@implementation ShipItView
@synthesize S_DataSource = _S_DataSource;
@synthesize C_DataSource = _C_DataSource;
@synthesize ContactListView = _ContactListView;
@synthesize ServiceListView = _ServiceListView;

@synthesize C_CenterIndex = _C_CenterIndex;
@synthesize C_ReceiveIndex = _C_ReceiveIndex;

@synthesize S_SelectedIndex = _S_SelectedIndex;
@synthesize C_SelectedIndex = _C_SelectedIndex;

@synthesize alertView;
@synthesize loadingView;

-(id)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"ShipItView" owner:self options:nil] lastObject];
    if(self){
        self.frame = frame;
        [_ContactListView registerClass:[ContactViewCell class] forCellWithReuseIdentifier:@"CCELL"];
        _ContactListView.delegate = self;
        _ContactListView.dataSource = self;
        
        [_ServiceListView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"SCELL"];
        _ServiceListView.delegate = self;
        _ServiceListView.dataSource = self;
        
        CALayer *lineLayer = [CALayer layer];
        lineLayer.frame = CGRectMake(0, frame.size.height - 224, frame.size.width, 1);
        lineLayer.backgroundColor = [[UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1]CGColor];
        [self.layer addSublayer:lineLayer];
        
        //注册一个数据变化监控
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didContactDataSourceChanged:) name:@"didContactDataSourceChanged" object:nil];
    }
    return self;
}

-(void)didContactDataSourceChanged:(NSNotification*)sender{
    ContactModel *itemdb = [sender object];
    for(NSInteger i=0; i< _C_DataSource.count;i++){
        if(itemdb.contactId == [_C_DataSource[i] contactId]){
            [_C_DataSource removeObjectAtIndex:i];
            [_ContactListView reloadData];
            break;
        }
    }
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if([collectionView isEqual:_ServiceListView]){
        return [_S_DataSource count];
    }else{
        return [_C_DataSource count];
    }
}

-(void)setC_DataSource:(NSMutableArray *)C_DataSource{
    _C_DataSource = C_DataSource;
    [_ContactListView reloadData];
}

-(void)setS_DataSource:(NSArray *)S_DataSource{
    _S_DataSource = S_DataSource;
    [_ServiceListView reloadData];
}

-(void)hideLoading{
    [loadingView removeFromSuperview];
    loadingView = nil;
}
-(void)showFeedback{
    loadingView.text = @"Ship it Success";
    loadingView.loading.hidden = YES;
    [UIView animateWithDuration:.4 animations:^{
        loadingView.frame = CGRectMake(self.bounds.size.width*.2, self.center.y-22, self.bounds.size.width*.6, 44);
    }];
    
    [self performSelector:@selector(hideLoading) withObject:nil afterDelay:2.4f];
}

-(void)showTips:(NSString*)msg{
    if(loadingView == nil){
        loadingView = [[UILoadingView alloc]initWithFrame:CGRectMake(self.bounds.size.width*.15, self.center.y-22, self.bounds.size.width*.7, 44) withText:msg];
    }else{
        loadingView.text = msg;
    }
    loadingView.loading.hidden = YES;
    
    [self addSubview:loadingView];
    [self performSelector:@selector(hideLoading) withObject:nil afterDelay:2.f];
}

- (IBAction)buttonAction:(UIButton *)sender {
    if([sender isEqual:_ShipBtn]){
        //获取:快递公司[_S_SelectedIndex]，寄件人信息，收件人信息
        if(_S_SelectedIndex == 0){
            [self showTips:@"please selected Service provider"];
            return;
        }
        
        if(_C_CenterIndex == 0){
            [self showTips:@"please selected the sender"];
            return;
        }
        
        if(_C_ReceiveIndex == 0){
            [self showTips:@"please selected the recipient"];
            return;
        }
        
    
        if(loadingView == nil){
            loadingView = [[UILoadingView alloc]initWithFrame:CGRectMake(self.bounds.size.width/2-45, self.bounds.size.height/2-45, 90, 90) withText:nil];
            [self addSubview:loadingView];
            [self performSelector:@selector(showFeedback) withObject:nil afterDelay:2.f];
        }
        
    }else if([sender isEqual:_SwitchBtn]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"showFunctionView" object:[NSNumber numberWithBool:_SwitchBtn.selected]];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"showKeyboard" object:[NSNumber numberWithBool:YES]];
        
    }else if([sender isEqual:_TokenBtn]){
        if(self.delegate && [self.delegate respondsToSelector:@selector(shipItView:didClickedTokenButton:)]){
            [self.delegate shipItView:self didClickedTokenButton:sender];
        }
    }
}


-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if([collectionView isEqual:_ServiceListView]){
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SCELL" forIndexPath:indexPath];
        UIImageView *imageItem;
        UIView *markView;
        for(UIView *view in cell.contentView.subviews){
            if(view.tag == markViewTag){
                markView = view;
            }
        }
        for(UIView *view in cell.contentView.subviews){
            if([view isKindOfClass:[UIImageView class]]){
                imageItem = (UIImageView*)view;
                break;
            }
        }
        
        if(imageItem == nil){
            imageItem = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
            imageItem.layer.cornerRadius = 20.f;
            imageItem.clipsToBounds = YES;
            [cell.contentView addSubview:imageItem];
        
        }
        
        if(markView == nil){
            markView = [[UIView alloc]initWithFrame:CGRectMake(10, cell.bounds.size.height - 3, 40, 3)];
            markView.backgroundColor = [UIColor orangeColor];
            markView.layer.cornerRadius = 1.5f;
            markView.clipsToBounds = YES;
            markView.tag = markViewTag;
            [cell.contentView addSubview:markView];
        }
        
        NSString *imageName = [_S_DataSource objectAtIndex:indexPath.item];
        imageItem.image = [UIImage imageNamed:[NSString stringWithFormat:@"source.bundle/%@.png",imageName]];
        
        if(_S_SelectedIndex == indexPath.item+1){
            markView.hidden = NO; //展示
        }else{
            markView.hidden = YES;//隐藏
        }
        return cell;
        
    }else{
        ContactModel *itemdb = [_C_DataSource objectAtIndex:indexPath.item];
        ContactViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CCELL" forIndexPath:indexPath];
        cell.CellIndex = indexPath.item;
        cell.delegate = self;
        cell.NameLabel.text = itemdb.strName;
        cell.PohoneLabel.text = itemdb.strPhone;
        cell.ProvinceLabel.text = itemdb.strProv;
        cell.CityLabel.text = itemdb.strCity;
        cell.AddressLabel.text = itemdb.strAddress;
        cell.CellState = itemdb.state;
        return cell;
    }
    
}

//选中
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if([collectionView isEqual:_ContactListView]) return;
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    for(UIView *view in cell.contentView.subviews){
        if(view.tag == markViewTag){
            view.hidden = NO;
            break;
        }
    }
    _S_SelectedIndex = indexPath.item+1;
}

//放弃选中
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if([collectionView isEqual:_ContactListView]) return;
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    for(UIView *view in cell.contentView.subviews){
        if(view.tag == markViewTag){
            view.hidden = YES;
            break;
        }
    }
}


#pragma mark ContactViewCell delegate
-(void)ContactViewCellDidClickedEditButton:(NSInteger)index{
    _C_SelectedIndex = index;
    if(self.delegate && [self.delegate respondsToSelector:@selector(shipItView:willbeEditData:)]){
        ContactModel *itemdb = [_C_DataSource objectAtIndex:index];
        [self.delegate shipItView:self willbeEditData:itemdb];
    }
}

-(void)ContactViewCellDidClickedRemoveButton:(NSInteger)index{
    _C_SelectedIndex = index;
    if(alertView == nil){
        alertView = [[AlertView alloc]initWithFrame:self.bounds
                                                 withMsg:@"Are you sure?"
                                             withOkTitle:nil
                                         withCancelTitle:nil];
        alertView.delegate = self;
        [self addSubview:alertView];
    }
}

-(void)ContactViewCellDidClickedReciepientButton:(NSInteger)index{
    _C_ReceiveIndex = index+1;
    //如果寄件人 与 收件人 为同一人。 撤销寄件人
    if(_C_CenterIndex == _C_ReceiveIndex) _C_CenterIndex = 0;
    for(NSInteger i=0; i< _C_DataSource.count;i++){
        ContactModel *itemdb = [_C_DataSource objectAtIndex:i];
        if(index == i){
            itemdb.state = 2;
        }else{
            if(itemdb.state == 2){
                itemdb.state = 0;
            }
        }
    }
    [_ContactListView reloadData];
}

-(void)ContactViewCellDidClickedSenderButton:(NSInteger)index{
    _C_CenterIndex = index+1;
    
    //如果寄件人 与 收件人 为同一人。 撤销收件人
    if(_C_CenterIndex == _C_ReceiveIndex) _C_ReceiveIndex = 0;
    
    for(NSInteger i=0; i< _C_DataSource.count;i++){
        ContactModel *itemdb = [_C_DataSource objectAtIndex:i];
        if(index == i){
            itemdb.state = 1;
        }else{
            if(itemdb.state == 1){
                itemdb.state = 0;
            }
        }
    }
    [_ContactListView reloadData];    
    
}




#pragma mark alertView delegate
-(void)alertViewDidClickedCancel{
    alertView = nil;
}
-(void)alertViewDidClickedOk{
    ContactModel *itemdb = [_C_DataSource objectAtIndex:_C_SelectedIndex];
    BoardDB *db = [BoardDB new];
    [db RemoveContactWithId:itemdb.contactId];
    
    [_C_DataSource removeObjectAtIndex:_C_SelectedIndex];
    [_ContactListView reloadData];
    
    alertView = nil;
}
@end
