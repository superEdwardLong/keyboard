//
//  KUITextView.m
//  BOTboard
//
//  Created by BOT01 on 17/2/16.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "KUITextView.h"

@implementation KUITextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.editable = NO;
//        self.layer.borderColor = [[UIColor colorWithRed:.95 green:.95 blue:.95 alpha:1]CGColor];
//        self.layer.borderWidth = 1.f;
//        self.layer.cornerRadius = 6.f;
        self.font = [UIFont systemFontOfSize:16.f];
        [self AddPlaceHolder];
    }
    return self;
}

-(void)AddPlaceHolder{
    if([self viewWithTag:999] == nil){
        UILabel *label = [[UILabel alloc]initWithFrame:self.bounds];
        label.tag = 999;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:25];
        label.textColor = [UIColor colorWithWhite:.5 alpha:1];
        label.text = @"请把地址粘贴到这里，长按调用功能菜单";
        label.numberOfLines = 0;
        [self addSubview:label];
    }else{
        [[self viewWithTag:999] setHidden:NO];
    }
}


-(void)ClearPlaceHolder{
    if([self viewWithTag:999]){
        [[self viewWithTag:999] setHidden:YES];
    }
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    BOOL doFun = action == @selector(cut:);
    if(doFun){
        if([self.KDelegate respondsToSelector:@selector(kTextViewDidConfirmSelection:)]){
            [self.KDelegate kTextViewDidConfirmSelection:self];
        }
    }
    return doFun;
}
@end
