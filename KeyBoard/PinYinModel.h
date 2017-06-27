//
//  PinYinModel.h
//  SMRT Board V3
//
//  Created by BOT01 on 17/3/31.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PinYinModel : NSObject
@property(nonatomic,copy)NSString *PinYinResult;

-(NSString*)trimSpell:(NSString*)text;
@end
