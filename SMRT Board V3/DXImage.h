//
//  DXImage.h
//  SMRT Board V3
//
//  Created by BOT01 on 2017/7/4.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef struct{
    int red;
    int green;
    int blue;
    int alpha;
} ARGBPixel;

@interface DXImage : NSObject
@property(nonatomic,strong)NSMutableData *bitmap;
@property(nonatomic,assign)int32_t width;
@property(nonatomic,assign)int32_t height;
@end
