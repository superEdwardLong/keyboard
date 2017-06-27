//
//  MakeOrderView.m
//  SMRT Board V3
//
//  Created by BOT01 on 17/4/20.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//
#import "PrintObject.h"
#import "MakeOrderView.h"

@implementation MakeOrderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithFrame:(CGRect)frame{
    self = [[[NSBundle mainBundle]loadNibNamed:@"MakeOrderView" owner:self options:nil]lastObject];
    if(self){
        _CurrentSelectedIndex = -1;
        self.frame = frame;
        NSString *path = [[NSBundle mainBundle]pathForResource:@"Companys" ofType:@"plist"];
        _colsArr = [NSArray arrayWithContentsOfFile:path];
        self.webView.delegate = self;
        [self.collectionBar registerClass:[CompanyCell class] forCellWithReuseIdentifier:@"CELL"];
        self.collectionBar.delegate = self;
        self.collectionBar.dataSource = self;
        
        //配置工具条
        self.NavBar.barTintColor = [UIColor colorWithWhite:.9 alpha:1];
        self.NavBarItems.title = @"顺丰自寄";
        
        UIButton *boardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        boardBtn.frame = CGRectMake(0, 0, 30, 22);
        [boardBtn setImage:[UIImage imageNamed:@"ui-board-48"] forState:UIControlStateNormal];
        [boardBtn addTarget:self action:@selector(CallKeyboardView) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *boardBtnItem = [[UIBarButtonItem alloc]initWithCustomView:boardBtn];
        self.NavBarItems.leftBarButtonItem = boardBtnItem;
        
        UIButton *listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        listBtn.frame = CGRectMake(0, 0, 30, 22);
        [listBtn setImage:[UIImage imageNamed:@"ui-list-45"] forState:UIControlStateNormal];
        [listBtn addTarget:self action:@selector(CallListView) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *listBtnItem = [[UIBarButtonItem alloc]initWithCustomView:listBtn];
        
        UIButton *orderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        orderBtn.frame = CGRectMake(0, 0, 30, 22);
        [orderBtn setImage:[UIImage imageNamed:@"ui-list-45"] forState:UIControlStateNormal];
        [orderBtn addTarget:self action:@selector(CallOrderView) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *shipBtnItem = [[UIBarButtonItem alloc]initWithCustomView:orderBtn];
        
        
        self.NavBarItems.rightBarButtonItems = @[listBtnItem,shipBtnItem];
    }return self;
}

-(void)CallKeyboardView{
    
}

-(void)CallListView{
    [self.webView stringByEvaluatingJavaScriptFromString:@"location.href = 'OrderList.html';"];
}

-(void)CallOrderView{
    [self.webView stringByEvaluatingJavaScriptFromString:@"location.href = 'AddOrder.html';"];
}



-(NSString*)getJSONString:(ContactModel*)obj{
    NSString *jsonString = @"";
    NSError *error;
    NSData *jsonData = [PrintObject getJSON:obj options:NSJSONWritingPrettyPrinted error:&error];

    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    return jsonString;
}

-(void)ContactList:(ContactList *)contactList withSender:(ContactModel *)sender withReceive:(ContactModel *)receive{
    
    NSString *senderJSON = @"";
    if(sender){
        senderJSON = [[[self getJSONString:sender] stringByReplacingOccurrencesOfString:@"\n"
                                                                             withString:@""]
                      stringByReplacingOccurrencesOfString:@"\r"
                      withString:@""];
    }
    NSString *receiveJSON = @"";
    if(receive){
        receiveJSON = [[[self getJSONString:receive] stringByReplacingOccurrencesOfString:@"\n"
                                                                               withString:@""]
                       stringByReplacingOccurrencesOfString:@"\r"
                       withString:@""];
    }
    //返回给 H5
    NSString *JSFunction  = [NSString stringWithFormat:@"DoFillSenderAndReceiver('%@','%@');",senderJSON,receiveJSON];

    
    [self.webView stringByEvaluatingJavaScriptFromString:JSFunction];
    
    //关闭地址簿
    [self ContactListDidBack:contactList];
}

-(void)ContactListDidBack:(ContactList *)contactList{
    [UIView animateWithDuration:.3f animations:^{
        contactListView.frame = CGRectMake(0, contactListView.frame.size.height,
                                           contactListView.frame.size.width,
                                           contactListView.frame.size.height);
    } completion:^(BOOL finished) {
        [contactListView removeFromSuperview];
        contactListView = nil;
    }];
}

-(void)ShowContactList{
    if(contactListView == nil){
        contactListView = [[ContactList alloc]initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height)];
        contactListView.delegate = self;
        [self addSubview:contactListView];
        [UIView animateWithDuration:.3f
                         animations:^{
                             contactListView.frame = self.bounds;
                         }];
    }
}

#pragma mark collectionView delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _colsArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CompanyCell*cell = (CompanyCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    if(cell){
        NSDictionary *itemdb = [_colsArr objectAtIndex:indexPath.item];
        cell.imageView.image = [UIImage imageNamed:[itemdb objectForKey:@"logo"]];
        cell.text = [itemdb objectForKey:@"company"];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.item == 0 && _CurrentSelectedIndex == -1){
        [self collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _CurrentSelectedIndex = indexPath.item;
    NSDictionary *itemdb = [_colsArr objectAtIndex:indexPath.item];
    NSString *URLPath = [itemdb objectForKey:@"url"];
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSURLRequest *Request = [NSURLRequest requestWithURL:URL];
    [_webView loadRequest:Request];
}


#pragma mark webview delegate


-(void)webViewDidStartLoad:(UIWebView *)webView{
    [_loading startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [_loading stopAnimating];

}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [_loading stopAnimating];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL * url = [request URL];
    if ([[url scheme] isEqualToString:@"doiosfunction"]) {
        NSArray *params =[url.query componentsSeparatedByString:@"&"];
        for (NSString *paramStr in params) {
            NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
            if (dicArray.count > 0) {
                if([dicArray[1] isEqualToString:@"ShowContactList"]){
                    [self ShowContactList];
                }
            }
        }
        
        return NO;
    }
    return YES;
}
@end
