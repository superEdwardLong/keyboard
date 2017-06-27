//
//  CreateOrderViewController.m
//  SMRT Board V3
//
//  Created by BOT01 on 2017/5/9.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "CreateOrderViewController.h"

@interface CreateOrderViewController ()

@end

@implementation CreateOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
//    for(UIViewController *vc in self.navigationController.childViewControllers){
//        NSLog(@"== CLASSNAME:%@ == \n\n",[vc class]);
//    }
    
    AddOrderView *orderView = [[AddOrderView alloc]initWithFrame:self.view.bounds];
    self.view = orderView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
