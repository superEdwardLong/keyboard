//
//  AddOrderView.m
//  SMRT Board V3
//
//  Created by john long on 2017/5/3.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "AddOrderView.h"
@interface AddOrderView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *icon_labels;
@property (weak, nonatomic) IBOutlet UITextField *input_sender;
@property (weak, nonatomic) IBOutlet UITextField *input_receive;

@property (weak, nonatomic) IBOutlet UIButton *btn_sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_receive;

@property (weak, nonatomic) IBOutlet UIView *picker_package;
@property (weak, nonatomic) IBOutlet UIView *picker_pay;
@property (weak, nonatomic) IBOutlet UIView *picker_price;

@property (weak, nonatomic) IBOutlet UITextField *input_price;
@property (weak, nonatomic) IBOutlet UITextField *input_package;
@property (weak, nonatomic) IBOutlet UITextField *input_pay;


@property (weak, nonatomic) IBOutlet UIButton *btn_save;

@property(nonatomic,retain)UIPickerView *picker;
@property(nonatomic,retain)NSArray *pickerDataSource;
@property(nonatomic,retain)UIView *picker_inner;

@property(nonatomic,strong)UITextField *CurrentSelectedField;

@property(nonatomic,retain)UILoadingView *loading;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *pickerCollection;


@end

@implementation AddOrderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"AddOrderView" owner:self options:nil]lastObject];
    if(self){
        self.frame = frame;
        
        
        for(UILabel *label in _icon_labels){
            label.clipsToBounds = YES;
            label.layer.cornerRadius = 14.f;
        }
        
        
        
        for(UIView *itemView in _pickerCollection){
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            [itemView addGestureRecognizer:tap];
        }
        
    }
    return self;
}
-(void)tapAction:(UITapGestureRecognizer*)sender{
    UIView *targetView = [sender view];
    NSInteger viewId = targetView.tag;
    
    switch (viewId) {
        case 100:
        case 200:{
            if(self.delegate && [self.delegate respondsToSelector:@selector(addOrderViewdidOpenAddressBook)]){
                [self.delegate addOrderViewdidOpenAddressBook];
            }
        }
            
            break;
        case 300:{
                   _CurrentSelectedField = _input_package;
            [self MakePickerView:@[@"文件",@"数码产品",@"日用品",@"服饰",@"食品",@"其他"] withTargetView:targetView];
        }
            
            break;
        case 400:{
            _CurrentSelectedField = _input_price;
            
            [self MakePickerView:@[@"0",@"500",@"1000",@"3000",@"5000",@"10000",@"15000",@"20000"] withTargetView:targetView];
        }
            
            break;
        case 500:{
            _CurrentSelectedField = _input_pay;
            
            [self MakePickerView:@[@"寄付现结",@"到付",@"寄付月结"] withTargetView:targetView];
        }
            
            break;
        default:{
            UIImageView *checkbox =  (UIImageView*)[[sender view] viewWithTag:601];
            checkbox.highlighted = !checkbox.highlighted;
        }
            break;
    }
}




-(void)setSenderAddress:(ContactModel *)senderAddress{
    _senderAddress = senderAddress;
    
    _input_sender.text = [NSString stringWithFormat:@"%@ %@%@%@ %@",senderAddress.strName,senderAddress.strProv,senderAddress.strCity,senderAddress.strAddress,senderAddress.strPhone];
}

-(void)setReceiveAddress:(ContactModel *)receiveAddress{
    _receiveAddress = receiveAddress;
    
    _input_receive.text = [NSString stringWithFormat:@"%@ %@%@%@ %@",receiveAddress.strName,receiveAddress.strProv,receiveAddress.strCity,receiveAddress.strAddress,receiveAddress.strPhone];
}

-(void)setAddressWithSender:(ContactModel *)sender withReceive:(ContactModel *)receive{
    self.senderAddress = sender;
    self.receiveAddress = receive;
}


- (IBAction)SaveAction:(UIButton *)sender {
    
    NSString *err_text;
        if(_input_sender.text.length == 0){
            err_text = @"请输入寄件人地址";
        }else if(_input_receive.text.length == 0){
            err_text = @"请输入收件人地址";
        }
    
    if(err_text){
        _loading = [[UILoadingView alloc]initWithFrame:self.bounds withOnlyText:err_text];
        [self addSubview:_loading];
        [self performSelector:@selector(RemoveLoading) withObject:nil afterDelay:2.f];
        return;
    }
    
    _loading = [[UILoadingView alloc]initWithFrame:self.bounds withText:@"数据提交中..."];
    [self addSubview:_loading];
    
    BoardDB *db = [BoardDB new];
    MailItemModel *mailItem = [MailItemModel new];
    
    if(_input_package.text.length == 0){
        mailItem.mailPackageType = @"文件";
    }else{
        mailItem.mailPackageType = _input_package.text;
    }
    if(_input_price.text.length == 0){
        mailItem.mailPackagePrice = 0;
    }else{
        mailItem.mailPackagePrice = [_input_price.text floatValue];
    }
    if(_input_pay.text.length == 0){
        mailItem.mailPayModel = @"寄付现结";
    }else{
        mailItem.mailPayModel = _input_pay.text;
    }
    
    
    
    NSInteger updateId =  [db UpdateMailList:mailItem withSender:_senderAddress withReceive:_receiveAddress];
    
    if(updateId >0){
        if(self.delegate && [self.delegate respondsToSelector:@selector(addOrderView:didSaveData:)]){
            [self.delegate addOrderView:self didSaveData:updateId];
        }
    }
    
    [self performSelector:@selector(RemoveLoading) withObject:nil afterDelay:2.f];
    
}

-(void)RemoveLoading{
    if(_loading){
        [_loading removeFromSuperview];
        _loading = nil;
    }
}

-(void)RemovePickerView{
    if(_picker_inner == nil)return;
    
    [UIView animateWithDuration:.3f animations:^{
        _picker_inner.frame = CGRectMake(0, self.size.height, self.size.width, 260);
        self.frame = CGRectMake(0, 0, self.size.width, self.size.height);
    } completion:^(BOOL finished) {
        [_picker_inner removeFromSuperview];
        _picker_inner = nil;
        _pickerDataSource = nil;
    }];
}

-(void)MakePickerView:(NSArray*)pickerData withTargetView:(UIView*)targetView{
    NSInteger tag = targetView.tag;
    CGFloat offsetTop = 0;
    if(tag == 300){
        offsetTop = self.size.height - ([[targetView superview]frame].origin.y+[[targetView superview]frame].size.height +268);
    }else{
         offsetTop = self.size.height - ([[[targetView superview]superview ]frame].origin.y+[[[targetView superview]superview ]frame].size.height +268);
    }
    
    offsetTop = MIN(0, offsetTop);
    
    _pickerDataSource = pickerData;
    if(_picker_inner == nil){
        _picker_inner = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 260)];
        _picker_inner.backgroundColor = [UIColor colorWithRed:40/255.f green:40/255.f blue:40/255.f alpha:1.f];
        
        UIButton *btn_done = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_done.frame = CGRectMake(0, 0, 46, 30);
        btn_done.clipsToBounds = YES;
        btn_done.layer.cornerRadius = 4.f;
        [btn_done setTitle:@"完成" forState:UIControlStateNormal];
        [btn_done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn_done setBackgroundColor:[UIColor redColor]];
        btn_done.titleLabel.font = [UIFont systemFontOfSize:15.f];
        [btn_done addTarget:self action:@selector(RemovePickerView) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btn_cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_cancel.frame = CGRectMake(0, 0, 46, 30);
        btn_cancel.clipsToBounds = YES;
        btn_cancel.layer.cornerRadius = 4.f;
        [btn_cancel setTitle:@"取消" forState:UIControlStateNormal];
        [btn_cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn_cancel setBackgroundColor:[UIColor darkGrayColor]];
        btn_cancel.titleLabel.font = [UIFont systemFontOfSize:15.f];
        [btn_cancel addTarget:self action:@selector(RemovePickerView) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.size.width, 44)];
        toolbar.backgroundColor = [UIColor colorWithRed:25.f/255.f green:25.f/255.f blue:25.f/255.f alpha:1.f];
        toolbar.barStyle = UIBarStyleBlack;
        
        UIView *spaceItem = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.size.width-140, 44)];
        UIBarButtonItem *item_middle = [[UIBarButtonItem alloc]initWithCustomView:spaceItem];
        UIBarButtonItem *item_cancel = [[UIBarButtonItem alloc]initWithCustomView:btn_cancel];
        UIBarButtonItem *item_done = [[UIBarButtonItem alloc]initWithCustomView:btn_done];
        
        [toolbar setItems:@[item_cancel,item_middle,item_done]];
        
        [_picker_inner addSubview:toolbar];
        
        if(_picker == nil){
            _picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 44, self.size.width, 216)];
            _picker.delegate = self;
            _picker.dataSource = self;
        }
        
        [_picker_inner addSubview:_picker];
        
        [self addSubview:_picker_inner];
    }
    [_picker reloadComponent:0];
    
    
    [UIView animateWithDuration:.3f animations:^{
        _picker_inner.frame = CGRectMake(0, self.size.height-260-offsetTop, self.size.width, 260);
        self.frame = CGRectMake(0, offsetTop, self.size.width, self.size.height);
    }];
}



-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _pickerDataSource.count;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}
//-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    return [_pickerDataSource objectAtIndex:row];
//}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _CurrentSelectedField.text = [_pickerDataSource objectAtIndex:row];
}
-(UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews)
    {
        if (singleLine.frame.size.height < 1)
        {
            singleLine.backgroundColor = [UIColor darkGrayColor];
        }
    }
    //设置文字的属性
    UILabel *genderLabel = [UILabel new];
    genderLabel.textAlignment = NSTextAlignmentCenter;
    genderLabel.text = [_pickerDataSource objectAtIndex:row];//self.genderArray里边内容为@[@"男",@"女"]
    genderLabel.textColor = [UIColor colorWithWhite:.8 alpha:1];
    
    return genderLabel;
}
@end
