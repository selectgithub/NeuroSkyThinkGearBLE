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
-(void)onPoorSignalReceived:(int)poorSignal withPeripheral:(CBPeripheral *)peripheral{
    [_detailLabel setText:[NSString stringWithFormat:@"PoorSignal: %d",poorSignal]];
}

-(void)onRawdataReceived:(int)rawdata withPeripheral:(CBPeripheral *)peripheral{
    [_rawdataLabel setText:[NSString stringWithFormat:@"Rawdata: %d",rawdata]];
}

-(void)onEEGPowerReceived:(EEGPower *)eegPower withPeripheral:(CBPeripheral *)peripheral{
    [_eegPowerLabel setText:[NSString stringWithFormat:@"Delta: %d \n Theta: %d \n LowAlpha: %d \n HighAlpha: %d \n LowBeta: %d \n HighBeta: %d \n LowGamma: %d \n MiddleGamma: %d",eegPower.delta,eegPower.theta,eegPower.lowAlpha,eegPower.highAlpha,eegPower.lowBeta,eegPower.highBeta,eegPower.lowGamma,eegPower.middleGamma]];
}

-(void)onESenseReceived:(ESense *)eSense withPeripheral:(CBPeripheral *)peripheral{
    [_eSenseLabel setText:[NSString stringWithFormat:@"Attention: %d Meditation: %d",eSense.attention,eSense.meditation]];
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
