//
//  EnglishKeyboardView.m
//  BOTboard
//
//  Created by BOT01 on 17/1/13.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "EnglishKeyboardView.h"
@interface EnglishKeyboardView()
@property (nonatomic,retain)NSArray* LetterArray;
@property (nonatomic,retain)NSArray* NumberArray;
@property (nonatomic,retain)NSArray* SymbolArray;
@property(nonatomic,strong)NSTimer *DelTimer;
@property(nonatomic,assign)BOOL IsLockUpper;

@end

@implementation EnglishKeyboardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
 🌐 ⇪ ⌫ ⬆︎ ⇧
}
*/
@synthesize Btn_Chs;
@synthesize Btn_Del;
@synthesize Btn_Lower;
@synthesize Btn_Space;
@synthesize Btn_Number;
@synthesize Btn_Symbol;
@synthesize Btn_Send;
@synthesize Btn_Lng;
@synthesize Btn_Array;
@synthesize DelTimer;

@synthesize LetterArray;
@synthesize NumberArray;
@synthesize SymbolArray;
@synthesize Proxy;
@synthesize CurrentInputText;

-(instancetype)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"EnglishKeyboardView" owner:self options:nil]lastObject];
    if(self){
        self.frame = frame;
        self.panelModel = keyboardPanelEnglish;
        NSArray *ActionBtns = @[Btn_Send,Btn_Symbol,Btn_Number,Btn_Space,Btn_Del,Btn_Chs,Btn_Lng];
        
        
        for(UIButton *btn in ActionBtns){
            [self SetBtnStyle:btn];
            [btn addTarget:self action:@selector(tapActionWithButton:) forControlEvents:UIControlEventTouchUpInside];
            if([btn isEqual:Btn_Del]){
                [btn addTarget:self action:@selector(delActionWithButton:) forControlEvents:UIControlEventTouchDown];
            }
        }
        for(UIButton *btn in Btn_Array){
            [self SetBtnStyle:btn];
            [btn addTarget:self action:@selector(tapActionWithButton:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
        
        //大小写切换，锁定 事件处理
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        [singleTapGestureRecognizer setNumberOfTapsRequired:1];
        [Btn_Lower addGestureRecognizer:singleTapGestureRecognizer];
        
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        [Btn_Lower addGestureRecognizer:doubleTapGestureRecognizer];
        
        //这行很关键，意思是只有当没有检测到doubleTapGestureRecognizer 或者 检测doubleTapGestureRecognizer失败，singleTapGestureRecognizer才有效
        [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
        
        //默认大写
        Btn_Lower.selected = YES;
        [self SetBtnStyle:Btn_Lower];
        
    
        NumberArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",
                        @"+",@"-",@"×",@"÷",@"%",@"&",@"=",@"(",@")",@"?",
                        @"[",@"]",@"{",@"}",@",",@"."];
        
        LetterArray = @[@"Q",@"W",@"E",@"R",@"T",@"Y",@"U",@"I",@"O",@"P",
                        @"A",@"S",@"D",@"F",@"G",@"H",@"J",@"K",@"L",@"Z",
                        @"X",@"C",@"V",@"B",@"N",@"M"];
        
        SymbolArray = @[@"@",@"$",@"¥",@"€",@"<",@">",@"~",@"'",@";",@"|",
                        @"!",@"#",@"*",@":",@"/",@"←",@"→",@"®",@"©",
                        @"☀︎",@"☽",@"☁︎",@"☔︎",@"★",@"♥︎",@"☃"];
        
    }
    return self;
}

-(void)SetBtnStyle:(UIButton*)button{
    UIColor *Title_Color_Normal = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];

    button.clipsToBounds = YES;
    button.layer.cornerRadius = 4.f;
    
    if([button isEqual:Btn_Send]){
        [button setBackgroundColor:[UIColor colorWithRed:0 green:122.f/255 blue:1 alpha:1]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; //默认颜色
    }else{
        [button setTitleColor:Title_Color_Normal forState:UIControlStateNormal]; //默认颜色
    
    }
}

-(void)delActionWithButton:(UIButton*)button{
    if(DelTimer == nil){
        DelTimer = [NSTimer scheduledTimerWithTimeInterval:.2f
                                                   repeats:YES
                                                     block:^(NSTimer * _Nonnull timer) {
                                                         [Proxy deleteBackward];
                                                    
            
        }];
    }
}


- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    NSLog(@"-----singleTap-----");
    self.IsLockUpper = NO;
    [self Lower_Upper_Change:Btn_Lower];
    [Btn_Lower setTitle:@"⇧" forState:UIControlStateNormal];
    [Btn_Lower setTitle:@"⇧" forState:UIControlStateSelected];
}

- (void)doubleTap:(UIGestureRecognizer*)gestureRecognizer
{
    NSLog(@"-----doubleTap-----");
    self.IsLockUpper = YES;
    if(self.Btn_Lower.selected == NO){
        [self Lower_Upper_Change:Btn_Lower];        
    }
    [Btn_Lower setTitle:@"⇪" forState:UIControlStateSelected];
}



-(void)tapActionWithButton:(UIButton*)button{
    NSString *title = [button titleForState:UIControlStateNormal];

    if([button isEqual:Btn_Lng]){
        //语言切换
        button.selected = !button.selected;
        if(button.selected){
            [button setTitle:@"中" forState:UIControlStateSelected];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [button setBackgroundColor:button.tintColor];
            self.panelModel = keyboardPanelChinese;
        }else{
            [button setTitle:@"En" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor whiteColor]];
            self.panelModel = keyboardPanelEnglish;
        }
        
        CurrentInputText = nil;
        
    }else if([button isEqual:Btn_Chs]){
        // 切换键盘
        //[SuperController advanceToNextInputMode];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"advanceToNextInputMode" object:nil];
        
    }else if([button isEqual:Btn_Del]){
        if(DelTimer){
            [DelTimer invalidate];
            DelTimer = nil;
        }
        
        
        [Proxy deleteBackward];

        //记忆中的输入字符串也自动删除最后一个字符
        if(CurrentInputText && CurrentInputText.length > 0){
            CurrentInputText = [CurrentInputText substringToIndex:CurrentInputText.length-1];
            if(self.delegate && [self.delegate respondsToSelector:@selector(englishKeyboardView:didTextChanged:)]){
                [self.delegate englishKeyboardView:self didTextChanged:CurrentInputText];
            }
        }else{
            //单词删除完成
            CurrentInputText = nil;
        }
        
    }else if([button isEqual:Btn_Space]){
        // 空格
         [Proxy insertText:@" "];
        //单词输入结束
        CurrentInputText = nil;
        
    }else if([button isEqual:Btn_Number]){
        // 数字
        [self Number_String_Change:button];
        CurrentInputText = nil;
        
    }else if([button isEqual:Btn_Symbol]){
        // 符号
        [self Symbol_Change:button];
        CurrentInputText = nil;
        
    }else if([button isEqual:Btn_Send]){
        // 发送
        [Proxy insertText:@"\n"];
        
        //单词输入结束

        CurrentInputText = nil;
        
    }else{
        // 其他

        if(CurrentInputText == nil){
            CurrentInputText = title;
        }else{
            CurrentInputText = [NSString stringWithFormat:@"%@%@",CurrentInputText,title];
        }
        
        [Proxy insertText:title];
        
   
        if(self.delegate && [self.delegate respondsToSelector:@selector(englishKeyboardView:didTextChanged:)]){
            [self.delegate englishKeyboardView:self didTextChanged:CurrentInputText];
        }
        
        //如果大写没有锁定 且 当前启动了大写模式
        //关闭大写键盘
        if(self.IsLockUpper == NO && self.Btn_Lower.selected){
            [self Lower_Upper_Change:self.Btn_Lower];
        }
    }
    
}
#pragma mark 键盘切换：数字／字符 ／符号
-(void)Symbol_Change:(UIButton*)button{
    
    NSString *title = [button titleForState:UIControlStateNormal];
    if([title isEqualToString:@"123"]){
        for(UIButton* item in Btn_Array){
            [item setTitle:NumberArray[item.tag] forState:UIControlStateNormal];
        }
        [button setTitle:@"#+=" forState:UIControlStateNormal];
        
        self.panelModel = keyboardPanelNumber;
        
    }else if([title isEqualToString:@"abc"]){
        
        if(Btn_Lower.selected){
            for(UIButton* item in Btn_Array){
                [item setTitle:LetterArray[item.tag] forState:UIControlStateNormal];
            }
        }else{
            for(UIButton* item in Btn_Array){
                [item setTitle:[LetterArray[item.tag] lowercaseString] forState:UIControlStateNormal];
            }
        }
        [button setTitle:@"#+=" forState:UIControlStateNormal];
        
        if(self.Btn_Lng.selected){
            self.panelModel = keyboardPanelChinese;
        }else{
            self.panelModel = keyboardPanelEnglish;
        }
    }else{
        for(UIButton* item in Btn_Array){
           [item setTitle:SymbolArray[item.tag] forState:UIControlStateNormal];
        }
        
        if(Btn_Lower.enabled){
            [button setTitle:@"abc" forState:UIControlStateNormal];
        }else{
            [button setTitle:@"123" forState:UIControlStateNormal];
        }
        
        self.panelModel = keyboardPanelSymbol;
        
    }
    
}

#pragma mark 键盘切换：数字／字符
-(void)Number_String_Change:(UIButton*)button{
    NSString* title = [button titleForState:UIControlStateNormal];
    if([title isEqualToString:@"123"]){
        Btn_Lower.enabled = NO;
        Btn_Lower.alpha = .3f;
        
        
        for(UIButton* item in Btn_Array){
            [item setTitle:NumberArray[item.tag] forState:UIControlStateNormal];
        }
        
        [button setTitle:@"ABC" forState:UIControlStateNormal];
        self.panelModel = keyboardPanelNumber;
        
    }else{
        Btn_Lower.enabled = YES;
        Btn_Lower.alpha = 1.0f;
        
        
        if(Btn_Lower.selected){
            for(UIButton* item in Btn_Array){
                [item setTitle:LetterArray[item.tag] forState:UIControlStateNormal];
            }
        }else{
            for(UIButton* item in Btn_Array){
                [item setTitle:[LetterArray[item.tag] lowercaseString] forState:UIControlStateNormal];
            }
        }
        
        [button setTitle:@"123" forState:UIControlStateNormal];
        
        if(self.Btn_Lng.selected){
            self.panelModel = keyboardPanelChinese;
            
        }else{
            self.panelModel = keyboardPanelEnglish;
        }
    }
    
    [Btn_Symbol setTitle:@"#+=" forState:UIControlStateNormal];
}

#pragma mark 键盘切换：字母大小写
-(void)Lower_Upper_Change:(UIButton*)button{
    button.selected = !button.selected;
    UIColor *Color_Select = [UIColor colorWithRed:0 green:122.f/255 blue:1 alpha:1];
    UIColor *Color_Normal = [UIColor lightGrayColor];
    
    if(button.selected){
        [button setTintColor:Color_Select];
        [button setBackgroundColor:Color_Select];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        for(UIButton*item in Btn_Array){
            NSString *upper_title = [[item titleForState:UIControlStateNormal] uppercaseString];
            [item setTitle:upper_title forState:UIControlStateNormal];
        }
    }else{
        [button setTintColor:Color_Normal];
        [button setBackgroundColor:Color_Normal];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        for(UIButton*item in Btn_Array){
            NSString *lower_title = [[item titleForState:UIControlStateNormal] lowercaseString];
            [item setTitle:lower_title forState:UIControlStateNormal];
        }
        
    }
}

@end
