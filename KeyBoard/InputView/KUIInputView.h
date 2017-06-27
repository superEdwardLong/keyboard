//
//  KUIInputView.h
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/22.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//


#import <UIKit/UIKit.h>
//自动布局类
#import "SDAutoLayout.h"
//提示弹窗类
#import "AlertView.h"
//LOADING 视图
#import "UILoadingView.h"
//简单视图
#import "SimpleShiptView.h"
//扩展文字输入类
#import "KUITextView.h"
//模拟放大镜
#import "KMagnifierView.h"
//弹出菜单
#import "LrdOutputView.h"

//对象转JSON
#import "PrintObject.h"

//主控制器
#import "KeyboardViewController.h"


typedef NS_ENUM(NSInteger ,WorkModel) {
    WorkModelNormal = 0, //普通模式
    WorkModelAdd = 1,    //新增模式
    WorkModelModify = 2  //修改模式
};

typedef NS_ENUM(NSInteger,OrderViewModel) {
    OrderViewModelList = 0,
    OrderViewModelAdd = 1,
    OrderViewModelInfo = 2,
    OrderViewModelService = 3
};

@interface KUIInputView : UIView<BOT3DOptionViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *option_button;
@property (weak, nonatomic) IBOutlet UIButton *swtich_button;

@property(nonatomic,assign)WorkModel CurrentWorkModel;

@property(nonatomic,assign)KeyboardViewController *superController;
@property (weak, nonatomic) IBOutlet UIView *ContactListView;

@property (weak, nonatomic) IBOutlet UIView *ToolbarView;
@property (weak, nonatomic) IBOutlet UIView *FlexBox_1;
@property (weak, nonatomic) IBOutlet UIView *FlexBox_2;
@property (weak, nonatomic) IBOutlet UIView *FlexBox_3;

@property (weak, nonatomic) IBOutlet UIView *InputContentView;
@property (weak, nonatomic) IBOutlet UIView *SwitchbarView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *InputViewOffsetTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FlexBoxWidth_1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FlexBoxWidth_2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FlexBoxWidth_3;

@property(nonatomic,retain)UICollectionView *WordOptionViewH;
@property(nonatomic,retain)UICollectionView *WordOptionView;

@property(nonatomic,retain)NSMutableArray *AddressBookData;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *FlexBoxWidthArr;

-(void)setSelectionTextMenuHide;
-(void)checkedFlexButtonStateDidKeyboardAppear;
@end
