//
//  TokenView2.m
//  SMRT Keyborad
//
//  Created by BOT01 on 17/3/20.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//


#import "TokenView2.h"

@interface TokenView2()<ContactViewCell2Delegate>{
    NSString* sur_name_regex;
}
@property(nonatomic,strong)UITextView *CursorTextView;
@property(nonatomic,assign)BOOL shouldContinueBlinking;
@property(nonatomic,retain)NSArray *menuDataArr;
@property(nonatomic,strong)LrdOutputView *menuOutputView;
@property(nonatomic,strong)KMagnifierView *magnifierView;
@property(nonatomic,strong)UILoadingView *loading;
@property(nonatomic,assign)NSInteger ContactModelState;
@property(nonatomic,assign)CGPoint prevCursorPoint;
@property(nonatomic,retain)ContactViewCell2 *SelectedCell;
@end

@implementation TokenView2
@synthesize ContactsDataSource = _ContactsDataSource;
@synthesize ContactsView = _ContactsView;
@synthesize TextInnerView = _TextInnerView;
@synthesize BoardTextView = _BoardTextView;

@synthesize menuDataArr;
@synthesize menuOutputView;
@synthesize magnifierView;
@synthesize prevCursorPoint;
@synthesize alertView;
@synthesize loadingView;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"TokenView2" owner:self options:nil]lastObject];
    if(self){
        self.frame = frame;
        

        //draw line
        CALayer *topLine = [CALayer layer];
        topLine.frame = CGRectMake(0, 0, self.TextInnerView.size.width, 1);
        
        CALayer *bottomLine = [CALayer layer];
        bottomLine.frame = CGRectMake(0, self.TextInnerView.size.height, self.TextInnerView.width, 1);
        
        bottomLine.backgroundColor =
        topLine.backgroundColor = [[UIColor colorWithRed:0 green:.78 blue:.96 alpha:1]CGColor];
        
        [self.TextInnerView.layer addSublayer:topLine];
        [self.TextInnerView.layer addSublayer:bottomLine];
        
        
        //COLLECTION VIEW SETTING
        [_ContactsView registerClass:[ContactViewCell2 class] forCellWithReuseIdentifier:@"CELL"];
        _ContactsView.delegate = self;
        _ContactsView.dataSource = self;
        
        NSMutableArray *arr = [NSMutableArray  array];
        ContactModel *db = [ContactModel new];
        [arr addObject:db];
        self.ContactsDataSource = arr;
        
        
        //TEXT VIEW SETTING
        [self addTextView];
        
        //draw swiper view
        [self drawSwiperView];
        
        
        
        
    }
    return self;
}


#pragma mark Collection delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _ContactsDataSource.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ContactViewCell2 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    if(cell){
        ContactModel *item = [_ContactsDataSource objectAtIndex:indexPath.item];
        cell.CellIndex = indexPath.item;
        [cell setForm:item];
        
        cell.delegate = self;
        
        if(self.SelectedCell == nil){
            self.SelectedCell = cell;
        }
    }
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(collectionView.size.width*.8, collectionView.size.height);
}

-(void)setContactsDataSource:(NSMutableArray *)ContactsDataSource{
    _ContactsDataSource = ContactsDataSource;
    [_ContactsView reloadData];
}

- (IBAction)toolbarItemAction:(UIButton *)sender {
    if([sender isEqual:_SectionBtn]){
        if(self.delegate && [self.delegate respondsToSelector:@selector(tokenView:didClickedSwitchButton:)]){
            [self.delegate tokenView:self didClickedSwitchButton:sender];
        }
    }else if([sender isEqual:_FunctionBtn]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"showFunctionView" object:[NSNumber numberWithBool:NO]];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"showKeyboard" object:[NSNumber numberWithBool:YES]];
    }
    
}

-(void)HideLoading{
    [loadingView removeFromSuperview];
    loadingView = nil;
}

#pragma mark CELL DELEGATE
-(void)ContactViewCellDidSelected:(ContactViewCell2 *)contactViewCell{
    if(![self.SelectedCell isEqual:contactViewCell]){
        [self.SelectedCell didAllTextViewEditEnd];
    }
    self.SelectedCell = contactViewCell;
}

-(void)ContactViewCell:(ContactViewCell2 *)contactViewCell didClickedAddButton:(UIButton *)sender{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [_ContactsView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    self.SelectedCell = contactViewCell;
    
}
-(void)ContactViewCell:(ContactViewCell2 *)contactViewCell didClickedCopyButton:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.SelectedCell = contactViewCell;
    NSString *TextValue = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",
                           contactViewCell.NameField.text,
                           contactViewCell.TelField.text,
                           contactViewCell.ProvinceField.text,
                           contactViewCell.CityField.text,
                           contactViewCell.AddressField.text];
    
    if([[TextValue stringByReplacingOccurrencesOfString:@" " withString:@""]length] > 0){
        self.BoardTextView.text =
        self.CursorTextView.text = TextValue;
        [self setFocusWithTextView:self.BoardTextView];
    }
    //关闭键盘
    [[NSNotificationCenter defaultCenter]postNotificationName:@"allTextFieldEditEnd" object:nil];

}
-(void)ContactViewCell:(ContactViewCell2 *)contactViewCell didClickedSaveButton:(UIButton *)sender{
    self.SelectedCell = contactViewCell;
    if(loadingView == nil){
        loadingView = [[UILoadingView alloc]initWithFrame:CGRectMake((self.size.width-90)/2, (contactViewCell.size.height-90)/2, 90, 90) withText:nil];
        [self addSubview:loadingView];
    }
    
    ContactModel *itemdb = [self.ContactsDataSource objectAtIndex:contactViewCell.CellIndex];
    itemdb.strName = contactViewCell.NameField.text;
    itemdb.strPhone = contactViewCell.TelField.text;
    itemdb.strProv = contactViewCell.ProvinceField.text;
    itemdb.strCity = contactViewCell.CityField.text;
    itemdb.strAddress = contactViewCell.AddressField.text;
    
    BoardDB *db = [BoardDB new];
    NSInteger updateId =  [db UpdateContact:itemdb];
    
    loadingView.loading.hidden = YES;
    loadingView.text = @"Save Success";
    [UIView animateWithDuration:0.3 animations:^{
        loadingView.frame = CGRectMake(self.size.width*.2, (contactViewCell.size.height-40)/2, self.size.width*.6, 40);
    }];
    [self performSelector:@selector(HideLoading) withObject:nil afterDelay:2.f];
    
    if(itemdb.contactId == 0){
        ContactModel *addItem = [ContactModel new];
        addItem.contactId = updateId;
        addItem.strName = itemdb.strName;
        addItem.strPhone = itemdb.strPhone;
        addItem.strProv = itemdb.strProv;
        addItem.strCity = itemdb.strCity;
        addItem.strAddress = itemdb.strAddress;
        addItem.strImage = itemdb.strImage;
        
        [self ContactViewCell:contactViewCell didClickedClearButton:nil];
        [self.ContactsDataSource insertObject:addItem atIndex:1];
        [self.ContactsView reloadData];
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(tokenViewDidSaveSuccess)]){
        [self.delegate tokenViewDidSaveSuccess];
    }
}




-(void)ContactViewCell:(ContactViewCell2 *)contactViewCell didClickedClearButton:(UIButton *)sender{
    self.SelectedCell = contactViewCell;
    ContactModel *itemdb = [self.ContactsDataSource objectAtIndex:contactViewCell.CellIndex];
    
    if(itemdb.contactId == 0){
        [contactViewCell resetForm];
        itemdb.strName =
        itemdb.strPhone =
        itemdb.strProv =
        itemdb.strCity =
        itemdb.strAddress =
        itemdb.strImage = @"";
    }else{
        if(alertView == nil){
            alertView = [[AlertView alloc]initWithFrame:self.bounds
                                                withMsg:@"Are you sure?"
                                            withOkTitle:nil
                                        withCancelTitle:nil];
            alertView.delegate = self;
            [self addSubview:alertView];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"allTextFieldEditEnd" object:nil userInfo:nil];
        }
        

    }
}
-(void)ContactViewCell:(ContactViewCell2 *)contactViewCell didClickedAddPhoto:(UIImageView *)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(tokenView:didSelectedContactCell:withImageView:)]){
        [self.delegate tokenView:self didSelectedContactCell:contactViewCell withImageView:sender];
    }
}


#pragma mark alertView delegate
-(void)alertViewDidClickedCancel{
    alertView = nil;
}
-(void)alertViewDidClickedOk{
    ContactModel *itemdb = [self.ContactsDataSource objectAtIndex:self.SelectedCell.CellIndex];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"didContactDataSourceChanged" object:itemdb];
    
    BoardDB *db = [BoardDB new];
    [db RemoveContactWithId:itemdb.contactId];
    
    [self.ContactsDataSource removeObjectAtIndex:self.SelectedCell.CellIndex];
    [self.ContactsView reloadData];
    
    
    
    alertView = nil;
}

#pragma mark 光标滑动区域
-(void)drawSwiperView{
    UIPanGestureRecognizer *Pan = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                         action:@selector(PanAction:)];
    [self.SwiperView addGestureRecognizer:Pan];
    [self performSelector:@selector(loadSwiperView) withObject:nil afterDelay:.2f];
    prevCursorPoint = self.SwiperView.center;
}

-(void)PanAction:(UIPanGestureRecognizer*)sender{
    if(self.BoardTextView.text == nil || self.BoardTextView.text.length == 0){
        return;
    }
    
    CGPoint localPoint = [sender locationInView:self.SwiperView];
    
    if(self.CursorTextView.text == nil){
        self.CursorTextView.text = self.BoardTextView.text;
    }
    
    
    
    if(localPoint.x > prevCursorPoint.x){
        //向右滑行
        if(self.CursorTextView.text.length == self.BoardTextView.text.length){
            return;
        }else{
            [self.CursorTextView insertText:[self.BoardTextView.text substringWithRange:NSMakeRange(self.CursorTextView.text.length, 1)]];
        }
    }else if(localPoint.x < prevCursorPoint.x){
        //向左滑行
        if(self.CursorTextView.text.length == 0){
            return;
        }else{
            [self.CursorTextView deleteBackward];
        }
    }
    
    CGPoint cursorPosition = [self.CursorTextView caretRectForPosition:self.CursorTextView.selectedTextRange.start].origin;
    textCursorView.frame = CGRectMake(cursorPosition.x, cursorPosition.y, textCursorView.size.width, textCursorView.size.height);
    prevCursorPoint = localPoint;
}

-(void)loadSwiperView{
    sliderView = [[ArrowSlider alloc]initWithFrame:self.SwiperView.bounds];
    [self.SwiperView addSubview:sliderView];
    sliderView.sd_layout
    .leftSpaceToView(self.SwiperView,0)
    .rightSpaceToView(self.SwiperView,0)
    .topSpaceToView(self.SwiperView,0)
    .bottomSpaceToView(self.SwiperView,0);
}

-(void)longPressAction:(UILongPressGestureRecognizer*)sender{
    if(sender.state != UIGestureRecognizerStateBegan){
        return;
    }
    if(((UITextView*)sender.view).text.length == 0){
       [self showTextMenuView];
    }
}

-(void)addTextView{
    self.CursorTextView = [[UITextView alloc]initWithFrame:self.TextInnerView.bounds];
    //self.CursorTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    self.CursorTextView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    self.CursorTextView.layer.borderWidth = 0.f;
    [self.TextInnerView addSubview:self.CursorTextView];
    self.CursorTextView.sd_layout
    .leftSpaceToView(self.TextInnerView,8)
    .rightSpaceToView(self.TextInnerView,8)
    .topSpaceToView(self.TextInnerView,8)
    .bottomSpaceToView(self.TextInnerView,8);
    
    self.BoardTextView = [[KUITextView alloc]initWithFrame:self.TextInnerView.bounds];
    //self.BoardTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    self.BoardTextView.backgroundColor = [UIColor whiteColor];
    self.BoardTextView.layer.borderWidth = 0.f;
    self.BoardTextView.KDelegate = self;
    self.BoardTextView.delegate = self;
    self.BoardTextView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    [self.TextInnerView addSubview:self.BoardTextView];
    
    self.CursorTextView.font = self.BoardTextView.font;
    [self setFocusWithTextView:self.BoardTextView];
    
    self.BoardTextView.sd_layout
    .leftSpaceToView(self.TextInnerView,8)
    .rightSpaceToView(self.TextInnerView,8)
    .topSpaceToView(self.TextInnerView,8)
    .bottomSpaceToView(self.TextInnerView,8);
}

#pragma mark 模拟光标定位
-(void)setFocusWithTextView:(UITextView*)textView{
    UIView *cursorView;
    for(UIView *item in textView.subviews){
        if(item.tag == 200){
            cursorView = item;
            cursorView.hidden = NO;
            break;
        }
    }
    CGPoint cursorPosition = [textView caretRectForPosition:textView.selectedTextRange.start].origin;
    
    CGRect cursorFrame = CGRectMake(cursorPosition.x, cursorPosition.y, 2,18);
    if(cursorView == nil){
        cursorView = [[UIView alloc]initWithFrame:cursorFrame];
        cursorView.tag = 200;
        cursorView.backgroundColor = [UIColor blueColor];
        [textView addSubview:cursorView];
        
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
        opacityAnimation.repeatCount = HUGE_VALF;
        opacityAnimation.duration = .9f;
        [cursorView.layer addAnimation:opacityAnimation forKey:@"AC_Opacity"];
    }else{
        cursorView.frame = cursorFrame;
    }
    
    if([textView isEqual:self.BoardTextView]){
        textCursorView = cursorView;
    }
    
    if([textView isEqual:self.BoardTextView] && textView.text.length > 0){
        [textView removeGestureRecognizer:longPress];
    }else if([textView isEqual:self.BoardTextView] && textView.text.length == 0){
        if(longPress == nil){
            longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
            longPress.minimumPressDuration = .4f;
        }
        [textView addGestureRecognizer:longPress];
    }
}



#pragma mark pop menu delegate
-(void)setSelectionTextMenuHide{
    if(menuOutputView)[menuOutputView dismiss];
}

-(void)setMagifierViewHide{
    if(self.magnifierView){
        [self.magnifierView removeFromSuperview];
        self.magnifierView = nil;
    }
}

-(void)showTextMenuView{
    if(menuDataArr == nil){
        LrdCellModel *NS_User = [[LrdCellModel alloc] initWithTitle:@"Name" imageName:@"source.bundle/icon_user.png"];
        LrdCellModel *NS_Phone = [[LrdCellModel alloc] initWithTitle:@"Phone" imageName:@"source.bundle/icon_phone.png"];
        LrdCellModel *NS_Prov = [[LrdCellModel alloc] initWithTitle:@"Prov." imageName:@"source.bundle/icon_prov.png"];
        LrdCellModel *NS_City = [[LrdCellModel alloc] initWithTitle:@"City" imageName:@"source.bundle/icon_city.png"];
        LrdCellModel *NS_Address = [[LrdCellModel alloc] initWithTitle:@"Address" imageName:@"source.bundle/icon_location.png"];
        LrdCellModel *NS_Paste = [[LrdCellModel alloc] initWithTitle:@"Paste" imageName:@"source.bundle/icon_paste.png"];
        LrdCellModel *NS_Copy = [[LrdCellModel alloc] initWithTitle:@"Copy" imageName:@"source.bundle/icon_copy.png"];
        
        menuDataArr = @[NS_Paste,NS_Copy,NS_User,NS_Phone,NS_Prov,NS_City,NS_Address];
    }
    
    CGFloat menu_h = 44.f;
    CGFloat x = self.center.x;
    CGFloat y = self.TextInnerView.superview.origin.y -  menu_h;
    
    if(menuOutputView == nil){
        menuOutputView = [[LrdOutputView alloc] initWithDataArray:menuDataArr
                                                           origin:CGPointMake(x,y)
                                                            width:self.width-16
                                                           height:menu_h
                                                        direction:kLrdOutputViewDirectionRight];
        menuOutputView.delegate = self;
        menuOutputView.dismissOperation = ^(){
            //设置成nil，以防内存泄露
            menuOutputView = nil;
        };
        [menuOutputView  pop:self];
    }
}

- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.item) {
        case 0:{
            //paste
            UIPasteboard *Pasteboard = [UIPasteboard generalPasteboard];
            
            if(Pasteboard.string.length > 0){
                NSString *str = [Pasteboard.string copy];
                self.BoardTextView.text =
                self.CursorTextView.text = str;
                [self setFocusWithTextView:self.BoardTextView];
                
               [[NSNotificationCenter defaultCenter]postNotificationName:@"matchAddress" object:@[str,self.SelectedCell]];
            }
        }
            break;
        case 1:{
            //copy
            if(self.BoardTextView.selectedRange.length > 0){
                NSString * selectRangeText = [self.BoardTextView.text substringWithRange:self.BoardTextView.selectedRange];
                UIPasteboard *Pasteboard = [UIPasteboard generalPasteboard];
                [Pasteboard setString:selectRangeText];
            }
        }
            break;
        case 2:{
            //user
            [self setContactItemValue:self.SelectedCell.NameField];
            
        }
            break;
        case 3:{
            //phone
            [self setContactItemValue:self.SelectedCell.TelField];
        }
            break;
        case 4:{
            //prov
            [self setContactItemValue:self.SelectedCell.ProvinceField];
        }
            break;
        case 5:{
            //city
           [self setContactItemValue:self.SelectedCell.CityField];
        }
            break;
        case 6:{
            //address
            [self setContactItemValue:self.SelectedCell.AddressField];
        }
            break;
    }
}



-(void)setContactItemValue:(UITextView*)textView{
    if(self.BoardTextView.selectedRange.length > 0){
        NSString * selectRangeText = [[self.BoardTextView.text substringWithRange:self.BoardTextView.selectedRange]copy];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"customFieldValue" object:selectRangeText];
        
        textView.text = selectRangeText;
        [[textView viewWithTag:300] setHidden:YES];
        
        [self.BoardTextView deleteBackward];
        
        NSString *tempStr = [self.BoardTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if(self.BoardTextView.text.length > 0 && tempStr.length == 0){
            self.BoardTextView.text = tempStr;
        }        
        self.CursorTextView.text = self.BoardTextView.text;
        [self setFocusWithTextView:self.BoardTextView];
    }
}


#pragma mark kUITextView 文本选择区域确认后
-(void)kTextViewDidConfirmSelection:(UITextView *)textView{
    //隐藏放大镜
    [self setMagifierViewHide];
    //显示选择文本操作菜单
    [self showTextMenuView];
}

-(void)textViewDidChange:(UITextView *)textView{
    if([textView isEqual:self.BoardTextView]){
        return;
    }
    
    
    [self setFocusWithTextView:textView];
}

-(void)textViewDidChangeSelection:(UITextView *)textView{
    if([textView isEqual:self.BoardTextView] == NO){
        return;
    }
    
    //隐藏选择文本操作菜单
    [self setSelectionTextMenuHide];
    
    NSRange range =  textView.selectedRange;
    if(range.length > 0){
        CGPoint scrollPosition = [textView contentOffset];
        CGPoint startPosition = [textView caretRectForPosition:textView.selectedTextRange.start].origin;
        CGPoint endPosition = [textView caretRectForPosition:textView.selectedTextRange.end].origin;
        
        
        if(startPosition.x != prevStartPoint.x || startPosition.y != prevStartPoint.y){
            currentPoint = CGPointMake(startPosition.x + self.BoardTextView.origin.x , startPosition.y-scrollPosition.y);
            
        }else if(endPosition.x != prevEndPoint.x || endPosition.y != prevEndPoint.y){
            currentPoint = CGPointMake(endPosition.x + self.BoardTextView.origin.x, endPosition.y-scrollPosition.y);
        }
        
        prevStartPoint = startPosition;
        prevEndPoint = endPosition;
        
        //放大预览视图
        if(self.magnifierView == nil){
            self.magnifierView = [[KMagnifierView alloc]init];
            self.magnifierView.viewToMagnify = self.TextInnerView;
            self.magnifierView.pointToCut = self.TextInnerView.superview.origin;
            [self addSubview:self.magnifierView];
        }
        self.magnifierView.pointToMagnify = currentPoint;
        
        
    }else{
        [self setMagifierViewHide];
    }
    
}




@end
