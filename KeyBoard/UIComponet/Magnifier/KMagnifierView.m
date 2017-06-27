//
//  KMagnifierView.m
//  BOTboard
//
//  Created by BOT01 on 17/2/13.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "KMagnifierView.h"
#define fierRadius 40.f

@interface KMagnifierView()
@property(nonatomic,strong)UIImageView *imageView;
@end

@implementation KMagnifierView

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
        // Initialization code
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, fierRadius*2, fierRadius*2);
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:1.f];
        self.layer.borderWidth = 2;
        self.layer.borderColor = [[UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1] CGColor];
        self.layer.cornerRadius = fierRadius;
        self.layer.masksToBounds = YES;
        self.layer.contentsScale = [[UIScreen mainScreen]scale];
        
        self.imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeTopLeft;
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)setPointToMagnify:(CGPoint)pointToMagnify
{
    _pointToMagnify = pointToMagnify;//触摸点坐标
    CGFloat centerX = MAX(fierRadius, pointToMagnify.x);
    CGFloat centerY = pointToMagnify.y - fierRadius + self.pointToCut.y;
    //放大镜定位
    CGPoint center = CGPointMake(centerX, centerY);
    self.center = center;

    CGPoint MovePoint = CGPointMake(self.pointToCut.x - pointToMagnify.x, -pointToMagnify.y + fierRadius/2);

    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //移动context
    CGContextTranslateCTM(context,MovePoint.x,MovePoint.y);
    CGContextScaleCTM(context,1.2,1.2);
    [self.viewToMagnify.layer renderInContext:context];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imageView.image = outputImage;
}
@end
