//
//  KMagnifierView.h
//  BOTboard
//
//  Created by BOT01 on 17/2/13.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMagnifierView : UIView
@property (nonatomic) UIView *viewToMagnify;
@property(nonatomic)CGPoint pointToCut;
@property (nonatomic) CGPoint pointToMagnify;
@end
