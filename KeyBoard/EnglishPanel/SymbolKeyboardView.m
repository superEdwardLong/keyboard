//
//  SymbolKeyboardView.m
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/18.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "SymbolKeyboardView.h"

@interface SymbolKeyboardView()
@property (weak, nonatomic) IBOutlet UICollectionView *menuCollection;
@property (weak, nonatomic) IBOutlet UICollectionView *optionCollection;

@property(nonatomic,retain)NSArray *menuData;
@property(nonatomic,assign)NSInteger selectedSection;
@end

@implementation SymbolKeyboardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    
    self = [[[NSBundle mainBundle]loadNibNamed:@"SymbolKeyboardView" owner:self options:nil]lastObject];
    
    if(self){
        self.frame = frame;
        NSString *path = [[NSBundle mainBundle]pathForResource:@"symbol" ofType:@".plist"];
        NSArray *arr = [NSArray arrayWithContentsOfFile:path];
        
        _selectedSection = 0;
        _menuData = arr;
        [_menuCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MCELL"];
        [_optionCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"OCELL"];
        
        _menuCollection.delegate = self;
        _menuCollection.dataSource = self;
        
        _optionCollection.delegate = self;
        _optionCollection.dataSource = self;
        
    }
    return self;
}
- (IBAction)DeleteAction:(UIButton *)sender {
    [_Proxy deleteBackward];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if([collectionView isEqual:_menuCollection]){
        return _menuData.count;
    }else{
        return [[_menuData[_selectedSection] objectForKey:@"optionValue"]count];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if([collectionView isEqual:_menuCollection]){
        UICollectionViewCell *CELL = [collectionView cellForItemAtIndexPath:indexPath];
        CELL.backgroundColor = [UIColor colorWithRed:240.f/255 green:240.f/255 blue:240.f/255  alpha:1];
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if([collectionView isEqual:_menuCollection]){
        return CGSizeMake(collectionView.frame.size.width, 50);
    }else{
        NSString *text = [[_menuData[_selectedSection] objectForKey:@"optionValue"] objectAtIndex:indexPath.item];
       CGRect textRect =  [text boundingRectWithSize:CGSizeMake(1000, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
        
        
        return CGSizeMake(collectionView.frame.size.width/4, 50);
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if([collectionView isEqual:_menuCollection]){
        UICollectionViewCell *CELL = [collectionView cellForItemAtIndexPath:indexPath];
        CELL.backgroundColor = [UIColor whiteColor];
        _selectedSection =  indexPath.item;
        [_optionCollection reloadData];
    }else{
        UICollectionViewCell *CELL  = [collectionView cellForItemAtIndexPath:indexPath];
        //直接插入字符
        NSString *str = ((UILabel*)[CELL.contentView viewWithTag:999]).text;
        [_Proxy insertText:str];
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *CELL;
    NSString *strLabel;
    UILabel *label;
    if([collectionView isEqual:_menuCollection]){
        CELL = [collectionView dequeueReusableCellWithReuseIdentifier:@"MCELL" forIndexPath:indexPath];
        CELL.backgroundColor = [UIColor colorWithRed:240.f/255 green:240.f/255 blue:240.f/255  alpha:1];
        strLabel = [_menuData[indexPath.item] objectForKey:@"optionName"];
    }else{
        CELL = [collectionView dequeueReusableCellWithReuseIdentifier:@"OCELL" forIndexPath:indexPath];
        CELL.backgroundColor = [UIColor clearColor];
        strLabel = [[_menuData[_selectedSection] objectForKey:@"optionValue"] objectAtIndex:indexPath.item];
    }
    label = (UILabel*)[CELL.contentView viewWithTag:999];
    if(label == nil){
        label = [[UILabel alloc]initWithFrame:CELL.contentView.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor darkGrayColor];
        label.tag = 999;
        label.backgroundColor = [UIColor clearColor];
        [CELL.contentView addSubview:label];
    }
    label.text = strLabel;
    if([collectionView isEqual:_menuCollection]){
        label.font =[UIFont systemFontOfSize:16];
    }else{
        label.font = [UIFont systemFontOfSize:15];
    }
    return CELL;
}
@end
