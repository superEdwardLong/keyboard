//
//  OrderInfoView.m
//  SMRT Board V3
//
//  Created by john long on 2017/5/3.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "OrderInfoView.h"

@implementation OrderInfoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
        
    if(self.delegate && [self.delegate respondsToSelector:@selector(orderInfoView:didSelectTabbarItem:)]){
        [self.delegate orderInfoView:self didSelectTabbarItem:item.tag];
    }
    
}

-(id)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"OrderInfoView" owner:self options:nil]lastObject];
    if(self){
        self.frame = frame;
        self.tabbar.delegate =  self;
        NSArray *itemImages = @[@"icon-shaohoushiyong",@"icon-shanchujilu",@"icon-hujiaoshunfeng"];
        NSArray *itemTitles = [self getTabbarItemsTitle];
        
        for(UITabBarItem*item in _tabbar.items){
            UIImage *itemImgage = [[UIImage imageNamed:itemImages[item.tag]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [item setImage:itemImgage];
            [item setTitle:[itemTitles objectAtIndex:item.tag]];
        }
        
        [self performSelector:@selector(drawArrow) withObject:nil afterDelay:.3f];
        
        BoardDB*db = [BoardDB new];
        _label_infoTip.text = [db getPageItemTitle:@"infoTip"];
        
    }return self;
}
-(NSArray*)getTabbarItemsTitle{
    BoardDB* db = [BoardDB new];
    NSString* title_later =  [db getMenuItemTitle:@"later"];
    NSString* title_del =  [db getMenuItemTitle:@"del"];
    NSString* title_callXiaoGe =  [db getMenuItemTitle:@"appointmentXiaoGe"];
    return @[title_later,title_del,title_callXiaoGe];
}
-(void)drawArrow{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(10, _col_2.frame.size.height/2+10)];
    [path addLineToPoint:CGPointMake(_col_2.frame.size.width-20, _col_2.frame.size.height/2+10)];
    [path addLineToPoint:CGPointMake(_col_2.frame.size.width-26, _col_2.frame.size.height/2)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = 1;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.path = path.CGPath;
    shapeLayer.frame = _col_2.bounds;
    
    [_col_2.layer addSublayer:shapeLayer];
}

-(id)initWithFrame:(CGRect)frame withOrderId:(NSInteger)OrderId{
    self = [self initWithFrame:frame];
    if(self){
        self.OrderId = OrderId;
        
    }
    return self;
}

-(void)setOrderId:(NSInteger)OrderId{
    _OrderId = OrderId;
    [self requestOrderInfo:OrderId];
}

-(void)requestOrderInfo:(NSInteger)orderId{
    BoardDB *db = [BoardDB new];
    NSString *sql = [NSString stringWithFormat:@"SELECT * From MailList WHERE mail_id = %ld",orderId];
    NSMutableArray *cols = [[db FindWithSql:sql withReturnFields:@[
                                           @"mail_id",              //-----------------> 0
                                           @"mail_order_id",        //-----------------> 1
                                           @"mail_package_type",    //-----------------> 2
                                           @"mail_package_price",   //-----------------> 3
                                           @"mail_pay_model",       //-----------------> 4
                                           @"mail_from_user",       //-----------------> 5
                                           @"mail_from_phone",      //-----------------> 6
                                           @"mail_from_province",   //-----------------> 7
                                           @"mail_from_city",       //-----------------> 8
                                           @"mail_from_address",    //-----------------> 9
                                           @"mail_to_user",         //-----------------> 10
                                           @"mail_to_phone",        //-----------------> 11
                                           @"mail_to_province",     //-----------------> 12
                                           @"mail_to_city",         //-----------------> 13
                                           @"mail_to_address",      //-----------------> 14
                                           @"mail_assign_time",//-----------------> 15
                                           @"mail_state",//-----------------> 16
                                           @"mail_to_targetNumber"]] firstObject];
    
    _label_sender_city.text = cols[8];
    _label_sender_name.text = [cols[5] stringByReplacingOccurrencesOfString:@"，" withString:@""];
    
    _label_receive_city.text = cols[13];
    _label_receive_name.text = [cols[10] stringByReplacingOccurrencesOfString:@"，" withString:@""];
    
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.恢复默认
    [filter setDefaults];
    // 3.给过滤器添加数据(正则表达式/账号和密码)
    NSString*targetCityCode = cols[17];
    if(targetCityCode.length > 2){
        targetCityCode = [targetCityCode substringFromIndex:1];
    }
    NSMutableString *QRCodeString = [NSMutableString string];
    [QRCodeString appendString:@"IOS.APP|ZNZD-13|T4|1|"];
    [QRCodeString appendString:cols[4]];
    [QRCodeString appendString:@"||1|"];
    [QRCodeString appendString:cols[3]];
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:cols[2]];
    [QRCodeString appendString:@"|1|0||"];
    [QRCodeString appendString:cols[10]];
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:cols[11]];
    [QRCodeString appendString:@"||"];
    
    [QRCodeString appendString:targetCityCode];
    
    
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:cols[12]];
    [QRCodeString appendString:cols[13]];
    [QRCodeString appendString:cols[14]];
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:cols[5]];
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:cols[6]];
    [QRCodeString appendString:@"||"];
    [QRCodeString appendString:cols[7]];
    [QRCodeString appendString:cols[8]];
    [QRCodeString appendString:cols[9]];
    [QRCodeString appendString:@"|UCMP"];
    [QRCodeString appendString:cols[1]];
    
    
    NSData *data = [QRCodeString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 4.获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    // 5.将CIImage转换成UIImage，并放大显示
    self.qr_image.image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:200];
    
    UITabBarItem * item =  [_tabbar.items lastObject];
    UIImage *imgNormal,*imgSelected;
    switch ([cols[16]integerValue]) {
        case OrderStateComplete:{
            imgNormal = [[UIImage imageNamed:@"icon-ordercomplete"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            imgSelected = [[UIImage imageNamed:@"icon-ordercomplete"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [item setImage:imgNormal];
            [item setSelectedImage:imgSelected];
            [item setTitle:[db getPageItemTitle:@"done"]];
        }
            break;
        case OrderStateWaitingReciive:{
            imgNormal = [[UIImage imageNamed:@"icon-yuyueshunfeng"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            imgSelected = [[UIImage imageNamed:@"icon-yuyueshunfeng"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [item setImage:imgNormal];
            [item setSelectedImage:imgSelected];
            [item setTitle:[db getMenuItemTitle:@"appointmentDone"]];
        }
        default:{
        }
            break;
    }
}


/**
 * 根据CIImage生成指定大小的UIImage
 *
 * @param image CIImage
 * @param size 图片宽度
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}
@end
