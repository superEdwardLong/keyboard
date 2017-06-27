//
//  OrderListView.m
//  SMRT Board V3
//
//  Created by john long on 2017/5/4.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "OrderListView.h"
@interface OrderListView()
@property(nonatomic,assign)int PageIndex;
@property(nonatomic,retain)BoardDB *db;
@end

@implementation OrderListView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        _db = [BoardDB new];
        
        _listData = [NSMutableArray array];
        CGFloat offsetX = (frame.size.width -260) /2;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 20.f;
        layout.minimumInteritemSpacing= 20.f;
        layout.itemSize = CGSizeMake(240, frame.size.height-20);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(10, offsetX, 10, offsetX);
        
        _ImageCollectionView = [[UICollectionView alloc]initWithFrame:frame collectionViewLayout:layout];
        [_ImageCollectionView registerClass:[OrderListCollectionItemCell class] forCellWithReuseIdentifier:@"ImageCell"];
        _ImageCollectionView.delegate = self;
        _ImageCollectionView.dataSource = self;
        _ImageCollectionView.hidden = YES;
        _ImageCollectionView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [self addSubview:_ImageCollectionView];
        
        
        _listView = [[UITableView alloc]initWithFrame:self.bounds];
        [_listView registerClass:[OrderListCell class] forCellReuseIdentifier:@"CELL"];
        
        
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
        _listView.editing = NO;
        _listView.tableFooterView =  [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_listView];
        
        _listView.mj_header.automaticallyChangeAlpha = YES;
        
        //下拉翻页
        _listView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            _PageIndex = 0;
            [self TurnPage:0];
        }];
        
        // 上拉刷新
        _listView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            _PageIndex++;
            [self TurnPage:_PageIndex];
        }];
        
        [_listView.mj_header beginRefreshing];
    }
    return self;
}

-(void)setIsImageModel:(BOOL)isImageModel{
    _isImageModel = isImageModel;
    if(isImageModel){
        _listView.hidden = YES;
        _ImageCollectionView.hidden = NO;
    }else{
        _listView.hidden = NO;
        _ImageCollectionView.hidden = YES;
    }
    
}

-(void)TurnPage:(int)page{
    if(page >0){
        int TargetPage =  (int)((_listData.count-1) / 50) + 1;
        if(TargetPage < page){
            _PageIndex = TargetPage;
            page = TargetPage;
        }
    }


    
    NSString *sql = [NSString stringWithFormat: @"SELECT * FROM MailList ORDER BY mail_create_time DESC LIMIT %d,50",page*50];
    NSMutableArray* items = [[BoardDB new] FindWithSql:sql
                          withReturnFields:@[@"mail_id",
                                             @"mail_order_id",//==============>1
                                             @"mail_create_time",
                                             @"mail_from_user",//==============>3
                                             @"mail_from_city",
                                             @"mail_to_user",//==============>5
                                             @"mail_to_city",
                                             @"mail_state",//==============>7
                                             @"mail_package_type",
                                             @"mail_package_price",//==============>9
                                             @"mail_from_phone",
                                             @"mail_from_province",//==============>11
                                             @"mail_from_address",
                                             @"mail_to_phone",//==============>13
                                             @"mail_to_province",
                                             @"mail_to_address",//==============>15
                                             @"mail_assign_time",
                                             @"mail_cancel_time",//==============>17
                                             @"mail_pay_model",
                                             @"mail_to_targetNumber"//==============>19
                                             ]];
    if(items.count >0){
        if(page == 0){
            _listData = items;
        }else{
            [_listData addObjectsFromArray:items];
        }
        
        
        [_listView reloadData];
        [_ImageCollectionView reloadData];
        
        [self CheckListData];
    }else{
        _PageIndex--;
    }
    
    [_listView.mj_header endRefreshing];
    [_listView.mj_footer endRefreshing];
}

-(void)CheckListData{
    if(_listData.count == 0){
        _btn_add = [UIButton buttonWithType:UIButtonTypeSystem];
        _btn_add.frame = CGRectMake(0, 0, self.bounds.size.width, 60);
        [_btn_add setTitle:[_db getMenuItemTitle:@"orderNone"] forState:UIControlStateNormal];
        _btn_add.titleLabel.font = [UIFont systemFontOfSize:15.f];
        [_btn_add setBackgroundColor:[UIColor colorWithWhite:.2 alpha:1]];
        [_btn_add setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:_btn_add];
        [_btn_add addTarget:self action:@selector(AddMailItem) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [_btn_add removeFromSuperview];
        _btn_add = nil;
    }
}

-(void)AddMailItem{
    if(self.delegate && [self.delegate respondsToSelector:@selector(orderListViewDidSelectedAddMailItem:)]){
        [self.delegate orderListViewDidSelectedAddMailItem:self];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_isImageModel == NO){
        return 120;
    }else{
        return MAX(180,tableView.frame.size.height/2);
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *cols = [_listData objectAtIndex:indexPath.row];
    
        OrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
        if(cell){
            
            cell.orderId = [cols[0] integerValue];
            cell.label_orderNo.text = [NSString stringWithFormat:@"%@:%@",[_db getPageItemTitle:@"orderNumber"],cols[1]];
            cell.label_makeOrderTime.text = [NSString stringWithFormat:@"%@:%@",[_db getPageItemTitle:@"orderCreateTime"],cols[2]];
            
            cell.label_sender_name.text = [cols[3] stringByReplacingOccurrencesOfString:@"，" withString:@""];
            cell.label_sender_city.text = cols[4];
            
            cell.label_recevie_name.text = [cols[5] stringByReplacingOccurrencesOfString:@"，" withString:@""];
            cell.label_receive_city.text = cols[6];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            switch ([cols[7]integerValue]) {
                case OrderStateUndetermined:{
                    cell.label_state.text = [_db getPageItemTitle:@"undefind"];
                    cell.label_desc.text = @"";
                    cell.image_qrcode.hidden = NO;
                }break;
                    
                case OrderStateWaitingReciive:{
                    cell.label_desc.text = @"";
                    cell.image_qrcode.hidden = NO;
                    cell.label_state.text = [_db getPageItemTitle:@"watting"];
                    cell.label_makeOrderTime.text = [NSString stringWithFormat:@"%@:%@",[_db getPageItemTitle:@"orderAssignTime"],cols[16]];
                }break;
                    
                case OrderStateCanceled:{
                    cell.image_qrcode.hidden = YES;
                    cell.label_state.text = [_db getPageItemTitle:@"cancel"];
                    cell.label_desc.text = [_db getPageItemTitle:@"cancel"];
                    cell.label_makeOrderTime.text = [NSString stringWithFormat:@"%@:%@",[_db getPageItemTitle:@"orderCancelTime"],cols[17]];
                    
                }break;
                    
                case OrderStateComplete:{
                    cell.label_state.text = [_db getPageItemTitle:@"done"];
                    cell.label_desc.text = [_db getPageItemTitle:@"orderComment"];
                    cell.image_qrcode.hidden = YES;
                    
                }break;
            }
            
        }
        return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *cols = [_listData objectAtIndex:indexPath.row];
    NSInteger orderId = [cols[0] integerValue];
    if(self.delegate && [self.delegate respondsToSelector:@selector(orderListView:didSelectedMailItem:)]){
        [self.delegate orderListView:self didSelectedMailItem:orderId];
    }
}

-(nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction * editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                           title:[_db getMenuItemTitle:@"edit"]
                                                                         handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(orderListView:didSelectedEditMailItem:)]){
            NSMutableArray *cols = [_listData objectAtIndex:indexPath.row];
            [self.delegate orderListView:self didSelectedEditMailItem:[cols[0] integerValue]];
        }
        
    }];
    editAction.backgroundColor = [UIColor orangeColor];
    
    UITableViewRowAction *removeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                            title:[_db getMenuItemTitle:@"del"]
                                                                          handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //从数据库删除
        NSMutableArray *cols = [_listData objectAtIndex:indexPath.row];
        [[BoardDB new] RemoveMailItem:[cols[0] integerValue]];
        //从 tableview 数据源中删除
        [_listData removeObjectAtIndex:indexPath.row];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        
        [self CheckListData];
    }];
    
    return @[editAction,removeAction];
    
}


#pragma mark collectionView delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _listData.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    OrderListCollectionItemCell *CELL = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    if(CELL){
        NSMutableArray *cols = [_listData objectAtIndex:indexPath.item];
        CELL.OrderData = cols;
    }
    return CELL;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *cols = [_listData objectAtIndex:indexPath.item];
    NSInteger orderId = [cols[0] integerValue];
    if(self.delegate && [self.delegate respondsToSelector:@selector(orderListView:didSelectedMailItem:)]){
        [self.delegate orderListView:self didSelectedMailItem:orderId];
    }
}
@end
