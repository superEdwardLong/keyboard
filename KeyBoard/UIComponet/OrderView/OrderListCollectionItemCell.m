//
//  OrderListCollectionItemCell.m
//  SMRT Board V3
//
//  Created by john long on 2017/5/23.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//
#import "BoardDB.h"
#import "OrderListCollectionItemCell.h"

@implementation OrderListCollectionItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"OrderListCollectionItemCell" owner:self options:nil]lastObject];
    self.frame = frame;
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
        
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor colorWithWhite:.8 alpha:1]CGColor];
        
        [self bringSubviewToFront:_label_state];
    }
    return self;
}

-(NSString*)formatDateWithString:(NSString*)str{
    NSString *shorTime = @"";
    if(str.length >0){
        shorTime = [[str componentsSeparatedByString:@" "]firstObject];
    }
    return shorTime;
}
-(NSString*)formatNumerWithString:(NSString*)str{
    NSNumber *number = [NSNumber numberWithInt:[str intValue]];
    NSNumberFormatter *format = [[NSNumberFormatter alloc]init];
    format.numberStyle = NSNumberFormatterDecimalStyle;
   return [format stringFromNumber:number];
}

-(void)setOrderData:(NSArray *)OrderData{
    BoardDB* db = [BoardDB new];
    _OrderData = OrderData;
    
    _label_sender_city.text = OrderData[4];
    _label_sender_user.text = [OrderData[3] stringByReplacingOccurrencesOfString:@"，" withString:@""];
    
    _label_reveice_city.text = OrderData[6];
    _label_reveice_user.text = [OrderData[5] stringByReplacingOccurrencesOfString:@"，" withString:@""];
    
    _label_order_number.text = [NSString stringWithFormat:@"%@:%@",[db getPageItemTitle:@"orderNumber"],OrderData[1]];
    
    if([OrderData[9] intValue] == 0){
        _label_order_insurance.text = [NSString stringWithFormat:@"%@: %@",[db getPageItemTitle:@"orderInsurance"],[db getPageItemTitle:@"orderInsuranceNot"]];
    }else{
        _label_order_insurance.text = [NSString stringWithFormat:@"%@: ¥%@",[db getPageItemTitle:@"orderInsurance"],[self formatNumerWithString:OrderData[9]]];
    }
    _label_order_paymodel.text = [NSString stringWithFormat:@"%@: %@",[db getPageItemTitle:@"orderPayModel"],OrderData[18]];
    
    NSString *ASSIGNTEXT;
    switch ([OrderData[7]integerValue]) {
        case OrderStateUndetermined:{
            _label_state.text = [db getPageItemTitle:@"undefind"];
            ASSIGNTEXT = [NSString stringWithFormat:@"%@: %@",[db getPageItemTitle:@"orderAssignTime"],[db getPageItemTitle:@"undefind"]];
        }break;
            
        case OrderStateWaitingReciive:{
            _label_state.text = [db getPageItemTitle:@"watting"];
            ASSIGNTEXT = [NSString stringWithFormat:@"%@: %@",[db getPageItemTitle:@"orderAssignTime"],[self formatDateWithString:OrderData[16]]];
        }break;
            
        case OrderStateCanceled:{
            _label_state.text = [db getPageItemTitle:@"cancel"];
            ASSIGNTEXT = [NSString stringWithFormat:@"%@: %@",[db getPageItemTitle:@"orderAssignTime"],[db getPageItemTitle:@"cancel"]];
        }break;
            
        case OrderStateComplete:{
            _label_state.text = [db getPageItemTitle:@"done"];
            ASSIGNTEXT = [NSString stringWithFormat:@"%@: %@",[db getPageItemTitle:@"orderAssignTime"],[db getPageItemTitle:@"done"]];
        }break;
    }
    _label_order_assing.text = ASSIGNTEXT;
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.恢复默认
    [filter setDefaults];
    // 3.给过滤器添加数据(正则表达式/账号和密码)
    NSString *dataString = [NSString stringWithFormat:@"IOS.APP|ZNZD-13|T801|1|1||1|%@|%@|1|0||%@|%@||000|%@%@%@|%@|%@||%@%@%@|UCMP000166336304",
                            OrderData[9],
                            OrderData[8],
                            OrderData[6],
                            OrderData[13],
                            OrderData[14],
                            OrderData[6],
                            OrderData[15],
                            OrderData[3],
                            OrderData[11],
                            OrderData[11],
                            OrderData[4],
                            OrderData[12]
                            ];
    //NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    /*
     @"mail_id",
     @"mail_order_id",//==============>1
     @"mail_create_time",
     @"mail_from_user",//==============>3
     @"mail_from_city",
     @"mail_to_user",//==============>5
     @"mail_to_city",
     @"mail_state",//==============>7
     @"mail_package_type",
     @"mail_package_price",//==============>9
     @"mail_from_phone",
     @"mail_from_province",//==============>11
     @"mail_from_address",
     @"mail_to_phone",//==============>13
     @"mail_to_province",
     @"mail_to_address",//==============>15
     @"mail_assign_time",
     @"mail_cancel_time",//==============>17
     @"mail_pay_model",
     @"mail_to_targetNumber"//==============>19
     */
    
    NSString*targetCityCode = OrderData[19];
    if(targetCityCode.length > 2){
        targetCityCode = [targetCityCode substringFromIndex:1];
    }
    NSMutableString *QRCodeString = [NSMutableString string];
    [QRCodeString appendString:@"IOS.APP|ZNZD-13|T4|1|"];
    [QRCodeString appendString:OrderData[18]];
    [QRCodeString appendString:@"||1|"];
    [QRCodeString appendString:OrderData[9]];
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:OrderData[8]];
    [QRCodeString appendString:@"|1|0||"];
    [QRCodeString appendString:OrderData[5]];
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:OrderData[13]];
    [QRCodeString appendString:@"||"];
    
    [QRCodeString appendString:targetCityCode];
    
    
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:OrderData[14]];
    [QRCodeString appendString:OrderData[6]];
    [QRCodeString appendString:OrderData[15]];
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:OrderData[3]];
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:OrderData[8]];
    [QRCodeString appendString:@"||"];
    [QRCodeString appendString:OrderData[11]];
    [QRCodeString appendString:OrderData[4]];
    [QRCodeString appendString:OrderData[12]];
    [QRCodeString appendString:@"|UCMP"];
    [QRCodeString appendString:OrderData[1]];
    
    NSData *data = [QRCodeString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 4.获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    // 5.将CIImage转换成UIImage，并放大显示
    _QRCodeImage.image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:200];
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
- (IBAction)printAction:(UIButton *)sender {
    NSString *poster = [NSString stringWithFormat:@"CallPrinter&PrintId=%@",_OrderData[0]];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CallAppPage" object:poster];
}
@end
