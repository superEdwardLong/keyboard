//
//  OrderListCell.m
//  SMRT Board V3
//
//  Created by john long on 2017/5/3.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "OrderListCell.h"

@implementation OrderListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    //self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self = [[[NSBundle mainBundle]loadNibNamed:@"OrderListCell" owner:self options:nil]lastObject];
    if(self){
        
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path moveToPoint:CGPointMake(0, _col_2.frame.size.height/2+10)];
        [path addLineToPoint:CGPointMake(_col_2.frame.size.width, _col_2.frame.size.height/2+10)];
        [path addLineToPoint:CGPointMake(_col_2.frame.size.width-5, _col_2.frame.size.height/2+5)];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.lineWidth = 1;
        shapeLayer.lineJoin = kCALineJoinRound;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.path = path.CGPath;
        shapeLayer.frame = _col_2.bounds;
        
        [_col_2.layer addSublayer:shapeLayer];
        
        [_col_2 bringSubviewToFront:_label_state];
    }
    return self;
}

- (IBAction)printAction:(UIButton *)sender {
    NSString *poster = [NSString stringWithFormat:@"CallPrinter&PrintId=%ld",_orderId];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CallAppPage" object:poster];
}
@end
