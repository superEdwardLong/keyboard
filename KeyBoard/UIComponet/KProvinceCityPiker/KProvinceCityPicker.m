//
//  KProvinceCityPicker.m
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/10.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "KProvinceCityPicker.h"

@implementation KProvinceCityPicker
@synthesize selectedCell = _selectedCell;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor colorWithRed:40/255.f green:40/255.f blue:40/255.f alpha:1];
        self.clipsToBounds = YES;
        
        // picker data
        provinceList = [NSMutableArray array];
        BoardDB *db = [BoardDB new];
        NSMutableArray *arr =  [db FindWithSql:@"SELECT * FROM Prov Order By id ASC" withReturnFields:@[@"id",@"prov_name"]];
        NSMutableDictionary *CITY_DIC = [[NSMutableDictionary alloc]init];
        for(NSInteger i=0; i<arr.count;i++){
            [provinceList addObject:[arr[i] lastObject]];
            NSString *sql = [NSString stringWithFormat:@"SELECT city_name FROM City WHERE prov_id = %@ ",[arr[i] firstObject]];
            NSMutableArray *arr_city =  [db FindWithSql:sql withReturnFields:@"city_name"];
            [CITY_DIC setObject:arr_city forKey:[arr[i] lastObject]];
        }
        cityList = CITY_DIC;
        
        
        UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        [toolbar setBarStyle:UIBarStyleBlack];
        [toolbar setTintColor:[UIColor colorWithWhite:.3 alpha:1]];
        
        UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(4, 7, 50, 30);
        btn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(dismissPricker) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"完成" forState:UIControlStateNormal];
        
        [btn setBackgroundColor:[UIColor colorWithRed:204/255.f green:50/255.f blue:50/255.f alpha:1]];
        btn.layer.cornerRadius = 4.f;

        
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
        NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneBtn,nil];
        [toolbar setItems:buttonsArray];
        [self addSubview:toolbar];
        
        self.picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 44, frame.size.width, frame.size.height-44)];
        self.picker.delegate = self;
        self.picker.dataSource = self;
        [self addSubview:self.picker];
        
        toolbar.sd_layout
        .leftSpaceToView(self,0)
        .rightSpaceToView(self,0)
        .topSpaceToView(self,0)
        .heightIs(44);
        
        self.picker.sd_layout
        .leftSpaceToView(self,0)
        .rightSpaceToView(self,0)
        .bottomSpaceToView(self,0)
        .topSpaceToView(toolbar,0);
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame withCell:(ContactViewCell2 *)cell{
    self =  [self initWithFrame:frame];
    if(self){
        _selectedCell = cell;
    }
    return self;
}

-(void)dismissPricker{
    [self.selectedCell didAllTextViewEditEnd];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"dataPickerShow" object:[NSNumber numberWithBool:NO]];
}

#pragma mark - 该方法的返回值决定该控件包含多少列
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

#pragma mark - 该方法的返回值决定该控件指定列包含多少个列表项
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (0 == component)
    {
        return provinceList.count;
    }else{
        
        NSInteger rowProvince = [pickerView selectedRowInComponent:0];
        NSString *provinceName = provinceList[rowProvince];
        NSArray *citys = cityList[provinceName];
        return citys.count;
    }
}

#pragma mark - 该方法返回的NSString将作为UIPickerView中指定列和列表项的标题文本
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (0 == component) {
        return provinceList[row];
    }else{
        NSInteger rowProvince = [pickerView selectedRowInComponent:0];
        NSString *provinceName = provinceList[rowProvince];
        NSArray *citys = cityList[provinceName];
        return citys[row];
    }
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
    genderLabel.textColor = [UIColor colorWithWhite:.8 alpha:1];
    
    if(0 == component){
        genderLabel.text = provinceList[row];

    }else{
        NSInteger rowProvince = [pickerView selectedRowInComponent:0];
        NSString *provinceName = provinceList[rowProvince];
        NSArray *citys = cityList[provinceName];
        genderLabel.text = citys[row];
    }
    
    return genderLabel;
}


#pragma mark - 当用户选中UIPickerViewDataSource中指定列和列表项时激发该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(0 == component){
        [pickerView reloadComponent:1];
    }
    
        NSInteger rowOne = [pickerView selectedRowInComponent:0];
        NSInteger rowTow = [pickerView selectedRowInComponent:1];
        
        NSString *provinceName = provinceList[rowOne];
        NSArray *citys = cityList[provinceName];
        NSString *cityName = citys[rowTow];
        
        //NSLog(@"%@~%@", provinceName, cityName);
        _selectedCell.ProvinceField.text = provinceName;
        _selectedCell.CityField.text = cityName;
        
        [_selectedCell setTextViewPlaceholderHide:_selectedCell.CityField];
         [_selectedCell setTextViewPlaceholderHide:_selectedCell.ProvinceField];
        

    
    //setFocusWithTextView
    [_selectedCell setFocusWithTextView:_selectedCell.currentTextView];
}
@end
