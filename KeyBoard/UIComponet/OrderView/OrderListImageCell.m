//
//  OrderListImageCell.m
//  SMRT Board V3
//
//  Created by BOT01 on 2017/5/10.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "OrderListImageCell.h"

@implementation OrderListImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [[[NSBundle mainBundle]loadNibNamed:@"OrderListImageCell" owner:self options:nil]lastObject];
    if(self){
        UIView *selectedBgView = [[UIView alloc]initWithFrame:self.bounds];
        selectedBgView.backgroundColor = [UIColor colorWithWhite:.3 alpha:1];
        self.selectedBackgroundView = selectedBgView;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

-(void)setQRCodeDatas:(NSArray *)QRCodeDatas{
    
    /*@[
     @"mail_id",//-----------------> 0
     @"mail_order_id",//-----------------> 1
     @"mail_create_time",//-----------------> 2
     @"mail_from_user",//-----------------> 3
     @"mail_from_city",//-----------------> 4
     @"mail_to_user",//-----------------> 5
     @"mail_to_city",//-----------------> 6
     @"mail_state",//-----------------> 7
     @"mail_package_type",//-----------------> 8
     @"mail_package_price",//-----------------> 9
     @"mail_from_phone",//-----------------> 10
     @"mail_from_province",//-----------------> 11
     @"mail_from_address",//-----------------> 12
     @"mail_to_phone",//-----------------> 13
     @"mail_to_province",//-----------------> 14
     @"mail_to_address"//-----------------> 15
     ];*/
    
    _QRCodeDatas = QRCodeDatas;
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.恢复默认
    [filter setDefaults];
    // 3.给过滤器添加数据(正则表达式/账号和密码)
    NSString *dataString = [NSString stringWithFormat:@"IOS.APP|ZNZD-13|T801|1|1||1|%@|%@|1|0||%@|%@||000|%@%@%@|%@|%@||%@%@%@|UCMP000166336304",
                            QRCodeDatas[9],
                            QRCodeDatas[8],
                            QRCodeDatas[6],
                            QRCodeDatas[13],
                            QRCodeDatas[14],
                            QRCodeDatas[6],
                            QRCodeDatas[15],
                            QRCodeDatas[3],
                            QRCodeDatas[11],
                            QRCodeDatas[11],
                            QRCodeDatas[4],
                            QRCodeDatas[12]
                            ];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 4.获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    // 5.将CIImage转换成UIImage，并放大显示
    _QRCodeImage.image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:150];
    
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
