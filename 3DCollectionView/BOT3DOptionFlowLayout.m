//
//  BOT3DOptionFlowLayout.m
//  Testing
//
//  Created by BOT01 on 16/9/26.
//  Copyright © 2016年 BizOpsTech. All rights reserved.
//

#import "BOT3DOptionFlowLayout.h"

@implementation BOT3DOptionFlowLayout
#pragma mark 1:布局
/**
 * 用来做布局的初始化操作（不建议在init方法中进行布局的初始化操作）
 */
-(void)prepareLayout{
    [super prepareLayout];
}


#pragma mark 2:排布rect范围内的控件
/**
 数组中保存的是 UICollectionViewLayoutAttributes *attrs;
 1.一个cell对应一个UICollectionViewLayoutAttributes对象
 2.UICollectionViewLayoutAttributes对象决定了cell的frame
 */
/**
 * 这个方法的返回值是一个数组（数组里面存放着rect范围内所有元素的布局属性）
 * 这个方法的返回值决定了rect范围内所有元素的排布（frame）
 */
- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    // 获得super已经计算好的布局属性
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    // 计算collectionView最中心点的x值
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.frame.size.width*0.5;
    
    
    
     // 在原有布局属性的基础上，进行微调
    for(UICollectionViewLayoutAttributes *attrs in array){
        // cell的中心点x 和 collectionView最中心点的x值 的间距
        CGFloat delta = ABS(attrs.center.x - centerX);
        
        // 根据间距值 计算 cell的缩放比例
        CGFloat scale = 1 - delta / self.collectionView.frame.size.width;
        
        // 设置缩放比例
        attrs.transform = CGAffineTransformMakeScale(scale, scale);
        NSNumber *zIndex = [NSNumber numberWithFloat:scale * 10000];
        attrs.zIndex = zIndex.integerValue;
        //attrs.alpha = scale;
    }
    
    return array;
}

#pragma mark 3:重新刷新布局
/**
 * 当collectionView的显示范围发生改变的时候，是否需要重新刷新布局
 * 一旦重新刷新布局，就会重新调用下面的方法：（也就上面那两）
 1.prepareLayout
 2.layoutAttributesForElementsInRect:方法
 */
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

#pragma mark 4:collectionView停止滚动时的偏移量
/**
 * 这个方法的返回值，就决定了collectionView停止滚动时的偏移量
 * 这个方法在滚动松手的那一刻调用
 */
-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    // 计算出最终显示的矩形框
    CGRect rect;
    rect.origin.y =0;
    rect.origin.x = proposedContentOffset.x;
    rect.size = self.collectionView.frame.size;
    
    // 获得super已经计算好的布局属性
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    NSLog(@"== c %@ ==",array);
    
    // 计算collectionView最中心点的x值
    CGFloat centerX = proposedContentOffset.x + rect.size.width * 0.5;
    
    // 存放最小的间距值;
    CGFloat minDelta = MAXFLOAT;
    
    
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if (ABS(minDelta) > ABS(attrs.center.x - centerX)) {
            minDelta = attrs.center.x - centerX;
        }
    }
    
    // 修改原有的偏移量
    proposedContentOffset.x += minDelta;
    
    if([self.delegate respondsToSelector:@selector(didScrollToPage:)]){
        CGFloat pIndex = (proposedContentOffset.x/rect.size.width*0.65)*10;
        NSNumber *PageIndex = [NSNumber numberWithFloat:pIndex];
        [self.delegate didScrollToPage:PageIndex.integerValue];
    }


    return proposedContentOffset;
    
}
@end
