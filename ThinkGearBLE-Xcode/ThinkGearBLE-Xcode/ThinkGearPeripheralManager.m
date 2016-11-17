//
//  ThinkGearPeripheralManager.m
//  TGAM-BLE
//
//  Created by Chris Wang on 14/11/2016.
//  Copyright © 2016 chris. All rights reserved.
//

#import "ThinkGearPeripheralManager.h"

@implementation ThinkGearPeripheralManager{
    Byte *tempbuffer;
}

@synthesize curPeripheral;

NSString * const uServiceUUID                        = @"FFF0";
NSString * const uWritableCharacteristicUUID         = @"FFF7";
NSString * const uIndicatableCharacteristicUUID      = @"FFF8";

-(id)initWithPeripheral:(CBPeripheral *)peripheral{
    if (self = [super init]) {
        //do something to init
        curPeripheral = peripheral;
        curPeripheral.delegate = self;
        [curPeripheral discoverServices:nil];
    }
    
    return self;
}

-(void)startRealtimeTempNotify{}
-(void)stopRealtimeTempNotify{}

-(void)clean{
    if (curPeripheral) {
        curPeripheral.delegate = nil;
        curPeripheral = nil;
    }
}

- (void)WriteCMDWithData:(NSData *)data {
    if (curPeripheral) {
        for (CBService * service in curPeripheral.services) {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:uServiceUUID]]) {
                for (CBCharacteristic * character in service.characteristics) {
                    if ([character.UUID isEqual:[CBUUID UUIDWithString:uWritableCharacteristicUUID]]) {
                        [curPeripheral writeValue:data forCharacteristic:character type:CBCharacteristicWriteWithResponse];
                    }
                }
            }
        }
    }
}

#pragma mark -Data Parse/Calculate Function
-(void)onReceivedDataPacket:(NSData *)data{
    
    tempbuffer = (Byte*)[data bytes];
    NSLog(@"%@ ---Data::%@",curPeripheral.name,data);
}

#pragma mark -CBPeripheralDelegate Function

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(nullable NSError *)error NS_DEPRECATED(NA, NA, 5_0, 8_0){
    if(error){
    }else{
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error NS_AVAILABLE(NA, 8_0){
    if(error){
    }else{
        if(self.delegate && [self.delegate respondsToSelector:@selector(onUpdatedRSSI:withPeripheral:)]){
            [self.delegate onUpdatedRSSI:RSSI withPeripheral:peripheral];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error{
    if (error) {
        NSLog(@"didDiscoverServices -- ERROR:%@--  %@",error,curPeripheral.name);
    }else{
        for (CBService * service in peripheral.services) {
            [curPeripheral discoverCharacteristics:nil forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error{
    if (error) {
        NSLog(@"didDiscoverCharacteristicsForService -- ERROR:%@--  %@",error,curPeripheral.name);
    }else{
        for (CBCharacteristic *character in service.characteristics)  {
            if ([character.UUID isEqual:[CBUUID UUIDWithString:uWritableCharacteristicUUID]]) {
                
            }
            if ([character.UUID isEqual:[CBUUID UUIDWithString:uIndicatableCharacteristicUUID]]) {
                [curPeripheral setNotifyValue:YES forCharacteristic:character];
                NSLog(@"Set Indicatable Notify YES --- %@",curPeripheral.name);
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
        NSLog(@"didUpdateValueForCharacteristic -- ERROR:%@--  %@",error,curPeripheral.name);
    }else{
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:uIndicatableCharacteristicUUID]]) {
            [self onReceivedDataPacket:characteristic.value];

            
        }
        
    }// end error else
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
        NSLog(@"didWriteValueForCharacteristic -- ERROR:%@--  %@",error,curPeripheral.name);
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:uWritableCharacteristicUUID]]) {
            //Write failed
            NSLog(@"Write Failed");
            
        }
    } else {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:uWritableCharacteristicUUID]]) {
            //Write Successfully
            NSLog(@"Write Success");
            
            
        }
        
        
    }
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
        NSLog(@"didUpdateNotificationStateForCharacteristic -- ERROR:%@--  %@",error,curPeripheral.name);
    }else{
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:uIndicatableCharacteristicUUID]]) {
            
        }
        NSLog(@"Notification State Updated --UUID:%@  -- Peripheral:%@",characteristic.UUID,curPeripheral.name);
    }
}

@end
