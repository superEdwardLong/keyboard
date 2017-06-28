 //
//  PrinterViewController.m
//  SMRT Board V3
//
//  Created by john long on 2017/6/22.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "ConnViewController.h"
#import "PrinterViewController.h"

@interface PrinterViewController ()<CBCentralManagerDelegate>
@property(nonatomic,strong) CBCentralManager *manager;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImage;
@property (weak, nonatomic) IBOutlet UILabel *label_sender_city;
@property (weak, nonatomic) IBOutlet UILabel *label_sender_user;
@property (weak, nonatomic) IBOutlet UILabel *label_reveice_city;
@property (weak, nonatomic) IBOutlet UILabel *label_reveice_user;
@property (weak, nonatomic) IBOutlet UILabel *label_order_number;
@property (weak, nonatomic) IBOutlet UILabel *label_order_assing;
@property (weak, nonatomic) IBOutlet UIView *col_2;
@property (weak, nonatomic) IBOutlet UILabel *label_order_paymodel;
@property (weak, nonatomic) IBOutlet UILabel *label_order_insurance;
@property(nonatomic,retain)BoardDB *db;
@property(nonatomic,retain)NSArray *PrintDataSource;
@end

@implementation PrinterViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    _btn_scan.tag = 201; //默认为等待扫描
    _manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [self ShowPrintData];
    if(self.currPeripheral && self.currPeripheral.state == CBPeripheralStateConnected){
        for(CBService*service in self.currPeripheral.services){
            //服务
            if([service.UUID.UUIDString hasPrefix:@"Device Information"]){
                continue;
            }
            
            if(service.characteristics.count != 1){
                continue;
            }
            
            //特征
            BOOL stopFind = NO;
            
            for(CBCharacteristic*Characteristic in service.characteristics){
                CBCharacteristicProperties p = Characteristic.properties;
                if(p & CBCharacteristicPropertyWriteWithoutResponse){
                    self.characteristic = Characteristic;
                    stopFind = YES;
                    break;
                }
            }
            
            if(stopFind){
                break;
            }
        }
         _btn_scan.tag = 200;
        [_btn_scan setTitle:@"打印运单" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 蓝牙代理
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{    
    switch (central.state) {
        case CBManagerStatePoweredOff:{
            _btn_scan.tag = 202;
            [_btn_scan setTitle:@"请打开蓝牙" forState:UIControlStateNormal];
        }
            break;
        case CBManagerStatePoweredOn:{
            if(self.currPeripheral && self.currPeripheral.state == CBPeripheralStateConnected){
                _btn_scan.tag = 200;
                [_btn_scan setTitle:@"打印运单" forState:UIControlStateNormal];
            }else{
                _btn_scan.tag = 201;
                [_btn_scan setTitle:@"扫描设备" forState:UIControlStateNormal];
            }
            
        }break;
            
        default:{
            
        }
            break;
    }

}


- (IBAction)Do_Scan:(UIButton *)sender {
    NSInteger act = sender.tag;
    
    switch (act) {
        case 201:{
            
            NSLog(@"================打开设备扫描程式====================");
            ConnViewController *connVC = [[ConnViewController alloc]init];
            connVC.PrintVc = self;
            [self.navigationController pushViewController:connVC animated:YES];
        }
            
            break;
            
        case 200:{
            
            if(self.currPeripheral.state  != CBPeripheralStateConnected){
                sender.tag = 201;
                [_btn_scan setTitle:@"重新扫描设备" forState:UIControlStateNormal];
                [self Do_Scan:sender];
                return;
            }
            
            NSLog(@"================启动设备打印程式====================");
            [self DoPrintQRCode];
            [self DoPrintData];
        }
            break;
            
        case 202:{
            [SVProgressHUD showInfoWithStatus:@"请打开蓝牙"];
        }break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)DoPrintQRCode{
    if(_db == nil){
        _db = [BoardDB new];
    }

    NSString *QRCodeString = [self GetQRCodeValue];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *contentData = [QRCodeString dataUsingEncoding:enc];
    
    int pL = (int)(contentData.length % 256 + 3);
    int pH = (int)(contentData.length / 256);

    
    Byte PrinterInit[] = {0x1b,0x40};
    Byte QRCodeSize[] = {0x1d,0x28,0x6b,0x03,0x00,0x31,0x43,0x09};
    Byte QRCodeLevel[] = {0x1d, 0x28, 0x6b, 0x03, 0x00, 0x31, 0x45, 0x30};
    Byte QRCodeContentHeader[] = {0x1d, 0x28, 0x6b, pL, pH, 0x31, 0x50, 0x30};
    Byte QRCodeAlign[] = {0x1b, 0x61, 0x01};
    Byte QRCodeChecked[] = {0x1d ,0x28 ,0x6b ,0x03 ,0x00 ,0x31 ,0x52 ,0x30};
    Byte QRCodePrint[] = {0x1d ,0x28 ,0x6b ,0x03 ,0x00 ,0x31 ,0x51 ,0x30};
    
    NSMutableData *QRCodeData = [[NSMutableData alloc]init];
    [QRCodeData appendBytes:PrinterInit length:sizeof(PrinterInit)];
    [QRCodeData appendBytes:QRCodeSize length:sizeof(QRCodeSize)];
    [QRCodeData appendBytes:QRCodeLevel length:sizeof(QRCodeLevel)];
    
    [QRCodeData appendBytes:QRCodeContentHeader length:sizeof(QRCodeContentHeader)];
    [QRCodeData appendData:contentData];
    
    [QRCodeData appendBytes:QRCodeAlign length:sizeof(QRCodeAlign)];
    [QRCodeData appendBytes:QRCodeChecked length:sizeof(QRCodeChecked)];
    [QRCodeData appendBytes:QRCodePrint length:sizeof(QRCodePrint)];
    
    [self.currPeripheral writeValue:QRCodeData
                  forCharacteristic:self.characteristic
                               type:CBCharacteristicWriteWithResponse];
}

-(void)DoPrintData{
    if(_db == nil){
        _db = [BoardDB new];
    }
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSData *SenderCity = [_PrintDataSource[8] dataUsingEncoding:enc];
    NSData *SenderName = [_PrintDataSource[5] dataUsingEncoding:enc];
    
    NSData *ReceiveCity = [_PrintDataSource[10] dataUsingEncoding:enc];
    NSData *ReceiveName = [_PrintDataSource[13] dataUsingEncoding:enc];
    
    NSString*StrOrderNumber = [NSString stringWithFormat:@"%@:%@",[_db getPageItemTitle:@"orderNumber"],_PrintDataSource[1]];
    NSString*StrOrderTime = [self GetAssignText:_PrintDataSource];
    NSString*StrOrderPayModel = [NSString stringWithFormat:@"%@: %@",[_db getPageItemTitle:@"orderPayModel"],_PrintDataSource[4]];
    NSString*StrOrderInsured = [self GetInsuranceText:_PrintDataSource];
    
    NSData *OrderNumber = [StrOrderNumber dataUsingEncoding:enc];
    NSData *OrderTime = [StrOrderTime dataUsingEncoding:enc];
    
    NSData *OrderPayModel = [StrOrderPayModel dataUsingEncoding:enc];
    NSData *OrderInsured = [StrOrderInsured dataUsingEncoding:enc];
    
    
    //    初始化打印机
    Byte insuArray[] ={ 0x1B,0x40};
    NSData *InsuData= [NSData dataWithBytes: insuArray length: sizeof(insuArray)];
    //换行
    Byte array[] ={ 0x0A};
    NSData *data1= [NSData dataWithBytes: array length: sizeof(array)];
    
    //左边间隔
    Byte paddingLeftByte[] = {0x1B,0x42,0x05};
    NSData* paddingLeft = [NSData dataWithBytes:paddingLeftByte length:sizeof(paddingLeftByte)];
    
    //左对齐
    Byte alignLeft[] = {0x1B,0x61,0};
    NSData *dataLeft = [NSData dataWithBytes: alignLeft length: sizeof(alignLeft)];
    
    
    //打印结束
    Byte end[] = {0x1d, 0x4c, 0x1f, 0x00};
    NSData *dataEnd = [NSData dataWithBytes: end length: sizeof(end)];
    
    //进纸
    Byte line[] = {0x1B,0X64,4};
    NSData *dataLine = [NSData dataWithBytes: line length: sizeof(line)];
    
    
    //间隔 ⇀
    double sizeLen0 = 368.00/32.00;
    double sizeTo0 = [self convertToInt:_PrintDataSource[10]];
    double len0 = 450 - sizeTo0 * sizeLen0;
    Byte str11Arr[] = {0x1b,0x24,(int)len0,1};
    NSData *citySpace = [NSData dataWithBytes: str11Arr length: sizeof(str11Arr)];
    
    double sizeTo1 = [self convertToInt:_PrintDataSource[13]];
    double len1 = 450- sizeTo1 * sizeLen0;
    Byte str12Arr[] = {0x1b,0x24,(int)len1,1};
    NSData *nameSpace = [NSData dataWithBytes: str12Arr length: sizeof(str12Arr)];
    
    //整理打印数据
    NSMutableData* printData = [[NSMutableData alloc]init];
    [printData appendData:InsuData];
    [printData appendData:data1];//换行
    [printData appendData:dataLeft];//左对齐
    [printData appendData:paddingLeft];//左对齐
    
    [printData appendData:SenderCity];
    [printData appendData:citySpace];
    [printData appendData:ReceiveCity];
    [printData appendData:data1];//换行
    
    [printData appendData:SenderName];
    [printData appendData:nameSpace];
    [printData appendData:ReceiveName];
    [printData appendData:data1];//换行
   
    
    [printData appendData:OrderNumber];
    [printData appendData:data1];//换行
    
    [printData appendData:OrderTime];
    [printData appendData:data1];//换行
    
    [printData appendData:OrderPayModel];
    [printData appendData:data1];//换行
    
    [printData appendData:OrderInsured];
    [printData appendData:data1];//换行
    
    [printData appendData:dataLine];//进纸
    [printData appendData:dataEnd];//结束打印
    
    [self.currPeripheral writeValue:printData
                  forCharacteristic:self.characteristic
                               type:CBCharacteristicWriteWithResponse];
}

//计算字符串实际长度
- (int)convertToInt:(NSString*)strtemp
{
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
        
    }
    return strlength;
}

-(NSString*)GetAssignText:(NSArray*)OrderData{
    NSString *ASSIGNTEXT;
    switch ([OrderData[16]integerValue]) {
        case OrderStateUndetermined:{
            
            ASSIGNTEXT = [NSString stringWithFormat:@"%@: %@",[_db getPageItemTitle:@"orderAssignTime"],[_db getPageItemTitle:@"undefind"]];
        }break;
            
        case OrderStateWaitingReciive:{
            
            ASSIGNTEXT = [NSString stringWithFormat:@"%@: %@",[_db getPageItemTitle:@"orderAssignTime"],[self formatDateWithString:OrderData[15]]];
        }break;
            
        case OrderStateCanceled:{
            
            ASSIGNTEXT = [NSString stringWithFormat:@"%@: %@",[_db getPageItemTitle:@"orderAssignTime"],[_db getPageItemTitle:@"cancel"]];
        }break;
            
        case OrderStateComplete:{
            
            ASSIGNTEXT = [NSString stringWithFormat:@"%@: %@",[_db getPageItemTitle:@"orderAssignTime"],[_db getPageItemTitle:@"done"]];
        }break;
    }
    return ASSIGNTEXT;
}

-(NSString*)GetInsuranceText:(NSArray*)OrderData{
    NSString *InsuranceText;
    if([OrderData[3] intValue] == 0){
        InsuranceText = [NSString stringWithFormat:@"%@: %@",[_db getPageItemTitle:@"orderInsurance"],[_db getPageItemTitle:@"orderInsuranceNot"]];
    }else{
        InsuranceText = [NSString stringWithFormat:@"%@: ¥%@",[_db getPageItemTitle:@"orderInsurance"],[self formatNumerWithString:OrderData[3]]];
    }
    return InsuranceText;
}

-(void)ShowPrintData{
    if(_db == nil){
        _db = [BoardDB new];
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * From MailList WHERE mail_id = %ld",(long)_OrderId];
    NSMutableArray *OrderData = [[_db FindWithSql:sql withReturnFields:@[
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
                                                                   @"mail_state",
                                                                   @"mail_to_targetNumber"]] firstObject];
    _PrintDataSource = OrderData;
    if(OrderData.count > 0){
        
        _label_sender_city.text = OrderData[8];
        _label_sender_user.text = [OrderData[5] stringByReplacingOccurrencesOfString:@"，" withString:@""];
        
        _label_reveice_city.text = OrderData[10];
        _label_reveice_user.text = [OrderData[13] stringByReplacingOccurrencesOfString:@"，" withString:@""];
        
        _label_order_number.text = [NSString stringWithFormat:@"%@:%@",[_db getPageItemTitle:@"orderNumber"],OrderData[1]];
        
        _label_order_paymodel.text = [NSString stringWithFormat:@"%@: %@",[_db getPageItemTitle:@"orderPayModel"],OrderData[4]];
        _label_order_assing.text = [self GetAssignText:OrderData];
        _label_order_insurance.text = [self GetInsuranceText:OrderData];
        
        
        
        ///组装数据生成QRCodeImage
        CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        // 2.恢复默认
        [filter setDefaults];
        // 3.给过滤器添加数据(正则表达式/账号和密码)
        NSString*targetCityCode = OrderData[17];
        if(targetCityCode.length > 2){
            targetCityCode = [targetCityCode substringFromIndex:1];
        }
        
        NSString *QRCodeString = [self GetQRCodeValue];
        
        NSData *data = [QRCodeString dataUsingEncoding:NSUTF8StringEncoding];
        [filter setValue:data forKeyPath:@"inputMessage"];
        // 4.获取输出的二维码
        CIImage *outputImage = [filter outputImage];
        // 5.将CIImage转换成UIImage，并放大显示
        _QRCodeImage.image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:200];
    }
    
}

-(NSString*)GetQRCodeValue{
    NSString*targetCityCode = _PrintDataSource[17];
    if(targetCityCode.length > 2){
        targetCityCode = [targetCityCode substringFromIndex:1];
    }
    NSMutableString *QRCodeString = [NSMutableString string];
    [QRCodeString appendString:@"IOS.APP|ZNZD-13|"];
    [QRCodeString appendString:@"T4"];//产品
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:@"1.5"];//重量
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:_PrintDataSource[4]];//支付模式
    [QRCodeString appendString:@"||1|"];
    [QRCodeString appendString:_PrintDataSource[3]];//保价金额
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:_PrintDataSource[2]];//包裹类型
    [QRCodeString appendString:@"|1|0||"];
    [QRCodeString appendString:_PrintDataSource[10]];//收件人
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:_PrintDataSource[11]];//收件人电话
    [QRCodeString appendString:@"||"];
    [QRCodeString appendString:targetCityCode];//目的地编码
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:_PrintDataSource[12]];//收件人 省份
    [QRCodeString appendString:_PrintDataSource[13]];//收件人 城市
    [QRCodeString appendString:_PrintDataSource[14]];//收件人 地址
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:_PrintDataSource[5]];//寄件人
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:_PrintDataSource[6]];//寄件人 电话
    [QRCodeString appendString:@"||"];
    [QRCodeString appendString:_PrintDataSource[7]];//寄件人 省份
    [QRCodeString appendString:_PrintDataSource[8]];//寄件人 城市
    [QRCodeString appendString:_PrintDataSource[9]];//寄件人 地址
    [QRCodeString appendString:@"|"];
    [QRCodeString appendString:@"UCMP"];//单号编码
    [QRCodeString appendString:_PrintDataSource[1]];
    return QRCodeString;
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
@end
