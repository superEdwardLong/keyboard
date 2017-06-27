//
//  PrinterViewController.h
//  SMRT Board V3
//
//  Created by john long on 2017/6/22.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BoardDB.h"
@interface PrinterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btn_scan;
@property(nonatomic,assign)NSInteger OrderId;
@property (nonatomic,strong)CBCharacteristic *characteristic;
@property (nonatomic,strong)CBPeripheral *currPeripheral;
@end
