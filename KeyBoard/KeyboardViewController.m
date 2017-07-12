//
//  KeyboardViewController.m
//  KeyBoard
//
//  Created by BOT01 on 17/3/31.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//
#import "BasicBoardView.h"
#import "UILoadingView.h"
#import "PinYinModel.h"
#import "KProvinceCityPicker.h"
#import "KUIInputView.h"
#import "KeyboardViewController.h"


@interface KeyboardViewController ()<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIScrollViewDelegate,
BasicBoardViewDelegate>

@property(nonatomic,strong)NSLayoutConstraint   *KeyboardHeightConstraint;
@property(nonatomic,strong)KUIInputView* contentView;
//@property(nonatomic,strong)EnglishKeyboardView  *keyboardView;

@property(nonatomic,strong)KProvinceCityPicker *CityPicker;
@property(nonatomic,assign)AFNetworkReachabilityStatus NetWorkState;

//启动图片编辑时需要用到
@property(nonatomic,retain)UIImageView* editContactImageView;


//候选词数据
@property(nonatomic,retain)NSMutableArray *WordsArr;
@property(nonatomic,assign)int WordsPage;
@property(nonatomic,assign)int WordsPageSize;
@property(nonatomic,retain)UIActivityIndicatorView *PageDataLoading;

@property(nonatomic,retain)BasicBoardView *keyboardView;

@property(nonatomic,retain)UILoadingView *LoadingView;
@end

@implementation KeyboardViewController
@synthesize KeyboardHeightConstraint;




- (void)updateViewConstraints {
    [super updateViewConstraints];
    //添加约束
    
    // Add custom view sizing constraints here
}

-(void)viewWillAppear:(BOOL)animated{
    _keyboardView = [[BasicBoardView alloc]initWithFrame:CGRectMake(0,KeyboardHeightConstraint.constant-kBoardViewContentHeight,
                                                                 self.view.size.width,
                                                                 kBoardViewContentHeight)];
    _keyboardView.Proxy = self.textDocumentProxy;
    _keyboardView.window.windowLevel = UIWindowLevelAlert;
    _keyboardView.clipsToBounds = NO;
    _keyboardView.delegate = self;
    [self.view addSubview:_keyboardView];
    
    _keyboardView.sd_layout
    .leftSpaceToView(self.view,0)
    .rightSpaceToView(self.view,0)
    .heightIs(kBoardViewContentHeight);
}

-(void)viewDidDisappear:(BOOL)animated{
    [_keyboardView removeFromSuperview];
    _keyboardView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.window.windowLevel = UIWindowLevelAlert;
    self.view.clipsToBounds = NO;
    
    
    KeyboardHeightConstraint = [NSLayoutConstraint constraintWithItem: self.view
                                                            attribute: NSLayoutAttributeHeight
                                                            relatedBy: NSLayoutRelationEqual
                                                               toItem: nil
                                                            attribute: NSLayoutAttributeNotAnAttribute
                                                           multiplier: 0.0
                                                             constant: kBoardViewHeight];
    [self.view addConstraint: KeyboardHeightConstraint];
    
    [self setDataBaseLocation];
    
    //创建功能视图
    self.contentView = [[KUIInputView alloc]initWithFrame:self.view.bounds];
    self.contentView.superController = self;
    [self.view addSubview: self.contentView];
    self.contentView.sd_layout
    .topSpaceToView(self.view,0)
    .bottomSpaceToView(self.view,0)
    .leftSpaceToView(self.view,0)
    .rightSpaceToView(self.view,0);
    
    
    [self performSelector:@selector(MakeWordsCollectionView) withObject:nil afterDelay:0.3];

    [self RegKeyboardNotification];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

-(void)CallAppPage:(NSNotification*)sender{

    NSString *APPURL = [NSString stringWithFormat:@"smrtkeyboard://%@",[sender object]];//smrtkeyboard
    UIResponder* responder = self;
    while ((responder = [responder nextResponder]) != nil)
    {
        
        if([responder respondsToSelector:@selector(openURL:)] == YES)
        {
            [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:APPURL]];
        }
    }
}


#pragma mark 数据库迁移
-(BOOL)setDataBaseLocation{
    int kCurrentVer = 13;
    NSString *dbName = [NSString stringWithFormat:@"wordlib_ver_%d.db",kCurrentVer];
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.bizopstech.keyboard"];
    NSString *db_path = [containerURL.path stringByAppendingPathComponent:dbName];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:db_path];
    BOOL isSuccess = YES;
    
    if(isExist == NO){
        ///// 如果新版本数据库不存在，且不是第一个版本，删除就版本数据库
        if(kCurrentVer > 1){
            NSString *oldDbName,*old_db_path;
            for(int i=1; i< kCurrentVer;i++){
                oldDbName = [NSString stringWithFormat:@"wordlib_ver_%d.db",i];
                old_db_path = [containerURL.path stringByAppendingPathComponent:oldDbName];
                BOOL subIsExist = [[NSFileManager defaultManager] fileExistsAtPath:old_db_path];
                if(subIsExist){
                    BOOL DELSuccess = [[NSFileManager defaultManager] removeItemAtPath:old_db_path error:nil];
                    if (DELSuccess) {
                        NSLog(@"数据库 wordlib_ver_%d 删除成功",i);
                    }else{
                        NSLog(@"数据库 wordlib_ver_%d 删除失败",i);
                    }
                }
            }
        }
        
        ////创建新版本数据库
        NSString *source_path = [[NSBundle mainBundle]pathForResource:@"wordlib" ofType:@"db"];
        isSuccess = [[NSFileManager defaultManager] copyItemAtPath:source_path toPath:db_path error:nil];
        if (isSuccess) {
            NSLog(@"新版本数据库复制成功");
        }else{
            NSLog(@"新版本数据库复制失败");
        }
    }else{
        NSLog(@"这个版本的数据库已经存在");
    }
    return isSuccess;
}


-(void)RegKeyboardNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(CallAppPage:) name:@"CallAppPage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NextInputMode:) name:@"advanceToNextInputMode" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ActivationKeyboard:) name:@"CallKeyboard" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataPickerShow:) name:@"dataPickerShow" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(matchAddress:) name:@"matchAddress" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showImagePicker:) name:@"showImagePicker" object:nil];
}

-(void)NextInputMode:(NSNotification*)sender{
    [self advanceToNextInputMode];
}


#pragma mark main viwe height resize
-(void)viewResize:(CGFloat)height completion:(void (^ __nullable)())resizeCompletion{
    KeyboardHeightConstraint.constant = height;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        resizeCompletion();
    }];
}



#pragma mark 呼叫键盘
-(void)setKeyboardViewProxy:(id<UITextDocumentProxy>)proxy{
    _keyboardView.Proxy = proxy;
    
    switch (_keyboardView.panelModel) {
        case keyboardPanelNumber:{
            _keyboardView.NumberView.Proxy = proxy;
        }
            break;
        case keyboardPanelSymbol:{
            _keyboardView.SymbolView.Proxy = proxy;
        }break;
            
        default:{
            
        }
            break;
    }
}

-(void)ActivationKeyboard:(NSNotification*)sender{
    BOOL visible;
    CGRect frame;
    
    //关闭弹出菜单
    [_contentView setSelectionTextMenuHide];
    
    
    if([[sender object]isKindOfClass:[NSNumber class]]){
        
        visible = [[sender object]boolValue];
        [self setKeyboardViewProxy:self.textDocumentProxy];
        
    }else if([[sender object]isKindOfClass:[NSDictionary class]]){
        
        NSDictionary*info = [sender object];
        visible = [info objectForKey:@"Visible"];
        [self setKeyboardViewProxy:[info objectForKey:@"UIInput"]];
        
    }else{

        visible = [[sender object]isEqualToString:@"ShowWordOption"] ? NO:YES;
    }
    
    //如果不是查看候选词的就清理记忆文本
    if(![[sender object]isKindOfClass:[NSString class]]){
        self.keyboardView.CurrentInputText = nil; //清空记忆中的输入文本
    }

    if(visible){
        [_contentView checkedFlexButtonStateDidKeyboardAppear];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"dataPickerShow" object:@0];
        _contentView.option_button.hidden = NO;
        
        [self MakeWordsCollectionView];
        frame = CGRectMake(0,
                           KeyboardHeightConstraint.constant-kBoardViewContentHeight,
                           self.keyboardView.size.width,
                           kBoardViewContentHeight);
    }else{
        //如果不是查看候选词的就清理选词控件
        if(![[sender object]isKindOfClass:[NSString class]]){
            [self RemoveWordsCollectionView];
            _contentView.option_button.hidden = YES;
        }
        frame = CGRectMake(0,
                           kFullHeight,
                           self.keyboardView.size.width,
                           kBoardViewContentHeight);
        
    }
    [UIView animateWithDuration:0.2f animations:^{
        self.keyboardView.frame = frame;
    } completion:^(BOOL finished) {
        if(_WordsArr == nil || _WordsArr.count == 0){
            _contentView.option_button.hidden = YES;
        }
    }];
}

/*=================================================
 
 省市联动选择器
 
 
 
 =================================================*/
#pragma mark 省市选择器
-(void)dataPickerShow:(NSNotification*)sender{
    BOOL visible;
    CGFloat KOriginY;
    ContactViewCell2 *cell;
    if([[sender object]isKindOfClass:[NSNumber class]]){
        visible = [[sender object]boolValue];
    }else {
        visible = [[[sender object] objectForKey:@"Visible"]boolValue];
        cell = [[sender object] objectForKey:@"Cell"];
    }
    
    if(visible){
        KOriginY = 0;
        if(self.CityPicker == nil){
            self.CityPicker = [[KProvinceCityPicker alloc]initWithFrame:CGRectMake(0, -kFullHeight, self.view.size.width, kBoardViewHeight) withCell:cell];
            [self.view addSubview:self.CityPicker];
            
            self.CityPicker.sd_layout
            .leftSpaceToView(self.view,0)
            .rightSpaceToView(self.view,0).heightIs(kBoardViewHeight);
            
            
        }else{
            self.CityPicker.selectedCell = cell;
        }
        
        [self.view bringSubviewToFront:self.CityPicker];
        
    }else{
        KOriginY = -kFullHeight;
    }
    
    if(self.CityPicker){
        self.CityPicker.sd_layout.bottomSpaceToView(self.view,KOriginY);
        [UIView animateWithDuration:0.4f animations:^{
            [self.CityPicker layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.CityPicker updateLayout];
        }];
    }
    
}


/*=================================================
 
 图片选择器
 
 
 
 =================================================*/
-(void)showImagePicker:(NSNotification*)sender{
    NSDictionary* info = [sender object];
    UIImageView *img = [info objectForKey:@"Image"];
    _editContactImageView = img;

    
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    _imagePickerController.allowsEditing = NO;
    _imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePickerController.videoQuality = UIImagePickerControllerQualityTypeLow;
    _imagePickerController.toolbar.barStyle = UIBarStyleBlack;
    
    [self presentViewController:_imagePickerController animated:YES completion:nil];
     
}


#pragma mark 图片选择器 imagePickerController delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if([mediaType isEqualToString:(NSString*)kUTTypeImage]){
        //组织文件路径
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
        NSString *imageName = [NSString stringWithFormat:@"Contact_%f",interval];
        NSString* paths = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString* fullPathToFile = [paths stringByAppendingPathComponent:imageName];
        
        //存入沙盒
        NSData *imageData = [self UseImage:info[UIImagePickerControllerOriginalImage]];//UIImagePickerControllerEditedImage
        [imageData writeToFile:fullPathToFile atomically:NO];
        
        [_editContactImageView setImage:[UIImage imageWithContentsOfFile:fullPathToFile]];
        _editContactImageView.accessibilityIdentifier = fullPathToFile;

    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        _imagePickerController = nil;
    }];
}



-(NSData*)UseImage:(UIImage*)image{
    //实现等比例缩放
    CGFloat hfactor = image.size.width / 320;
    CGFloat vfactor = image.size.height / 320;
    CGFloat factor = fmax(hfactor, vfactor);
    //画布大小
    CGFloat newWith = image.size.width / factor;
    CGFloat newHeigth = image.size.height / factor;
    CGSize newSize = CGSizeMake(newWith, newHeigth);
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newWith, newHeigth)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //图像压缩
    NSData *newImageData = UIImageJPEGRepresentation(newImage, 0.5);
    return newImageData;
}

/*=================================================
 
 联网数据交互
 
 
 
 =================================================*/
#pragma mark AFNetWork
-(void)set_network_config{
    if(self.session == nil){
        
        self.session = [AFHTTPSessionManager manager];
        self.session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"application/x-json",@"text/html", nil];
    }

    
    if (!isOpen) {
        //打开网络监测
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        isOpen = YES;
    } else {
        // 关闭网络监测
        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
        isOpen = NO;
    }

    
}

/*================================================================
 
 智能匹配地址
 
================================================================*/
#pragma mark 中文分词
-(NSMutableArray *)stringTokenizerWithWord:(NSString *)word{
    NSMutableArray *keyWords=[NSMutableArray new];
    
    CFStringTokenizerRef ref=CFStringTokenizerCreate(NULL,  (__bridge CFStringRef)word, CFRangeMake(0, word.length),kCFStringTokenizerUnitWord,NULL);
    CFRange range;
    CFStringTokenizerAdvanceToNextToken(ref);
    range=CFStringTokenizerGetCurrentTokenRange(ref);
    NSString *keyWord;
    
    
    while (range.length>0)
    {
        keyWord=[word substringWithRange:NSMakeRange(range.location, range.length)];
        [keyWords addObject:keyWord];
        CFStringTokenizerAdvanceToNextToken(ref);
        range=CFStringTokenizerGetCurrentTokenRange(ref);
    }
    
    return keyWords;
}

#pragma mark 电话号码提取
- (NSString *)getPhoneNumbersFromString:(NSString *) str {
    NSString *phone = @"";
    NSError* error = nil;
    NSString* regulaStr = @"((((\\+86|\\+86 |\\+86\\- |86)?)([0-9]{11,12}))|((400|800)([0-9\\-]{7,10})|(([0-9]{4}|[0-9]{3})(-| )?)?([0-9]{7,8})((-| |转)*([0-9]{1,4}))?))";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSArray *arrayOfAllMatches = [regex matchesInString:str options:0 range:NSMakeRange(0, [str length])];
    //NSMutableArray* numbers = [NSMutableArray arrayWithCapacity:arrayOfAllMatches.count];
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString* substringForMatch = [str substringWithRange:match.range];
        //[numbers addObject:substringForMatch];
        phone = [phone stringByAppendingString:substringForMatch];
    }
    
    return phone;
}

-(NSArray*)getProvinceAndCityFromString:(NSString*)str{
    BoardDB *DB = [BoardDB new];
    NSArray *city_arr = [DB FindWithSql:@"SELECT prov_name,city_name FROM Prov JOIN City ON Prov.id = City.prov_id" withReturnFields:@[@"prov_name",@"city_name"]];
    NSArray *words = [self stringTokenizerWithWord:str]; //打散字符串，分词
    NSString *CITY,*PROVINCE;
    BOOL IsMatch = NO;
    for(NSInteger i=0; i<words.count;i++){
        if([words[i] length] <= 1) continue;
        for(NSInteger j=0;j<city_arr.count;j++){
            CITY = [city_arr[j] lastObject];
            NSRange Range = [words[i] length] > CITY.length ?  [words[i] rangeOfString:CITY]:[CITY rangeOfString:words[i]];
            if(Range.location != NSNotFound){
                PROVINCE = [city_arr[j] firstObject];
                IsMatch = YES;
                break;
            }
        }
        
        if(IsMatch){
            break;
        }
    }
    
    NSArray *arr = [NSArray array];
    if(IsMatch){
        //如果匹配成功
        arr = @[PROVINCE,CITY];
        
    }else{
        // 市，区 匹配失败
        // 再试试匹配直辖市
        NSError* error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"北京市|天津市|上海市|重庆市"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        
        NSArray *arrayOfAllMatches = [regex matchesInString:str options:0 range:NSMakeRange(0, [str length])];
        NSString *CITY = @"";
        for (NSTextCheckingResult *match in arrayOfAllMatches)
        {
            NSString* substringForMatch = [str substringWithRange:match.range];
            CITY = [CITY stringByAppendingString:substringForMatch];
        }
        
        if(CITY.length >0){
            PROVINCE = [CITY copy];
            arr = @[PROVINCE,CITY];
        }
    }
    return arr;
}


-(NSDictionary*)getNameFromString:(NSString*)str_temp{
    BoardDB *db = [BoardDB new];
    NSArray *xing = [db FindWithSql:@"SELECT name FROM Surname" withReturnFields:@"name"];
    NSRange xingRange;
    NSInteger matchIndex = -1;
    
    NSString*myName = @"";
    NSArray *items = [self stringTokenizerWithWord:str_temp];
    for(NSInteger i=0; i< items.count;i++){
        if ([items[i] length] > 4) continue;
        for(NSInteger j=0; j< xing.count; j++){
            xingRange = [items[i] rangeOfString:xing[j]];
            if(xingRange.location != NSNotFound && xingRange.location == 0){
                matchIndex = i;
                break;
            }
        }
        if(matchIndex != -1){
            break;
        }
    }
    
    //最有可能出现名字的位置
    if(matchIndex == 0){
        if([items[matchIndex] length] >1 && [items[matchIndex] length] <= 4){
            myName = items[matchIndex];
        }else if([items[matchIndex] length] == 1){
            for(NSInteger i=matchIndex;i<items.count;i++){
                myName = [myName stringByAppendingString:items[i]];
                if(i==1){
                    if(myName.length > 4){
                        myName = @"";
                    }
                    break;
                }
            }
        }
    }else if((items.count > 2 && matchIndex >= items.count-2) || matchIndex == items.count-1){
        for(NSInteger i=matchIndex;i<items.count;i++){
            myName = [myName stringByAppendingString:items[i]];
        }
        if(myName.length > 4){
            myName = @"";
        }
    }
    
    myName = [myName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@".?#!,，。？！"]];
    return @{@"name":myName,@"index":@(matchIndex)};
}

-(NSArray*)getDetailAndNameFromString:(NSString*)address
                         withProvince:(NSString*)province
                             withCity:(NSString*)city{
    
    NSString *phone = [self getPhoneNumbersFromString:address];
    NSString *myName = @"";
    NSString *detail = @"";
    NSString *str_temp,*str_temp2;
    NSRange cityRange;
    NSRange phoneRange;
    
    if(phone && phone.length > 0){
        phoneRange = [address rangeOfString:phone];
    }else{
        phoneRange = NSMakeRange(NSNotFound, 0);
    }
    
    
    
    if(phoneRange.location == NSNotFound || phoneRange.location == 0 || phoneRange.location + phoneRange.length == address.length){
        //无电话，或 电话在前面 或 电话在 最后面
        //电话在两边，先过滤电话号码
        str_temp = phone.length == 0 ? address : [address stringByReplacingOccurrencesOfString:phone withString:@""];
        str_temp = [str_temp stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@".?#!,，。？！"]];
        
        //从这个字符串提取姓名和地址
        cityRange = [self getCityRange:city withProvince:province withAddress:str_temp];
        
        if(cityRange.location != NSNotFound && cityRange.location > 0){
            //在省份或市区前面还存在字符串的，前面是名字
            myName = [str_temp substringToIndex:cityRange.location];
            detail = [str_temp substringFromIndex:cityRange.location+cityRange.length];
            
        }else if((cityRange.location != NSNotFound && cityRange.location == 0) || cityRange.location == NSNotFound){
            
            
            //出现省市区关键字，且在开始位置，名字隐藏在后面 或者 根本没有名字
            //省份市区关键字根本没有出现，名字可能在前面或在后面或根本没有
            //寻找姓氏出现位置，要么在首位出现，要么在最后
            if(cityRange.location != NSNotFound){
                str_temp = [str_temp substringFromIndex:cityRange.length];
            }
            
            //寻找姓氏出现的位置
            NSDictionary *nameInfo = [self getNameFromString:str_temp];
            myName = [nameInfo objectForKey:@"name"];
            NSInteger matchIndex = [[nameInfo objectForKey:@"index"]integerValue];
            
            if(myName.length > 0){
                detail = matchIndex ==0 ?[str_temp substringFromIndex:myName.length]:[str_temp substringToIndex:[str_temp rangeOfString:myName].location];
            }else{
                detail = str_temp;
            }
            
        }
    }else{
        //在中间
        str_temp = [address substringToIndex:phoneRange.location];
        str_temp2 = [address substringFromIndex:phoneRange.location+phoneRange.length];
        if(str_temp.length > str_temp2.length){
            detail = str_temp;
            myName = str_temp2;
        }else{
            myName = str_temp;
            detail = str_temp2;
        }
        
        cityRange = [self getCityRange:city withProvince:province withAddress:detail];
        
        if(cityRange.location != NSNotFound){
            detail = [detail substringFromIndex:cityRange.location+cityRange.length];
        }
    }
    
    //过滤两端字符
    myName = [myName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@".?#!,，。？！"]];
    detail = [detail stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@".?#!,，。？！"]];
    
    NSArray *arr = @[myName,detail];
    return arr;
}


-(NSRange)getCityRange:(NSString*)city withProvince:(NSString*)province withAddress:(NSString*)address{
    NSRange cityRange;
    if(city.length > 0){
        cityRange = [address rangeOfString:[NSString stringWithFormat:@"%@省%@市",province,city]];//省+市
        if(cityRange.location == NSNotFound){
            cityRange = [address rangeOfString:[NSString stringWithFormat:@"%@省%@",province,city]];//省+市
            if(cityRange.location == NSNotFound){
                cityRange = [address rangeOfString:[NSString stringWithFormat:@"%@市%@",province,city]];//直辖市+区
                if(cityRange.location == NSNotFound){
                    cityRange = [address rangeOfString:[NSString stringWithFormat:@"%@%@",province,city]];
                    if(cityRange.location == NSNotFound){
                        //直辖市区的可能性比较大
                        cityRange = [city rangeOfString:@"区"];
                        if(cityRange.location > 0){
                            cityRange = [address rangeOfString:[NSString stringWithFormat:@"%@",city]];
                            if(cityRange.location == NSNotFound){
                                cityRange = [address rangeOfString:[city stringByReplacingOccurrencesOfString:@"区" withString:@"新区"]];
                            }
                            
                        }
                    }
                }
            }
        }
        
    }else if(province.length > 0 && city.length == 0){
        cityRange = [address rangeOfString:[NSString stringWithFormat:@"%@省",province]]; //省份或直辖市
        if(cityRange.location == NSNotFound){
            cityRange = [address rangeOfString:[NSString stringWithFormat:@"%@市",province]];//直辖市
            if(cityRange.location == NSNotFound){
                cityRange = [address rangeOfString:province];//直辖市
            }
        }
        
    }else{
        cityRange = NSMakeRange(NSNotFound, 0);
    }
    return cityRange;
}

#pragma mark 智能匹配地址，并发送
-(void)doShipt:(ContactModel*)sender{
    BoardDB*db = [BoardDB new];
    NSInteger ContactId =  [db UpdateContact:sender];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DoShipt" object:[NSNumber numberWithInteger:ContactId]];
}

-(void)matchAddressToShipt:(NSString*_Nullable)address{
    ContactModel *sendItem = [ContactModel new];
    NSString *phone = [self getPhoneNumbersFromString:address];
    if(phone.length > 0){
        sendItem.strPhone = phone;
    }
    
    NSArray *ProvinceAndCity = [self getProvinceAndCityFromString:address];
    
    if(ProvinceAndCity.count > 0){
        sendItem.strProv = [ProvinceAndCity firstObject];
        sendItem.strCity = [ProvinceAndCity lastObject];
        
        NSArray *itmes = [self getDetailAndNameFromString:address withProvince:sendItem.strProv withCity:sendItem.strCity];
        if([itmes[0] length] >0){
            sendItem.strName = itmes[0];
        }
        
        if([itmes[1] length] >0){
            sendItem.strAddress = itmes[1];
        }
        
        
        //入库 + 去寄件页面
        [self doShipt:sendItem];
        
        
        
    }else{
        if(phone.length > 0){
            address = [address stringByReplacingOccurrencesOfString:phone withString:@""];
            address = [address stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@".?#!,，。？！"]];
        }
        
        NSArray *itmes = [self getDetailAndNameFromString:address withProvince:@"" withCity:@""];
        sendItem.strName = itmes[0];
        sendItem.strAddress = itmes[1];
        
        address = itmes[1];
        [self check_Address_api:address
                       withCell:nil
                   withResponse:^(NSString * _Nullable resultProvince, NSString * _Nullable resultCity) {
                       if(resultProvince && resultCity){
                           //省份
                           sendItem.strProv = resultProvince;
                           
                           //城市
                           sendItem.strCity = resultCity;
                       }
                       //入库 + 去寄件页面
                       [self doShipt:sendItem];
                       
                   }];
        
    }
    
}

#pragma mark 智能匹配复合字符串
-(void)matchAddress:(NSNotification*)sender{
    //复合字符串
    NSString *address = [[sender object] firstObject];
    
    //当前单元格
    ContactViewCell2 *cell = [[sender object] lastObject];
    
    //提取电话
    NSString *phone = [self getPhoneNumbersFromString:address];
    if(phone.length > 0){
        cell.TelField.text = phone;
        [cell setTextViewPlaceholderHide:cell.TelField];
    }
    
    
    //提取省份
    //提取城市
    NSString *province,*city;
    NSArray *ProvinceAndCity = [self getProvinceAndCityFromString:address];
    if(ProvinceAndCity.count > 0){
        province = [ProvinceAndCity firstObject];
        city = [ProvinceAndCity lastObject];
        
        cell.ProvinceField.text = province;
        [cell setTextViewPlaceholderHide:cell.ProvinceField];
        
        cell.CityField.text = city;
        [cell setTextViewPlaceholderHide:cell.CityField];
        
        //提取人名
        //提取详细地址
        NSArray *itmes = [self getDetailAndNameFromString:address withProvince:province withCity:city];
        if([itmes[0] length] >0){
            cell.NameField.text = itmes[0];
            [cell setTextViewPlaceholderHide:cell.NameField];
        }
        
        if([itmes[1] length] >0){
            cell.AddressField.text = itmes[1];
            [cell setTextViewPlaceholderHide:cell.AddressField];
        }
        
        
    }else{
        if(phone.length > 0){
            address = [address stringByReplacingOccurrencesOfString:phone withString:@""];
            address = [address stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@".?#!,，。？！"]];
        }
        NSArray *itmes = [self getDetailAndNameFromString:address withProvince:@"" withCity:@""];
        
        if([itmes[0] length] > 0){
            cell.NameField.text = itmes[0];
            [cell setTextViewPlaceholderHide:cell.NameField];
        }
        
        if([itmes[1] length] >0){
            cell.AddressField.text = itmes[1];
            [cell setTextViewPlaceholderHide:cell.AddressField];
        }
        
        address = itmes[1];
        
        [self check_Address_api:address
                       withCell:cell
                   withResponse:^(NSString * _Nullable resultProvince, NSString * _Nullable resultCity) {
                    
                       if(resultProvince && resultCity){
                           //省份
                           cell.ProvinceField.text = resultProvince;
                           [cell setTextViewPlaceholderHide:cell.ProvinceField];
                           //城市
                           cell.CityField.text = resultCity;
                           [cell setTextViewPlaceholderHide:cell.CityField];
                           
                       }
                   }];
    }
}

#pragma mark 网络匹配字符串
-(void)check_Address_api:(NSString*)address
                withCell:(ContactViewCell2*)cell
            withResponse:(void (^)(NSString * _Nullable resultProvince, NSString * _Nullable resultCity))Respones{
    
    BoardDB *db = [BoardDB new];
    _LoadingView = [[UILoadingView alloc]initWithFrame:self.view.bounds withText:[db getPageItemTitle:@"networkRequest"]];
    [self.view addSubview:_LoadingView];
    
    //配置网络，进行网络适配
    [self set_network_config];
    
    // 接下来会判断当前是WiFi状态还是3g状态,网络不可用状态
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                
                
                NSString *http_api = [NSString stringWithFormat:@"http://api.map.baidu.com/place/v2/suggestion?query=%@&region=全国city_limit=true&output=json&ak=qbbbX32yTTAeGF04Yz2if9Mi",address];
                http_api = [http_api stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                
                [self.session GET:http_api
                       parameters:nil
                         progress:^(NSProgress * _Nonnull downloadProgress) {
                             NSLog(@"下载的进度");
                             
                         }
                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                              NSLog(@"%@",responseObject);
                              NSArray *result =  [responseObject objectForKey:@"result"];
                              if(result && result.count >0){
                                  NSDictionary *item = [result firstObject];
                                  NSString *city = [item objectForKey:@"city"];
                                  NSString *province = [self getProvinceFormCity:city];
                                  Respones(province,city);
                              }else{
                                  Respones(nil,nil);
                              }
                              
                              [self RemoveLoadingView];
                          }
                          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                              Respones(nil,nil);
                            [self RemoveLoadingView];
                          }
                 ];
            }
                break;
            default:{
                //网络不可用
                BoardDB *db = [BoardDB new];
                UILoadingView *loadView  = [[UILoadingView alloc]initWithFrame:self.view.bounds withOnlyText:[db getPageItemTitle:@"networkDisable"]];
                [self.view addSubview:loadView];
                [self performSelector:@selector(RemoveLoadingView) withObject:loadView afterDelay:1.6f];
                
            }
                break;
        }
    }];
}

-(NSString*)getProvinceFormCity:(NSString*)city{
    NSString *prov = @"";
    NSString *CITY = [city stringByReplacingOccurrencesOfString:@"市" withString:@""];
    BoardDB *DB = [BoardDB new];
    NSString *sql = [NSString stringWithFormat:@"Select prov_name FROM Prov where id = (Select Prov_id from City where city_name = '%@')",CITY];
    NSArray *result = [DB FindWithSql:sql withReturnFields:@"prov_name"];
    if(result.count > 0){
        prov = result[0];
    }
    return prov;
}

#pragma mark 关闭LOADING
-(void)RemoveLoadingView{
    [UIView animateWithDuration:0.3 animations:^{
        _LoadingView.alpha = 0;
    } completion:^(BOOL finished) {
        [_LoadingView removeFromSuperview];
        _LoadingView = nil;
    }];
}

/*============================
 
 
 键盘委托代理
 
=============================*/
#pragma mark 键盘代理事件
-(void)basicBoardView:(BasicBoardView *)basicBoardView didChineseInputTextChanged:(NSString *)text{
    _WordsPage = 0;
    
    if(self.WordsArr == nil){
        self.WordsArr = [NSMutableArray array];
    }
    if(text == nil){
        self.WordsArr = nil;
        return;
    }
    
    
    
    NSString *searchTxt = [text lowercaseString];
    
//    NSError *error = nil;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^aoeiuv]?h?[iuv]?(ai|ei|ao|ou|er|ang?|eng?|ong|a|o|e|i|u|ng|n)?"
//                                                                           options:NSRegularExpressionCaseInsensitive
//                                                                             error:&error];
//    
//    NSArray *arrayOfAllMatches = [regex matchesInString:searchTxt options:0 range:NSMakeRange(0, [searchTxt length])];
//    NSString *tempStr;
//    for (NSTextCheckingResult *match in arrayOfAllMatches)
//    {
//        if(tempStr == nil){
//            tempStr = [searchTxt substringWithRange:match.range];
//        }else{
//            tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@"'%@",[searchTxt substringWithRange:match.range]]];
//        }
//    }
//    if(tempStr && tempStr.length > 1){
//        tempStr = [tempStr substringToIndex:tempStr.length-1];
//    }
    
    
    
    PinYinModel *PinYin = [PinYinModel new];
    NSString* tempStr =  [PinYin trimSpell:searchTxt];
    
    NSRange range = [tempStr rangeOfString:@"'"];
    BoardDB *db = [BoardDB new];
    
    if(range.length == 0){
        
        self.WordsArr = [db FindPinYinZiKuWithFilter:tempStr withPageIndex:_WordsPage withPageSize:_WordsPageSize];
    }else{
        
        self.WordsArr = [db FindPinYinCiKuWithFilter:tempStr withPageIndex:_WordsPage withPageSize:_WordsPageSize];
    }

}

-(void)basicBoardView:(BasicBoardView *)basicBoardView didEnglishInputTextChanged:(NSString *)text{
    _WordsPage = 0;
    
    if(self.WordsArr == nil){
        self.WordsArr = [NSMutableArray array];
    }
    
    if(text == nil){
        self.WordsArr = nil;
        
        return;
    }
    
    BoardDB *db = [BoardDB new];
    NSMutableArray *tempArr = [db FindWordWithFilter:text withPageIndex:_WordsPage withPageSize:_WordsPageSize];
    if(tempArr.count == 0){
        self.WordsArr = nil;
        return;
    }
    
    
    //排序，单词短的在前，长的在后
    NSArray* sortArr = [tempArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if(((NSString*)obj1).length >  ((NSString*)obj2).length){
            return NSOrderedDescending; //升序
        }else{
            return NSOrderedAscending; //降序
        }
    }];
    
    self.WordsArr = [NSMutableArray arrayWithArray:sortArr];
}


-(BOOL)loadMoreWords{
    _WordsPage++;
    NSLog(@"==== 加载第 %d 页 ====", _WordsPage);
    
    NSString *keyword = _keyboardView.CurrentInputText;
    if(keyword == nil) return YES;
    
    if(_keyboardView.panelModel == keyboardPanelChinese){
        NSString *searchTxt = [keyword lowercaseString];
        PinYinModel *PinYin = [PinYinModel new];
        NSString* tempStr =  [PinYin trimSpell:searchTxt];
        NSRange range = [tempStr rangeOfString:@"'"];
        
        BoardDB *db = [BoardDB new];
        NSArray *pageData;
        if(range.length == 0){
            pageData = [db FindPinYinZiKuWithFilter:tempStr withPageIndex:_WordsPage withPageSize:_WordsPageSize];
        }else{
            pageData = [db FindPinYinCiKuWithFilter:tempStr withPageIndex:_WordsPage withPageSize:_WordsPageSize];
        }
        if(pageData.count == 0){
            _WordsPage--;
            return YES;
        }
        [self.WordsArr addObjectsFromArray:pageData];
        
        
    }else if(_keyboardView.panelModel == keyboardPanelEnglish){
        BoardDB *db = [BoardDB new];
        NSMutableArray *tempArr = [db FindWordWithFilter:keyword withPageIndex:_WordsPage withPageSize:_WordsPageSize];
        if(tempArr.count == 0){
            _WordsPage--;
            return YES;
        }
        
        NSArray* sortArr = [tempArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if(((NSString*)obj1).length >  ((NSString*)obj2).length){
                return NSOrderedDescending; //升序
            }else{
                return NSOrderedAscending; //降序
            }
        }];
        
        [self.WordsArr addObjectsFromArray:sortArr];
        
    }
    
    [_contentView.WordOptionView reloadData];
    return YES;
}


-(void)MakeWordsCollectionView{
    _WordsPageSize = 100;
    _WordsPage = 0;
    
    if(_contentView.WordOptionViewH == nil){
        CGRect Frame = _contentView.SwitchbarView.bounds;
        UICollectionViewFlowLayout *layoutH = [[UICollectionViewFlowLayout alloc]init];
        layoutH.minimumLineSpacing =
        layoutH.minimumInteritemSpacing = 5;
        layoutH.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layoutH.itemSize = CGSizeMake((Frame.size.width-10)/3, Frame.size.height);
        
        _contentView.WordOptionViewH = [[UICollectionView alloc]initWithFrame:Frame collectionViewLayout:layoutH];
        [_contentView.WordOptionViewH registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CELL_H"];
        _contentView.WordOptionViewH.dataSource = self;
        _contentView.WordOptionViewH.delegate = self;
        _contentView.WordOptionViewH.backgroundColor = [UIColor clearColor];
         [_contentView.SwitchbarView addSubview:_contentView.WordOptionViewH];
        
        _contentView.WordOptionViewH.sd_layout
        .leftSpaceToView(_contentView.SwitchbarView,0)
        .rightSpaceToView(_contentView.SwitchbarView,0)
        .topSpaceToView(_contentView.SwitchbarView,0)
        .bottomSpaceToView(_contentView.SwitchbarView,0);
    }
    
    if(_contentView.WordOptionView == nil){
        CGRect Frame = _contentView.InputContentView.bounds;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing =
        layout.minimumInteritemSpacing = 5;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(Frame.size.width/2, 30);
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        _contentView.WordOptionView = [[UICollectionView alloc]initWithFrame:Frame collectionViewLayout:layout];
        [_contentView.WordOptionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CELL_V"];
        _contentView.WordOptionView.delegate = self;
        _contentView.WordOptionView.dataSource = self;
        _contentView.WordOptionView.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1];
        [_contentView.InputContentView addSubview:_contentView.WordOptionView];
        [_contentView.InputContentView bringSubviewToFront:_contentView.WordOptionView];
        
        _contentView.WordOptionView.sd_layout
        .leftSpaceToView(_contentView.InputContentView,0)
        .rightSpaceToView(_contentView.InputContentView,0)
        .topSpaceToView(_contentView.InputContentView,0)
        .bottomSpaceToView(_contentView.InputContentView,0);
        
    }
}

-(void)setWordsArr:(NSMutableArray *)WordsArr{
    _WordsArr = WordsArr;
    [_contentView.WordOptionViewH reloadData];
    [_contentView.WordOptionView reloadData];
    if(WordsArr == nil || WordsArr.count == 0){
        _contentView.option_button.hidden = YES;
    }else{
        _contentView.option_button.hidden = NO;
    }
}

-(void)RemoveWordsCollectionView{
    [_contentView.WordOptionViewH removeFromSuperview];
    [_contentView.WordOptionView removeFromSuperview];
    
    _contentView.WordOptionViewH = nil;
    _contentView.WordOptionView = nil;
    self.WordsArr = nil;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if([collectionView isEqual:_contentView.WordOptionViewH]){
        return MIN(_WordsArr.count, 50);
    }else{
        return _WordsArr.count;
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if([collectionView isEqual:_contentView.WordOptionViewH]){
       CGRect rect = [_WordsArr[indexPath.item] boundingRectWithSize:CGSizeMake(1000, collectionView.size.height)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                                             context:nil];
        return CGSizeMake(MAX(rect.size.width,collectionView.size.width/3), collectionView.size.height);
    }else{
        return CGSizeMake((collectionView.width-25)/2, 40);
    }
    
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *Identifier = collectionView == _contentView.WordOptionViewH ? @"CELL_H" : @"CELL_V";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
    if(self){
        UILabel *WordLabel = [cell.contentView viewWithTag:999];
        if(WordLabel == nil){
            WordLabel = [[UILabel alloc]initWithFrame:cell.contentView.bounds];
            WordLabel.tag = 999;
            WordLabel.clipsToBounds = YES;
            WordLabel.font = [UIFont systemFontOfSize:17];
            WordLabel.textAlignment = NSTextAlignmentCenter;
            WordLabel.textColor = [UIColor darkGrayColor];
            [cell.contentView addSubview:WordLabel];
            
            WordLabel.sd_layout
            .leftSpaceToView(cell.contentView,0)
            .rightSpaceToView(cell.contentView,0)
            .topSpaceToView(cell.contentView,0)
            .bottomSpaceToView(cell.contentView,0);
            
            if([Identifier isEqualToString:@"CELL_V"]){
                WordLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
                WordLabel.layer.cornerRadius = 5.f;
                WordLabel.layer.borderWidth = 1;
                WordLabel.layer.borderColor = [[UIColor colorWithWhite:.95 alpha:1]CGColor];
            }
        }
        WordLabel.text = [_WordsArr objectAtIndex:indexPath.item];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if(cell){
        UILabel *WordLabel = [cell.contentView viewWithTag:999];
        if(_keyboardView.panelModel == keyboardPanelChinese){
            //删除框选的拼音，替换成文字
            for(NSInteger i=0; i< _keyboardView.CurrentInputText.length;i++){
                [_keyboardView.Proxy deleteBackward];
            }
            [_keyboardView.Proxy insertText:WordLabel.text];
            [self updateWordRate:WordLabel.text];
            
        }else if(_keyboardView.panelModel == keyboardPanelEnglish){
            
            if(_keyboardView.CurrentInputText && _keyboardView.CurrentInputText.length > 0){
                NSString *text = [WordLabel.text substringFromIndex:_keyboardView.CurrentInputText.length];
                [_keyboardView.Proxy insertText:[NSString stringWithFormat:@"%@ ",text]];
            }else{
                [_keyboardView.Proxy insertText:[NSString stringWithFormat:@"%@ ",WordLabel.text]];
            }
            
            
        }
        _keyboardView.CurrentInputText = nil;
        self.WordsArr = nil;
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CallKeyboard" object:@"HideWordOption"];
    }
}

//翻页
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView == _contentView.WordOptionView){
        if(scrollView.contentOffset.y +scrollView.height - scrollView.contentSize.height > 30){
            if(_PageDataLoading == nil){
                _PageDataLoading = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(scrollView.width/2 - 10, scrollView.superview.size.height-35, 20, 20)];
                _PageDataLoading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                _PageDataLoading.hidesWhenStopped = YES;
                [scrollView.superview addSubview:_PageDataLoading];
                
            }
            
            [_PageDataLoading startAnimating];
            scrollView.centerY -= 30;
            
            if([self loadMoreWords]){
                [_PageDataLoading stopAnimating];
                scrollView.centerY += 30;
            };
        }
    }
}

//更新词频
-(void)updateWordRate:(NSString*)word{
    BoardDB *db = [BoardDB new];
    double ev = log10(1.2);

    if(word.length > 1){
        [db UpdatePinYinTable:@"PinYinCiKu" withRate:ev withText:word];
    }else if(word.length == 1){
        [db UpdatePinYinTable:@"PinYinZiKu" withRate:ev withText:word];
    }
    
}
@end
