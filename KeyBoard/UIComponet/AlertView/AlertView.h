//
//  AlertView.h
//  SMRT Keyborad
//
//  Created by BOT01 on 17/3/6.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlertViewDelegate;

typedef void(^OkActionBlock)();
typedef void(^CancelActionBlock)();

@interface AlertView : UIView
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offset_x_doBtn;

@property (nonatomic, copy) OkActionBlock okBlock;
@property (nonatomic, copy) CancelActionBlock cancelBlock;

@property(nonatomic,assign)id<AlertViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *InnerView;
@property (weak, nonatomic) IBOutlet UIButton *doButton;

@property(nonatomic,assign)id Caller;

@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
-(instancetype)initWithFrame:(CGRect)frame withMsg:(NSString*)msg withOkTitle:(NSString*)okTitle withCancelTitle:(NSString*)cancelTitle;
-(instancetype)initWithFrame:(CGRect)frame withMsg:(NSString*)msg withDoFunctionTitle:(NSString*)funcTitle withOkTitle:(NSString*)okTitle withCancelTitle:(NSString*)cancelTitle;
@end

@protocol AlertViewDelegate <NSObject>
-(void)alertViewDidClickedOk:(AlertView*)KAlerView;
-(void)alertViewDidClickedCancel:(AlertView*)KAlerView;
-(void)alertViewDidClickedDo:(AlertView*)KAlerView;
@end
