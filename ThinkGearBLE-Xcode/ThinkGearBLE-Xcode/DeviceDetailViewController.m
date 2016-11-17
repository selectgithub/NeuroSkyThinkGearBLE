//
//  DeviceDetailViewController.m
//  TGAM-BLE
//
//  Created by Chris Wang on 14/11/2016.
//  Copyright © 2016 chris. All rights reserved.
//

#import "DeviceDetailViewController.h"

@interface DeviceDetailViewController ()

@end

@implementation DeviceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    centralManager = [ThinkGearCentralManager shareInstance];
}

-(void)viewWillAppear:(BOOL)animated{
    if (centralManager.standardPeripheralManager) {
        centralManager.standardPeripheralManager.delegate = self;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [centralManager disconnect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark --BasePeripheralManagerDelegate
-(void)onRealtimeDataReceived:(NSDictionary *)dataDictionary withPeripheral:(CBPeripheral *)peripheral{
    
}

-(void)onUpdatedRSSI:(NSNumber *)RSSI withPeripheral:(CBPeripheral *)peripheral{
    
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
