//
//  KeyButton.m
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/25.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "KeyButton.h"
@interface KeyButton()
@property(nonatomic,retain)UILabel *TextLabel;
@property(nonatomic,retain)UILabel *POPView;
@end

@implementation KeyButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 */
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.clipsToBounds = NO;
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    if(_TextLabel == nil){
        _TextLabel = [[UILabel alloc]initWithFrame:rect];
        if(_normalTitle){
            _TextLabel.text = _normalTitle;
        }
        if(_normalTitleColor){
            _TextLabel.textColor = _normalTitleColor;
        }
        if(_normalBackgroundColor){
            _TextLabel.backgroundColor = _normalBackgroundColor;
        }
        _TextLabel.textAlignment = NSTextAlignmentCenter;
        _TextLabel.layer.cornerRadius = _cornerRadius;
        
        _TextLabel.clipsToBounds = YES;
        [self addSubview:_TextLabel];
        _TextLabel.sd_layout
        .topSpaceToView(self,0)
        .bottomSpaceToView(self,0)
        .leftSpaceToView(self,0)
        .rightSpaceToView(self,0);
    }
    
    if(_highlightTitleColor == nil){
        self.highlightTitleColor = [UIColor whiteColor];
    }
    
    if(_highlightBackgroundColor == nil){
        self.highlightBackgroundColor = [UIColor colorWithWhite:.2 alpha:1];
    }
    
    if(_normalTitle == nil){
        _normalTitle = _TextLabel.text;
    }
    
    if(_normalTitleColor == nil){
        _normalTitleColor =  _TextLabel.textColor;
    }
    
    if(_normalBackgroundColor == nil){
        _normalBackgroundColor = _TextLabel.backgroundColor;
    }
}

-(void)setDisable:(BOOL)disable{
    _disable = disable;
    if(_disable){
        self.alpha = .5;
    }else{
        self.alpha = 1;
    }
    
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.clipsToBounds = NO;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        
        if(_TextLabel == nil){
            _TextLabel = [[UILabel alloc]initWithFrame:self.bounds];
            _TextLabel.textAlignment = NSTextAlignmentCenter;
            _TextLabel.clipsToBounds = YES;
            [self addSubview:_TextLabel];
        }

        self.highlightBackgroundColor = [UIColor colorWithWhite:.2 alpha:1];
        self.highlightTitleColor = [UIColor whiteColor];
   
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame withTitle:(NSString*)title{
    self = [self initWithFrame:frame];
    _TextLabel.text = title;
    _normalTitle = title;
    _normalTitleColor = _TextLabel.textColor;
    _normalBackgroundColor = _TextLabel.backgroundColor;
    return  self;
}

-(void)setCornerRadius:(CGFloat)cornerRadius{
    _cornerRadius = cornerRadius;
    _TextLabel.layer.cornerRadius = cornerRadius;
    
}


-(void)MakePOPView{
    CGFloat fontSize = [[_TextLabel font]pointSize] *2.5;
    CGFloat popHeight = self.bounds.size.height*1.4;
    CGFloat popX = -self.bounds.size.width*.5;
    CGFloat popY = _cornerRadius/2 - popHeight;
    CGFloat popWidth = self.bounds.size.width*2;
    
    self.POPView = [[UILabel alloc]initWithFrame:CGRectMake(popX,
                                                            popY,
                                                            popWidth,
                                                            popHeight+_cornerRadius/2)];
    _POPView.backgroundColor = self.highlightBackgroundColor;
    _POPView.textColor = self.highlightTitleColor;
    _POPView.textAlignment = NSTextAlignmentCenter;
    _POPView.font = [UIFont systemFontOfSize:fontSize];
    if(self.highlightTitle){
        _POPView.text = self.highlightTitle;
    }else{
        _POPView.text = self.normalTitle;
    }
    
    _POPView.layer.cornerRadius = 8.f;
    _POPView.clipsToBounds = YES;
    
    [self addSubview:_POPView];
    [self sendSubviewToBack:_POPView];
}

-(void)RemovePOPView{
    [self.POPView removeFromSuperview];
    self.POPView = nil;
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(self.disable == YES){
        return;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(KeyButtomDidTouchDownBegin:)]){
        [self.delegate KeyButtomDidTouchDownBegin:self];
    }
    self.keyButtonState = KeyButtonStateHighLight;
    if(self.notUseTip == NO){
        [self MakePOPView];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(self.disable == YES){
        return;
    }
    
    if(self.notUseTip == NO){
        [self RemovePOPView];
    }
    if(self.selected){
        self.keyButtonState = KeyButtonStateSelected;
    }else{
        self.keyButtonState = KeyButtonStateNormal;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(KeyButtomDidTouchUpInside:)]){
        [self.delegate KeyButtomDidTouchUpInside:self];
    }
}

-(void)setFont:(UIFont *)font{
    _font = font;
    _TextLabel.font = font;
}

-(void)setNormalTitle:(NSString *)normalTitle{
    _normalTitle = normalTitle;
    _TextLabel.text = normalTitle;
}

-(void)setSelectedTitle:(NSString *)selectedTitle{
    _selectedTitle = selectedTitle;
    _TextLabel.text = selectedTitle;
}

-(void)setHighlightTitle:(NSString *)highlightTitle{
    _highlightTitle = highlightTitle;
    _TextLabel.text = highlightTitle;
}

-(void)setKeyButtonState:(KeyButtonState)keyButtonState{
    switch (keyButtonState) {
        case KeyButtonStateSelected:{
            if(self.selectedTitle){
                _TextLabel.text = _selectedTitle;
            }
            if(self.selectedTitleColor){
                _TextLabel.textColor = _selectedTitleColor;
            }
            if(self.selectedBackgroundColor){
                _TextLabel.backgroundColor = _selectedBackgroundColor;
            }
        }
            break;
        case KeyButtonStateHighLight:{
            if(self.highlightTitle){
               _TextLabel.text = _highlightTitle;
            }
            if(self.highlightTitleColor){
               _TextLabel.textColor = _highlightTitleColor;
            }

            if(self.highlightBackgroundColor){
                _TextLabel.backgroundColor = _highlightBackgroundColor;
            }
            
        }break;
        default:{
            if(self.normalTitle){
                _TextLabel.text = _normalTitle;
            }
            if(self.normalTitleColor){
                _TextLabel.textColor = _normalTitleColor;
            }
            if(self.normalBackgroundColor){
                _TextLabel.backgroundColor = _normalBackgroundColor;
            }
        }
            break;
    }
    _keyButtonState = keyButtonState;
}



-(void)keyButtonTitle:(NSString*)title withKeyButtonState:(KeyButtonState)state;{
    switch (state) {
        case KeyButtonStateSelected:{
            self.selectedTitle = title;
        }
            break;
        case KeyButtonStateHighLight:{
            self.highlightTitle = title;
        }break;
        default:{
            self.normalTitle = title;
        }
            break;
    }
}

-(void)keyButtonTitleColor:(UIColor*)titleColor withKeyButtonState:(KeyButtonState)state{
    switch (state) {
        case KeyButtonStateSelected:{
            self.selectedTitleColor = titleColor;
        }
            break;
        case KeyButtonStateHighLight:{
            self.highlightTitleColor = titleColor;
        }break;
        default:{
            self.normalTitleColor = titleColor;
        }
            break;
    }
}

-(void)keyButtonBackgroundColor:(UIColor*)color withKeyButtonState:(KeyButtonState)state{
    switch (state) {
        case KeyButtonStateSelected:{
            self.selectedBackgroundColor = color;
        }
            break;
        case KeyButtonStateHighLight:{
            self.highlightBackgroundColor = color;
        }break;
        default:{
            self.normalBackgroundColor = color;
        }
            break;
    }
}
@end
