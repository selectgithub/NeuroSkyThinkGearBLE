//
//  ScanListViewController.h
//  TGAM-BLE
//
//  Created by Chris Wang on 14/11/2016.
//  Copyright © 2016 chris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThinkGearCentralManager.h"

@interface ScanListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ThinkGearCentralManagerDelegate>{
    
    NSArray * dataArray;
    ThinkGearCentralManager *centralManager;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;




@end
