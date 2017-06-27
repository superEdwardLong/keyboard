//
//  KeyLabel.h
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/25.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDAutoLayout.h"
typedef NS_ENUM(NSInteger,KeyButtonState) {
    KeyButtonStateNormal = 0,
    KeyButtonStateSelected = 1,
    KeyButtonStateHighLight = 2
};
@protocol KeyButtonDelegate;
@interface KeyButton : UIView
@property(nonatomic,assign)id<KeyButtonDelegate>delegate;
@property(nonatomic,assign)BOOL disable;
@property(nonatomic,retain)UIFont *font;
@property(nonatomic,assign)BOOL selected;
@property(nonatomic,assign)BOOL notUseTip;
@property(nonatomic,assign)KeyButtonState keyButtonState;
@property(nonatomic,assign)CGFloat cornerRadius;

@property(nonatomic,copy)NSString* normalTitle;
@property(nonatomic,copy)NSString* selectedTitle;
@property(nonatomic,copy)NSString* highlightTitle;

@property(nonatomic,retain)UIColor* normalTitleColor;
@property(nonatomic,retain)UIColor* selectedTitleColor;
@property(nonatomic,retain)UIColor* highlightTitleColor;

@property(nonatomic,retain)UIColor* normalBackgroundColor;
@property(nonatomic,retain)UIColor* selectedBackgroundColor;
@property(nonatomic,retain)UIColor* highlightBackgroundColor;


-(id)initWithFrame:(CGRect)frame withTitle:(NSString*)title;
-(void)keyButtonTitle:(NSString*)title withKeyButtonState:(KeyButtonState)state;
-(void)keyButtonTitleColor:(UIColor*)titleColor withKeyButtonState:(KeyButtonState)state;
-(void)keyButtonBackgroundColor:(UIColor*)color withKeyButtonState:(KeyButtonState)state;
@end

@protocol KeyButtonDelegate <NSObject>
-(void)KeyButtomDidTouchDownBegin:(KeyButton*)keyButton;
-(void)KeyButtomDidTouchUpInside:(KeyButton*)keyButton;
@end
