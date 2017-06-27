//
//  OrderListView.h
//  SMRT Board V3
//
//  Created by john long on 2017/5/4.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
#import "BoardDB.h"
#import "OrderListCollectionItemCell.h"
#import "OrderListCell.h"
#import "ContactModel.h"

@protocol OrderListViewDelegate;
@interface OrderListView : UIView<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,retain)UITableView *listView;
@property(nonatomic,retain)UICollectionView *ImageCollectionView;

@property(nonatomic,retain)NSMutableArray *listData;
@property(nonatomic,assign)id<OrderListViewDelegate>delegate;
@property(nonatomic,retain)UIButton *btn_add;
@property(nonatomic,assign)BOOL isImageModel;

-(void)TurnPage:(int)page;
@end

@protocol OrderListViewDelegate <NSObject>
-(void)orderListViewDidSelectedAddMailItem:(OrderListView*)orderListView;
-(void)orderListView:(OrderListView*)orderListView didSelectedMailItem:(NSInteger)mailItemId;
-(void)orderListView:(OrderListView*)orderListView didSelectedEditMailItem:(NSInteger)mailItemId;
@end
