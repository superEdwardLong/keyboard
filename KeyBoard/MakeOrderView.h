//
//  MakeOrderView.h
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/20.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CompanyCell.h"
#import "ContactList.h"

@interface MakeOrderView : UIView<UIWebViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,ContactListDelegate>{
    ContactList *contactListView;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property(nonatomic,retain)NSArray *colsArr;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionBar;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UINavigationBar *NavBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *NavBarItems;

-(void)ShowContactList;
//当前选中单元格
@property(nonatomic,assign)NSInteger CurrentSelectedIndex;
@end

