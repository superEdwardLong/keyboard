//
//  BasicBoardView.m
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/25.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "BasicBoardView.h"
@interface BasicBoardView()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *Rows;

@property (weak, nonatomic) IBOutlet KeyButton *Btn_Lower;
@property (weak, nonatomic) IBOutlet KeyButton *Btn_Del;
@property (weak, nonatomic) IBOutlet KeyButton *Btn_Number;
@property (weak, nonatomic) IBOutlet KeyButton *Btn_Chs;
@property (weak, nonatomic) IBOutlet KeyButton *Btn_Space;
@property (weak, nonatomic) IBOutlet KeyButton *Btn_Lng;
@property (weak, nonatomic) IBOutlet KeyButton *Btn_Send;
@property (weak, nonatomic) IBOutlet KeyButton *Btn_Symbol;


@property (weak, nonatomic) IBOutlet UIView *row_1;
@property (weak, nonatomic) IBOutlet UIView *row_2;
@property (weak, nonatomic) IBOutlet UIView *row_3;
@property (weak, nonatomic) IBOutlet UIView *row_4;

@property(nonatomic,strong)NSTimer *DelTimer;
@property(nonatomic,retain)NSArray *defaultKeyTitles;

@end

@implementation BasicBoardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code ⇪
}
*/
-(id)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"BasicBoardView" owner:self options:nil]lastObject];
    if(self){
        self.frame = frame;
        _defaultKeyTitles = @[@[@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p"],
                         @[@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l"],
                         @[@"⇧",@"z",@"x",@"c",@"v",@"b",@"n",@"m",@"⌫"],
                         @[@"123",@"🌐",@"符",@"space",@"英",@"send"]
                         ];
        
        
        NSInteger row,col;
        for(UIView* item in _Rows){
            for(KeyButton*view in item.subviews){
                row = view.tag /100 -1;
                col = view.tag % 100;
                [((KeyButton*)view) keyButtonTitle:_defaultKeyTitles[row][col] withKeyButtonState:KeyButtonStateNormal];
                
                [((KeyButton*)view) keyButtonTitleColor:[UIColor colorWithWhite:0 alpha:1] withKeyButtonState:KeyButtonStateNormal];
                [((KeyButton*)view) keyButtonBackgroundColor:[UIColor colorWithWhite:1 alpha:1] withKeyButtonState:KeyButtonStateNormal];

                [((KeyButton*)view) setHighlightBackgroundColor:[UIColor colorWithRed:253/255.f green:220/255.f blue:10/255.f alpha:1]];
                
                ((KeyButton*)view).cornerRadius = 4.f;
                ((KeyButton*)view).delegate = self;
                if(row == 3 || (row == 2 && col == 0) || (row == 2 && col == 8)){
                    ((KeyButton*)view).notUseTip = YES;
                }
            }
        }
    
    }
    return self;
}

-(void)ChangedLowerToUpper:(BOOL)upper{
    NSInteger row,col;
    for(UIView* item in _Rows){
        for(KeyButton*view in item.subviews){
            row = view.tag /100 -1;
            col = view.tag % 100;
            if(row < 2 || (row == 2 && col != 0  && col != 8)){
                NSString*title = upper ? [_defaultKeyTitles[row][col] uppercaseString]:[_defaultKeyTitles[row][col] lowercaseString];
                ((KeyButton*)view).normalTitle = title;
                
            }
        }
    }
}

-(void)setCurrentInputText:(NSString *)CurrentInputText{
    _CurrentInputText = CurrentInputText;
    //回调查询
        if(_panelModel == keyboardPanelChinese){
            if(self.delegate && [self.delegate respondsToSelector:@selector(basicBoardView:didChineseInputTextChanged:)]){
                [self.delegate basicBoardView:self didChineseInputTextChanged:CurrentInputText];
            }return;
        }
        
        if(_panelModel == keyboardPanelEnglish){
            if(self.delegate && [self.delegate respondsToSelector:@selector(basicBoardView:didEnglishInputTextChanged:)]){
                [self.delegate basicBoardView:self didEnglishInputTextChanged:CurrentInputText];
            }return;
        }
}

-(void)MakeNumberView{
    if(_NumberView == nil){
        _NumberView = [[NumberKeyboardView alloc]initWithFrame:CGRectMake(0, self.size.height, self.size.width, self.size.height)];
        _NumberView.Proxy = _Proxy;
        [_NumberView.backButton  addTarget:self action:@selector(dismissOtherBoardView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_NumberView];
       
        [UIView animateWithDuration:0.3 animations:^{
            _NumberView.frame = self.bounds;
        }];
    }
    
    _panelModel = keyboardPanelNumber;
}

-(void)MakeSymbolView{
    if(_SymbolView == nil){
        _SymbolView = [[SymbolKeyboardView alloc]initWithFrame:CGRectMake(0, self.size.height, self.size.width, self.size.height)];
        _SymbolView.Proxy = _Proxy;
        [self addSubview:_SymbolView];
        
        [_SymbolView.backButton addTarget:self action:@selector(dismissOtherBoardView:) forControlEvents:UIControlEventTouchUpInside];
        [_SymbolView.abcButton addTarget:self action:@selector(dismissNumberBoardAndSymbolBoard) forControlEvents:UIControlEventTouchUpInside];
        [_SymbolView.numberButton addTarget:self action:@selector(showNumberViewFromSymbolView) forControlEvents:UIControlEventTouchUpInside];
        
        [UIView animateWithDuration:0.3 animations:^{
            _SymbolView.frame = self.bounds;
        }];
    }
    _panelModel = keyboardPanelSymbol;
    
}
-(void)showNumberViewFromSymbolView{
    [self MakeNumberView];
    [self dismissOtherBoardView:_SymbolView.numberButton];
}

-(void)dismissNumberBoardAndSymbolBoard{
    if(_NumberView){
        [self dismissOtherBoardView:_NumberView.backButton];
    }
    if(_SymbolView){
        [self dismissOtherBoardView:_SymbolView.backButton];
    }
    
    if([_Btn_Lng.normalTitle isEqualToString:@"英"]){
        _panelModel = keyboardPanelEnglish;
    }else{
         _panelModel = keyboardPanelChinese;
    }
   
    
}

-(void)dismissOtherBoardView:(UIButton*)sender{
    UIView *otherBoardView;
    if([sender isEqual:_NumberView.backButton]){
        otherBoardView = _NumberView;
        
    }else{
        otherBoardView = _SymbolView;
    }
    
    if(otherBoardView == nil) return;
    
    [UIView animateWithDuration:0.3 animations:^{
        otherBoardView.frame = CGRectMake(0, self.size.height, self.size.width, self.size.height);
    } completion:^(BOOL finished) {
        [otherBoardView removeFromSuperview];
        if([sender isEqual:_NumberView.backButton]){
            _NumberView = nil;
            
        }else{
            _SymbolView = nil;
        }
    }];
    
    if([_Btn_Lng.normalTitle isEqualToString:@"英"]){
        _panelModel = keyboardPanelEnglish;
    }else{
        _panelModel = keyboardPanelChinese;
    }

}




#pragma mark 按键的代理方法
-(void)KeyButtomDidTouchDownBegin:(KeyButton *)keyButton{
    [keyButton.superview bringSubviewToFront:keyButton];
    
    if([keyButton isEqual:_Btn_Del]){
        //启动循环调用删除
        if(_DelTimer == nil){
            _DelTimer = [NSTimer scheduledTimerWithTimeInterval:.1f
                                                       repeats:YES
                                                         block:^(NSTimer * _Nonnull timer) {
                                                             [_Proxy deleteBackward];
                                                             //记忆中的字符也同步删除一个字符
                                                             if(_CurrentInputText && _CurrentInputText.length > 1){
                                                                 self.CurrentInputText = [_CurrentInputText substringToIndex:_CurrentInputText.length-1];
                                                             }else{
                                                                 self.CurrentInputText = nil;
                                                             }
                                                         }];
        }
    }
}

-(void)KeyButtomDidTouchUpInside:(KeyButton *)keyButton{
    NSString *keyValue = keyButton.normalTitle;
    
    //中英切换
    if([keyButton isEqual:_Btn_Lng]){
        if([keyValue isEqualToString:@"英"]){
            _panelModel = keyboardPanelChinese;
            keyButton.normalTitle = @"中";
        }else{
            _panelModel = keyboardPanelEnglish;
            keyButton.normalTitle = @"英";
        }
        self.CurrentInputText = nil;
        return;
    }
    
    //切换输入法
    if([keyButton isEqual:_Btn_Chs]){
        _CurrentInputText = nil;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"advanceToNextInputMode" object:nil];
        return;
    }
    
    //大小写切换
    if([keyButton isEqual:_Btn_Lower]){
        if([keyValue isEqualToString:@"⇪"]){
            //调用小写
            keyButton.normalTitle = @"⇧";
            [self ChangedLowerToUpper:NO];
        }else{
            //调用大写
            keyButton.normalTitle = @"⇪";
             [self ChangedLowerToUpper:YES];
        }
        
        return;
    }
    
    //停止循环删除
    if([keyButton isEqual:_Btn_Del]){
        if(_DelTimer){
            [_DelTimer invalidate];
            _DelTimer = nil;
        }
        [_Proxy deleteBackward];
        //记忆中的字符也同步删除一个字符
        if(_CurrentInputText && _CurrentInputText.length > 1){
            self.CurrentInputText = [_CurrentInputText substringToIndex:_CurrentInputText.length-1];
        }else{
            self.CurrentInputText = nil;
        }
        return;
    }
    
    //空格
    if([keyButton isEqual:_Btn_Space]){
        [_Proxy insertText:@" "];
        self.CurrentInputText = nil;
        return;
    }
    
    if([keyButton isEqual:_Btn_Send]){
        [_Proxy insertText:@"\n"];
        self.CurrentInputText = nil;
        return;
    }
    
    
    //数字
    if([keyButton isEqual:_Btn_Number]){
        self.CurrentInputText = nil;
        // 呼叫数字键盘
        [self MakeNumberView];
        return ;
    }
    
    //符号
    if([keyButton isEqual:_Btn_Symbol]){
        self.CurrentInputText = nil;
        //呼叫符号键盘
        [self MakeSymbolView];
        return;
    }
    
    //其他键
    [_Proxy insertText:keyValue];
    if(_CurrentInputText == nil){
        self.CurrentInputText = keyValue;
    }else{
        self.CurrentInputText = [NSString stringWithFormat:@"%@%@",_CurrentInputText,keyValue];
    }
}
@end
