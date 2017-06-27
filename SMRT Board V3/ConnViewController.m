//
//  ConnViewController.m
//  SMRT Board V3
//
//  Created by john long on 2017/6/25.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//
#define channelOnPeropheralView @"peripheralView"
#define channelOnCharacteristicView @"CharacteristicView"


#import "ConnViewController.h"

@interface ConnViewController ()<UITableViewDelegate,UITableViewDataSource>{
    BabyBluetooth *baby;
}
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property(nonatomic,retain)NSMutableArray *sectionDataA;
@property(nonatomic,retain)NSMutableArray *sectionDataB;

@property(nonatomic,retain)CBPeripheral *currPeripheral;
@property(nonatomic,assign)NSInteger currPeripheralIndex;

@end

@implementation ConnViewController
@synthesize myTable = _myTable;
@synthesize sectionDataA = _sectionDataA;
@synthesize sectionDataB = _sectionDataB;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _sectionDataB = [NSMutableArray array];
    _sectionDataA = [NSMutableArray array];
    
    [_myTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
    
    _myTable.dataSource = self;
    _myTable.delegate = self;
    
    
    [SVProgressHUD showInfoWithStatus:@"准备打开设备"];
    //初始化BabyBluetooth 蓝牙库
    baby = [BabyBluetooth shareBabyBluetooth];

    
    //设置蓝牙委托
    [self babyDelegate];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear");
    //停止之前的连接
    [baby cancelAllPeripheralsConnection];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。    
    baby.scanForPeripherals().begin();
}

-(void)viewWillDisappear:(BOOL)animated{
    self.PrintVc.currPeripheral = self.currPeripheral;
}


#pragma mark -蓝牙配置和操作
//蓝牙网关初始化和委托方法设置
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
        }
    }];
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
        if(peripheral.state == CBPeripheralStateConnected){
            [weakSelf insertTableView:peripheral advertisementData:advertisementData RSSI:RSSI atSection:0];
        }else{
            [weakSelf insertTableView:peripheral advertisementData:advertisementData RSSI:RSSI atSection:1];
        }
        
    }];
    
    
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"charateristic name is :%@",c.UUID);
        }
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        //最常用的场景是查找某一个前缀开头的设备
        //        if ([peripheralName hasPrefix:@"Pxxxx"] ) {
        //            return YES;
        //        }
        //        return NO;
        
        //设置查找规则是名称大于0 ， the search rule is peripheral.name length > 0
        if (peripheralName.length >0) {
            return YES;
        }
        return NO;
    }];
    
    
    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    
    
    /*设置babyOptions
     
     参数分别使用在下面这几个地方，若不使用参数则传nil
     - [centralManager scanForPeripheralsWithServices:scanForPeripheralsWithServices options:scanForPeripheralsWithOptions];
     - [centralManager connectPeripheral:peripheral options:connectPeripheralWithOptions];
     - [peripheral discoverServices:discoverWithServices];
     - [peripheral discoverCharacteristics:discoverWithCharacteristics forService:service];
     
     该方法支持channel版本:
     [baby setBabyOptionsAtChannel:<#(NSString *)#> scanForPeripheralsWithOptions:<#(NSDictionary *)#> connectPeripheralWithOptions:<#(NSDictionary *)#> scanForPeripheralsWithServices:<#(NSArray *)#> discoverWithServices:<#(NSArray *)#> discoverWithCharacteristics:<#(NSArray *)#>]
     */
    
    //示例:
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    
    
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions
                             connectPeripheralWithOptions:nil
                           scanForPeripheralsWithServices:nil
                                     discoverWithServices:nil
                              discoverWithCharacteristics:nil];
    
    /*
        设置蓝牙连接block
     
     */
    
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.currPeripheralIndex inSection:1];
        NSDictionary*item = [weakSelf.sectionDataB objectAtIndex:weakSelf.currPeripheralIndex];
        NSDictionary*advertisementData = [item objectForKey:@"advertisementData"];
        NSNumber *RSSI = [item objectForKey:@"RSSI"];
        //给已连接表添加数据
        [weakSelf insertTableView:peripheral advertisementData:advertisementData RSSI:RSSI atSection:0];
        
        //从可连接表中移除已经连接的设备选项
        [weakSelf.sectionDataB removeObject:item];
        [weakSelf.myTable beginUpdates];
        [weakSelf.myTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [weakSelf.myTable endUpdates];
        
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败",peripheral.name]];
        UITableViewCell*CELL = [weakSelf.myTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.currPeripheralIndex inSection:0]];
        if(CELL){
            CELL.detailTextLabel.text = @"连接失败";
        }
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
        if(error){
             [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--断开失败",peripheral.name]];
        }else{
             [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--断开连接",peripheral.name]];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            NSDictionary*item = [weakSelf.sectionDataA objectAtIndex:0];
            NSDictionary*advertisementData = [item objectForKey:@"advertisementData"];
            NSNumber *RSSI = [item objectForKey:@"RSSI"];
            //把数据还给 可连接设备
            [weakSelf insertTableView:peripheral advertisementData:advertisementData RSSI:RSSI atSection:1];
            
            //移除当前连接
            [weakSelf.sectionDataA removeObject:item];
            [weakSelf.myTable beginUpdates];
            [weakSelf.myTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf.myTable endUpdates];
            
        }
    }];
    
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
                [rhythm beats];
    }];
    
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===Bluetooth service name:%@",service.UUID);

    }];
    
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"===Bluetooth characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===Bluetooth characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"===Bluetooth CBDescriptor name is :%@",d.UUID);
        }
    }];
    
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"===Bluetooth Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //读取rssi的委托
    [baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        NSLog(@"===Bluetooth setBlockOnDidReadRSSI:RSSI:%@",RSSI);
    }];
    
    
    //设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsBreak call");
        
        //如果完成任务，即可停止beat,返回bry可以省去使用weak rhythm的麻烦
        //        if (<#condition#>) {
        //            [bry beatsOver];
        //        }
        
    }];
    
    //设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsOver call");
    }];
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
   
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [baby setBabyOptionsAtChannel:channelOnPeropheralView
    scanForPeripheralsWithOptions:scanForPeripheralsWithOptions
     connectPeripheralWithOptions:connectOptions
   scanForPeripheralsWithServices:nil
             discoverWithServices:nil
      discoverWithCharacteristics:nil];
    
}


-(void)DoConnect{
    [SVProgressHUD showInfoWithStatus:@"开始连接设备"];
    baby.having(self.currPeripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI atSection:(NSInteger)section{
    
    NSArray *peripherals;
    if(section == 0){
        peripherals = [_sectionDataA valueForKey:@"peripheral"];
    }else{
        peripherals = [_sectionDataB valueForKey:@"peripheral"];
    }
    
    if(![peripherals containsObject:peripheral]) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:peripherals.count inSection:section];
        [indexPaths addObject:indexPath];
        
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setValue:peripheral forKey:@"peripheral"];
        [item setValue:RSSI forKey:@"RSSI"];
        [item setValue:advertisementData forKey:@"advertisementData"];
        if(section == 0){
            self.currPeripheralIndex = _sectionDataA.count;
            [_sectionDataA addObject:item];
            
        }else{
            [_sectionDataB addObject:item];
        }
        
        
        [_myTable insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma MARK TABLEVIEW DELEGATE
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 1:{
            return _sectionDataB.count;
        }
            
            break;
            
        default:{
            return _sectionDataA.count;
        }
            break;
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 1:{
            return @"可连接设备";
        }
            
            break;
            
        default:{
            return @"已连接设备";
        }
            break;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *CELL = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    if(CELL){
        CELL.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *item;
        switch (indexPath.section) {
            case 1:{
                item = [_sectionDataB objectAtIndex:indexPath.row];
            }
                
                break;
                
            default:{
                item = [_sectionDataA objectAtIndex:indexPath.row];
            }
                break;
        }
        
        CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
        NSDictionary *advertisementData = [item objectForKey:@"advertisementData"];
        NSNumber *RSSI = [item objectForKey:@"RSSI"];
        //peripheral的显示名称,优先用kCBAdvDataLocalName的定义，若没有再使用peripheral name
        NSString *peripheralName;
        if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
            peripheralName = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
        }else if(!([peripheral.name isEqualToString:@""] || peripheral.name == nil)){
            peripheralName = peripheral.name;
        }else{
            peripheralName = [peripheral.identifier UUIDString];
        }
        
        CELL.textLabel.text = peripheralName;
        //信号和服务
        if( indexPath.section == 0){
            CELL.detailTextLabel.text = @"已连接";
        }else{
            CELL.detailTextLabel.text = [NSString stringWithFormat:@"RSSI:%@",RSSI];
        }
        
    }
    return CELL;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 1:{
            //选中可连接设备
            [baby cancelScan];//停止扫描
            
            if(self.currPeripheral){
                [baby cancelPeripheralConnection:self.currPeripheral];
            }
            
            [SVProgressHUD showInfoWithStatus:@"准备连接设备"];
            NSDictionary *item = [_sectionDataB objectAtIndex:indexPath.row];
            CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
            
            self.currPeripheral = peripheral;
            self.currPeripheralIndex = indexPath.row;
            
            //连接设备
            [self DoConnect];
            
        }
            
            break;
            
        default:{
            //选中已经连接设备
            [baby cancelPeripheralConnection:self.currPeripheral];
           
        }
            break;
    }
    
    
    
}
@end
