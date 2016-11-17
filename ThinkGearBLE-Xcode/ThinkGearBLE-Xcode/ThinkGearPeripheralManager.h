//
//  ThinkGearPeripheralManager.h
//  TGAM-BLE
//
//  Created by Chris Wang on 14/11/2016.
//  Copyright © 2016 chris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "EEGPower.h"
#import "ESense.h"

@protocol ThinkGearPeripheralManagerDelegate <NSObject>

@optional
-(void)onPoorSignalReceived:(int)poorSignal withPeripheral:(CBPeripheral *)peripheral;
-(void)onRawdataReceived:(int)rawdata withPeripheral:(CBPeripheral *)peripheral;

-(void)onEEGPowerReceived:(EEGPower *)eegPower withPeripheral:(CBPeripheral *)peripheral;
-(void)onESenseReceived:(ESense *)eSense withPeripheral:(CBPeripheral *)peripheral;


-(void)onUpdatedRSSI:(NSNumber *)RSSI withPeripheral:(CBPeripheral *)peripheral;

@end



@interface ThinkGearPeripheralManager : NSObject<CBPeripheralDelegate>

@property(nonatomic,strong)CBPeripheral * curPeripheral;

@property (nonatomic,weak)id<ThinkGearPeripheralManagerDelegate> delegate;

-(id)initWithPeripheral:(CBPeripheral *)peripheral;

-(void)startRealtimeTempNotify;
-(void)stopRealtimeTempNotify;

-(void)clean;


@end
