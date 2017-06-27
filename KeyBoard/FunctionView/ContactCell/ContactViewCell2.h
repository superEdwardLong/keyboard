//
//  ContactViewCell2.h
//  SMRT Keyborad
//
//  Created by BOT01 on 17/3/20.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//
#import "BoardDB.h"
#import "ContactModel.h"
#import <UIKit/UIKit.h>


@interface ContactViewCell2 : UICollectionViewCell<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *UserImageView;
@property(nonatomic,assign)id currentTextView;
@property (weak, nonatomic) IBOutlet UITextView *NameField;
@property (weak, nonatomic) IBOutlet UITextView *TelField;
@property (weak, nonatomic) IBOutlet UITextView *ProvinceField;
@property (weak, nonatomic) IBOutlet UITextView *CityField;
@property (weak, nonatomic) IBOutlet UITextView *AddressField;
@property(nonatomic,assign)BOOL editEnable;
@property (strong, nonatomic) IBOutletCollection(UITextView) NSArray *FieldArr;



@property (weak, nonatomic) IBOutlet UIButton *SaveButton;

@property(nonatomic,assign)NSInteger ContactId;
@property(nonatomic,assign)NSInteger CellIndex;


-(void)setForm:(ContactModel*)data;
-(void)resetForm;
-(void)didAllTextViewEditEnd;
-(void)setTextViewPlaceholderHide:(UITextView *)textView;
-(void)setFocusWithTextView:(UITextView *)textView;
-(void)setTextView:(UITextView*)textView Value:(NSString*)value;
@end


