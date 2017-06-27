//
//  FlexButtonView.m
//  HelloWorld1
//
//  Created by mac-mini on 16/8/29.
//  Copyright © 2016年 mac-mini. All rights reserved.
//

#import "FlexButtonView.h"
#import <objc/runtime.h>
#define PADDING 0

@interface FlexButtonView()

@property (nonatomic, assign) float btndistance;
@property(nonatomic,retain)UIScrollView *btnCollectionView;

@end

@implementation FlexButtonView
@synthesize baseButton;
@synthesize buttonArray;

-(instancetype)initWithFrame:(CGRect)frame withBaseButton:(UIButton*)BaseButton withSubButtons:(NSArray*)subButtons{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
        _btndistance = frame.size.width + PADDING; //基础宽度
        
        if(BaseButton){
            [self setBaseButton:BaseButton];
        }
        
        if(subButtons){
            if(_btnCollectionView == nil){
                
                _btnCollectionView = [[UIScrollView alloc]initWithFrame:CGRectMake(_btndistance, 0, frame.size.width-_btndistance, frame.size.height)];
                _btnCollectionView.backgroundColor = [UIColor clearColor];
                _btnCollectionView.clipsToBounds = YES;
                [self addSubview:_btnCollectionView];
    
                _btnCollectionView.sd_layout
                .leftSpaceToView(baseButton, 5)
                .rightSpaceToView(self, 0)
                .topSpaceToView(self, 0)
                .bottomSpaceToView(self, 0);
            }
            
            [self setButtonArray:subButtons];
        }
    }
    return self;
}

-(void)setSelected:(BOOL)selected{
    _selected = selected;
    if(selected){
        self.backgroundColor = [UIColor colorWithRed:1 green:225/255.f blue:0 alpha:1];
        self.baseButton.backgroundColor = [UIColor whiteColor];
    }else{
        self.baseButton.backgroundColor =
        self.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
    }
}

-(void)updateButtonCollectionContentSize{
    CGFloat contentWidth = 0;
    for(UIButton *btn in buttonArray){
        if(btn.hidden == NO){
            contentWidth += btn.frame.size.width+PADDING;
        }        
    }
    [_btnCollectionView setContentSize:CGSizeMake(contentWidth, _btnCollectionView.frame.size.height)];
    _btnCollectionView.alwaysBounceVertical = NO;
}

-(void)setButtonArray:(NSArray *)btnArray{
    
    buttonArray = btnArray;
    int btntag = 100;
    NSInteger lineIndex = -1;
    _SPLITVIEWS = [NSMutableArray arrayWithCapacity:btnArray.count-1];
    
    for (UIButton *btn in buttonArray) {
        btn.alpha = 0;
        btn.tag = btntag;
        
        [btn addTarget:self action:@selector(btnOnclick:) forControlEvents:UIControlEventTouchUpInside];
        [_btnCollectionView addSubview:btn];
        
        
        
        if(-1 < lineIndex){
            
            CGRect lineFrame = CGRectMake(btn.frame.origin.x,
                                          btn.frame.origin.y+btn.frame.size.height*.25,
                                          1,
                                          btn.frame.size.height*.5);
            
            
            UIView*lineView = [[UIView alloc]initWithFrame:lineFrame];
            lineView.hidden = btn.hidden;
            lineView.alpha = 0;
            lineView.backgroundColor = [UIColor colorWithRed:208/255.f green:180/255.f blue:15/255.f alpha:1];
            lineView.transform = CGAffineTransformMakeScale(.5,1);
            [_btnCollectionView addSubview:lineView];
            [_SPLITVIEWS addObject:lineView];
        }
        
        lineIndex++;
        
        btntag ++;
    }
}

-(void)setBaseButton:(UIButton *)btn{
    baseButton = btn;
    baseButton.tag = 99;
    [baseButton addTarget:self action:@selector(ShowHiddenOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:baseButton];
    
}

-(void)ShowHiddenOnclick:(UIButton *)btn{
    if(self.delegate && [self.delegate respondsToSelector:@selector(flexButtonView:didShowHiddenOnclick:)]){
        [self.delegate flexButtonView:self didShowHiddenOnclick:btn];
    }else{
        if (btn.selected == YES) {
            btn.selected = NO;
            [self btnHidden];
        }else{
            btn.selected = YES;
            [self btnShow];
        }
    }
}

-(void)btnHidden{
    [UIView animateWithDuration:0.25 animations:^{
        NSInteger lineIndex = 0;
        for (UIButton *btn in buttonArray) {
            [btn setCenter:baseButton.center];
            btn.alpha = 0;
            
            if(lineIndex < _SPLITVIEWS.count){
                UIView *lineView = [_SPLITVIEWS objectAtIndex:lineIndex];
                [lineView setCenter:CGPointMake(btn.size.width+btn.origin.x, btn.center.y)];
                lineView.alpha = 0;
                lineView.hidden = btn.hidden;                
            }
            lineIndex++;
        }
        
    } completion:^(BOOL finished) {
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, _btndistance, baseButton.frame.size.height)];
    }];
}

-(void)btnShow{
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, _componetMaxWidth, baseButton.frame.size.height)];
    [UIView animateWithDuration:0.25 animations:^{
        CGFloat offsetX = 0;
        NSInteger lineIndex = -1;
        for (UIButton *btn in buttonArray) {
            if(btn.tag == 100){
                offsetX = PADDING + btn.frame.size.width/2;
            }else{
                UIButton*prevButton = [self viewWithTag:btn.tag-1];
                offsetX = prevButton.center.x + prevButton.frame.size.width/2 + PADDING + btn.frame.size.width/2;
            }
            
            [btn setCenter:CGPointMake(offsetX, btn.center.y) ];
            btn.alpha = 1;
            
            if(-1 < lineIndex){
                
                UIView *lineView = [_SPLITVIEWS objectAtIndex:lineIndex];
                [lineView setCenter:CGPointMake(btn.origin.x, btn.center.y)];
                lineView.alpha = 1;
                lineView.hidden = btn.hidden;
            }
            lineIndex++;
        }
    }];
}

-(void)btnOnclick:(UIButton *)btn{
    if(self.delegate && [self.delegate respondsToSelector:@selector(flexButtonView:didOptionOnclick:)]){
        [self.delegate flexButtonView:self didOptionOnclick:btn];
    }else{
        self.flexBlock(btn);
    }
}


-(UIButton *)getBaseButton{
    return baseButton;
}
@end
