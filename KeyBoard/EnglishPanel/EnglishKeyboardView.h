//
//  EnglishKeyboardView.h
//  BOTboard
//
//  Created by BOT01 on 17/1/13.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//




#import <UIKit/UIKit.h>
#import "KeyboardViewController.h"
@protocol EnglishKeyboardViewDelegate;
typedef NS_ENUM(NSInteger,keyboardPanel){
    keyboardPanelEnglish = 0,
    keyboardPanelNumber = 1,
    keyboardPanelSymbol = 2,
    keyboardPanelChinese = 3
};
@interface EnglishKeyboardView : UIView
@property (weak, nonatomic) IBOutlet UIButton *Btn_Lower;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Del;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Number;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Space;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Chs;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Symbol;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Send;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Lng;

@property (nonatomic,assign)keyboardPanel panelModel;

@property(nonatomic)id <UITextDocumentProxy> Proxy;
@property(nonatomic,copy)NSString *CurrentInputText;

@property(nonatomic,assign)id<EnglishKeyboardViewDelegate>delegate;

@property (nonatomic,strong)  IBOutletCollection(UIButton) NSArray* Btn_Array;

@end
@protocol EnglishKeyboardViewDelegate <NSObject>
@optional
-(void)englishKeyboardView:(EnglishKeyboardView*)englishKeyboardView didTextChanged:(NSString*)text;
@end
