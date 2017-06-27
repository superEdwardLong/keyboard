//
//  UILoadingView.h
//  BOTboard
//
//  Created by BOT01 on 17/2/17.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILoadingView : UIView
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property(nonatomic,copy)NSString *text;
@property (weak, nonatomic) IBOutlet UIView *groupView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

-(id)initWithFrame:(CGRect)frame withText:(NSString*)text;
-(id)initWithFrame:(CGRect)frame withOnlyText:(NSString *)text;
@end
