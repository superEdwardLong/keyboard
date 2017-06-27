//
//  ConnViewController.h
//  SMRT Board V3
//
//  Created by john long on 2017/6/25.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BabyBluetooth.h"
#import "SVProgressHUD.h"
#import "PeripheralInfo.h"

#import "PrinterViewController.h"
@interface ConnViewController : UIViewController
@property(nonatomic,assign)PrinterViewController* PrintVc;
@end
