//
//  MyPluginBridge.m
//  ThinkGearBLE-Xcode
//
//  Created by 306-t on 2018/12/27.
//  Copyright © 2018年 chris. All rights reserved.
//

#import "ThinkGearPluginBridge.h"
@implementation ThinkGearPluginBridge

@end

extern "C"
{
    //主动开启设备扫描
    void iOSStartScan(){

        [[ThinkGearCentralManager shareInstance] startScan];
    }
    //连接设备
    void iOSOnClickScanDevice(int index){
        
        [[ThinkGearCentralManager shareInstance] connectPeripheralWithIndex:index];
    }
    //主动停止设备扫描
    void iOSStopScan(){
        [[ThinkGearCentralManager shareInstance] stopScan];
    }
    //主动断开设备连接
    void iOSDisConnect(){
        [[ThinkGearCentralManager shareInstance] disconnect ];
    }
}
