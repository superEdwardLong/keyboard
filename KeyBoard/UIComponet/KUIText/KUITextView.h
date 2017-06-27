//
//  KUITextView.h
//  BOTboard
//
//  Created by BOT01 on 17/2/16.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol KUITextViewDelegate <NSObject>
@optional
-(void)kTextViewDidConfirmSelection:(UITextView*)textView;
@end

@interface KUITextView : UITextView
@property(nonatomic,assign)id<KUITextViewDelegate>KDelegate;
-(void)ClearPlaceHolder;
-(void)AddPlaceHolder;
@end

