//
//  KProvinceCityPicker.h
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/10.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardDB.h"
#import "SDAutoLayout.h"
#import "ContactViewCell2.h"
@interface KProvinceCityPicker : UIView<UIPickerViewDelegate,UIPickerViewDataSource>{
    NSMutableArray *provinceList;
    NSDictionary *cityList;
}
@property(nonatomic,strong)UIPickerView *picker;
@property(nonatomic,strong)ContactViewCell2 *selectedCell;

-(id)initWithFrame:(CGRect)frame withCell:(ContactViewCell2*)cell;
@end
