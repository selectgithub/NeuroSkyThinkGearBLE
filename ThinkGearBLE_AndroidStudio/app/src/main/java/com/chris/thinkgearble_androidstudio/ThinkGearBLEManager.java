package com.chris.thinkgearble_androidstudio;

/**
 * Created by mac on 14/11/2016.
 */

import android.bluetooth.*;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import android.content.Context;
import android.util.Log;

public class ThinkGearBLEManager implements BluetoothAdapter.LeScanCallback {

    private BluetoothAdapter btAdapter;
    private List<BluetoothDevice> deviceList;
    private BluetoothGatt gatt;

    String uServiceUUID                        = "FFE0";
    String uNotifyCharacteristicUUID           = "FFE1";

    private static class SingletonHolder {
        private static final ThinkGearBLEManager INSTANCE = new ThinkGearBLEManager();
    }

    private ThinkGearBLEManager(){
        btAdapter = BluetoothAdapter.getDefaultAdapter();
        deviceList = new ArrayList<>();
    }

    public static final ThinkGearBLEManager getInstance(){
        return SingletonHolder.INSTANCE;
    }

    public void startScan() {
        Log.d("Chris", "startScan--");
        //btAdapter.startDiscovery();
        btAdapter.startLeScan(this);
    }
    public void stopScan() {
        Log.d("Chris", "stopScan--");
        btAdapter.cancelDiscovery();
    }

    public void connectWith(Context context, int index){
        gatt = deviceList.get(index).connectGatt(context, true, gattCallback);
    }

    public void disconnect(){
        gatt.disconnect();
    }

    @Override
    public void onLeScan(BluetoothDevice device, int rssi, byte[] scanRecord) {
        deviceList.add(device);

        Log.d("Chris", "Device Name:" + device.getName());
    }

    private BluetoothGattCallback gattCallback = new BluetoothGattCallback() {

        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status,
                                            int newState) {
            Log.d("Chris", "onConnectionStateChange");
            switch (newState) {
                case BluetoothProfile.STATE_CONNECTED:
                    Log.d("Chris", "STATE_CONNECTED");
                    gatt.discoverServices();

                    break;
                case BluetoothProfile.STATE_DISCONNECTED:
                    Log.d("Chris", "STATE_DISCONNECTED");
                    break;
                case BluetoothProfile.STATE_CONNECTING:
                    Log.d("Chris", "STATE_CONNECTING");
                    break;
                case BluetoothProfile.STATE_DISCONNECTING:
                    Log.d("Chris", "STATE_DISCONNECTING");
                    break;
            }
            super.onConnectionStateChange(gatt, status, newState);
        }

        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            Log.d("Chris", "onServicesDiscovered");
            if (status == BluetoothGatt.GATT_SUCCESS) {
                for (int i = 0; i < gatt.getServices().size(); i++) {
                    BluetoothGattService theService = gatt.getServices().get(i);
                    Log.d("Chris", "ServiceName:" + theService.getUuid());
                    if (theService.getUuid().toString().equalsIgnoreCase(uServiceUUID)){
                        for (int j = 0; j < theService.getCharacteristics().size(); j++) {
                            BluetoothGattCharacteristic theCharacter = theService.getCharacteristics().get(j);
                            Log.d("Chris","---CharacterName:" + theCharacter.getUuid());
                            if (theCharacter.getUuid().toString().equalsIgnoreCase(uNotifyCharacteristicUUID)){
                                gatt.setCharacteristicNotification(theCharacter,true);
                            }
                        }
                    }

                }
            }
            super.onServicesDiscovered(gatt, status);
        }

        @Override
        public void onCharacteristicRead(BluetoothGatt gatt,
                                         BluetoothGattCharacteristic characteristic, int status) {
            Log.d("Chris", "onCharacteristicRead");
            super.onCharacteristicRead(gatt, characteristic, status);
        }

        @Override
        public void onCharacteristicWrite(BluetoothGatt gatt,
                                          BluetoothGattCharacteristic characteristic, int status) {
            Log.d("Chris", "onCharacteristicWrite");
            super.onCharacteristicWrite(gatt, characteristic, status);
        }

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt,
                                            BluetoothGattCharacteristic characteristic) {
            Log.d("Chris", "onCharacteristicChanged");
            super.onCharacteristicChanged(gatt, characteristic);
        }

        @Override
        public void onDescriptorRead(BluetoothGatt gatt,
                                     BluetoothGattDescriptor descriptor, int status) {
            Log.d("Chris", "onDescriptorRead");
            super.onDescriptorRead(gatt, descriptor, status);
        }

        @Override
        public void onDescriptorWrite(BluetoothGatt gatt,
                                      BluetoothGattDescriptor descriptor, int status) {
            Log.d("Chris", "onDescriptorWrite");
            super.onDescriptorWrite(gatt, descriptor, status);
        }

        @Override
        public void onReliableWriteCompleted(BluetoothGatt gatt, int status) {
            Log.d("Chris", "onReliableWriteCompleted");
            super.onReliableWriteCompleted(gatt, status);
        }

        @Override
        public void onReadRemoteRssi(BluetoothGatt gatt, int rssi, int status) {
            Log.d("Chris", "onReadRemoteRssi");
            super.onReadRemoteRssi(gatt, rssi, status);
        }

    };

}
