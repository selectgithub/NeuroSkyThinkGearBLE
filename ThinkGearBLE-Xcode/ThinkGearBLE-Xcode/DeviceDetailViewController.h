//
//  DeviceDetailViewController.h
//  TGAM-BLE
//
//  Created by Chris Wang on 14/11/2016.
//  Copyright © 2016 chris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThinkGearCentralManager.h"

@interface DeviceDetailViewController : UIViewController<ThinkGearPeripheralManagerDelegate>{

    ThinkGearCentralManager *centralManager;
}

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UILabel *rawdataLabel;

@property (weak, nonatomic) IBOutlet UILabel *eSenseLabel;

@property (weak, nonatomic) IBOutlet UILabel *eegPowerLabel;


@end
