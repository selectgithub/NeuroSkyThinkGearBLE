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
    Byte chrisbuffer;
    Byte payload[64];
    
    int parserStatus;
    int payloadLength;
    int payloadBytesReceived;
    int payloadSum;
    int checksum;
    
    int raw,poorsignal;
}

@synthesize curPeripheral;

NSString * const uServiceUUID                        = @"FFE0";
NSString * const uNotifyCharacteristicUUID           = @"FFE1";
NSString * const uWritableCharacteristicUUID         = @"FFF7";
NSString * const uIndicatableCharacteristicUUID      = @"FFF8";

static const int PARSER_SYNC_BYTE                 = 170;
static const int PARSER_STATE_SYNC                = 1;
static const int PARSER_STATE_SYNC_CHECK          = 2;
static const int PARSER_STATE_PAYLOAD_LENGTH      = 3;
static const int PARSER_STATE_PAYLOAD             = 4;
static const int PARSER_STATE_CHKSUM              = 5;


-(id)initWithPeripheral:(CBPeripheral *)peripheral{
    if (self = [super init]) {
        //do something to init
        curPeripheral = peripheral;
        curPeripheral.delegate = self;
        [curPeripheral discoverServices:nil];
        
        parserStatus = PARSER_STATE_SYNC;
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
    //NSLog(@"%@ ---Data::%@",curPeripheral.name,data);
    
    for (int i = 0; i < [data length]; i++) {
        chrisbuffer = tempbuffer[i];
        
        switch (parserStatus) {
            case PARSER_STATE_SYNC:
                if ((chrisbuffer & 0xFF) != PARSER_SYNC_BYTE)break;
                
                parserStatus = PARSER_STATE_SYNC_CHECK;
                break;
                
            case PARSER_STATE_SYNC_CHECK:
                if ((chrisbuffer & 0xFF) == PARSER_SYNC_BYTE)
                    parserStatus = PARSER_STATE_PAYLOAD_LENGTH;
                else {
                    parserStatus = PARSER_STATE_SYNC;
                }
                break;
                
            case PARSER_STATE_PAYLOAD_LENGTH:
                payloadLength = (chrisbuffer & 0xFF);
                payloadBytesReceived = 0;
                payloadSum = 0;
                parserStatus = PARSER_STATE_PAYLOAD;
                break;
                
            case PARSER_STATE_PAYLOAD:
                payload[(payloadBytesReceived++)] = chrisbuffer;
                payloadSum += (chrisbuffer & 0xFF);
                if (payloadBytesReceived < payloadLength) break;
                parserStatus = PARSER_STATE_CHKSUM;
                break;
                
            case PARSER_STATE_CHKSUM:
                checksum = (chrisbuffer & 0xFF);
                parserStatus = PARSER_STATE_SYNC;
                if (checksum != ((payloadSum ^ 0xFFFFFFFF) & 0xFF)) {
                    NSLog(@"CheckSum Error!!!");
                } else {
                    [self parsePacketPayload];
                }
                break;
                
            default:
                break;
        }
    }
}


-(void)parsePacketPayload{
    
    NSLog(@"payload: %@",[NSData dataWithBytes:payload length:payloadLength]);
    
    switch (payload[0]) {
        case 0x80:{
            //rawdata
            raw = [self getRawValue:payload[2] lowByte:payload[3]];
            
            if(raw > 32768) raw -= 65536;
            
            NSLog(@"Rawdata:%d",raw);
            UnitySendMessage("ThinkGearManager", "DataParse", [[NSString stringWithFormat:@"Rawdata:%d",raw] cStringUsingEncoding:NSUTF8StringEncoding]);
            if (_delegate && [_delegate respondsToSelector:@selector(onRawdataReceived:withPeripheral:)]) {
                [_delegate onRawdataReceived:raw withPeripheral:curPeripheral];
            }
        }
            break;
            
        case 0x02:{
            //big packet
            //      pqCode     eegCode  length   delta   theta     lowAlpha  highAlpha   lowBeta   highBeta   lowGamma   middleGamma   attCode     medCode
            //Body:<02     c8  83       18       02753d  1897fb    070df3    069635      01e344    04a030     01be0d     0de203        04      00  05      00>
            //      0      1   2        3        4 5 6   7 8 9     10        13          16        19         22         25            28      29  30      31
            
            poorsignal  = payload[1] & 0xFF;
            
            EEGPower *eegPower = [EEGPower new];
            eegPower.delta       = (payload[4] << 16) | (payload[5] << 8) | payload[6];
            eegPower.theta       = (payload[7] << 16) | (payload[8] << 8) | payload[9];
            eegPower.lowAlpha    = (payload[10] << 16) | (payload[11] << 8) | payload[12];
            eegPower.highAlpha   = (payload[13] << 16) | (payload[14] << 8) | payload[15];
            eegPower.lowBeta     = (payload[16] << 16) | (payload[17] << 8) | payload[18];
            eegPower.highBeta    = (payload[19] << 16) | (payload[20] << 8) | payload[21];
            eegPower.lowGamma    = (payload[22] << 16) | (payload[23] << 8) | payload[24];
            eegPower.middleGamma = (payload[25] << 16) | (payload[26] << 8) | payload[27];
            
            ESense *eSense = [ESense new];
            eSense.attention   = payload[29];
            eSense.meditation  = payload[31];
            
            NSLog(@"PoorSignal:%d",poorsignal);
            NSLog(@"delta:%d",eegPower.delta);
            NSLog(@"attention:%d",eSense.attention);
            NSLog(@"meditation:%d",eSense.meditation);
            
            UnitySendMessage("ThinkGearManager","DataParse",[[NSString stringWithFormat:@"PoorSignal:%d",poorsignal] cStringUsingEncoding:NSUTF8StringEncoding]);
            UnitySendMessage("ThinkGearManager","DataParse",[[NSString stringWithFormat:@"delta:%d",eegPower.delta] cStringUsingEncoding:NSUTF8StringEncoding]);
            UnitySendMessage("ThinkGearManager","DataParse",[[NSString stringWithFormat:@"theta:%d",eegPower.theta] cStringUsingEncoding:NSUTF8StringEncoding]);
            UnitySendMessage("ThinkGearManager","DataParse",[[NSString stringWithFormat:@"lowAlpha:%d",eegPower.lowAlpha] cStringUsingEncoding:NSUTF8StringEncoding]);
            UnitySendMessage("ThinkGearManager","DataParse",[[NSString stringWithFormat:@"highAlpha:%d",eegPower.highAlpha] cStringUsingEncoding:NSUTF8StringEncoding]);
            UnitySendMessage("ThinkGearManager","DataParse",[[NSString stringWithFormat:@"lowBeta:%d",eegPower.lowBeta] cStringUsingEncoding:NSUTF8StringEncoding]);
            UnitySendMessage("ThinkGearManager","DataParse",[[NSString stringWithFormat:@"highBeta:%d",eegPower.highBeta] cStringUsingEncoding:NSUTF8StringEncoding]);
            UnitySendMessage("ThinkGearManager","DataParse",[[NSString stringWithFormat:@"lowGamma:%d",eegPower.lowGamma] cStringUsingEncoding:NSUTF8StringEncoding]);
            UnitySendMessage("ThinkGearManager","DataParse",[[NSString stringWithFormat:@"middleGamma:%d",eegPower.middleGamma] cStringUsingEncoding:NSUTF8StringEncoding]);
            UnitySendMessage("ThinkGearManager","DataParse",[[NSString stringWithFormat:@"attention:%d",eSense.attention] cStringUsingEncoding:NSUTF8StringEncoding]);
            UnitySendMessage("ThinkGearManager","DataParse",[[NSString stringWithFormat:@"meditation:%d",eSense.meditation] cStringUsingEncoding:NSUTF8StringEncoding]);
            
            if (_delegate && [_delegate respondsToSelector:@selector(onPoorSignalReceived:withPeripheral:)]) {
                [_delegate onPoorSignalReceived:poorsignal withPeripheral:curPeripheral];
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(onEEGPowerReceived:withPeripheral:)]) {
                
                [_delegate onEEGPowerReceived:eegPower withPeripheral:curPeripheral];
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(onESenseReceived:withPeripheral:)]) {
                
                [_delegate onESenseReceived:eSense withPeripheral:curPeripheral];
            }
            
        }
            break;
            
        default:
            break;
    }
}

-(int)getRawValue:(Byte)highByte lowByte:(Byte)lowByte{
    
    int hi = (int)highByte;
    int lo = ((int)lowByte) & 0xFF;
    
    int return_value = (hi<<8) | lo;
    
    return return_value;
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
            if ([character.UUID isEqual:[CBUUID UUIDWithString:uNotifyCharacteristicUUID]]) {
                [curPeripheral setNotifyValue:YES forCharacteristic:character];
                NSLog(@"Set Notify YES --- %@",curPeripheral.name);
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
        NSLog(@"didUpdateValueForCharacteristic -- ERROR:%@--  %@",error,curPeripheral.name);
    }else{
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:uIndicatableCharacteristicUUID]]) {
            
        }
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:uNotifyCharacteristicUUID]]) {
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
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:uNotifyCharacteristicUUID]]) {
            
        }
        NSLog(@"Notification State Updated --UUID:%@  -- Peripheral:%@",characteristic.UUID,curPeripheral.name);
    }
}

@end
