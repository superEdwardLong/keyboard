//
//  NumberKeyboardView.h
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/18.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NumberKeyboardView : UIView
@property (nonatomic, assign) id <UITextDocumentProxy> Proxy;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonArr;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *spaceButton;

@end
