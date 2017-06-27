//
//  BOT3DOptionView.m
//  Testing
//
//  Created by BOT01 on 16/9/26.
//  Copyright © 2016年 BizOpsTech. All rights reserved.
//
#import "BOT3DOptionFlowLayout.h"
#import "BOT3DOptionView.h"
#import "ContactViewCell.h"
#import "ContactViewCell2.h"

static NSString *BOTCellID = @"BOTCellID";

@interface BOT3DOptionView()<UICollectionViewDataSource,BOT3DOptionFlowLayoutDelegate,ContactViewCellDelegate>
@property(nonatomic,strong)BOT3DOptionFlowLayout *flow;
@property(nonatomic,copy)NSString *CellClassName;
@end

@implementation BOT3DOptionView
@synthesize flow = _flow;
@synthesize groupView = _groupView;
@synthesize OptionsData = _OptionsData;


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithFrame:(CGRect)frame withCellClassName:(NSString*)ClassName{
    self = [super initWithFrame:frame];
    if(self){
        self.CellClassName = ClassName;
        
        CGFloat oneX = self.center.x - frame.size.width*0.4; //内容左右padding
        _flow = [[BOT3DOptionFlowLayout alloc]init];
        _flow.itemSize = CGSizeMake(frame.size.width*0.8, frame.size.height);//单元格尺寸
        _flow.minimumLineSpacing = -_flow.itemSize.width/8*7; //单元格偏移值
        _flow.minimumInteritemSpacing = 0;
        _flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flow.sectionInset = UIEdgeInsetsMake(0, oneX, 0, oneX);
        _flow.delegate = self;
        
        
        _groupView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:_flow];
        _groupView.backgroundColor = [UIColor clearColor];
        _groupView.dataSource = self;
        //_groupView.showsHorizontalScrollIndicator = NO;
        _groupView.scrollEnabled = NO;
        
        if([ClassName isEqualToString:@"ContactViewCell"]){
            [_groupView registerNib:[UINib nibWithNibName:@"ContactViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:BOTCellID];
        }else{
            [_groupView registerClass:[ContactViewCell2 class] forCellWithReuseIdentifier:BOTCellID];
            //[_groupView registerNib:[UINib nibWithNibName:@"ContactViewCell2" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:BOTCellID];
        }
        
        
        [self addSubview:_groupView];
        
       
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(SwipeAction:)];
        
        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self addGestureRecognizer:swipeLeft];
        
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(SwipeAction:)];
        
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [self addGestureRecognizer:swipeRight];
        
    
    }return self;
}



-(void)SwipeAction:(UISwipeGestureRecognizer*)gesture{
    NSInteger ToIndex = 0;
    NSInteger PrevIndex = _selectItemIndex;
    
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionLeft:{
            PrevIndex++;
            ToIndex = MIN(_OptionsData.count-1, PrevIndex);
        }
            
            break;
        case UISwipeGestureRecognizerDirectionRight:{
            PrevIndex--;
            ToIndex = MAX(0, PrevIndex);
            
        }break;
        default:{}break;
    }
    [self ScrollToItem:ToIndex];
}


-(void)setOptionsData:(NSMutableArray *)OptionsData{
    _OptionsData = OptionsData;
    [_groupView reloadData];
}



-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _OptionsData.count;
}


-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *itemCell = [collectionView dequeueReusableCellWithReuseIdentifier:BOTCellID forIndexPath:indexPath];
    ContactModel *itemDB = [_OptionsData objectAtIndex:indexPath.item];
    if(itemCell){
        if(self.selectItemIndex == indexPath.item){
            itemCell.selected = YES;
        }else{
            itemCell.selected = NO;
        }
        if([_CellClassName isEqualToString:@"ContactViewCell"]){
            ((ContactViewCell*)itemCell).NameLabel.text = itemDB.strName;
            ((ContactViewCell*)itemCell).PohoneLabel.text = itemDB.strPhone;
            ((ContactViewCell*)itemCell).ProvinceLabel.text = itemDB.strProv;
            ((ContactViewCell*)itemCell).CityLabel.text = itemDB.strCity;
            ((ContactViewCell*)itemCell).AddressLabel.text = itemDB.strAddress;
            ((ContactViewCell*)itemCell).CellIndex = indexPath.item;
            if(_editEnable == YES){
                ((ContactViewCell*)itemCell).delegate = self;
                ((ContactViewCell*)itemCell).btn_edit.hidden = NO;
                if(itemDB.isDefaultSender == 1){
                    ((ContactViewCell*)itemCell).btn_edit.selected = YES;
                }else{
                    ((ContactViewCell*)itemCell).btn_edit.selected = NO;
                }
            }
            
        }else{
            [((ContactViewCell2*)itemCell) setForm:itemDB];
            ((ContactViewCell2*)itemCell).CellIndex = indexPath.item;
            ((ContactViewCell2*)itemCell).editEnable = NO;
        }
    }
    return itemCell;
}

-(void)ContactViewCell:(ContactViewCell *)cell didClickedEditButton:(UIButton *)sender withItemIndex:(NSInteger)index{
    ContactModel*updateItem = [_OptionsData objectAtIndex:index];
    BoardDB *db = [BoardDB new];
    //如果是选中状态，把之前的默认发件者取消
    if(sender.selected == YES){
        for(ContactModel*item in _OptionsData){
            if(item.isDefaultSender == 1 && item.contactId != updateItem.contactId){
                item.isDefaultSender = 0;
                [db UpdateContact:item];
                break;
            }
        }
    }
    
    NSInteger isDefaultSender = sender.selected ? 1 : 0;
    updateItem.isDefaultSender = isDefaultSender;
    //修改当前选中对象的状态
    [db UpdateContact:updateItem];
    [_groupView reloadData];
}


-(void)setCell:(NSInteger)ItemIndex SelectedStyle:(BOOL)IsSelected{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:ItemIndex inSection:0];
    UICollectionViewCell *itemCell = [_groupView cellForItemAtIndexPath:indexPath];
    if(IsSelected){
        _selectItemIndex = ItemIndex;
        itemCell.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    }else{
        itemCell.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    }
    
}

-(void)ScrollToItem:(NSInteger)itemIndex{
    if(self.delegate && [self.delegate respondsToSelector:@selector(BOT3DOptionViewWillTurnPage:withPageNumber:)]){
        [self.delegate BOT3DOptionViewWillTurnPage:self withPageNumber:_selectItemIndex];
    }
    
    itemIndex = MIN(_OptionsData.count-1, MAX(-1,itemIndex));
    
    //取消之前选中的
    [self setCell:_selectItemIndex SelectedStyle:NO];
    //设置现在选中
    [self setCell:itemIndex SelectedStyle:YES];
    //移动到指定单元格
    [_groupView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0]
                       atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                               animated:YES];
    
    if([self.delegate respondsToSelector:@selector(BOT3DOptionView:didScrollToPage:withCellData:)]){
        [self.delegate BOT3DOptionView:self didScrollToPage:itemIndex withCellData:_OptionsData[itemIndex]];
    }
}

#pragma mark flowlayout delegate
-(void)didScrollToPage:(NSInteger)pageNumber{
    for(NSInteger i=0;i<_OptionsData.count;i++){
        if(i == pageNumber){
            [self setCell:i SelectedStyle:YES];
        }else{
            [self setCell:i SelectedStyle:NO];
        }
        
        /*
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        BOT3DCell *itemCell = (BOT3DCell *)[_groupView cellForItemAtIndexPath:indexPath];
        if(i == pageNumber)
            itemCell.OptionText.backgroundColor = [UIColor colorWithRed:158.f/255 green:67.f/255 blue:29.f/255 alpha:1.0];
        else
            itemCell.OptionText.backgroundColor = [UIColor colorWithRed:178.f/255 green:178.f/255 blue:178.f/255 alpha:1.0];
         */
    }
    
    if([self.delegate respondsToSelector:@selector(BOT3DOptionView:didScrollToPage:withCellData:)]){
        [self.delegate BOT3DOptionView:self didScrollToPage:pageNumber withCellData:_OptionsData[pageNumber]];
    }
}

@end
