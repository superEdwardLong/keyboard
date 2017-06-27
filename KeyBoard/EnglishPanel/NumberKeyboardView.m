//
//  NumberKeyboardView.m
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/18.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "NumberKeyboardView.h"

@implementation NumberKeyboardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"NumberKeyboardView" owner:self options:nil]lastObject];
    if(self){

    }
    return self;
}
- (IBAction)doAction:(UIButton *)sender {
    for(UIButton*item in self.buttonArr){
        if([sender isEqual:item]){
            if([sender isEqual:_deleteButton] ){
                [self.Proxy deleteBackward];
            }else if([sender isEqual:_enterButton]){
                [self.Proxy insertText:@"\n"];
            }else if([sender isEqual:_spaceButton]){
                [self.Proxy insertText:@" "];
            }else{
                [self.Proxy insertText:[item titleForState:UIControlStateNormal]];
            }
            break;
        }
        
    }
}

@end
