//
//  CallPhoneNumberViewController.m
//  SMRT Board V3
//
//  Created by BOT01 on 2017/5/9.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//

#import "CallPhoneNumberViewController.h"

@interface CallPhoneNumberViewController ()

@end

@implementation CallPhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self CallAction:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)BackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)CallAction:(id)sender {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://95338"]];
}

@end
