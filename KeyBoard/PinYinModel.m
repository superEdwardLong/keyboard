//
//  PinYinModel.m
//  SMRT Board V3
//
//  Created by BOT01 on 17/3/31.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//


#define sm @[@"b",@"c",@"d",@"f",@"g",@"h",@"j",@"k",@"l",@"m",@"n",@"p",@"q",@"r",@"s",@"t",@"w",@"x",@"y",@"z",@"sh",@"zh",@"ch"]//声母集合

#define yy @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"en",@"eng",@"er",@"o",@"ou",@"ong"]//单字韵母集合
#define ym_b @[@"a",@"ai",@"an",@"ang",@"ao",@"ei",@"en",@"eng",@"i",@"ian",@"iao",@"ie",@"in",@"ing",@"o",@"u"]// 声母b的韵母集合
#define ym_c @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"en",@"eng",@"i",@"ong",@"ou",@"u",@"uan",@"ui",@"un",@"uo"]// 声母c的韵母集合
#define ym_d @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"ei",@"en",@"eng",@"i",@"ia",@"ian",@"iao",@"ie",@"ing",@"iu",@"ong",@"ou",@"u",@"uan",@"ui",@"un",@"uo"]// 声母d的韵母集合
#define ym_f @[@"a",@"an",@"ang",@"ei",@"en",@"eng",@"iao",@"o",@"ou",@"u"]// 声母f的韵母集合
#define ym_g @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"ei",@"en",@"eng",@"ong",@"ou",@"u",@"uai",@"uan",@"uang",@"ui",@"un",@"uo"]// 声母g的韵母集合
#define ym_h @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"ei",@"en",@"eng",@"ong",@"ou",@"u",@"ua",@"uai",@"uan",@"uang",@"ui",@"un",@"uo"]// 声母h的韵母集合
#define ym_j @[@"i",@"ia",@"ian",@"iang",@"iao",@"ie",@"in",@"ing",@"iong",@"iu",@"u",@"uan",@"ue",@"un"]// 声母j的韵母集合
#define ym_k @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"en",@"eng",@"ong",@"ou",@"u",@"ui",@"un",@"uo"]// 声母k的韵母集合
#define ym_l @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"ei",@"eng",@"i",@"ia",@"iao",@"ie",@"in",@"ing",@"iu",@"o",@"ong",@"ou",@"u",@"uan",@"un",@"uo",@"v",@"ve"]// 声母l的韵母集合
#define ym_m @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"ei",@"en",@"eng",@"i",@"ian",@"iao",@"ie",@"in",@"ing",@"iu",@"o",@"ou",@"u"]// 声母m的韵母集合
#define ym_n @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"ei",@"en",@"eng",@"i",@"ian",@"iang",@"iao",@"ie",@"in",@"ing",@"iu",@"ong",@"ou",@"u",@"uan",@"un",@"uo",@"v",@"ve"]// 声母n的韵母集合
#define ym_p @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"ei",@"en",@"eng",@"i",@"ian",@"iao",@"ie",@"in",@"ing",@"o",@"ou",@"u"]// 声母p的韵母集合
#define ym_q @[@"i",@"ia",@"ian",@"iang",@"iao",@"ie",@"in",@"ing",@"iong",@"iu",@"u",@"uan",@"ue",@"un"]// 声母q的韵母集合
#define ym_r @[@"an",@"ang",@"ao",@"e",@"en",@"eng",@"i",@"ong",@"ou",@"u",@"ua",@"uan",@"ui",@"un",@"uo"]// 声母r的韵母集合
#define ym_s @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"en",@"eng",@"i",@"ong",@"ou",@"u",@"uan",@"ui",@"un",@"uo"]// 声母s的韵母集合
#define ym_t @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"ei",@"eng",@"i",@"ian",@"iao",@"ie",@"ing",@"ong",@"ou",@"u",@"uan",@"ui",@"un",@"uo"]// 声母t的韵母集合
#define ym_w @[@"a",@"ai",@"an",@"ang",@"ei",@"en",@"eng",@"o",@"u"]// 声母w的韵母集合
#define ym_x @[@"i",@"ia",@"ian",@"iang",@"iao",@"ie",@"in",@"ing",@"iong",@"iu",@"u",@"uan",@"un",@"ue"]// 声母x的韵母集合
#define ym_y @[@"a",@"an",@"ang",@"ao",@"e",@"i",@"in",@"ing",@"o",@"ong",@"ou",@"u",@"uan",@"un",@"ue"]// 声母y的韵母集合
#define ym_z @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"ei",@"en",@"eng",@"i",@"o",@"ong",@"ou",@"u",@"uan",@"ui",@"un",@"uo"]// 声母z的韵母集合

#define ym_ch @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"en",@"eng",@"i",@"ong",@"ou",@"u",@"ua",@"uai",@"uan",@"uang",@"ui",@"un",@"uo"]// 声母ch的韵母集合
#define ym_sh @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"ei",@"en",@"eng",@"i",@"ou",@"u",@"ua",@"uai",@"uan",@"uang",@"ui",@"un",@"uo"]// 声母sh的韵母集合
#define ym_zh @[@"a",@"ai",@"an",@"ang",@"ao",@"e",@"ei",@"en",@"eng",@"i",@"ong",@"ou",@"u",@"ua",@"uai",@"uan",@"uang",@"ui",@"un",@"uo"]// 声母zh的韵母集合

#define ym @[yy,ym_b,ym_c,ym_d,ym_f,ym_g,ym_h,ym_j,ym_k,ym_l,ym_m,ym_n,ym_p,ym_q,ym_r,ym_s,ym_t,ym_w,ym_x,ym_y,ym_z,ym_ch,ym_sh,ym_zh]



#import "PinYinModel.h"
@implementation PinYinModel
@synthesize PinYinResult = _PinYinResult;


-(NSString*)findShengMu:(NSString*)text{
    NSInteger temp = 0;
    NSInteger index = 0;

     // 遍历声母集合，匹对
    for(NSInteger i=0; i<sm.count;i++){
        for(NSInteger j=1;j<=text.length;j++){
            NSString *py3 = [text substringToIndex:j];// 截取从0开始到j结束的字符串
            if([py3 isEqualToString:sm[i]]){
                temp = [sm[i] length]; // 对应的声母的长度
                index = i+1;
                break;
            }
        }
    }
    
    NSString *py = [text copy];
    if(temp != 0){
        _PinYinResult = [_PinYinResult stringByAppendingString:[text substringToIndex:temp]];
        py = [text substringFromIndex:temp];
    }
    
    if(py.length != 0){
        return [self findYunMu:py withBeginIndex:index];
    }
    
    return py;
}


-(NSString*)findYunMu:(NSString*)text withBeginIndex:(NSInteger)index{
    
    NSInteger temp = 0;
    for(NSInteger i=0; i<[ym[index] count]; i++){
        for(NSInteger j=1; j<= text.length; j++){
            NSString *py3 = [text substringToIndex:j];
            if([py3 isEqualToString: [ym[index] objectAtIndex:i]]){
                temp = [[ym[index] objectAtIndex:i] length];
                break;
            }
        }
    }
    NSString *py = [text copy];
    
    if(temp != 0){
        _PinYinResult = [_PinYinResult stringByAppendingString:[NSString stringWithFormat:@"%@'",[text substringToIndex:temp]]];
        py = [text substringFromIndex:temp];
    }
    
    
    return py;
}


-(NSString*)trimSpell:(NSString*)text{
    _PinYinResult = @"";

    NSString *s = [text copy];
    for(NSInteger i=0; i<text.length*2;i++){
        if(s.length == 0){
            break;
        }
        s = [self findYunMu:s withBeginIndex:0];
        s = [self findShengMu:s];
    }
    
    
    if(_PinYinResult.length >0 &&  [[_PinYinResult substringFromIndex:_PinYinResult.length-1] isEqualToString:@"'"]){
        _PinYinResult = [_PinYinResult substringWithRange:NSMakeRange(0, _PinYinResult.length-1)];
    }
    
    return _PinYinResult;
}
@end
