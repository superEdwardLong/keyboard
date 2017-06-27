//
//  PrintObject.h
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/21.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrintObject : NSObject
+(NSDictionary*)getObjectData:(id)obj;

+(NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error;
@end
