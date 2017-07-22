//
//  BoardDB.h
//  SMRT Keyborad
//
//  Created by BOT01 on 17/3/1.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactModel.h"
#import "FMDB.h"
typedef NS_ENUM(NSInteger,OrderState) {
    OrderStateUndetermined = 0,
    OrderStateWaitingReciive = 1,
    OrderStateComplete = 2,
    OrderStateCanceled = 3
};
@interface BoardDB : NSObject
+(BOOL)CheckDbVersion;

-(NSMutableArray*)FindWithSql:(NSString*)sql withReturnFields:(id)fields;

//查找联系人
-(NSMutableArray*)FindContactsWithFilter:(NSNumber*)strFilter;

//查找拼音字库
-(NSMutableArray*)FindPinYinZiKuWithFilter:(NSString*)strFilter withPageIndex:(int)pageIndex withPageSize:(int)pageSize;

//查找拼音词库
-(NSMutableArray*)FindPinYinCiKuWithFilter:(NSString*)strFilter withPageIndex:(int)pageIndex withPageSize:(int)pageSize;

//查找英文单词
-(NSMutableArray*)FindWordWithFilter:(NSString*)strFilter withPageIndex:(int)pageIndex withPageSize:(int)pageSize;

//添加 或 修改
-(NSInteger)UpdateContact:(ContactModel*)data;

//修改拼音表 词频
-(void)UpdatePinYinTable:(NSString *)table  withRate:(double)rate withText:(NSString*)text;

-(void)RemoveContactWithId:(NSInteger)ContactId;

-(NSInteger)UpdateMailList:(MailItemModel*)MailItem withSender:(ContactModel*)Sender withReceive:(ContactModel*)Receive;

-(void)RemoveMailItem:(NSInteger)mailId;

-(BOOL)UpdateWithSql:(NSString*)sql;

-(NSString*)getCityCode:(NSString*)cityName;

-(ContactModel*)getDefaultSender;

/* =====================================
 获取语言版本
 ===================================== */
-(NSDictionary*)getLanguage;
-(NSString*)getMenuItemTitle:(NSString*)itemKey;
-(NSString*)getAlertItemTitle:(NSString*)itemKey;
-(NSString*)getPageItemTitle:(NSString*)itemKey;
-(NSDictionary*)getPikerItemData:(NSString*)itemKey;
@end
