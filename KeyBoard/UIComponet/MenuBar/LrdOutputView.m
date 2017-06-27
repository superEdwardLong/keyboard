//
//  LrdOutputView.m
//  LrdOutputView
//
//  Created by 键盘上的舞者 on 4/14/16.
//  Copyright © 2016 键盘上的舞者. All rights reserved.
//
#import "SDAutoLayout.h"
#import "LrdOutputView.h"
#define MENUITEM_WIDTH 96.f
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define CellLineEdgeInsets UIEdgeInsetsMake(0, 10, 0, 10)
#define LeftToView 10.f
#define TopToView 10.f

@interface LrdOutputView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *tableView;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) LrdOutputViewDirection direction;

@end

@implementation LrdOutputView

- (instancetype)initWithDataArray:(NSArray *)dataArray
                           origin:(CGPoint)origin
                            width:(CGFloat)width
                           height:(CGFloat)height
                        direction:(LrdOutputViewDirection)direction {
    if (height <= 0) {
        height = 44;
    }
    
    if (self = [super initWithFrame:CGRectMake(0, origin.y, SCREEN_WIDTH, height+10)]) {
        //背景色为clearColor
        self.backgroundColor = [UIColor clearColor];
        self.origin = origin;
        self.height = height;
        self.width = width;
        self.direction = direction;
        self.dataArray = dataArray;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        layout.itemSize = CGSizeMake(MENUITEM_WIDTH, self.height);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
                
        self.tableView = [[UICollectionView alloc]initWithFrame:CGRectMake(8, 0, width, self.height) collectionViewLayout:layout];
        

        _tableView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
        _tableView.bounces = NO;
        _tableView.layer.cornerRadius = 6;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        

        
        [_tableView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        [self addSubview:self.tableView];
        

    }
    return self;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if(cell){
        UIImageView *imgView = [self getImageViewFormCell:cell];
        UILabel *txtLabel = [self getTxtLabelFormCell:cell];
        if(imgView == nil){
            imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 28, 28)];
            imgView.tag = 200;
            [cell.contentView addSubview:imgView];
            
            imgView.sd_layout
            .widthIs(28).heightIs(28)
            .centerYEqualToView(cell.contentView)
            .leftSpaceToView(cell.contentView,0);
        }
        if(txtLabel == nil){
            txtLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, MENUITEM_WIDTH-40, self.height)];
            imgView.tag = 201;
            txtLabel.textColor = [UIColor whiteColor];
            txtLabel.font = [UIFont systemFontOfSize:15.f];
            [cell.contentView addSubview:txtLabel];
            
            txtLabel.sd_layout
            .leftSpaceToView(imgView,8)
            .rightSpaceToView(cell.contentView,0)
            .topSpaceToView(cell.contentView,0)
            .bottomSpaceToView(cell.contentView,0);
        }
        LrdCellModel *model = [self.dataArray objectAtIndex:indexPath.row];
        imgView.image = [UIImage imageNamed:model.imageName];
        txtLabel.text = model.title;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
        if ([self.delegate respondsToSelector:@selector(LrdOutPutViewDidSelectedAtIndexPath:)]) {
            [self.delegate LrdOutPutViewDidSelectedAtIndexPath:indexPath];
        }
        [self dismiss];
}

-(UIImageView*)getImageViewFormCell:(UICollectionViewCell*)cell{
    UIImageView *imageView;
    for(UIView *view in cell.contentView.subviews){
        if([view isKindOfClass:[UIImageView class]]){
            imageView = (UIImageView*)view;
        }
    }
    return imageView;
}

-(UILabel*)getTxtLabelFormCell:(UICollectionViewCell*)cell{
    UILabel *txtLabel;
    for(UIView *view in cell.contentView.subviews){
        if([view isKindOfClass:[UILabel class]]){
            txtLabel = (UILabel*)view;
        }
    }
    return txtLabel;
}


//画出尖尖
- (void)drawRect:(CGRect)rect {
    //拿到当前视图准备好的画板
    CGContextRef context = UIGraphicsGetCurrentContext();
    //利用path进行绘制三角形
    CGContextBeginPath(context);//标记
    CGFloat startX = self.origin.x;
    CGFloat startY = self.height + 10;
    CGContextMoveToPoint(context, startX, startY);//设置起点
    CGContextAddLineToPoint(context, startX + 10, startY-10);
    CGContextAddLineToPoint(context, startX - 10, startY-10);
    
    CGContextClosePath(context);//路径结束标志，不写默认封闭
    
    [self.tableView.backgroundColor setFill]; //设置填充色
    
    
    [self.tableView.backgroundColor setStroke];
    
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径path
    

}

- (void)pop:(UIView*)vc {
   // UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    //[keyWindow addSubview:self];
    [vc addSubview:self];
    
    //动画效果弹出
    self.alpha = 0;
    CGRect frame = self.tableView.frame;
    self.tableView.frame = CGRectMake(self.origin.x, self.origin.y, 0, 0);
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
        self.tableView.frame = frame;
    }];
}

- (void)dismiss {
    //动画效果淡出
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
        self.tableView.frame = CGRectMake(self.origin.x, self.origin.y, 0, 0);
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            if (self.dismissOperation) {
                self.dismissOperation();
            }
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (![touch.view isEqual:self.tableView]) {
        [self dismiss];
    }
}

@end


#pragma mark - LrdCellModel

@implementation LrdCellModel

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName {
    LrdCellModel *model = [[LrdCellModel alloc] init];
    model.title = title;
    model.imageName = imageName;
    return model;
}

@end
