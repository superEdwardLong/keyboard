//
//  ContactModel.m
//  SMRT Keyborad
//
//  Created by BOT01 on 17/3/1.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "ContactModel.h"

@implementation ContactModel
@synthesize strName = _strName;
@synthesize strPhone = _strPhone;
@synthesize strProv = _strProv;
@synthesize strCity = _strCity;
@synthesize strAddress = _strAddress;
@synthesize contactId = _contactId;
-(id)init{
    self = [super init];
    if(self){
        _strName = @"";
        _strPhone = @"";
        _strProv = @"";
        _strCity = @"";
        _strAddress = @"";
        _strImage = @"";
        _contactId = 0;
        _isDefaultSender = 0;
    }
    return self;
}
-(void)setStrName:(NSString *)strName{
    _strName = [strName stringByReplacingOccurrencesOfString:@"，" withString:@""];
}
-(void)setStrCity:(NSString *)strCity{
    _strCity = [strCity stringByReplacingOccurrencesOfString:@"，" withString:@""];
}
-(void)setStrProv:(NSString *)strProv{
    _strProv = [strProv stringByReplacingOccurrencesOfString:@"，" withString:@""];
}
@end


@implementation MailItemModel

-(id)init{
    self = [super init];
    if(self){
        NSDate *senddate = [NSDate date];
        
        //NSTimeInterval interval = 60 * 60 * 2;
        //NSDate *AssignDate = [NSDate dateWithTimeInterval:interval sinceDate:senddate];
        
        
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        
        
        _mailId = 0;
        _mailNumber = @"待定";
        _mailCreateTime = [dateformatter stringFromDate:senddate];
       // _mailAssignTime = [dateformatter stringFromDate:AssignDate];
        _mailPayModel = @"寄付现结";
        _mailPackagePrice = 0;
        _mailPackageType = @"文件";
        _mailDescription = @"";
    }
    return self;
}

@end
