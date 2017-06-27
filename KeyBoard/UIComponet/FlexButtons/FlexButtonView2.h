//
//  FlexButtonView2.h
//  SMRT Board V3
//
//  Created by BOT01 on 2017/5/7.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FlexButtonView2Delegate;
@interface FlexButtonView2 : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,assign)id<FlexButtonView2Delegate>delegate;

@property(nonatomic,retain)NSArray *options;
@property (weak, nonatomic) IBOutlet UIButton *btn_base;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *width_base;

@property (weak, nonatomic) IBOutlet UILabel *label_value;
@property (weak, nonatomic) IBOutlet UICollectionView *option_view;

-(instancetype)initWithFrame:(CGRect)frame withBaseTitle:(NSString*)title withDefaultValue:(NSString*)defaultValue withOptions:(NSArray*)options;
-(void)setBaseTitle:(NSString*)baseTitle;
-(void)setDefaultValue:(NSString*)defaultValue;
-(void)setOptions:(NSArray*)options;
-(void)resetFlextButtonView;
@end

@protocol FlexButtonView2Delegate <NSObject>
@optional
-(void)flexButtonViewWillDisplay:(FlexButtonView2*)flexButtonView;
-(void)flexButtonViewWillDedisplay:(FlexButtonView2 *)flexButtonView;
@end
