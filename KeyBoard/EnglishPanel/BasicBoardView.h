//
//  BasicBoardView.h
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/25.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyButton.h"
#import "NumberKeyboardView.h"
#import "SymbolKeyboardView.h"

typedef NS_ENUM(NSInteger,keyboardPanel){
    keyboardPanelEnglish = 0,
    keyboardPanelNumber = 1,
    keyboardPanelSymbol = 2,
    keyboardPanelChinese = 3
};

@protocol BasicBoardViewDelegate;
@interface BasicBoardView : UIView<KeyButtonDelegate>
@property(nonatomic,assign)id<BasicBoardViewDelegate>delegate;
@property(nonatomic,assign)id<UITextDocumentProxy>Proxy;
@property(nonatomic,assign)keyboardPanel panelModel; //控制板模式
@property(nonatomic,copy)NSString *CurrentInputText;//当前输入的字符

@property(nonatomic,retain)NumberKeyboardView *NumberView;
@property(nonatomic,retain)SymbolKeyboardView *SymbolView;
@end

@protocol BasicBoardViewDelegate <NSObject>
-(void)basicBoardView:(BasicBoardView*)basicBoardView didEnglishInputTextChanged:(NSString*)text;
-(void)basicBoardView:(BasicBoardView*)basicBoardView didChineseInputTextChanged:(NSString*)text;
@end
