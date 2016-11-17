//
//  ThinkGearCentralManager.m
//  TGAM-BLE
//
//  Created by Chris Wang on 14/11/2016.
//  Copyright © 2016 chris. All rights reserved.
//

#import "ThinkGearCentralManager.h"

@implementation ThinkGearCentralManager

@synthesize manager,standardPeripheralManager;

static ThinkGearCentralManager *controller;

+(id)shareInstance{
    //has been rewrite "allocWithZone" and "copy"
    @synchronized(self){
        if (controller == nil) {
            controller = [[ThinkGearCentralManager alloc] init];
        }
    }
    
    return controller;
}

//rewrite this method, whatever you call how many init, this class return only same one object
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    
    if (controller == nil) {
        controller = [super allocWithZone:zone];
    }
    
    return controller;
}

//rewrite this method, whatever you call how many init, this class return only same one object
-(id)copy{
    return controller;
}

-(id)init{
    if (self = [super init]) {
        //do something to init
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        peripheralDictionaryArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)startScan{
    [peripheralDictionaryArray removeAllObjects];
    [self stopScan];
    
    [manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FEE7"]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
    NSLog(@"Start Scan!!");
}
-(void)stopScan{
    NSLog(@"Stop Scan!!");
    [manager stopScan];
}


-(void)connectPeripheralWithIndex:(int)aindex{
    
    if (aindex >= peripheralDictionaryArray.count) {
        return;
    }
    
    [self stopScan];
    
    NSMutableDictionary * tmpDict = [peripheralDictionaryArray objectAtIndex:aindex];
    
    CBPeripheral * p = tmpDict[thePeripheral];
    
    [manager connectPeripheral:p options:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onConnectingPeripheral:)]) {
        [self.delegate onConnectingPeripheral:p];
    }
    
    //to do: need to add timeout for connection
    
    NSLog(@"Connect!!!");
}

-(void)disconnect{
    [self stopScan];
    if (standardPeripheralManager && standardPeripheralManager.curPeripheral) {
        [manager cancelPeripheralConnection:standardPeripheralManager.curPeripheral];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onDisconnectedPeripheral:)]) {
            [self.delegate onDisconnectedPeripheral:standardPeripheralManager.curPeripheral];
        }
        
        [standardPeripheralManager clean];
        standardPeripheralManager = nil;
    }
    NSLog(@"Disconnect!!!");
}



#pragma mark -CBCentralManagerDelegate Function
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            
            NSLog(@"蓝牙---CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            
            NSLog(@"蓝牙---CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            
            NSLog(@"蓝牙---CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            
            NSLog(@"蓝牙---CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            [self disconnect];
            NSLog(@"关闭蓝牙---CBCentralManagerStatePoweredOff！");
            break;
        case CBCentralManagerStatePoweredOn:
            
            NSLog(@"打开蓝牙------CBCentralManagerStatePoweredOn！！");
            break;
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    if (RSSI.intValue < -68 || RSSI.intValue > 0) {
        //if signal is poor
        return;
    }
    if (![aPeripheral.name hasPrefix:DeviceName]) {
        return;
    }
    
    NSString * identifier = [NSString stringWithFormat:@"%@",aPeripheral.identifier.UUIDString];
    NSLog(@"Scanned device ID:%@",identifier);
    
    
    NSMutableDictionary * peripheralDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:aPeripheral,thePeripheral,aPeripheral.name,thePeripheralName,identifier,theIdentifier,RSSI,theRSSI, nil];
    
    NSMutableDictionary * tmpDict;
    for (int i = 0; i < peripheralDictionaryArray.count; i++) {
        tmpDict = [peripheralDictionaryArray objectAtIndex:i];
        if ([tmpDict[theIdentifier] isEqualToString:identifier]) {
            //if the same identifier peripheral has been exist, replace it with latest dictionary with new RSSI.
            [peripheralDictionaryArray replaceObjectAtIndex:i withObject:peripheralDictionary];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(onScanning:)]) {
                [self.delegate onScanning:peripheralDictionaryArray];
            }
            
            return;
        }
    }
    // if there are no replacement, directily add dictionary to array.
    [peripheralDictionaryArray addObject:peripheralDictionary];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onScanning:)]) {
        [self.delegate onScanning:peripheralDictionaryArray];
    }
    
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral{
    NSLog(@"didConnectPeripheral:%@",aPeripheral);

    standardPeripheralManager = [[ThinkGearPeripheralManager alloc] initWithPeripheral:aPeripheral];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onConnectedPeripheral:)]) {
        [self.delegate onConnectedPeripheral:aPeripheral];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:deviceConnected object:aPeripheral];
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error{
    NSLog(@"didFailToConnectPeripheral: --ERROR:%@  ---Peripheral:%@",error,aPeripheral);
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDisconnectedPeripheral:)]) {
        [self.delegate onDisconnectedPeripheral:aPeripheral];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:deviceDisconnected object:aPeripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error{
    NSLog(@"didDisconnectPeripheral: ---ERROR:%@  ----Peripheral:%@",error,aPeripheral);
    
    if (standardPeripheralManager) {
        [standardPeripheralManager clean];
        standardPeripheralManager = nil;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDisconnectedPeripheral:)]) {
        [self.delegate onDisconnectedPeripheral:aPeripheral];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:deviceDisconnected object:aPeripheral];
    
}

@end
