//
//  KUIInputView.m
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/22.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//
//#define kURL_ORDER_LIST @"http://u2898.com/SFKeyboard/OrderList.html"
//#define kURL_ORDER_ADD @"http://u2898.com/SFKeyboard/AddOrder.html"
//#define KURL_ORDER_INFO @"http://u2898.com/SFKeyboard/OrderInfo.html"
//#define KURL_ORDER_POST @"http://u2898.com/SFKeyboard/api/AddSimpleOrder.php"

#include "FlexButtonView.h"
#import "KUIInputView.h"
#import "VerticalImageButton.h"

#import "OrderListView.h"
#import "OrderCallView.h"
#import "OrderInfoView.h"



@interface KUIInputView()<
UICollectionViewDelegate,UICollectionViewDataSource,
OrderListViewDelegate,OrderInfoViewDelegate,OrderCallViewDelegate,SimpleShiptViewDelegate,
FlexButtonViewDelegate,
AlertViewDelegate,
UIWebViewDelegate,
UITextViewDelegate,
KUITextViewDelegate,
LrdOutputViewDelegate>{
    CGPoint prevStartPoint;
    CGPoint prevEndPoint;
    CGPoint currentPoint;
    UILongPressGestureRecognizer *longPress;
    NSArray *menuDataArr;
    ContactModel *EditContactItem;
}
@property(nonatomic,retain)NSMutableArray *mySubViews;

@property(nonatomic,assign)NSInteger read_count;//记住我的选项


@property(nonatomic,retain)FlexButtonView* fbv_left;
@property(nonatomic,retain)FlexButtonView* fbv_right;
@property(nonatomic,retain)FlexButtonView* fbv_center;
@property(nonatomic,assign)FlexButtonView* current_fbv;

@property(nonatomic,retain)UILoadingView *LOADINGView;
@property(nonatomic,retain)AlertView *alertView;

//@property(nonatomic,strong)UIWebView *HTMLView;
//@property(nonatomic,retain)SimpleShiptView *simpleShiptView;

@property(nonatomic,strong)KUITextView *AddressTextView;
@property(nonatomic,strong)KMagnifierView *magnifierView;
@property(nonatomic,strong)LrdOutputView *menuOutputView;

@property(nonatomic,retain)BOT3DOptionView *AddressBookView;
@property(nonatomic,retain)UICollectionView *EditBookView;


@property(nonatomic,retain)BoardDB *db;

@property(nonatomic,assign)BOOL AddressBookIsEditModel;
@end

@implementation KUIInputView
@synthesize FlexBox_1 = _FlexBox_1;
@synthesize FlexBox_2 = _FlexBox_2;
@synthesize FlexBox_3 = _FlexBox_3;

@synthesize fbv_left = _fbv_left;
@synthesize fbv_right = _fbv_right;
@synthesize fbv_center = _fbv_center;

@synthesize current_fbv = _current_fbv;
@synthesize menuOutputView;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"KUIInputView" owner:self options:nil]lastObject];
    if(self){
        _db = [BoardDB new];
        //_FlexBoxWidth_1.constant = frame.size.width - _FlexBoxWidth_2.constant - _FlexBoxWidth_3.constant;
        
        _fbv_left = [self MakeFlexButtonView:@{@"title":[_db getMenuItemTitle:@"address"],@"image":@"icon-dizhibuxian",@"imageSelected":@"icon-dizhibumian"}
                             withButtonsInfo:@[@{@"title":[_db getMenuItemTitle:@"del"]},
                                               @{@"title":[_db getMenuItemTitle:@"add"]},
                                               @{@"title":[_db getMenuItemTitle:@"edit"]},
                                               @{@"title":[_db getMenuItemTitle:@"ai"],@"hide":@1}
                                               ]];
        
        _fbv_center = [self MakeFlexButtonView:@{@"title":[_db getMenuItemTitle:@"searchRecord"],@"image":@"icon-yundanliebiaoxian",@"imageSelected":@"icon-yundanliebiaomian"}
                               withButtonsInfo:@[
                                                 @{@"image":@"icon-chaxun"},
                                                 @{@"title":[_db getMenuItemTitle:@"img"]},
                                                 @{@"title":[_db getMenuItemTitle:@"edit"],@"hide":@1}
                                                 ]];
        
        _fbv_right = [self MakeFlexButtonView:@{@"title":[_db getMenuItemTitle:@"shipt"],@"image":@"icon-jikuaidixian",@"imageSelected":@"icon-jikuaidimian"}
                              withButtonsInfo:@[
                                                @{@"title":[_db getMenuItemTitle:@"adv"]},
                                                @{@"title":[_db getMenuItemTitle:@"edit"],@"hide":@1}
                                                ]];
        _fbv_left.componetMaxWidth =
        _fbv_right.componetMaxWidth =
        _fbv_center.componetMaxWidth = [self getMaxWidthInFlexButtonViews];
        
        _FlexBox_1.layer.cornerRadius =
        _FlexBox_2.layer.cornerRadius =
        _FlexBox_3.layer.cornerRadius = 3.f;
        
        _FlexBox_1.clipsToBounds =
        _FlexBox_2.clipsToBounds =
        _FlexBox_3.clipsToBounds = YES;
        
        [_FlexBox_1 addSubview:_fbv_left];
        [_FlexBox_2 addSubview:_fbv_center];
        [_FlexBox_3 addSubview:_fbv_right];
        
        _fbv_left.sd_layout
        .leftSpaceToView(_FlexBox_1, 0)
        .rightSpaceToView(_FlexBox_1, 0)
        .topSpaceToView(_FlexBox_1, 0)
        .bottomSpaceToView(_FlexBox_1, 0);
        
        
        _fbv_center.sd_layout
        .leftSpaceToView(_FlexBox_2, 0)
        .rightSpaceToView(_FlexBox_2, 0)
        .topSpaceToView(_FlexBox_2, 0)
        .bottomSpaceToView(_FlexBox_2, 0);
        
        _fbv_right.sd_layout
        .leftSpaceToView(_FlexBox_3, 0)
        .rightSpaceToView(_FlexBox_3, 0)
        .topSpaceToView(_FlexBox_3, 0)
        .bottomSpaceToView(_FlexBox_3, 0);
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ContactBeginEdit:) name:@"ContactBeginEdit" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ContactEndEdit:) name:@"ContactEndEdit" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DoShipt:) name:@"DoShipt" object:nil];
    }
    return self;
}

#pragma mark 模拟导航器
-(void)initNavigation{
    if(_mySubViews == nil){
        _mySubViews = [NSMutableArray array];
    }else{
        [self HiddenAddressTextView];
        [self setSelectionTextMenuHide];
        
        for(UIView *view in _mySubViews){
            [view removeFromSuperview];
        }
        
        [_mySubViews removeAllObjects];
        
        
    }
}
#pragma mark 模拟导航器 进盏
-(void)PushView:(UIView*)tagView{
    tagView.frame = _InputContentView.bounds;
     tagView.transform = CGAffineTransformMakeScale(.1, .1);
    [_InputContentView addSubview:tagView];
    [_mySubViews addObject:tagView];
    
    [UIView animateWithDuration:0.3 animations:^{
        tagView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark 模拟导航器 出盏
-(void)PopView{
    UIView*delView  =  [_mySubViews lastObject];
    [UIView animateWithDuration:0.3 animations:^{
        delView.transform = CGAffineTransformMakeScale(.1, .1);
    } completion:^(BOOL finished) {
        [delView removeFromSuperview];
        [_mySubViews removeLastObject];
        if([[_mySubViews lastObject] isKindOfClass:[OrderListView class]]){
            [self FlextButtonUpdate:_fbv_center forView:[_mySubViews lastObject]];
        }
    }];
}


-(void)DoShipt:(NSNotification*)sender{
    NSInteger contactId = [[sender object] integerValue];
    [self flexButtonView:_fbv_right didShowHiddenOnclick:_fbv_right.baseButton];
    [self performSelector:@selector(SimpleShiptViewSelectContactItemWithId:) withObject:[NSNumber numberWithInteger:contactId] afterDelay:0.8f];
}

-(void)SimpleShiptViewSelectContactItemWithId:(id)ContactId{
    SimpleShiptView * simpleShiptView = [_mySubViews lastObject];
    [simpleShiptView SelectedReceiveItemAtId:[ContactId integerValue]];
}

#pragma 更新约束
-(void)viewResize:(CGFloat)value
       completion:(void (^ __nullable)())resizeCompletion{
    self.InputViewOffsetTop.constant = value;
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2f animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        resizeCompletion();
    }];
}

- (IBAction)CallKeyboard:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(sender.selected == YES){
        
        
        
        //先关闭键盘
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CallKeyboard" object:[NSNumber numberWithInt:0]];
        
        //启动高级功能,更新布局
        [_superController viewResize:kFullHeight completion:^{
            self.InputContentView.hidden =
            self.ContactListView.hidden = NO;
            
            if(_current_fbv == nil){
                [self flexButtonView:_fbv_left didShowHiddenOnclick:_fbv_left.baseButton];
            }else{
                _current_fbv.baseButton.selected = NO;
                [self flexButtonView:_current_fbv didShowHiddenOnclick:_current_fbv.baseButton];
            }
            
        }];
        
    }else{
        //关闭高级功能
        self.InputContentView.hidden =
        self.ContactListView.hidden = YES;
        
        [_superController viewResize:kBoardViewHeight completion:^{
            [self viewResize:-227 completion:^{
                 [[NSNotificationCenter defaultCenter]postNotificationName:@"CallKeyboard" object:[NSNumber numberWithInt:1]];
            }];
        }];
    }
    
}

- (IBAction)CallWordOptionShow:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(sender.selected == YES){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CallKeyboard" object:@"ShowWordOption"];
    }else{
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CallKeyboard" object:@"HideWordOption"];
    }
    
}

-(void)RemoveLoadingView{
    [UIView animateWithDuration:0.2 animations:^{
        _LOADINGView.alpha = 0;
    } completion:^(BOOL finished) {
        [_LOADINGView removeFromSuperview];
        _LOADINGView = nil;
    }];
}
/*=======================================================
 
 baseInfo = @{
    title:_title
    image:_image
 }
 
======================================================= */
#pragma mark 创建功能分区
-(FlexButtonView*)MakeFlexButtonView:(NSDictionary*)baseInfo withButtonsInfo:(NSArray*)arr{
    
    
    NSString* baseTitle = [baseInfo objectForKey:@"title"];
    //NSString* baseImage = [baseInfo objectForKey:@"image"];
    //NSString* baseImageSelected = [baseInfo objectForKey:@"imageSelected"];
    
    
    UIButton *baseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [baseButton setTitle:baseTitle forState:UIControlStateNormal];
    [baseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];//默认黑色字体
    //[baseButton setTitleColor:[UIColor colorWithWhite:0 alpha:1] forState:UIControlStateSelected];//选中黑色字体
    [baseButton setBackgroundColor:[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1]];//默认按钮背景
    baseButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:500];
    baseButton.frame = CGRectMake(4, 4, 52, 31);
    baseButton.clipsToBounds = YES;
    baseButton.layer.cornerRadius = 4.f;
    
    
    /*
    if(baseTitle && baseImage){
        baseButton = [[VerticalImageButton alloc]initWithFrame:CGRectMake(4, 4, 42, 34)];
    }else{
        baseButton = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, 42, 34)];
    }
    if(baseImage){
        [baseButton setImage:[UIImage imageNamed:baseImage] forState:UIControlStateNormal];
    }
    if(baseTitle){
        [baseButton setTitle:baseTitle forState:UIControlStateNormal];
    }
    if(baseImageSelected){
        [baseButton setImage:[UIImage imageNamed:baseImageSelected] forState:UIControlStateSelected];
    }
    
    */
    
    NSMutableArray *btnArr = [NSMutableArray arrayWithCapacity:arr.count];
    for(NSDictionary* item in arr){
        UIButton *itemButton;
        NSString*btnTitle = [item objectForKey:@"title"];
        NSString*btnImage = [item objectForKey:@"image"];
        NSNumber *btnHide = [item objectForKey:@"hide"];
        
        
        if(btnTitle && btnImage){
            itemButton = [[VerticalImageButton alloc]initWithFrame:CGRectMake(0, 4, 42, 31)];
        }else{
            itemButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 4, 42, 31)];
        }
        
        
        if(btnImage){
            [itemButton setImage:[UIImage imageNamed:btnImage] forState:UIControlStateNormal];
        }
        
        if(btnTitle){
            [itemButton setTitle:btnTitle forState:UIControlStateNormal];
            
           CGRect titleRect = [btnTitle boundingRectWithSize:CGSizeMake(1000.f, 31)
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}
                                   context:nil];
            
            CGFloat avg_width =  ([self getMaxWidthInFlexButtonViews]-60) /4;
            itemButton.frame = CGRectMake(0, 4, MAX(titleRect.size.width+8,avg_width) , 31);
            
        }
        
        if(btnHide){
            [itemButton setHidden:[btnHide boolValue]];
        }
        
        
        //[itemButton setBackgroundColor:[UIColor colorWithRed:30/255.f green:30/255.f blue:30/255.f alpha:1]];
        [itemButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        itemButton.backgroundColor = [UIColor clearColor];
        itemButton.alpha = 0;
        itemButton.layer.cornerRadius = 6.f;
        itemButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [btnArr addObject:itemButton];
    }
    FlexButtonView *fbv = [[FlexButtonView alloc]initWithFrame:CGRectMake(0, 0, 60, 49) withBaseButton:baseButton withSubButtons:btnArr];
    fbv.delegate = self;
    return fbv;
}

#pragma mark FlexButtonView delegate
// 获取最大约束值
-(CGFloat)getMaxWidthInFlexButtonViews{
    CGFloat itemWidth = 0;
    CGFloat FullWidth = [[UIScreen mainScreen]bounds].size.width;
    itemWidth = FullWidth - (_FlexBoxWidthArr.count-1)* 60 - 26;//最左，最右 边8点间隔，中间有两个 5点间隔 8*2 + 5*2;
    return itemWidth;
}

// 更新约束集合
-(void)updateConstraintsWithFlexButtonView:(FlexButtonView*)flexButtonView{
    CGFloat maxWidth = [self getMaxWidthInFlexButtonViews];
    if([flexButtonView isEqual:_fbv_left] || flexButtonView == nil){
        _FlexBoxWidth_1.constant = maxWidth;
        _FlexBoxWidth_2.constant = 60;
        _FlexBoxWidth_3.constant = 60;

        
    }else if([flexButtonView isEqual:_fbv_right]){
        _FlexBoxWidth_1.constant = 60;
        _FlexBoxWidth_2.constant = 60;
        _FlexBoxWidth_3.constant = maxWidth;
    }else{
        _FlexBoxWidth_1.constant = 60;
        _FlexBoxWidth_2.constant = maxWidth;
        _FlexBoxWidth_3.constant = 60;

    }
    
    [_FlexBox_1 setNeedsUpdateConstraints];
    [_FlexBox_2 setNeedsUpdateConstraints];
    [_FlexBox_3 setNeedsUpdateConstraints];
    
    //更新滚动内容尺寸
    [flexButtonView updateButtonCollectionContentSize];
}

#pragma mark FLEX BUTTON 主按钮事件处理器
-(void)flexButtonView:(FlexButtonView *)flexButtonView didShowHiddenOnclick:(UIButton *)btn{
    if(![flexButtonView isEqual:_fbv_left] && _AddressBookIsEditModel == YES){
        UIView *parentView = [_superController view];
        
        _alertView = [[AlertView alloc]initWithFrame:parentView.bounds
                                             withMsg:[_db getAlertItemTitle:@"msgLeave"]
                                         withOkTitle:[_db getAlertItemTitle:@"btnTitleOk"]
                                     withCancelTitle:[_db getAlertItemTitle:@"btnTitleCancel"]];
        _alertView.Caller = flexButtonView;
        _alertView.delegate = self;
        [parentView addSubview:_alertView];
        
    }else{
        //如果选中的不是当前flexButtonView && 状态为隐藏
        if([flexButtonView isEqual:_current_fbv] == NO && btn.selected == NO){
            
            
            if(_current_fbv != nil){
                [_current_fbv btnHidden];
                _current_fbv.baseButton.selected = NO;
                _current_fbv.selected = NO;
            }
            
            
            //更新布局约束
            [self updateConstraintsWithFlexButtonView:flexButtonView];
            
            //执行显示操作
            btn.selected = YES;
            flexButtonView.selected = YES;
            [flexButtonView btnShow];
            
            //修改当前选中的flexButtonView
            _current_fbv = flexButtonView;
            
            
            //加载默认视图
            [self loadDefaultViewWithFlex];
        }else if([flexButtonView isEqual:_current_fbv] && btn.selected == NO){
            btn.selected = YES;
            flexButtonView.selected = YES;
            [self loadDefaultViewWithFlex];
        }
    }
}



#pragma mark FLEX BUTTON 子菜单处理器
-(void)flexButtonView:(FlexButtonView *)flexButtonView didOptionOnclick:(UIButton *)btn{
    
    if([flexButtonView isEqual:_fbv_left]){
        //左边区域  地址簿
        switch (btn.tag-100) {
            case 0:{
                //删除
                
                UIView *parentView = [_superController view];
                _alertView = [[AlertView alloc]initWithFrame:parentView.bounds
                                                     withMsg:[_db getAlertItemTitle:@"msgDel"]
                                                 withOkTitle:[_db getAlertItemTitle:@"bnTitleOk"]
                                             withCancelTitle:[_db getAlertItemTitle:@"btnTitleCancel"]];
                _alertView.Caller = _fbv_left;
                _alertView.delegate = self;
                
                [parentView addSubview:_alertView];
            }
                
                break;
            
            case 1:{
                
                if(_AddressTextView && _AddressTextView.text.length > 0){
                    [_AddressTextView selectAll:_AddressTextView];
                    [_AddressTextView  deleteBackward];
                    [_AddressTextView AddPlaceHolder];
                }
                [[NSNotificationCenter defaultCenter]postNotificationName:@"ContactBeginEdit" object:nil];

                //调出键盘
                [[NSNotificationCenter defaultCenter]postNotificationName:@"CallKeyboard" object:@1];
                
                
            }
                
                break;
                
            case 2:{
                //编辑
                ContactViewCell2* EditCell = (ContactViewCell2*)[_AddressBookView.groupView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_AddressBookView.selectItemIndex inSection:0]];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"ContactBeginEdit" object:EditCell];
                
            }break;
                
            case 3:{
                btn.selected = !btn.selected;
                if(btn.selected){
                    //[btn setBackgroundColor:[UIColor colorWithRed:204/255.f green:50/255.f blue:50/255.f alpha:1]];
                    //启动智能分词
                    [self MakeAddressTextView];
                    if(_AddressTextView.text.length > 0){
                        [_AddressTextView selectAll:_AddressTextView];
                        [_AddressTextView  deleteBackward];
                        [_AddressTextView AddPlaceHolder];
                    }
                     [[NSNotificationCenter defaultCenter]postNotificationName:@"CallKeyboard" object:@0];
                }else{
                    //[btn setBackgroundColor:[UIColor colorWithRed:30/255.f green:30/255.f blue:30/255.f alpha:1]];
                    //关闭智能分词
                    [self HiddenAddressTextView];
                    
                     [[NSNotificationCenter defaultCenter]postNotificationName:@"CallKeyboard" object:@1];
                }
            }
                
                break;
            case 4:{
                //取消
                [[NSNotificationCenter defaultCenter]postNotificationName:@"ContactEndEdit" object:nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"CallKeyboard" object:@1];
                [self HiddenAddressTextView];
                
            }break;
                
            case 5:{
                //清空
                ContactViewCell2*EditCell = (ContactViewCell2*)[_EditBookView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                [EditCell resetForm];
            }break;
                
                
            case 6:{
                //保存
                ContactViewCell2*EditCell = (ContactViewCell2*)[_EditBookView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"ContactEndEdit" object:EditCell];
                
            }break;
                
            default:{
                
            }
                break;
        }
        
    }else if([flexButtonView isEqual:_fbv_center]){
        
        switch (btn.tag-100){
            case 1:{
                //大图 或 列表
                
                OrderListView* targetView = [_mySubViews lastObject];
                NSString *imgMenuItemTitle = [_db getMenuItemTitle:@"img"];
                if([[btn titleForState:UIControlStateNormal] isEqualToString:imgMenuItemTitle]){
                    targetView.isImageModel = YES;
                    [btn setTitle:[_db getMenuItemTitle:@"list"] forState:UIControlStateNormal];
                }else{
                    targetView.isImageModel = NO;
                    [btn setTitle:imgMenuItemTitle forState:UIControlStateNormal];
                }
                [targetView TurnPage:0];
                
                
            }break;
                
                
            case 2:{
                //编辑
                
                NSInteger OrderId = 0;
                for(UIView *itemView in _mySubViews){
                    if([itemView isKindOfClass:[OrderInfoView class]]){
                        OrderId = ((OrderInfoView*)[_mySubViews lastObject]).OrderId;
                        break;
                    }
                    if([itemView isKindOfClass:[OrderCallView class]]){
                        OrderId = ((OrderCallView*)[_mySubViews lastObject]).OrderId;
                        break;
                    }
                }
                
                if(OrderId == 0) return;
                
                //调用编辑页面
                [self PushView:[self MakeSimpleShiptView]];
                [self performSelector:@selector(SimpleShiptViewRunEditModel:) withObject:@(OrderId) afterDelay:0.6f];
                
            }break;
                
            default:{
                //搜索
            }break;
        }
        
    }else{
        switch (btn.tag-100){
            case 1:{
                //编辑
                NSInteger OrderId = 0;
                for(UIView *itemView in _mySubViews){
                    if([itemView isKindOfClass:[OrderInfoView class]]){
                        OrderId = ((OrderInfoView*)[_mySubViews lastObject]).OrderId;
                        break;
                    }
                    if([itemView isKindOfClass:[OrderCallView class]]){
                        OrderId = ((OrderCallView*)[_mySubViews lastObject]).OrderId;
                        break;
                    }
                }
                
                if(OrderId == 0) return;
                //调用编辑页面
                [self PushView:[self MakeSimpleShiptView]];
                [self performSelector:@selector(SimpleShiptViewRunEditModel:) withObject:@(OrderId) afterDelay:0.6f];
                
            }break;
            default:{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"CallAppPage" object:@"CreateOrder"];
            }break;
        }
    }
}

-(void)SimpleShiptViewRunEditModel:(NSNumber*)sender{
    SimpleShiptView* simpleShiptView =  [_mySubViews lastObject];
    simpleShiptView.orderId = [sender integerValue];
    
}

-(void)checkedFlexButtonStateDidKeyboardAppear{
    if([_current_fbv isEqual:_fbv_left]){
        ((UIButton*)[_fbv_left.buttonArray lastObject]).selected = NO;
       // [((UIButton*)[_fbv_left.buttonArray lastObject])setBackgroundColor:[UIColor colorWithRed:30/255.f green:30/255.f blue:30/255.f alpha:1]];
    }
}

/*=======================================================
 
 寄件功能区 默认视图：简易模式
 
 =======================================================*/
-(SimpleShiptView*)MakeSimpleShiptView{
    SimpleShiptView* shiptView = [[SimpleShiptView alloc]initWithFrame:_InputContentView.bounds];
    shiptView.delegate = self;
    shiptView.senderList.delegate = self;
    shiptView.recevieList.delegate = self;
    [shiptView.MakeOrderButton addTarget:self
                                         action:@selector(simpleShiptViewPostData)
                               forControlEvents:UIControlEventTouchUpInside];

    [shiptView.btn_QRCode addTarget:self
                                    action:@selector(simpleShiptViewToQRCodeView)
                          forControlEvents:UIControlEventTouchUpInside];

    [shiptView.btn_Apointment addTarget:self
                                        action:@selector(simpleShiptViewToAssignView)
                              forControlEvents:UIControlEventTouchUpInside];
    
    ///// 更新TOOLBAR ITEMS
    [self FlextButtonUpdate:_fbv_right forView:shiptView];
    return shiptView;
}

-(void)simpleShiptViewAddressIsNull:(SimpleShiptView *)simpleShiptView{
    UIView *parentView = [self.superController view];
    
    _alertView = [[AlertView alloc]initWithFrame:parentView.bounds
                                         withMsg:[_db getAlertItemTitle:@"msgNil"]
                                     withOkTitle:[_db getAlertItemTitle:@"btnTitleCreate"]
                                 withCancelTitle:[_db getAlertItemTitle:@"btnTitleNotCreate"]];
    _alertView.Caller = simpleShiptView;
    _alertView.delegate = self;
    [parentView addSubview:_alertView];
}

-(NSInteger)simpleShipViewDataHandler{
    SimpleShiptView *simpleShiptView = [_mySubViews lastObject];
    ContactModel *sender = [simpleShiptView.senderList.OptionsData objectAtIndex:simpleShiptView.senderList.selectItemIndex];
    ContactModel *recevie = [simpleShiptView.recevieList.OptionsData objectAtIndex:simpleShiptView.recevieList.selectItemIndex];
    
    if(sender.contactId == recevie.contactId){
        return 0;
    }
    
    
    MailItemModel *mailItem = [MailItemModel new];
    mailItem.mailId = simpleShiptView.orderId;
    if(simpleShiptView.orderNumber){
        mailItem.mailNumber = simpleShiptView.orderNumber;
    }
    mailItem.mailPackageType = simpleShiptView.left_flex.label_value.text;
    mailItem.mailPackagePrice = [simpleShiptView.center_flex.label_value.text floatValue];
    mailItem.mailPayModel = simpleShiptView.right_flex.label_value.text;
    NSInteger updateId =  [_db UpdateMailList:mailItem withSender:sender withReceive:recevie];
    return updateId;
}

//修改
-(void)simpleShiptViewPostData{
    SimpleShiptView *simpleShiptView = [_mySubViews lastObject];
    if(simpleShiptView.arr.count == 0){
        [self simpleShiptViewAddressIsNull:simpleShiptView];
        return;
    }
    
    NSInteger updateId =  [self simpleShipViewDataHandler];
    if(updateId == 0){
        [self AlertSenderEqualReceive];
        return;
    }
    
    //关闭列表编辑
    if([_fbv_center isEqual:_current_fbv]){
        for(UIView *childView in _mySubViews){
            if([childView isKindOfClass:[OrderListView class]]){
                [((OrderListView*)childView).listView setEditing:NO animated:YES];
                break;
            }
        }
    }
    [self FlextButtonUpdate:_fbv_right forView:_mySubViews[_mySubViews.count-2]];
    [self PopView];
    
   
}

//生成二维码
-(void)simpleShiptViewToQRCodeView{
    SimpleShiptView *simpleShiptView = [_mySubViews lastObject];
    if(simpleShiptView.arr.count == 0){
        [self simpleShiptViewAddressIsNull:simpleShiptView];
        return;
    }
    
    NSInteger updateId =  [self simpleShipViewDataHandler];
    if(updateId == 0){
        [self AlertSenderEqualReceive];
        return;
    }
    
    [self PushView:[self MakeOrderView:OrderViewModelInfo withOrderId:updateId]];
}

//直接分配
-(void)simpleShiptViewToAssignView{
    SimpleShiptView *simpleShiptView = [_mySubViews lastObject];
    if(simpleShiptView.arr.count == 0){
        [self simpleShiptViewAddressIsNull:simpleShiptView];
        return;
    }
    
    NSInteger updateId =  [self simpleShipViewDataHandler];
    
    if(updateId == 0){
        [self AlertSenderEqualReceive];
        return;
    }
    
    [self PushView:[self MakeOrderView:OrderViewModelService withOrderId:updateId]];
}

-(void)AlertSenderEqualReceive{
    UIView *parentView = [self.superController view];
    
    _LOADINGView = [[UILoadingView alloc]initWithFrame:parentView.bounds withOnlyText:[_db getPageItemTitle:@"sameWorring"]];
    [parentView addSubview:_LOADINGView];
    [self performSelector:@selector(RemoveLoadingView) withObject:nil afterDelay:2.f];
}
/*=======================================================
 
 地址簿功能区默认视图
 
 =======================================================*/


-(void)AddItemToContactBookView{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ContactBeginEdit" object:nil];
}

-(void)MakeContactBookViewEditor:(BOOL)UsedPasteboard{
    [self MakeAddressTextView];
    [self MakeContactBookView];
    if(UsedPasteboard){
        //执行粘贴，粘贴后自动匹配地址
        [self performSelector:@selector(AddItemToContactBookView) withObject:nil afterDelay:0.3];
        
        //调用弹出菜单的粘贴按钮执行，粘贴和自动匹配
        [self performSelector:@selector(LrdOutPutViewDidSelectedAtIndexPath:) withObject:[NSIndexPath indexPathForItem:0 inSection:0] afterDelay:1];
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CallKeyboard" object:@1];
    }
}

-(BOOL)MakeContactBookView{
    if(_AddressBookData == nil){
        
        _AddressBookData = [_db FindContactsWithFilter:nil];
    }
    if(_AddressBookView == nil){
        _AddressBookView = [[BOT3DOptionView alloc]initWithFrame:_ContactListView.bounds withCellClassName:@"ContactViewCell2"];
        _AddressBookView.delegate = self;
        _AddressBookView.OptionsData = _AddressBookData;
        [self.ContactListView addSubview:_AddressBookView];
        
        if(_AddressBookData.count > 3){
            [_AddressBookView ScrollToItem:2];
        }else if(_AddressBookData.count > 1 && _AddressBookData.count <= 3){
            [_AddressBookView ScrollToItem:1];
        }
        
        _AddressBookView.sd_layout
        .leftSpaceToView(self.ContactListView,0)
        .rightSpaceToView(self.ContactListView,0)
        .topSpaceToView(self.ContactListView,5)
        .bottomSpaceToView(self.ContactListView,5);
    }
    [self CheckAddressBookData];
    return YES;
}

#pragma mark 检查地址簿数据
-(void)CheckAddressBookData{
    if(_AddressBookData.count == 0){
        if([_ContactListView viewWithTag:999] == nil){
            
            
            UIButton *btn =[UIButton buttonWithType:UIButtonTypeSystem];
            btn.tag = 999;
            btn.frame = CGRectMake(_ContactListView.size.width*.2,
                                   (_ContactListView.size.height-50)*.5,
                                   _ContactListView.size.width*.6, 50);
            
            [btn setTitle:[_db getMenuItemTitle:@"addressNone"] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor colorWithWhite:.1 alpha:1]];
            btn.layer.borderColor = [[UIColor darkGrayColor]CGColor];
            btn.layer.cornerRadius = 6.f;
            btn.layer.borderWidth = 1.f;
            btn.clipsToBounds = YES;
            
            [_ContactListView addSubview:btn];
            [btn addTarget:self action:@selector(CreateContact) forControlEvents:UIControlEventTouchUpInside];
        }
    }else{
       UIButton *btn =  [_ContactListView viewWithTag:999];
        [btn removeFromSuperview];
        btn = nil;
    }
}
-(void)CreateContact{
    [self flexButtonView:_fbv_left didOptionOnclick:_fbv_left.buttonArray[1]];
}

#pragma mark 电子簿编辑结束
-(void)ContactEndEdit:(NSNotification*)sender{
   
    if([sender object]){
        NSInteger EditId = EditContactItem.contactId;
        NSLog(@"====编辑EndID： %ld ===",EditId);
        
        //保存
        ContactViewCell2 *EditCell = [sender object];
        if(EditCell.NameField.text.length >0){
            EditContactItem.strName = EditCell.NameField.text;
        }
        if(EditCell.TelField.text.length > 0){
            EditContactItem.strPhone = EditCell.TelField.text;
        }
        
        if(EditCell.ProvinceField.text.length >0){
            EditContactItem.strProv = EditCell.ProvinceField.text;
        }
        
        if(EditCell.CityField.text.length > 0){
            EditContactItem.strCity = EditCell.CityField.text;
        }
        
        if(EditCell.AddressField.text.length >0){
            EditContactItem.strAddress = EditCell.AddressField.text;
        }
        
        if(EditCell.UserImageView.accessibilityIdentifier.length > 0){
            EditContactItem.strImage = EditCell.UserImageView.accessibilityIdentifier;
        
        }
        
        //入库
        
        EditContactItem.contactId = [_db UpdateContact:EditContactItem];
        
        //如果当前是新增模式
        if(EditId == 0){
            [_AddressBookView.OptionsData insertObject:EditContactItem atIndex:_AddressBookView.selectItemIndex];
        }
        
        //刷新数据
        [_AddressBookView.groupView reloadData];
        
        //保存成功提示
        UIView*parentView = self.superController.view;
        _LOADINGView = [[UILoadingView alloc]initWithFrame:parentView.bounds withOnlyText:[_db getAlertItemTitle:@"msgSucc"]];
        [parentView addSubview:_LOADINGView];
        
        [self performSelector:@selector(RemoveLoadingView) withObject:nil afterDelay:1.f];
        
        
    }else{
        
        //离开编辑页面时的 取消
        if(EditContactItem.contactId == 0)
            EditContactItem = nil;
    }
    
    [self CheckAddressBookData];
    
    _AddressBookIsEditModel = NO;//结束编辑模式
    
    //修改 分段菜单【地址簿部分的子菜单】
    for(UIButton *button in _fbv_left.buttonArray){
        if(button.tag == 104){
            button.tag = 100;
            [button setTitle:[_db getMenuItemTitle:@"del"] forState:UIControlStateNormal];
            
        }else if(button.tag == 105){
            button.tag = 101;
            [button setTitle:[_db getMenuItemTitle:@"add"] forState:UIControlStateNormal];
            
        }else if(button.tag == 106){
            button.tag = 102;
            [button setTitle:[_db getMenuItemTitle:@"edit"] forState:UIControlStateNormal];
        }
        else {
            //ai
            button.selected = NO;
            button.hidden = YES;
             [[_fbv_left.SPLITVIEWS lastObject] setHidden:YES];
        }
    }
    [_fbv_left updateButtonCollectionContentSize];
    
    
    [UIView animateWithDuration:0.4 animations:^{
        _EditBookView.transform = CGAffineTransformMakeScale(.1, .1);
    } completion:^(BOOL finished) {
        [_EditBookView removeFromSuperview];
        _EditBookView = nil;
    }];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CallKeyboard" object:@1];
}

#pragma mark 启动电子簿编辑功能
-(void)ContactBeginEdit:(NSNotification*)sender{
    _AddressBookIsEditModel = YES; //启动编辑模式
    
    if([[sender object]isKindOfClass:[ContactViewCell2 class]]){
        //修改
        ContactViewCell2 *EditCell = [sender object];
        EditContactItem = [_AddressBookView.OptionsData objectAtIndex:EditCell.CellIndex];
    }else{
        //新增
        EditContactItem = [ContactModel new];
    }
    NSLog(@"====编辑BeginID： %ld ===",EditContactItem.contactId);
    
    if(_EditBookView == nil){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = _ContactListView.size;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _EditBookView = [[UICollectionView alloc]initWithFrame:_ContactListView.bounds collectionViewLayout:layout];
        [_EditBookView registerClass:[ContactViewCell2 class] forCellWithReuseIdentifier:@"EditCELL"];
        _EditBookView.delegate = self;
        _EditBookView.dataSource = self;
        _EditBookView.transform = CGAffineTransformMakeScale(0, 0);
        _EditBookView.scrollEnabled = NO;
        [_ContactListView addSubview:_EditBookView];
        [UIView animateWithDuration:0.4 animations:^{
            _EditBookView.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }
    
    //修改 分段菜单【地址簿部分的子菜单】
    
    for(UIButton *button in _fbv_left.buttonArray){
        if(button.tag == 100){
            button.tag = 104;
            [button setTitle:[_db getMenuItemTitle:@"cancel"] forState:UIControlStateNormal];
            
        }else if(button.tag == 101){
            button.tag = 105;
            [button setTitle:[_db getMenuItemTitle:@"clear"] forState:UIControlStateNormal];
            
        }else if(button.tag == 102){
            button.tag = 106;
            [button setTitle:[_db getMenuItemTitle:@"save"] forState:UIControlStateNormal];
        }else{
            //ai
            button.hidden = NO;
            button.selected = NO;
            [[_fbv_left.SPLITVIEWS lastObject] setHidden:NO];
            
        }
    }
     [_fbv_left updateButtonCollectionContentSize];
    
}

#pragma mark EditBookView delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 1;
    
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ContactViewCell2* CELL = [collectionView dequeueReusableCellWithReuseIdentifier:@"EditCELL" forIndexPath:indexPath];
    CELL.editEnable = YES;
    [CELL setForm:EditContactItem];
    //CELL.SaveButton.tag = 300; //默认200 发布编辑事件，300 发布结束编辑事件
    
    [CELL.SaveButton setTitle:[_db getMenuItemTitle:@"save"] forState:UIControlStateNormal];
    return CELL;
}





-(void)MakeAddressTextView{
    if(_AddressTextView == nil){
        _AddressTextView = [[KUITextView alloc]initWithFrame:self.InputContentView.bounds];
        _AddressTextView.textContainerInset = UIEdgeInsetsMake(16, 16, 16, 16);
        _AddressTextView.delegate = self;
        _AddressTextView.KDelegate = self;
        _AddressTextView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        _AddressTextView.textColor = [UIColor colorWithWhite:.3 alpha:1];
        
        [self.InputContentView addSubview:_AddressTextView];
       
        _AddressTextView.sd_layout
        .leftSpaceToView(self.InputContentView,0)
        .rightSpaceToView(self.InputContentView,0)
        .topSpaceToView(self.InputContentView,0)
        .bottomSpaceToView(self.InputContentView,0);
        
        if(longPress == nil){
            longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
            longPress.minimumPressDuration = .4f;
        }
        [_AddressTextView addGestureRecognizer:longPress];
        
    }
    
}

-(void)HiddenAddressTextView{
    if(_AddressTextView){
        [UIView animateWithDuration:0.3 animations:^{
            _AddressTextView.alpha = 0;
        } completion:^(BOOL finished) {
            [_AddressTextView removeFromSuperview];
            _AddressTextView = nil;
        }];
    }
}


#pragma mark 长按手势处理方法
-(void)longPressAction:(UILongPressGestureRecognizer*)sender{
    if(sender.state != UIGestureRecognizerStateBegan){
        return;
    }
    if(((UITextView*)sender.view).text.length == 0){
        [self showTextMenuView];
    }
}

#pragma mark UITextViewDelegate KUITextViewDelegate
-(void)kTextViewDidConfirmSelection:(UITextView *)textView{
    //隐藏放大镜
    [self setMagifierViewHide];
    //显示选择文本操作菜单
    [self showTextMenuView];
}

//文本变化
-(void)textViewDidChange:(UITextView *)textView{
    if(textView.text.length == 0){
        [textView addGestureRecognizer:longPress];
        [((KUITextView*)textView) AddPlaceHolder];
    }else{
        [textView removeGestureRecognizer:longPress];
        [((KUITextView*)textView) ClearPlaceHolder];
    }
}

//选区变化
-(void)textViewDidChangeSelection:(UITextView *)textView{
    //隐藏选择文本操作菜单
    [self setSelectionTextMenuHide];
    
    NSRange range =  textView.selectedRange;
    if(range.length > 0){
        CGPoint scrollPosition = [textView contentOffset];
        CGPoint startPosition = [textView caretRectForPosition:textView.selectedTextRange.start].origin;
        CGPoint endPosition = [textView caretRectForPosition:textView.selectedTextRange.end].origin;
        
        
        if(startPosition.x != prevStartPoint.x || startPosition.y != prevStartPoint.y){
            currentPoint = CGPointMake(startPosition.x + _AddressTextView.origin.x , startPosition.y-scrollPosition.y);
            
        }else if(endPosition.x != prevEndPoint.x || endPosition.y != prevEndPoint.y){
            currentPoint = CGPointMake(endPosition.x + _AddressTextView.origin.x, endPosition.y-scrollPosition.y);
        }
        
        prevStartPoint = startPosition;
        prevEndPoint = endPosition;
        
        //放大预览视图
        if(self.magnifierView == nil){
            self.magnifierView = [[KMagnifierView alloc]init];
            self.magnifierView.viewToMagnify = self.InputContentView;
            self.magnifierView.pointToCut = self.InputContentView.origin;
            [self addSubview:self.magnifierView];
        }
        self.magnifierView.pointToMagnify = currentPoint;
    }else{
        [self setMagifierViewHide];
    }
    
}

-(void)setMagifierViewHide{
    if(self.magnifierView){
        [self.magnifierView removeFromSuperview];
        self.magnifierView = nil;
    }
}



#pragma mark pop menu delegate
-(void)showTextMenuView{
    if(menuDataArr == nil){
        LrdCellModel *NS_User = [[LrdCellModel alloc] initWithTitle:@"Name" imageName:@"source.bundle/icon_user.png"];
        LrdCellModel *NS_Phone = [[LrdCellModel alloc] initWithTitle:@"Phone" imageName:@"source.bundle/icon_phone.png"];
        LrdCellModel *NS_Prov = [[LrdCellModel alloc] initWithTitle:@"Prov." imageName:@"source.bundle/icon_prov.png"];
        LrdCellModel *NS_City = [[LrdCellModel alloc] initWithTitle:@"City" imageName:@"source.bundle/icon_city.png"];
        LrdCellModel *NS_Address = [[LrdCellModel alloc] initWithTitle:@"Address" imageName:@"source.bundle/icon_location.png"];
        LrdCellModel *NS_Paste = [[LrdCellModel alloc] initWithTitle:@"Paste" imageName:@"source.bundle/icon_paste.png"];
        LrdCellModel *NS_Copy = [[LrdCellModel alloc] initWithTitle:@"Copy" imageName:@"source.bundle/icon_copy.png"];
        
        menuDataArr = @[NS_Paste,NS_Copy,NS_User,NS_Phone,NS_Prov,NS_City,NS_Address];
    }
    
    CGFloat menu_h = 44.f;
    CGFloat x = self.center.x;
    CGFloat y = _InputContentView.origin.y -  menu_h;
    
    if(menuOutputView == nil){
        menuOutputView = [[LrdOutputView alloc] initWithDataArray:menuDataArr
                                                           origin:CGPointMake(x,y)
                                                            width:self.width-16
                                                           height:menu_h
                                                        direction:kLrdOutputViewDirectionRight];
        menuOutputView.delegate = self;
        menuOutputView.dismissOperation = ^(){
            //设置成nil，以防内存泄露
            menuOutputView = nil;
        };
        [menuOutputView  pop:self];
    }
}
-(void)setSelectionTextMenuHide{
    if(menuOutputView)[menuOutputView dismiss];
}

#pragma mark 智能地址编辑器弹出菜单代理
- (void)LrdOutPutViewDidSelectedAtIndexPath:(NSIndexPath *)indexPath{
    
    ContactViewCell2 *SelectCell = (ContactViewCell2*)[_EditBookView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    NSString * selectRangeText = @"";
    if(_AddressTextView.selectedRange.length >0){
        selectRangeText = [[_AddressTextView.text substringWithRange:_AddressTextView.selectedRange]copy];
    }
    
    switch (indexPath.item) {
        case 0:{
            //paste
            UIPasteboard *Pasteboard = [UIPasteboard generalPasteboard];
            if(Pasteboard.string.length > 0){
                NSString *str = [Pasteboard.string copy];
                if(_AddressTextView.text.length > 0){
                    [_AddressTextView selectAll:_AddressTextView];
                    [_AddressTextView  deleteBackward];
                };
                [_AddressTextView insertText:str];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"matchAddress" object:@[str,SelectCell]];
                
                Pasteboard.string = @"";
            }
        }
            break;
        case 1:{
            //copy
            if(_AddressTextView.selectedRange.length > 0){
                NSString * selectRangeText = [_AddressTextView.text substringWithRange:_AddressTextView.selectedRange];
                UIPasteboard *Pasteboard = [UIPasteboard generalPasteboard];
                [Pasteboard setString:selectRangeText];
            }
        }
            break;
        case 2:{
            [SelectCell setTextView:SelectCell.NameField Value:selectRangeText];
            
        }
            break;
        case 3:{
            [SelectCell setTextView:SelectCell.TelField Value:selectRangeText];

        }
            break;
        case 4:{
            [SelectCell setTextView:SelectCell.ProvinceField Value:selectRangeText];

        }
            break;
        case 5:{
            [SelectCell setTextView:SelectCell.CityField Value:selectRangeText];
  
        }
            break;
        case 6:{
            [SelectCell setTextView:SelectCell.AddressField Value:selectRangeText];

        }
            break;
    }
}





/*=======================================================
 
 订单类视图
 
 =======================================================*/
-(void)FlextButtonUpdate:(FlexButtonView*)flexButtonView forView:(UIView*)tagView{
    if([flexButtonView isEqual:_fbv_center]){
        if([tagView isKindOfClass:[OrderInfoView class]] || [tagView isKindOfClass:[OrderCallView class]]){
            //显示编辑按钮，其他隐藏
            for(UIButton *btn in _fbv_center.buttonArray){
                if(btn.tag == 102){
                    btn.center = ((UIButton*)[_fbv_center.buttonArray objectAtIndex:0]).center;
                    btn.hidden = NO;
                }else{
                    btn.hidden = YES;
                }
            }
            for(UIView*lineView in _fbv_center.SPLITVIEWS){
                lineView.hidden = YES;
            }
            
        }else{
            //隐藏编辑按钮，其他显示
            for(UIButton *btn in _fbv_center.buttonArray){
                if(btn.tag == 102){
                    btn.hidden = YES;
                }else{
                    btn.hidden = NO;
                }
            }
            [[_fbv_center.SPLITVIEWS firstObject]setHidden:NO];
        }
        return;
    }
    
    if([flexButtonView isEqual:_fbv_right]){
        if([tagView isKindOfClass:[OrderInfoView class]] || [tagView isKindOfClass:[OrderCallView class]]){
            ((UIButton*)[_fbv_right.buttonArray lastObject]).hidden = NO;
            [[_fbv_right.SPLITVIEWS lastObject]setHidden:NO];
        }else{
            ((UIButton*)[_fbv_right.buttonArray lastObject]).hidden = YES;
            [[_fbv_right.SPLITVIEWS lastObject]setHidden:YES];
        }
    }
    
    [flexButtonView updateButtonCollectionContentSize];
    
}

-(UIView*)MakeOrderView:(OrderViewModel)viewModel withOrderId:(NSInteger)OrderId{
    CGRect startFrame = _InputContentView.bounds;
    UIView *targetView;
    switch (viewModel) {
        //详情视图
        case OrderViewModelInfo:{
            targetView = [[OrderInfoView alloc]initWithFrame:startFrame withOrderId:OrderId];
            ((OrderInfoView*)targetView).delegate = self;
            //更新中间按钮段的按钮
            [self FlextButtonUpdate:_current_fbv forView:targetView];
            
        }break;
            
        //呼叫小哥视图
        case OrderViewModelService:{
            targetView = [[OrderCallView alloc]initWithFrame:startFrame withOrderId:OrderId];
            ((OrderCallView*)targetView).delegate = self;
            //更新中间按钮段的按钮
            [self FlextButtonUpdate:_current_fbv forView:targetView];
        }break;
            
        //列表视图
        default:{
            targetView = [[OrderListView alloc]initWithFrame:startFrame];
            ((OrderListView*)targetView).delegate = self;
            //更新中间按钮段的按钮
             [self FlextButtonUpdate:_fbv_center forView:targetView];
        }break;
    }
    return targetView;    
}



#pragma mark 订单视图代理 OrderView delegate

//OrderListView delegate
-(void)orderListView:(OrderListView *)orderListView didSelectedMailItem:(NSInteger)mailItemId{
    [self PushView:[self MakeOrderView:OrderViewModelInfo withOrderId:mailItemId]];
}
-(void)orderListView:(OrderListView *)orderListView didSelectedEditMailItem:(NSInteger)mailItemId{
    [self PushView:[self MakeSimpleShiptView]];
    [self performSelector:@selector(SimpleShiptViewRunEditModel:) withObject:@(mailItemId) afterDelay:0.6f];
}
-(void)orderListViewDidSelectedAddMailItem:(OrderListView *)orderListView{
 [self flexButtonView:_fbv_right didShowHiddenOnclick:_fbv_right.baseButton];
}


//OrderInfoView delegate
-(void)orderInfoView:(OrderInfoView *)orderInfoView didSelectTabbarItem:(NSInteger)itemTag{
    switch (itemTag) {
        case 1:{
            NSLog(@"删除");
            
            UIView *parentView = [_superController view];
            _alertView = [[AlertView alloc]initWithFrame:parentView.bounds
                                                 withMsg:[_db getAlertItemTitle:@"msgDel"]
                                             withOkTitle:[_db getAlertItemTitle:@"btnTitleOK"]
                                         withCancelTitle:[_db getAlertItemTitle:@"btnTitleCancel"]];
            _alertView.Caller = orderInfoView;
            _alertView.delegate = self;
            
            [parentView addSubview:_alertView];
        }break;
            
        case 2:{
            NSLog(@"呼叫顺丰");
            [self PushView:[self MakeOrderView:OrderViewModelService withOrderId:orderInfoView.OrderId]];
        }break;
            
        default:{
            NSLog(@"稍后使用");
            if([_current_fbv isEqual:_fbv_right]){
                [self flexButtonView:_fbv_center didShowHiddenOnclick:_fbv_center.baseButton];
            }else{
                [self PopView];
            }
            
            
        }break;
    }

}

#pragma mark 订单取消后
-(void)DidOrderCancel{
    [self RemoveLoadingView];
    [self PushView:[self MakeOrderView:OrderViewModelList withOrderId:0]];
}

-(void)orderCallView:(OrderCallView *)orderCallView didSelectedTabItem:(NSInteger)itemId{
    switch (itemId) {
        case 1:{
            //分享
//            NSString*shareData = @"http://www.longyuchuan.com";
//            [self.superController.textDocumentProxy insertText:shareData];
//            [self.superController.textDocumentProxy insertText:@"\n"];
            
            UIImage*QRCodeImage = [orderCallView makeQRCodeImage];
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setImage:QRCodeImage];
            
            UIView *parentView = [self.superController view];
            
            _LOADINGView = [[UILoadingView alloc]initWithFrame:parentView.bounds withOnlyText:[_db getAlertItemTitle:@"msgDidPaste"]];
            [parentView addSubview:_LOADINGView];
            [self performSelector:@selector(DidOrderCancel) withObject:nil afterDelay:2.f];
            
        }
            break;
        case 2:{
            NSInteger OrderId = orderCallView.OrderId;
            //取消
            UIView *parentView = [self.superController view];
            
            NSDate *cancelData = [NSDate date];
            NSDateFormatter *format = [[NSDateFormatter alloc]init];
            [format setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            
            NSString *sql = [NSString stringWithFormat:@"UPDATE MailList set mail_state = %ld, mail_cancel_time ='%@', mail_assign_time = ''  WHERE mail_id = %ld",OrderStateCanceled,[format stringFromDate:cancelData],OrderId];
            [_db UpdateWithSql:sql];
            
            _LOADINGView = [[UILoadingView alloc]initWithFrame:parentView.bounds withOnlyText:[_db getAlertItemTitle:@"msgOrderCancel"]];
            [parentView addSubview:_LOADINGView];
            [self performSelector:@selector(DidOrderCancel) withObject:nil afterDelay:1.6f];
            
        }break;
            
        case 3:{
            //呼叫小哥
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CallAppPage" object:@"CallPhone"];
        }break;
            
        default:{
            if([_current_fbv isEqual:_fbv_right]){
                [self flexButtonView:_fbv_center didShowHiddenOnclick:_fbv_center.baseButton];
            }else{
                 [self PopView];
            }           
        }
            break;
    }
    
}

-(void)orderCallView:(OrderCallView *)orderCallView didClickedEdit:(UIButton *)sender{
    [self PushView:[self MakeSimpleShiptView]];
    [self performSelector:@selector(SimpleShiptViewRunEditModel:) withObject:@(orderCallView.OrderId) afterDelay:0.6f];
}
/*=======================================================
 
  载入三个功能区的默认视图
 
 =======================================================*/
#pragma mark 加载默认视图
-(void)loadDefaultViewWithFlex{
    CGFloat marginTop;
    if(_current_fbv == nil || [_current_fbv isEqual:_fbv_left]){
        marginTop = 0;
    }else{
        marginTop = -177;
    }
    
    [self viewResize:marginTop completion:^{
        [self initNavigation];
        
        if(_current_fbv == nil || [_current_fbv isEqual:_fbv_left]){
            
            UIPasteboard *Pasteboard = [UIPasteboard generalPasteboard];
            if(Pasteboard.string && Pasteboard.string.length > 0 && _read_count == 0){
                _read_count++;
                //询问进入什么模式：手动模式 或 智能模式
                UIView *parentView = [_superController view];
                
                
                self.alertView = [[AlertView alloc]initWithFrame:parentView.bounds
                                                         withMsg:[NSString stringWithFormat:@"%@？\n【%@】",[_db getAlertItemTitle:@"msgClipboard"],Pasteboard.string]
                                             withDoFunctionTitle:[_db getAlertItemTitle:@"btnTitleShipt"]
                                                     withOkTitle:[_db getAlertItemTitle:@"btnTitlePaste"]
                                                 withCancelTitle:[_db getAlertItemTitle:@"btnTitleNotDo"]];
                self.alertView.delegate = self;
                [parentView addSubview:self.alertView];
                
            }else{
                [self MakeContactBookViewEditor:NO];
            }
            
            
            return;
        }
        if([_current_fbv isEqual:_fbv_center]){
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CallKeyboard" object:@0];
            [self PushView:[self MakeOrderView:OrderViewModelList withOrderId:0]];
            return;
        }
        if([_current_fbv isEqual:_fbv_right]){
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CallKeyboard" object:@0];
            [self PushView:[self MakeSimpleShiptView]];
            return;
        }

    }];
}


#pragma mark 弹窗代理
/*=======================================================
 
 主要处理粘贴板有文本内容时的询问处理
 
 =======================================================*/
-(void)alertViewDidClickedDo:(AlertView *)KAlerView{
    //马上寄件
    UIPasteboard *Pasteboard = [UIPasteboard generalPasteboard];
    NSString*Address =  [Pasteboard.string copy];
    [self.superController matchAddressToShipt:Address];    
    Pasteboard.string = @"";
}

-(void)alertViewDidClickedOk:(AlertView *)KAlerView{
    if(KAlerView.Caller){
        [self.alertView removeFromSuperview];
        self.alertView = nil;
        
        if([KAlerView.Caller isKindOfClass:[SimpleShiptView class]]){
            [self flexButtonView:_fbv_left didShowHiddenOnclick:_fbv_left.baseButton];
            return;
        }
        
        
        //确定离开编辑页面
        if(![KAlerView.Caller isEqual:_fbv_left] && _AddressBookIsEditModel == YES){
            //发布取消编辑通知
            [[NSNotificationCenter defaultCenter]postNotificationName:@"ContactEndEdit" object:nil];
            
            FlexButtonView *targetFlex = KAlerView.Caller;
            [self flexButtonView:targetFlex didShowHiddenOnclick:targetFlex.baseButton];
            return;
        }
        
        
        UIView* parentView = _superController.view;
        _LOADINGView = [[UILoadingView alloc]initWithFrame:self.bounds withText:[_db getAlertItemTitle:@"msgDataLoading"]];
        [parentView addSubview:_LOADINGView];
        
        
        if([KAlerView.Caller isEqual:_fbv_left]){
            ContactModel *item = [_AddressBookView.OptionsData objectAtIndex:_AddressBookView.selectItemIndex];
            if(item.contactId == 0){
                [_AddressBookView.OptionsData removeObjectAtIndex:0];
            }else{
                [_db RemoveContactWithId:item.contactId];
                [_AddressBookView.OptionsData removeObjectAtIndex:_AddressBookView.selectItemIndex];
            }
            NSInteger selectItem = _AddressBookView.OptionsData.count / 2;
            selectItem = MAX(0, selectItem);
            [_AddressBookView.groupView reloadData];
            if(_AddressBookData.count > 0){
                [_AddressBookView ScrollToItem:selectItem];
            }
            
            [self CheckAddressBookData];
            
            [self performSelector:@selector(RemoveLoadingView) withObject:nil afterDelay:1.f];
        }
        
        
        
        if([KAlerView.Caller isKindOfClass:[OrderInfoView class]]){
            NSInteger RemoveId = ((OrderInfoView*)KAlerView.Caller).OrderId;
            [_db RemoveMailItem:RemoveId];
            if([_current_fbv isEqual:_fbv_center]){
                for(UIView* childView in _mySubViews){
                    if([childView isKindOfClass:[OrderListView class]]){
                        OrderListView *listView = (OrderListView*)childView;
                        for(NSInteger i=0;i<listView.listData.count;i++){
                            if( [listView.listData[i][0] integerValue] == RemoveId){
                                [listView.listData removeObjectAtIndex:i];
                                break;
                            }
                        }
                        [listView.listView reloadData];
                        break;
                    }
                }
            }
            [self PopView];
            //[self PushView:[self MakeOrderView:OrderViewModelList withOrderId:0]];
        }
        
        [self performSelector:@selector(RemoveLoadingView) withObject:nil afterDelay:1.f];
        
    }else{
        //键盘关闭
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CallKeyboard" object:[NSNumber numberWithInt:0]];
        
        
        /* == 把粘贴板内容 贴入 新地址编辑 ==*/
        
        [self MakeContactBookViewEditor:YES];
        [self.alertView removeFromSuperview];
        self.alertView = nil;
    }
    
  
}

-(void)alertViewDidClickedCancel:(AlertView *)KAlerView{
    if(KAlerView.Caller){
        
    }else{
        //打开键盘，使用手动处理
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CallKeyboard" object:[NSNumber numberWithInt:1]];
        [self MakeContactBookViewEditor:NO];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _alertView.alpha = 0;
    } completion:^(BOOL finished) {
        [_alertView removeFromSuperview];
        _alertView = nil;
    }];
}
@end
