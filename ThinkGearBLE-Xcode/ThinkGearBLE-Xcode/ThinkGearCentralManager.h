//
//  ThinkGearCentralManager.h
//  TGAM-BLE
//
//  Created by Chris Wang on 14/11/2016.
//  Copyright © 2016 chris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ThinkGearPeripheralManager.h"

#define DeviceName @"Sichiray"

#pragma mark -----------------key---------------
#define thePeripheral @"thePeripheral"
#define thePeripheralName @"thePeripheralName"
#define theIdentifier @"theIdentifier"
#define theRSSI @"theRSSI"

#pragma mark -----------------Notification--------------- 
#define deviceConnected @"deviceConnected"
#define deviceDisconnected @"deviceDisconnected"

@protocol ThinkGearCentralManagerDelegate <NSObject>

@optional
-(void)onScanning:(NSArray *)peripheralArray;
-(void)onConnectingPeripheral:(CBPeripheral *)peripheral;
-(void)onConnectedPeripheral:(CBPeripheral *)peripheral;
-(void)onDisconnectedPeripheral:(CBPeripheral *)peripheral;

@end

@interface ThinkGearCentralManager : NSObject<CBCentralManagerDelegate>{
    
    NSMutableArray *peripheralDictionaryArray;
    
}
@property(nonatomic,strong)CBCentralManager *manager;
@property(nonatomic,strong)ThinkGearPeripheralManager *standardPeripheralManager;
@property (nonatomic,weak)id<ThinkGearCentralManagerDelegate> delegate;


+(id)shareInstance;
-(void)startScan;
-(void)stopScan;
-(void)connectPeripheralWithIndex:(int)aindex;
-(void)disconnect;

@end
