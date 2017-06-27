//
//  ContactViewCell.m
//  SMRT Keyborad
//
//  Created by BOT01 on 17/2/22.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "ContactViewCell.h"

@implementation ContactViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"ContactViewCell" owner:self options:nil]lastObject];
    if(self){
        self.frame = frame;
        self.clipsToBounds = YES;
        self.layer.borderWidth = 1.f;
        self.layer.borderColor = [[UIColor lightGrayColor]CGColor];

        
    }
    return self;
}



- (IBAction)buttonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(ContactViewCell:didClickedEditButton:withItemIndex:)]){
        [self.delegate ContactViewCell:self didClickedEditButton:sender withItemIndex:_CellIndex];
    }
}

@end
