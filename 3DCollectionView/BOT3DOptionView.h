//
//  BOT3DOptionView.h
//  Testing
//
//  Created by BOT01 on 16/9/26.
//  Copyright © 2016年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactModel.h"

@protocol BOT3DOptionViewDelegate;
@interface BOT3DOptionView : UIView
@property(nonatomic,strong)UICollectionView *groupView;
@property(nonatomic,assign)id<BOT3DOptionViewDelegate> delegate;
@property(nonatomic,retain)NSMutableArray *OptionsData;
@property(nonatomic,assign)NSInteger selectItemIndex;
@property(nonatomic,assign)BOOL editEnable;

-(id)initWithFrame:(CGRect)frame withCellClassName:(NSString*)ClassName;
-(void)ScrollToItem:(NSInteger)itemIndex;
@end

@protocol BOT3DOptionViewDelegate <NSObject>
@optional
-(void)BOT3DOptionViewWillTurnPage:(BOT3DOptionView*)BOTOptionView withPageNumber:(NSInteger)PageNumber;
-(void)BOT3DOptionView:(BOT3DOptionView*)BOTOptionView didScrollToPage:(NSInteger)PageNumber withCellData:(ContactModel*)Data;
@end
