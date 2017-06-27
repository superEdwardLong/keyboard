//
//  UILoadingView.m
//  BOTboard
//
//  Created by BOT01 on 17/2/17.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "UILoadingView.h"

@implementation UILoadingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithFrame:(CGRect)frame withText:(NSString*)text{
    self = [[[NSBundle mainBundle]loadNibNamed:@"UILoadingView" owner:self options:nil]lastObject];
    if(self){
        self.frame = frame;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        
        CGFloat show_w = frame.size.width*.36;
        CGFloat show_x  = frame.size.width*.32;
        CGFloat show_y = (frame.size.height - show_w)*.5;
        
        self.groupView.frame = CGRectMake(show_x, show_y, show_w, show_w);
        
        self.loading.center = CGPointMake(show_w*.5, show_x*.5-10);
        
        
        if(text){
            self.loadingLabel.text = text;
        }
        CGFloat lable_y = self.loading.center.y+16;
        self.loadingLabel.frame = CGRectMake(8, lable_y, show_w-16, show_w-lable_y);
        
        self.groupView.layer.cornerRadius = 8.f;
        [self.loading startAnimating];
    }
    return self;
}

-(void)setText:(NSString *)text{
    _text = text;
    self.loadingLabel.text = text;
}

-(id)initWithFrame:(CGRect)frame withOnlyText:(NSString *)text{
   self =  [self initWithFrame:frame withText:text];
    if(self){
        [self.loading stopAnimating];
        CGFloat show_w = frame.size.width*.5;
        CGFloat show_h = frame.size.width*.3;
        CGFloat show_x  = frame.size.width*.25;
        CGFloat show_y = (frame.size.height - show_h)*.5;
        self.groupView.frame = CGRectMake(show_x, show_y, show_w, show_h);
        
        self.loadingLabel.frame = self.groupView.bounds;
        self.loadingLabel.font = [UIFont systemFontOfSize:16];
    }
    return self;
}
@end
