//
//  ThinkGearPeripheralManager.h
//  TGAM-BLE
//
//  Created by Chris Wang on 14/11/2016.
//  Copyright © 2016 chris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol ThinkGearPeripheralManagerDelegate <NSObject>

@optional
-(void)onRealtimeDataReceived:(NSDictionary *)dataDictionary withPeripheral:(CBPeripheral *)peripheral;
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
