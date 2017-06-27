//
//  KFunctionView.m
//  SMRT Keyborad
//
//  Created by BOT01 on 17/2/24.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//
#import "SDAutoLayout.h"


#import "KFunctionView.h"
@interface KFunctionView()


@end

@implementation KFunctionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        self.myScroll = [[UIScrollView alloc]initWithFrame:self.bounds];
        self.myScroll.contentSize = CGSizeMake(frame.size.width*2, frame.size.height);
        self.myScroll.pagingEnabled = YES;
        self.myScroll.scrollEnabled = NO;
        [self addSubview:self.myScroll];
        
        self.myScroll.sd_layout
        .leftSpaceToView(self,0)
        .topSpaceToView(self,0)
        .rightSpaceToView(self,0)
        .bottomSpaceToView(self,0);
        
        BoardDB *db = [BoardDB new];
        NSMutableArray *contact_arr = [db FindContactsWithFilter:nil];
        
        self.KTokenView = [[TokenView2 alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.KTokenView.ContactsDataSource addObjectsFromArray:contact_arr];
        
        self.KShipItView = [[ShipItView alloc]initWithFrame:CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height)];
        self.KShipItView.S_DataSource = @[@"KD_SF_60",
                                          @"KD_JiaJiSong_60",
                                          @"KD_kuaiJie_60",
                                          @"KD_LongBang_60",
                                          @"KD_QuanFeng_60",
                                          @"KD_ShenTong_60",
                                          @"KD_TianTian_60",
                                          @"KD_UC_60",
                                          @"KD_YuanTong_60"];
        self.KShipItView.C_DataSource = contact_arr;
        
        [self.myScroll addSubview:self.KTokenView];
        [self.myScroll addSubview:self.KShipItView];
        
    }return self;
}
@end
