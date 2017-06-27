//
//  ContactViewCell2.m
//  SMRT Keyborad
//
//  Created by BOT01 on 17/3/20.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "ContactViewCell2.h"
@interface ContactViewCell2()

@end

@implementation ContactViewCell2

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(id)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"ContactViewCell2" owner:self options:nil]lastObject];
    if(self){
        self.frame = frame;
        for(UITextView *textView in self.FieldArr){
            textView.textContainer.lineFragmentPadding = 0;
            textView.textContainerInset = UIEdgeInsetsZero;
            textView.delegate = self;
        }
        BoardDB *db = [BoardDB new];
        [self.SaveButton setTitle:[db getMenuItemTitle:@"edit"] forState:UIControlStateNormal];
        
        self.layer.borderWidth = 1.f;
        self.layer.borderColor = [[UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.f]CGColor];
        
        self.UserImageView.clipsToBounds = YES;
        self.UserImageView.layer.cornerRadius = _UserImageView.bounds.size.width/2;
        
        
        UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [self.UserImageView addGestureRecognizer:tap];
        
        
        for(UITextView *textView in self.FieldArr){
            UILabel *textPlaceholder = [[UILabel alloc]initWithFrame:textView.bounds];
            textPlaceholder.font = textView.font;
            textPlaceholder.textColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1.f];
            textPlaceholder.backgroundColor = [UIColor clearColor];
            textPlaceholder.tag = 300;
            [textView addSubview:textPlaceholder];
            if([textView isEqual:_NameField]){
                textPlaceholder.text = @"Name";
            }else if([textView isEqual:_TelField]){
                textPlaceholder.text = @"Phone";
            }else if([textView isEqual:_ProvinceField]){
                textPlaceholder.text = @"Province";
            }else if([textView isEqual:_CityField]){
                textPlaceholder.text = @"City";
            }else{
                textPlaceholder.text = @"Address";
            }
            UITapGestureRecognizer*textTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(textTapAction:)];
            [textView addGestureRecognizer:textTap];
        }
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didAllTextViewEditEnd)
                                                     name:@"didAllTextViewEditEnd"
                                                   object:nil];
        
    }return self;
}




- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        return NO;
    }
    return YES;
}



-(void)setCellIndex:(NSInteger)CellIndex{
    _CellIndex = CellIndex;
}


-(void)setTextViewPlaceholderHide:(UITextView *)textView{
    if(textView.text.length == 0){
        [[textView viewWithTag:300] setHidden:NO];
    }else{
        [[textView viewWithTag:300] setHidden:YES];
    }
}

-(void)setForm:(ContactModel *)data{
    _NameField.text = data.strName;
    _TelField.text = data.strPhone;
    _ProvinceField.text = data.strProv;
    _CityField.text = data.strCity;
   _AddressField.text = data.strAddress;
    _ContactId = data.contactId;
    
    if(data.strImage.length > 0){
        _UserImageView.image = [UIImage imageWithContentsOfFile:data.strImage];
        _UserImageView.accessibilityIdentifier = data.strImage;
    }else{
        _UserImageView.image = [UIImage imageNamed:@"touxianghui-2"];
    }
    
    for(UITextView *textView in self.FieldArr){
        
         [self setTextViewPlaceholderHide:textView];

    }
}

-(void)resetForm{
    //显示代替文本
    for(UITextView *textView in self.FieldArr){
        textView.text = @"";
        [[textView viewWithTag:300] setHidden:NO];
    }
    //隐藏光标
    [self didAllTextViewEditEnd];
}

-(void)setTextView:(UITextView*)textView Value:(NSString*)value{
    if(value && value.length >0){
        textView.text = value;
        [[textView viewWithTag:300]setHidden:YES];
    }
    [self didAllTextViewEditEnd];
}

-(void)tapAction:(UITapGestureRecognizer*)sender{
     if(_editEnable == NO)return;
    UIImageView* img =  (UIImageView*)sender.view;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"showImagePicker" object:@{@"Image":img,@"Cell":self}];

}

#pragma mark 编辑事件
- (IBAction)buttonAction:(UIButton *)sender {
    if(sender.tag == 200){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ContactBeginEdit" object:self];
    }else{
         [[NSNotificationCenter defaultCenter]postNotificationName:@"ContactEndEdit" object:self];
    }
    
}



-(void)textTapAction:(UITapGestureRecognizer*)sender{
    if(_editEnable == NO)return;
    
    //撤销上一个输入框的光标
    if(self.currentTextView != nil){
        [[self.currentTextView viewWithTag:200] setHidden:YES];
    }

    UITextView * textView = (UITextView*)sender.view;

    
    //当前输入框的光标定位
    [self setFocusWithTextView:textView];
    
    /*打开键盘
     */
    if([textView isEqual:_ProvinceField] || [textView isEqual:_CityField]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"dataPickerShow" object:@{@"Cell":self,@"Visible":@1}];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CallKeyboard"
                                                            object:@{@"Visible":@1,@"UIInput":textView}
                                                          userInfo:nil];
    }
    
    
    
    //更新当前对象
    self.currentTextView = textView;
}

-(void)setFocusWithTextView:(UITextView*)textView{
    UIView *cursorView = [textView viewWithTag:200];
 
    CGPoint cursorPosition = [textView caretRectForPosition:textView.selectedTextRange.start].origin;
    CGRect cursorFrame = CGRectMake(cursorPosition.x, cursorPosition.y, 2,18);
    if(cursorView == nil){
        cursorView = [[UIView alloc]initWithFrame:cursorFrame];
        cursorView.tag = 200;
        cursorView.backgroundColor = [UIColor blueColor];
        [textView addSubview:cursorView];
        
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
        opacityAnimation.repeatCount = HUGE_VALF;
        opacityAnimation.duration = .9f;
        [cursorView.layer addAnimation:opacityAnimation forKey:@"AC_Opacity"];
    }else{
        cursorView.frame = cursorFrame;
        cursorView.hidden = NO;
    }
}


#pragma mark 所有输入对象结束编辑
-(void)didAllTextViewEditEnd{
    self.currentTextView = nil;
    for(UITextView *textView in self.FieldArr){
        UIView *itemView = [textView viewWithTag:200];
        itemView.hidden = YES;
    }
}

//文本变化中,光标重新定位
-(void)textViewDidChange:(UITextView *)textView{
     [self setFocusWithTextView:textView];
    [self setTextViewPlaceholderHide:textView];
}
@end

