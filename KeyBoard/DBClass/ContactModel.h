//
//  ContactModel.h
//  SMRT Keyborad
//
//  Created by BOT01 on 17/3/1.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ContactModel;

@interface ContactModel : NSObject
@property(nonatomic,assign)NSInteger contactId;
@property(nonatomic,copy)NSString *strName;
@property(nonatomic,copy)NSString *strPhone;
@property(nonatomic,copy)NSString *strProv;
@property(nonatomic,copy)NSString *strCity;
@property(nonatomic,copy)NSString *strAddress;
@property(nonatomic,copy)NSString *strImage;
@property(nonatomic,assign)NSInteger isDefaultSender;
@property(nonatomic,assign)NSInteger state; //状态0:没选   状态1:发件人    状态2:收件人
@end

@interface MailItemModel : NSObject
@property(nonatomic,assign)NSInteger mailId;
@property(nonatomic,assign)float mailPackagePrice;
@property(nonatomic,copy)NSString *mailPackageType;
@property(nonatomic,copy)NSString *mailPayModel;
@property(nonatomic,copy)NSString *mailNumber;
@property(nonatomic,copy)NSString *mailCreateTime;
@property(nonatomic,copy)NSString *mailDescription;
@end
