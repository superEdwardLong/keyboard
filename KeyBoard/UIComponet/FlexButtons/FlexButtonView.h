//
//  FlexButtonView.h
//  HelloWorld1
//
//  Created by mac-mini on 16/8/29.
//  Copyright © 2016年 mac-mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDAutoLayout.h"

typedef void(^FlexButtonViewBlock)(UIButton *btn);
@protocol FlexButtonViewDelegate;
@interface FlexButtonView : UIView
@property(nonatomic,assign)id<FlexButtonViewDelegate>delegate;
@property (nonatomic, copy) FlexButtonViewBlock flexBlock;
@property(nonatomic,retain) UIButton *baseButton;
@property(nonatomic,retain) NSArray *buttonArray;
@property(nonatomic,assign)CGFloat componetMaxWidth;
@property(nonatomic,assign)BOOL selected;
@property(nonatomic,retain)NSMutableArray *SPLITVIEWS;

-(void)setButtonArray:(NSArray *)btnArray;
-(void)setBaseButton:(UIButton *)btn;
-(UIButton *)getBaseButton;
-(instancetype)initWithFrame:(CGRect)frame withBaseButton:(UIButton*)BaseButton withSubButtons:(NSArray*)subButtons;
-(void)btnHidden;
-(void)btnShow;
-(void)updateButtonCollectionContentSize;
@end

@protocol FlexButtonViewDelegate <NSObject>

@optional
-(void)flexButtonView:(FlexButtonView*)flexButtonView didShowHiddenOnclick:(UIButton *)btn;
-(void)flexButtonView:(FlexButtonView*)flexButtonView didOptionOnclick:(UIButton *)btn;
@end
