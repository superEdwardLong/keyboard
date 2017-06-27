//
//  KFunctionView.h
//  SMRT Keyborad
//
//  Created by BOT01 on 17/2/24.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TokenView2.h"
#import "ShipItView.h"
#import "BoardDB.h"

@interface KFunctionView : UIView
@property(nonatomic,strong)UIScrollView *myScroll;
@property(nonatomic,strong)TokenView2 *KTokenView;
@property(nonatomic,strong)ShipItView *KShipItView;
@end
