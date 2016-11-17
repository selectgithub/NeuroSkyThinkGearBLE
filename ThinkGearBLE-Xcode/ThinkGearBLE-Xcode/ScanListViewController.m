//
//  ScanListViewController.m
//  TGAM-BLE
//
//  Created by Chris Wang on 14/11/2016.
//  Copyright © 2016 chris. All rights reserved.
//

#import "ScanListViewController.h"

@interface ScanListViewController ()

@end

@implementation ScanListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataArray = [[NSArray alloc] init];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.title = @"Device List";
    
    UIButton *scanButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 30)];
    [scanButton setTitle:@"Scan" forState:UIControlStateNormal];
    [scanButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(onScanClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:scanButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    centralManager = [ThinkGearCentralManager shareInstance];
    centralManager.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
    [centralManager startScan];
}

-(void)viewWillDisappear:(BOOL)animated{
    
}

-(void)onScanClicked{
    [centralManager startScan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark --BaseCentralManagerDelegate Function
-(void)onScanning:(NSArray *)peripheralArray{
    dataArray = peripheralArray;
    [self.tableView reloadData];
    
}
-(void)onConnectingPeripheral:(CBPeripheral *)peripheral{
    
}
-(void)onConnectedPeripheral:(CBPeripheral *)peripheral{
    //go to next screen;
    [self performSegueWithIdentifier:@"gotoDetail" sender:nil];
}
-(void)onDisconnectedPeripheral:(CBPeripheral *)peripheral{
    
}

#pragma -mark --UITableViewDataSource Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = dataArray[indexPath.row][thePeripheralName];
    cell.detailTextLabel.text = dataArray[indexPath.row][theRSSI];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma -mark --UITableViewDelegate Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [centralManager connectPeripheralWithIndex:(int)indexPath.row];
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
