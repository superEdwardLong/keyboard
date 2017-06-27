//
//  FlexButtonView2.m
//  SMRT Board V3
//
//  Created by BOT01 on 2017/5/7.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "FlexButtonView2.h"

@implementation FlexButtonView2

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"FlexButtonView2" owner:self options:nil]lastObject];
    if(self){
        
        [_option_view registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"OPTIONCELL"];
        _option_view.delegate = self;
        _option_view.dataSource = self;
        _option_view.hidden = YES;
        _option_view.alpha = 0;
        
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 3.f;
        
        UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        tap.numberOfTapsRequired = 1;
    
        
        _label_value.textColor =
        _label_value.tintColor = [UIColor orangeColor];
        
        _label_value.font = [UIFont systemFontOfSize:12];
        [_label_value addGestureRecognizer:tap];
        
        
    }return self;
}

-(instancetype)initWithFrame:(CGRect)frame withBaseTitle:(NSString*)title withDefaultValue:(NSString*)defaultValue withOptions:(NSArray*)options{
    self = [self initWithFrame:frame];
    if(self){
        
        [self setDefaultValue:defaultValue];
        [self setBaseTitle:title];
        [self setOptions:options];
        
    }return self;
}

-(void)tapAction:(UITapGestureRecognizer*)sender{
    [self baseButtonAction:_btn_base];
}

- (IBAction)baseButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(sender.selected == YES){
        //展开
        if(self.delegate && [self.delegate respondsToSelector:@selector(flexButtonViewWillDisplay:)]){
            [self.delegate flexButtonViewWillDisplay:self];
            [self performSelector:@selector(showHideFlexButton:) withObject:sender afterDelay:0.3];
        }else{
            [self showHideFlexButton:sender];
        }
        
    }else{
        //关闭
        if(self.delegate && [self.delegate respondsToSelector:@selector(flexButtonViewWillDedisplay:)]){
            [self.delegate flexButtonViewWillDedisplay:self];
            [self performSelector:@selector(showHideFlexButton:) withObject:sender afterDelay:0.3];
        }else{
            [self showHideFlexButton:sender];
        }
        
    }
}

-(void)resetFlextButtonView{
    _btn_base.selected = NO;
    _label_value.alpha = 1;
    
    _option_view.hidden = YES;
    
    _option_view.alpha = 0;
    
}

-(void)showHideFlexButton:(UIButton*)sender{
    _option_view.hidden = !sender.selected;
    
    
    CGFloat alpha = sender.selected ? 1.f : 0.f;
    CGFloat valAlpha = sender.selected ? 0.f : 1.f;
    [UIView animateWithDuration:0.3 animations:^{
        _option_view.alpha = alpha;
        
        _label_value.alpha = valAlpha;
    }];
}

- (IBAction)backButtonAction:(UIButton *)sender {
    [self baseButtonAction:_btn_base];
}

-(void)setBaseTitle:(NSString*)baseTitle{
    [_btn_base setTitle:baseTitle forState:UIControlStateNormal];
    CGRect rect = [baseTitle boundingRectWithSize:CGSizeMake(1000.f, 34)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}
                                      context:nil];
    
    CGFloat max_width  = 60;
    CGFloat width = MIN(max_width, rect.size.width+10);
    _width_base.constant = width;
}

-(void)setDefaultValue:(NSString*)defaultValue{
    _label_value.text = defaultValue;
}

-(void)setOptions:(NSArray*)options{
    _options = options;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _options.count;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [_options objectAtIndex:indexPath.item];
    CGRect rect = [title boundingRectWithSize:CGSizeMake(1000.f, 34)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}
                                      context:nil];
    
    return  CGSizeMake(rect.size.width+16, 34);
}
-(__kindof UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *CELL = [collectionView dequeueReusableCellWithReuseIdentifier:@"OPTIONCELL" forIndexPath:indexPath];
    if(CELL){
        CELL.backgroundColor = [UIColor clearColor];
        CELL.contentView.backgroundColor = [UIColor clearColor];
        
        UILabel *label = [CELL.contentView viewWithTag:99];
        if(label == nil){
            label = [[UILabel alloc]initWithFrame:CELL.contentView.bounds];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:12.f];
            label.tag = 99;
            label.textColor =
            label.tintColor = [UIColor orangeColor];
            [CELL.contentView addSubview:label];
        }
        label.text = [_options objectAtIndex:indexPath.item];
        label.frame = CELL.contentView.bounds;
    }
    return CELL;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _label_value.text = [_options objectAtIndex:indexPath.item];
    [self baseButtonAction:_btn_base];
}
@end
