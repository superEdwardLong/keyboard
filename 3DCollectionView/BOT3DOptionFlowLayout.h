//
//  BOT3DOptionFlowLayout.h
//  Testing
//
//  Created by BOT01 on 16/9/26.
//  Copyright © 2016年 BizOpsTech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BOT3DOptionFlowLayoutDelegate <NSObject>
- (void)didScrollToPage:(NSInteger)pageNumber;

@end

@interface BOT3DOptionFlowLayout : UICollectionViewFlowLayout
@property(nonatomic,assign)id<BOT3DOptionFlowLayoutDelegate>delegate;
@end
