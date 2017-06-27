//
//  TokenView2.h
//  SMRT Keyborad
//
//  Created by BOT01 on 17/3/20.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//
#import "SDAutoLayout.h"
#import "KMagnifierView.h"
#import "LrdOutputView.h"
#import "KUITextView.h"
#import "ContactModel.h"
#import "BoardDB.h"
#import "UILoadingView.h"
#import "ArrowSlider.h"
#import "AlertView.h"
#import "UILoadingView.h"
#import "ContactViewCell2.h"
#import <UIKit/UIKit.h>
@protocol TokenView2Delegate;
@interface TokenView2 : UIView<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
LrdOutputViewDelegate,
KUITextViewDelegate,
UITextViewDelegate,AlertViewDelegate>{
    CGPoint prevStartPoint;
    CGPoint prevEndPoint;
    CGPoint currentPoint;
    UILongPressGestureRecognizer *longPress;
    ArrowSlider *sliderView;
    UIView *textCursorView;
}
@property(nonatomic,strong)AlertView *alertView;
@property(nonatomic,strong)UILoadingView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *SectionBtn;
@property (weak, nonatomic) IBOutlet UIButton *FunctionBtn;

@property (weak, nonatomic) IBOutlet UICollectionView *ContactsView;
@property(nonatomic,retain)NSMutableArray *ContactsDataSource;

@property (weak, nonatomic) IBOutlet UIView *ToolbarView;
@property (weak, nonatomic) IBOutlet UIView *TextInnerView;
@property (weak, nonatomic) IBOutlet UIView *SwiperView;


@property(nonatomic,strong)KUITextView *BoardTextView;
@property(nonatomic,assign)id currentTextView;
//@property(nonatomic,assign) NSInteger ContactId;

@property(nonatomic,assign)id<TokenView2Delegate>delegate;
@end

@protocol TokenView2Delegate <NSObject>
@optional
-(void)tokenView:(TokenView2*)tokenView didClickedSwitchButton:(UIButton*)sender;
-(void)tokenView:(TokenView2 *)tokenView didSelectedContactCell:(id)cell withImageView:(UIImageView*)imageView;
-(void)tokenViewDidSaveSuccess;
@end
