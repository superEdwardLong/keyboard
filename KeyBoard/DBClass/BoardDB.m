//
//  BoardDB.m
//  SMRT Keyborad
//
//  Created by BOT01 on 17/3/1.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#define KData       @"ContactList"
#define KId         @"field_Id"
#define KName       @"field_Name"
#define KPhone      @"field_Phone"
#define KProv       @"field_Prov"
#define KCity       @"field_City"
#define KAddress    @"field_Address"
#define KImage    @"field_Image"

#import "BoardDB.h"

@implementation BoardDB
-(id)init{
    self = [super init];
    if(self){
        
    }
    return self;
}


-(FMDatabase *)OpenDb{
    int kCurrentVer = 12;
    
    NSString *dbName = [NSString stringWithFormat:@"wordlib_ver_%d.db",kCurrentVer];
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.bizopstech.keyboard"];
    NSString *db_path = [containerURL.path stringByAppendingPathComponent:dbName];
    
   // NSString *path = [[NSBundle mainBundle]pathForResource:@"wordlib" ofType:@"db"];
    FMDatabase *db = [FMDatabase databaseWithPath:db_path];
    
    if ([db open] == YES){
        
       // NSLog(@"数据库已打开");
    }else{
        
       // NSLog(@"数据库打开失败");
        db = nil;
    }
    
    return db;
    
}

-(BOOL)UpdateWithSql:(NSString*)sql{
    FMDatabase *db = [self OpenDb];
    BOOL result = NO;
    if(db){
        result = [db executeUpdate:sql];
        [db close];
    }
    return  result;
}

-(NSString*)getCityCode:(NSString*)cityName{
    NSString*sql = [NSString stringWithFormat:@"SELECT cityCode FROM Destination WHERE cityName like '%@%%'  LIMIT 0,1",cityName];
    NSString*code = @"";
    FMDatabase *db = [self OpenDb];
    FMResultSet *s = [db executeQuery:sql];
    while ([s next]){
        code = [s stringForColumn:@"cityCode"];
    }
    [db close];
    return code;
}

-(NSMutableArray*)FindWithSql:(NSString*)sql withReturnFields:(id)fields{
    NSMutableArray *arr = [NSMutableArray array];
    FMDatabase *db = [self OpenDb];
    FMResultSet *s = [db executeQuery:sql];
    if([fields isKindOfClass:[NSString class]]){
        while ([s next]){
            [arr addObject:[s stringForColumn:fields]];
        }
    }else if([fields isKindOfClass:[NSArray class]]){
        while ([s next]){
            NSMutableArray *itemArr = [NSMutableArray array];
            for(NSInteger i = 0; i< ((NSArray*)fields).count; i++){
                if([s stringForColumn:fields[i]]){
                    [itemArr addObject: [s stringForColumn:fields[i]]];
                }else{
                    [itemArr addObject: @""];
                }
                
            }
            [arr addObject:itemArr];
        }
    }
    [db close];
    return arr;
}


//查找联系人
-(NSMutableArray*)FindContactsWithFilter:(NSNumber*)strFilter{
    NSMutableArray *arr = [NSMutableArray array];
    FMDatabase *db = [self OpenDb];
    if(db){
        FMResultSet *s;
        if(strFilter == nil){
            s = [db executeQuery:@"SELECT * FROM Contacts ORDER BY id DESC"];
        }else{
            s = [db executeQuery:@"SELECT * FROM Contacts WHERE id = ? ",strFilter];
        }
        
        while ([s next]){
            ContactModel *item = [ContactModel new];
            item.contactId = [s longForColumn:@"id"];
            item.strName = [s stringForColumn:@"name"];
            item.strPhone = [s stringForColumn:@"phone"];
            item.strProv = [s stringForColumn:@"prov"];
            item.strCity = [s stringForColumn:@"city"];
            item.strAddress = [s stringForColumn:@"address"];
            item.strImage = [s stringForColumn:@"image"];
            item.isDefaultSender = [s longForColumn:@"isDefaultSender"];
            [arr addObject:item];
        }
        [db close];
    }
    return arr;
}

//查找拼音字库
-(NSMutableArray*)FindPinYinZiKuWithFilter:(NSString*)strFilter withPageIndex:(int)pageIndex withPageSize:(int)pageSize{
    NSMutableArray *arr = [NSMutableArray array];
    FMDatabase *db = [self OpenDb];
    if(db){
        strFilter = [strFilter stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *sql = [NSString stringWithFormat:@"SELECT text FROM PinYinZiKu WHERE pinyin like '%@%%' ORDER BY rate DESC LIMIT %d,%d",strFilter,pageIndex*pageSize,pageSize];
        //NSLog(@"字库：%@",sql);
        
        FMResultSet *s = [db executeQuery:sql];
        while ([s next]){
            [arr addObject:[s stringForColumn:@"text"]];
        }
        [db close];
    }
    return arr;
}

//查找拼音词库
-(NSMutableArray*)FindPinYinCiKuWithFilter:(NSString*)strFilter withPageIndex:(int)pageIndex withPageSize:(int)pageSize{
    NSMutableArray *arr = [NSMutableArray array];
    FMDatabase *db = [self OpenDb];
    if(db){
        strFilter = [strFilter stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *sql = [NSString stringWithFormat:@"SELECT text FROM PinYinCiKu WHERE pinyin like '%@%%' ORDER BY rate DESC LIMIT %d, %d",strFilter,pageIndex*pageSize,pageSize];
        //NSLog(@"词库：%@",sql);
        
        FMResultSet *s = [db executeQuery:sql,strFilter];
        while ([s next]){
            [arr addObject:[s stringForColumn:@"text"]];
        }
        [db close];
    }
    return arr;
}

//查找英文单词
-(NSMutableArray*)FindWordWithFilter:(NSString*)strFilter withPageIndex:(int)pageIndex withPageSize:(int)pageSize{
    NSMutableArray *arr = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM words WHERE text like '%@%%' LIMIT %d,%d",strFilter,pageIndex*pageSize,pageSize];
    //模糊查询，查找text中 以 strFilter 开头的内容
    FMDatabase *db = [self OpenDb];
    if(db){
        FMResultSet *s = [db executeQuery:sql];
        while ([s next]){
            [arr addObject:[s stringForColumn:@"text"]];
        }
        [db close];
    }
    
    return arr;
}


//添加 或 修改
-(NSInteger)UpdateContact:(ContactModel*)data{
    
    
    FMDatabase *db = [self OpenDb];
    BOOL result = NO;
    NSInteger ContactId = data.contactId;
    if(db){
        if(data.contactId == 0){
            result = [db executeUpdate:@"INSERT INTO Contacts (name,phone,prov,city,address,image,isDefaultSender) VALUES (?,?,?,?,?,?,?)",data.strName,data.strPhone,data.strProv,data.strCity,data.strAddress,data.strImage,[NSNumber numberWithInteger:data.isDefaultSender]];
            
            FMResultSet *r = [db executeQuery:@"SELECT max(id) FROM Contacts"];
            while ([r next]){
                ContactId = [r longForColumnIndex:0];
            }
            
        }else{
            result = [db executeUpdate:@"UPDATE Contacts SET name = ?, phone = ?, prov = ?, city = ?, address = ?, image = ? , isDefaultSender = ? WHERE id = ?",data.strName,data.strPhone,data.strProv,data.strCity,data.strAddress,data.strImage,[NSNumber numberWithInteger:data.isDefaultSender],[NSNumber numberWithInteger:data.contactId]];
        }
        
        [db close];
    }
    if(result){
        NSLog(@"数据更新成功");
    }else{
        NSLog(@"数据更新失败");
    }
    return ContactId;
    
}

-(void)RemoveContactWithId:(NSInteger)ContactId{
    FMDatabase *db = [self OpenDb];
    if(db){
        
       BOOL result =  [db executeUpdate:@"DELETE FROM Contacts WHERE id = ?",[NSNumber numberWithInteger:ContactId]];
        [db close];
        
        if(result){
            NSLog(@"数据更新成功");
        }else{
            NSLog(@"数据更新失败");
        }
    }
}

-(void)UpdatePinYinTable:(NSString *)table withRate:(double)rate withText:(NSString *)text{
    //UPDATE PinYinZiKu SET rate = (SELECT max(rate) FROM PinYinZiKu WHERE pinyin = (SELECT pinyin FROM PinYinZiKu WHERE text = '爱'))+1  WHERE text = '爱'
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET rate = (SELECT max(rate) FROM %@ WHERE pinyin = (SELECT pinyin FROM %@ WHERE text = '%@'))+%f  WHERE text = '%@' ",table,table,table,text,rate,text];
    
    FMDatabase *db = [self OpenDb];
    BOOL result = NO;
    if(db){
        result = [db executeUpdate:sql];
        [db close];
    }
    
    NSLog(@"%@\n",sql);
    
    if(result){
        NSLog(@"词频更新成功");
    }else{
        NSLog(@"词频更新失败");
    }
}

-(NSInteger)UpdateMailList:(MailItemModel*)MailItem withSender:(ContactModel*)Sender withReceive:(ContactModel*)Receive{
    NSString *MailToTargetNumber = @"";
    if(Receive.strCity.length >0){
        MailToTargetNumber = [self getCityCode:Receive.strCity];
    }
    
    
    NSString*sql;
    BOOL result;
    FMDatabase *db = [self OpenDb];
    NSInteger updateId = 0;
    
    if(MailItem.mailId == 0){
        sql = @"INSERT INTO MailList (mail_order_id,mail_package_type,mail_package_price,mail_pay_model,mail_from_user,mail_from_phone,mail_from_province,mail_from_city,mail_from_address,mail_to_user,mail_to_phone,mail_to_province,mail_to_city,mail_to_address,mail_create_time,mail_from_uid,mail_to_uid,mail_to_targetNumber) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        
        result = [db executeUpdate:sql,MailItem.mailNumber,MailItem.mailPackageType,[NSNumber numberWithFloat:MailItem.mailPackagePrice],MailItem.mailPayModel,Sender.strName,Sender.strPhone,Sender.strProv,Sender.strCity,Sender.strAddress,Receive.strName,Receive.strPhone,Receive.strProv,Receive.strCity,Receive.strAddress,MailItem.mailCreateTime,[NSNumber numberWithInteger:Sender.contactId],[NSNumber numberWithInteger:Receive.contactId],MailToTargetNumber];
        
        FMResultSet *r = [db executeQuery:@"SELECT max(mail_id) FROM MailList"];
        while ([r next]){
            updateId = [r longForColumnIndex:0];
        }
    }else{
        updateId = MailItem.mailId;
        sql = @"UPDATE MailList SET mail_order_id = ?,mail_package_type = ?,mail_package_price = ?,mail_pay_model = ?,mail_from_user = ?,mail_from_phone = ?,mail_from_province = ?,mail_from_city = ?,mail_from_address = ?,mail_to_user = ?,mail_to_phone = ?,mail_to_province = ?,mail_to_city = ?,mail_to_address = ?,mail_to_targetNumber  WHERE mail_id = ?";
        result = [db executeUpdate:sql,MailItem.mailNumber,MailItem.mailPackageType,[NSNumber numberWithFloat:MailItem.mailPackagePrice],MailItem.mailPayModel,Sender.strName,Sender.strPhone,Sender.strProv,Sender.strCity,Sender.strAddress,Receive.strName,Receive.strPhone,Receive.strProv,Receive.strCity,Receive.strAddress,MailToTargetNumber,[NSNumber numberWithInteger:MailItem.mailId]];
    }
    return updateId;
}

-(void)RemoveMailItem:(NSInteger)mailId{
    FMDatabase *db = [self OpenDb];
    if(db){
        
        BOOL result =  [db executeUpdate:@"DELETE FROM MailList WHERE mail_id = ?",[NSNumber numberWithInteger:mailId]];
        [db close];
        
        if(result){
            NSLog(@"数据更新成功");
        }else{
            NSLog(@"数据更新失败");
        }
    }
}


-(NSDictionary*)getLanguage{
    NSString* packagePath = [[NSBundle mainBundle]pathForResource:@"langPackage" ofType:@"plist"];
    NSDictionary *package = [[NSDictionary alloc]initWithContentsOfFile:packagePath];
    NSString *useLanguageKey = [package objectForKey:@"useLanguage"];
    NSDictionary *language = [package objectForKey:useLanguageKey];
    return language;
}
-(NSString*)getMenuItemTitle:(NSString*)itemKey{
    NSDictionary* menu = [[self getLanguage] objectForKey:@"menu"];
    NSString* Title = [menu objectForKey:itemKey];
    return Title;
}
-(NSString*)getAlertItemTitle:(NSString*)itemKey{
    NSDictionary* alertDic = [[self getLanguage]objectForKey:@"alert"];
    NSString *text = [alertDic objectForKey:itemKey];
    return text;
}
-(NSString*)getPageItemTitle:(NSString*)itemKey{
    NSDictionary* alertDic = [[self getLanguage]objectForKey:@"page"];
    NSString *text = [alertDic objectForKey:itemKey];
    return text;
}
-(NSDictionary*)getPikerItemData:(NSString*)itemKey{
    NSDictionary* itemDics = [[self getLanguage]objectForKey:@"picker"];
    NSDictionary* itemDic = [itemDics objectForKey:itemKey];
    return itemDic;
}
@end
