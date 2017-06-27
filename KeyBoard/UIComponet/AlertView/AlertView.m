//
//  AlertView.m
//  SMRT Keyborad
//
//  Created by BOT01 on 17/3/6.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "AlertView.h"

@implementation AlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame withMsg:(NSString*)msg withOkTitle:(NSString*)okTitle withCancelTitle:(NSString*)cancelTitle{
    self= [[[NSBundle mainBundle]loadNibNamed:@"AlertView" owner:self options:nil]lastObject];
    if(self){
        self.frame = frame;
       
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.4];
        
        if(msg){
            self.msgLabel.text = msg;
        }
        
        if(okTitle){
            [self.okButton setTitle:okTitle forState:UIControlStateNormal];
        }
        
        if(cancelTitle){
            [self.cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
        }
        
        
        
        self.InnerView.layer.borderColor = [[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1.f]CGColor];
        self.InnerView.layer.borderWidth = 1.f;
        self.InnerView.layer.cornerRadius = 8.f;
        self.InnerView.clipsToBounds = YES;
        
        self.offset_x_doBtn.constant = -frame.size.width * .4001;
        
    }return self;
}


-(instancetype)initWithFrame:(CGRect)frame withMsg:(NSString *)msg withDoFunctionTitle:(NSString *)funcTitle withOkTitle:(NSString *)okTitle withCancelTitle:(NSString *)cancelTitle{
   self =  [self initWithFrame:frame withMsg:msg withOkTitle:okTitle withCancelTitle:cancelTitle];
    if(self){
        self.offset_x_doBtn.constant = 0;
        [self.doButton setTitle:funcTitle forState:UIControlStateNormal];
    }
    return self;
}


- (IBAction)funAction:(UIButton *)sender {
    [self removeFromSuperview];
    if(self.delegate && [self.delegate respondsToSelector:@selector(alertViewDidClickedDo:)]){
        [self.delegate alertViewDidClickedDo:self];
    }
}



- (IBAction)OkAction:(id)sender {
    [self removeFromSuperview];
    if(self.delegate && [self.delegate respondsToSelector:@selector(alertViewDidClickedOk:)]){
        [self.delegate alertViewDidClickedOk:self];
    }
}

- (IBAction)CancelAction:(id)sender {
    [self removeFromSuperview];
    if(self.delegate && [self.delegate respondsToSelector:@selector(alertViewDidClickedCancel:)]){
        [self.delegate alertViewDidClickedCancel:self];
    }
}
@end
