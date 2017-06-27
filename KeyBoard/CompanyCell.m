//
//  CompanyCell.m
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/20.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "CompanyCell.h"

@implementation CompanyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(id)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"CompanyCell" owner:self options:nil]lastObject];
    if(self){
        UIView *select_bg = [[UIView alloc]initWithFrame:self.bounds];
        select_bg.backgroundColor = [UIColor yellowColor];
        self.selectedBackgroundView = select_bg;
    }
    return self;
}
@end
