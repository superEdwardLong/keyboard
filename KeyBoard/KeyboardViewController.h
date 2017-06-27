//
//  KeyboardViewController.h
//  KeyBoard
//
//  Created by BOT01 on 17/3/31.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#define kFullHeight 484.f
#define kBoardViewHeight 257.f
#define kBoardViewContentHeight 216.f

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>

#import "AFNetworking.h"

@interface KeyboardViewController : UIInputViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UIImagePickerController *_imagePickerController;
    BOOL isOpen;
}
// 用于网络请求的Session对象
@property (nonatomic, strong) AFHTTPSessionManager * _Nullable session;



-(void)viewResize:(CGFloat)height completion:(void (^ __nullable)())resizeCompletion;
-(void)matchAddressToShipt:(NSString*_Nullable)address;
@end
