//
//  TestViewController.m
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/23.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//
#import "PrinterViewController.h"
#import "TestViewController.h"
@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
//    self.view.backgroundColor = [UIColor whiteColor];
//    UILabel *lable = [[UILabel alloc]initWithFrame:self.view.bounds];
//    lable.text = @"Hello word";
//    lable.textAlignment = NSTextAlignmentCenter;
//    lable.font = [UIFont systemFontOfSize:30 weight:400];
//    
//    [self.view addSubview:lable];
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    //[self performSegueWithIdentifier:@"GoToCreateOrderPage" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Do_Test:(UIButton *)sender {
    BoardDB *db = [BoardDB new];
    NSString*sql = @"SELECT mail_id FROM MailList ORDER BY mail_id DESC LIMIT 0,1";
    NSArray *result = [db FindWithSql:sql withReturnFields:@"mail_id"];
    
    PrinterViewController *TagVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
             instantiateViewControllerWithIdentifier:@"PrinterPage"];
        NSInteger OrderId = [[result lastObject]integerValue];
    TagVC.OrderId = OrderId;
    [self.navigationController pushViewController:TagVC animated:YES];
}

@end
