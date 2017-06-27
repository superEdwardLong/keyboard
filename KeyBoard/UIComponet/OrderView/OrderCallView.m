//
//  OrderCallView.m
//  SMRT Board V3
//
//  Created by john long on 2017/5/3.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "OrderCallView.h"
@interface OrderCallView()
@property (weak, nonatomic) IBOutlet UILabel *label_callXiaoGe;
@property (weak, nonatomic) IBOutlet UILabel *label_callSupplement;
@property (weak, nonatomic) IBOutlet UILabel *label_callHelp;
@end

@implementation OrderCallView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"OrderCallView" owner:self options:nil]lastObject];
    if(self){
        BoardDB* db = [BoardDB new];
        
        _label_callXiaoGe.text = [db getPageItemTitle:@"callXiaoGe"];
        _label_callSupplement.text = [db getPageItemTitle:@"callSupplement"];
        _label_callHelp.text = [db getPageItemTitle:@"callHelp"];
        
        self.img_face.clipsToBounds = YES;
        self.img_face.layer.cornerRadius = self.img_face.frame.size.width/2;
        self.img_face.layer.borderColor = [[UIColor darkGrayColor]CGColor];
        self.img_face.layer.borderWidth = 1.0f;
        
        self.tabbar.delegate = self;
        NSArray *itemTitles = [self getTabbarItemsTitle];
        NSArray *itemImages = @[@"return",@"share",@"icon-quxiaodingdan",@"icon-hujiaoxiaoge"];
        for(UITabBarItem*item in _tabbar.items){
            UIImage *itemImgage = [[UIImage imageNamed:itemImages[item.tag]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [item setImage:itemImgage];
            
            [item setTitle:itemTitles[item.tag]];
        }
        
        for(UIImageView*img in _imgTimers){
            img.clipsToBounds = YES;
            img.layer.cornerRadius = 3.f;
        }
        
        self.label_start.clipsToBounds = YES;
        self.label_start.layer.cornerRadius = _label_start.frame.size.height/2;
        self.label_start.layer.borderColor = [[UIColor colorWithWhite:.75 alpha:1]CGColor];
        self.label_start.layer.borderWidth = 1.f;
        self.OrderId = 0;
        
        [self performSelector:@selector(drawArrow) withObject:nil afterDelay:.3f];
        
                
    }return self;
}

-(NSArray*)getTabbarItemsTitle{
    BoardDB* db = [BoardDB new];
    NSString* title_back =  [db getMenuItemTitle:@"back"];
    NSString* title_share =  [db getMenuItemTitle:@"share"];
    NSString* title_cancel =  [db getMenuItemTitle:@"orderCancel"];
    NSString* title_callXiaoGe =  [db getMenuItemTitle:@"callXiaoGe"];
    return @[title_back,title_share,title_cancel,title_callXiaoGe];
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

- (IBAction)EditButtonAction:(UIButton *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(orderCallView:didClickedEdit:)]){
        [self.delegate orderCallView:self didClickedEdit:sender];
    }
}


-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if(self.delegate && [self.delegate respondsToSelector:@selector(orderCallView:didSelectedTabItem:)]){
        [self.delegate orderCallView:self didSelectedTabItem:item.tag];
    }
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
                                                                   @"mail_assign_time",     //-----------------> 15
                                                                   @"mail_state"]] firstObject];
    if(cols == nil || cols.count == 0)return;
    
    _label_sender_city.text = cols[8];
    _label_sender_name.text = [cols[5] stringByReplacingOccurrencesOfString:@"，" withString:@""];
    
    _label_receive_city.text = cols[13];
    _label_receive_name.text = [cols[10] stringByReplacingOccurrencesOfString:@"，" withString:@""];
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate *AssignDate;
    NSString *timePart;
    NSString *str_day;
    
    switch ([cols[16] integerValue]) {
        case OrderStateWaitingReciive:{            
            AssignDate = [dateformatter dateFromString:cols[15]];
            timePart = [[cols[15] componentsSeparatedByString:@" "]lastObject];
            AssignDate = [dateformatter dateFromString:cols[15]];
            str_day = [self getAssignDay:AssignDate];
            _label_assign.text = [NSString stringWithFormat:@"%@          %@",str_day,[db getPageItemTitle:@"maybe"]];
        }
            break;
        case OrderStateComplete:{
            _label_assign.text = [db getPageItemTitle:@"done"];
            AssignDate = [dateformatter dateFromString:cols[15]];
            timePart = [[cols[15] componentsSeparatedByString:@" "]lastObject];
        }
            
            break;
            
        default:{
            //已经取消 | 待定  => 重新分配时间
            int x = arc4random() % 1000;
            AssignDate =[self getAssignTime];
            NSString *assignTime =  [dateformatter stringFromDate:AssignDate];
            NSString *orderNumberId = [NSString stringWithFormat:@"SF_%ld%d", (long)[[NSDate date] timeIntervalSince1970],x];
            //更新分配时间
            [db UpdateWithSql:[NSString stringWithFormat:@"UPDATE MailList SET mail_assign_time = '%@',mail_order_id = '%@',mail_state = %ld WHERE mail_id = %ld",assignTime,orderNumberId,OrderStateWaitingReciive,orderId]];
            
            timePart = [[[dateformatter stringFromDate:AssignDate] componentsSeparatedByString:@" "]lastObject];
            str_day = [self getAssignDay:AssignDate];
            _label_assign.text = [NSString stringWithFormat:@"%@          %@",str_day,[db getPageItemTitle:@"maybe"]];
            
        }
            break;
    }
    
    
    for(UIImageView*img in _imgTimers){
        NSString *imgName;
        if(img.tag > 1){
            imgName = [timePart substringWithRange:NSMakeRange(img.tag+1, 1)];
        }else{
            imgName = [timePart substringWithRange:NSMakeRange(img.tag, 1)];
        }
        img.image = [UIImage imageNamed:imgName];
        img.clipsToBounds = YES;
        img.layer.cornerRadius = 6.f;
        
    }
}

-(NSString*)getAssignDay:(NSDate*)assignDate{
    BoardDB *db = [BoardDB new];
    NSString *str_day = [db getPageItemTitle:@"today"];
    
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:today];
    NSDateComponents *assingDateComponent = [calendar components:unitFlags fromDate:assignDate];
    
    NSInteger todayD =  [dateComponent year] + [dateComponent month] +  [dateComponent day];
    NSInteger assingD = [assingDateComponent year] + [assingDateComponent month] +[assingDateComponent day];
    
    if(todayD < assingD){
        str_day = [db getPageItemTitle:@"tomorrow"];
    }else if(todayD > assingD){
        str_day = [db getPageItemTitle:@"done"];
    }else{
        str_day = [db getPageItemTitle:@"today"];
    }
    
    return str_day;
}

-(NSDate*)getAssignTime{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour ;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:today];
    NSInteger hours =  [dateComponent hour];
    
    NSDate *AssignDate;
    NSTimeInterval interval = 0.0;
    if(hours > 19){
        //19:00 点后
        interval = 60 * 60 * (24- hours + 8);
    }else if(hours < 8){
        //8:00 点前
        interval = 60 * 60 * (8 - hours);
    }else{
        //8-19
        interval = 60 * 60 * 2;
    }
    AssignDate = [NSDate dateWithTimeInterval:interval sinceDate:today];
    return AssignDate;
}

-(UIImage*)makeQRCodeImage{
    BoardDB *db = [BoardDB new];
    NSString *sql = [NSString stringWithFormat:@"SELECT * From MailList WHERE mail_id = %ld",_OrderId];
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
                                                                   @"mail_assign_time",
                                                                   @"mail_state"]] firstObject];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.恢复默认
    [filter setDefaults];
    // 3.给过滤器添加数据(正则表达式/账号和密码)
    NSString *dataString = [NSString stringWithFormat:@"IOS.APP|ZNZD-13|T801|1|1||1|%@|%@|1|0||%@|%@||000|%@%@%@|%@|%@||%@%@%@|UCMP000166336304",cols[3],cols[2],cols[10],cols[11],cols[12],cols[13],cols[14],cols[5],cols[6],cols[7],cols[8],cols[9]];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 4.获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    // 5.将CIImage转换成UIImage，并放大显示
    UIImage*QRCodeImage = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:200];
    return QRCodeImage;
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
