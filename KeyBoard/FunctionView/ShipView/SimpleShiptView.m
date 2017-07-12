//
//  SimpleShiptView.m
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/22.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "SimpleShiptView.h"

@interface SimpleShiptView()<FlexButtonView2Delegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offset_x_left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offset_x_right;
@property (weak, nonatomic) IBOutlet UIView *segmentView;

@property (weak, nonatomic) IBOutlet UIView *col_1;
@property (weak, nonatomic) IBOutlet UIView *col_2;
@property (weak, nonatomic) IBOutlet UIView *col_3;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offset_x_left_button;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offset_x_right_button;
@property(nonatomic,retain)AlertView *alertView;

@property(nonatomic,retain)BoardDB *DB;

@end

@implementation SimpleShiptView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle]loadNibNamed:@"SimpleShiptView" owner:self options:nil]lastObject];
    if(self){
        self.frame = frame;
        _DB = [BoardDB new];
        self.arr = [_DB FindContactsWithFilter:nil];
        [self performSelector:@selector(MakeContactList) withObject:self afterDelay:0.3];
        
        [_btn_QRCode setTitle:[_DB getMenuItemTitle:@"qrcode"] forState:UIControlStateNormal];
        NSString *strAppointment = [_DB getMenuItemTitle:@"appointment"];
        [_btn_Apointment setTitle:strAppointment forState:UIControlStateNormal];
        [_MakeOrderButton setTitle:[_DB getMenuItemTitle:@"ok"] forState:UIControlStateNormal];
        
        CGRect strAppointmentRect = [strAppointment boundingRectWithSize:CGSizeMake(1000.f, _btn_Apointment.frame.size.height)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{NSFontAttributeName:_btn_Apointment.titleLabel.font}
                                                                 context:nil];
        
        if(strAppointmentRect.size.width > _btn_Apointment.frame.size.width){
            CGFloat bit = _btn_Apointment.frame.size.width/strAppointmentRect.size.width;
            CGFloat fontSize = [_btn_Apointment.titleLabel.font pointSize]*bit;
            [_btn_Apointment.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
        }
       
    }
    return self;
}


-(void)MakeContactList{
    [self MakeFlexButtonView];
    
    self.senderList = [[BOT3DOptionView alloc]initWithFrame:_row_sender.bounds withCellClassName:@"ContactViewCell"];
    self.senderList.editEnable = YES;
    self.senderList.OptionsData = _arr;
    [self.row_sender addSubview:self.senderList];
    
    self.senderList.sd_layout
    .leftSpaceToView(self.label_sender,0)
    .rightSpaceToView(self.row_sender,0)
    .topSpaceToView(self.row_sender,0)
    .bottomSpaceToView(self.row_sender,0);
    
    
    self.recevieList = [[BOT3DOptionView alloc]initWithFrame:_row_receive.bounds withCellClassName:@"ContactViewCell"];
    self.recevieList.editEnable = NO;
    self.recevieList.OptionsData = _arr;
    
    [self.row_receive addSubview:self.recevieList];
    
    self.recevieList.sd_layout
    .leftSpaceToView(self.label_receive,0)
    .rightSpaceToView(self.row_receive,0)
    .topSpaceToView(self.row_receive,0)
    .bottomSpaceToView(self.row_receive,0);
    
    if(_arr.count == 0){
        if(self.delegate && [self.delegate respondsToSelector:@selector(simpleShiptViewAddressIsNull:)]){
            [self.delegate simpleShiptViewAddressIsNull:self];
        }
        return;
    }
    
    
    
    
    NSInteger DefaultSenderIndex = 0;
    for(NSInteger i= 0; i<_arr.count;i++){
        if(((ContactModel*)_arr[i]).isDefaultSender == 1){
            [_senderList ScrollToItem:i];
            DefaultSenderIndex = i;
            break;
        }
    }
    
    if(DefaultSenderIndex == 0){
        [_recevieList ScrollToItem:MIN(DefaultSenderIndex+1,_arr.count-1)];
    }

}




-(void)MakeFlexButtonView{
    NSDictionary*option_1 = [_DB getPikerItemData:@"package"];
    NSDictionary*option_2 = [_DB getPikerItemData:@"insured"];
    NSDictionary*option_3 = [_DB getPikerItemData:@"pay"];
    
    NSString*title_1 = [option_1 objectForKey:@"title"];
    NSString*title_2 = [option_2 objectForKey:@"title"];
    NSString*title_3 = [option_3 objectForKey:@"title"];
    
    NSArray*arr_1 = [option_1 objectForKey:@"options"];
    NSArray*arr_2 = [option_2 objectForKey:@"options"];
    NSArray*arr_3 = [option_3 objectForKey:@"options"];
    
    _left_flex = [[FlexButtonView2 alloc]initWithFrame:_col_1.bounds
                                         withBaseTitle:title_1
                                      withDefaultValue:[arr_1 objectAtIndex:0]
                                           withOptions:arr_1];
    _left_flex.delegate = self;
    
    _right_flex = [[FlexButtonView2 alloc]initWithFrame:_col_3.bounds
                                          withBaseTitle:title_3
                                       withDefaultValue:[arr_3 objectAtIndex:0]
                                            withOptions:arr_3];
    _right_flex.delegate = self;
    
    _center_flex = [[FlexButtonView2 alloc]initWithFrame:_col_2.bounds
                                           withBaseTitle:title_2
                                        withDefaultValue:[arr_2 objectAtIndex:0]
                                             withOptions:arr_2];
    _center_flex.delegate = self;
    
    [_col_1 addSubview:_left_flex];
    [_col_2 addSubview:_center_flex];
    [_col_3 addSubview:_right_flex];

    _left_flex.sd_layout
    .leftSpaceToView(_col_1,10)
    .rightSpaceToView(_col_1,5)
    .topSpaceToView(_col_1,0)
    .bottomSpaceToView(_col_1,0);
    
    
    _right_flex.sd_layout
    .leftSpaceToView(_col_3,5)
    .rightSpaceToView(_col_3,10)
    .topSpaceToView(_col_3,0)
    .bottomSpaceToView(_col_3,0);
    
    
    _center_flex.sd_layout
    .leftSpaceToView(_col_2,5)
    .rightSpaceToView(_col_2,5)
    .topSpaceToView(_col_2,0)
    .bottomSpaceToView(_col_2,0);
}

-(void)SelectedReceiveItemAtId:(NSInteger)ReceiveId{
    for(NSInteger i=0; i< _arr.count;i++){
        if(((ContactModel*)_arr[i]).contactId == ReceiveId){
            [_recevieList ScrollToItem:i];
            break;
        }
    }
}

-(void)setOrderId:(NSInteger)orderId{
    _orderId = orderId;
    if(orderId > 0){
    
        BoardDB *db = [BoardDB new];
        NSString *sql = [NSString stringWithFormat:@"SELECT mail_from_uid,mail_to_uid,mail_package_type,mail_package_price,mail_pay_model,mail_order_id, From MailList WHERE mail_id = %ld",orderId];
        NSMutableArray *rows = [[db FindWithSql:sql withReturnFields:@[@"mail_from_uid",@"mail_to_uid",@"mail_package_type",@"mail_package_price",@"mail_pay_model",@"mail_order_id"]] lastObject];
        
        NSInteger senderId,receiveId;
        senderId = [rows[0] integerValue];
        receiveId = [rows[1] integerValue];
        
        BOOL sender_local = NO;
        BOOL receive_local = NO;
        
        //选中 发件人 和 收件人
        for(NSInteger i=0; i<_arr.count;i++){
            if (sender_local && receive_local) {
                break;
            }
            
            if( [_arr[i] contactId] == senderId){
                sender_local = YES;
                [_senderList ScrollToItem:i];
            }
            
            if( [_arr[i] contactId] == receiveId){
                receive_local = YES;
                [_recevieList ScrollToItem:i];
            }
            
        }
        //配置，快件属性
        if([rows[2]length] >0){
            _left_flex.label_value.text = rows[2];
        }
        if([rows[3]length] >0){
            _center_flex.label_value.text = rows[3];
        }
        if([rows[4]length] >0){
            _right_flex.label_value.text = rows[4];
        }
        
        
        if([rows[5]length] >0){
            _orderNumber = rows[5];
        }
        _offset_x_right_button.constant =  0 - [[UIScreen mainScreen]bounds].size.width *2;
        _offset_x_left_button.constant =  0;
    }
}

-(void)layoutSubviews{
    if(_orderId > 0){
        //修改模式
        _offset_x_right_button.constant =  0 - [[UIScreen mainScreen]bounds].size.width *2;
        _offset_x_left_button.constant =  0;
    }else{
        //非修改模式
        _offset_x_left_button.constant =  0 - [[UIScreen mainScreen]bounds].size.width *0.5;
        _offset_x_right_button.constant =  0;
    }
}


#pragma mark flexButtonView delegate
//即将展开
-(void)flexButtonViewWillDisplay:(FlexButtonView2 *)flexButtonView{
    if([flexButtonView isEqual:_left_flex]){        
        CGFloat constraintValue =  0 - self.size.width * 2;
        [self updateConstraints:@[_offset_x_right] withValues:@[[NSNumber numberWithFloat:constraintValue]]];
    }else if([flexButtonView isEqual:_right_flex]){
        
        CGFloat constraintValue =  0 - self.size.width * 2;
        [self updateConstraints:@[_offset_x_left] withValues:@[[NSNumber numberWithFloat:constraintValue]]];
    }else{
        CGFloat constraintLeftValue = 0 - self.size.width;
        CGFloat constraintRightValue = 0 - self.size.width;
        [self updateConstraints:@[_offset_x_right,_offset_x_left]
                     withValues:@[[NSNumber numberWithFloat:constraintLeftValue],
                                  [NSNumber numberWithFloat:constraintRightValue]
                                  ]
         ];
    }
}
//即将关闭
-(void)flexButtonViewWillDedisplay:(FlexButtonView2 *)flexButtonView{
    if([flexButtonView isEqual:_left_flex]){
        [self updateConstraints:@[_offset_x_right] withValues:@[[NSNumber numberWithFloat:0]]];
    }else if([flexButtonView isEqual:_right_flex]){
        [self updateConstraints:@[_offset_x_left] withValues:@[[NSNumber numberWithFloat:0]]];
    }else{
        [self updateConstraints:@[_offset_x_right,_offset_x_left]
                     withValues:@[[NSNumber numberWithFloat:0],
                                  [NSNumber numberWithFloat:0]
                                  ]
         ];
    }
}

-(void)updateConstraints:(NSArray*)constraints withValues:(NSArray*)values{
    for(NSInteger i=0; i< constraints.count; i++){
        ((NSLayoutConstraint*)constraints[i]).constant = [values[i] floatValue];
    }
    [_segmentView setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [_segmentView layoutIfNeeded];
    }];
}
@end
