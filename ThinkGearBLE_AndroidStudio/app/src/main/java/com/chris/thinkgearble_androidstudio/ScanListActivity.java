package com.chris.thinkgearble_androidstudio;

import android.annotation.TargetApi;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanResult;
import android.os.Build;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.content.pm.*;
import android.util.Log;
import android.widget.*;
import android.bluetooth.*;
import android.content.*;
import android.view.*;

import java.util.ArrayList;
import java.util.List;

@TargetApi(Build.VERSION_CODES.LOLLIPOP)
public class ScanListActivity extends AppCompatActivity{

    ThinkGearBLEManager bleManager;
    private BluetoothAdapter mBluetoothAdapter;
    private final static int REQUEST_ENABLE_BT = 1;

    private BluetoothGatt gatt;
    private ArrayList<BluetoothDevice> deviceList;

    private String uServiceUUID                        = "0000ffe0-0000-1000-8000-00805f9b34fb";
    private String uNotifyCharacteristicUUID           = "0000ffe1-0000-1000-8000-00805f9b34fb";

    private static final int PARSER_SYNC_BYTE                 = 170;
    private static final int PARSER_STATE_SYNC                = 1;
    private static final int PARSER_STATE_SYNC_CHECK          = 2;
    private static final int PARSER_STATE_PAYLOAD_LENGTH      = 3;
    private static final int PARSER_STATE_PAYLOAD             = 4;
    private static final int PARSER_STATE_CHKSUM              = 5;

    private byte chrisbuffer;
    private byte payload[] = new byte[64];

    private int parserStatus;
    private int payloadLength;
    private int payloadBytesReceived;
    private int payloadSum;
    private int checksum;

    private int raw,poorsignal;

    private ListView deviceListView;
    private ArrayList<String> deviceNameList;
    private ArrayList<String> deviceMACList;

    private ArrayAdapter listViewAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_scan_list);
        bleManager = ThinkGearBLEManager.getInstance();

        deviceList = new ArrayList<>();
        deviceNameList = new ArrayList<>();
        deviceMACList = new ArrayList<>();
        deviceListView = (ListView)findViewById(R.id.device_list);

        listViewAdapter = new ArrayAdapter<String>(this,
                android.R.layout.simple_list_item_1, deviceNameList);

        deviceListView.setAdapter(listViewAdapter);


        deviceListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                Log.d("Chris", "Clicked Index:" + i + " lll:" + l );
                connectWith(ScanListActivity.this,i);
            }
        });


        // Use this check to determine whether BLE is supported on the device. Then
        // you can selectively disable BLE-related features.
        if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
            Toast.makeText(this, R.string.ble_not_supported, Toast.LENGTH_SHORT).show();
            finish();
        }

        // Initializes Bluetooth adapter.
        final BluetoothManager bluetoothManager =
                (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        mBluetoothAdapter = bluetoothManager.getAdapter();

        if (mBluetoothAdapter == null || !mBluetoothAdapter.isEnabled()) {
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
        }


    }

    public void onStartScanClicked(View view){
        startScan();
    }

    @Override
    protected void onStart() {
        super.onStart();
        //bleManager.startScan();
        startScan();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        disconnect();
    }

    /*==================Android API 21 Scan========================*/
    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public void startScan(){
        if (mBluetoothAdapter != null) {
            mBluetoothAdapter.getBluetoothLeScanner().startScan(scanCallback);
            Log.d("Chris", "Start Scan!!!");
        }
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public void stopScan(){
        if (mBluetoothAdapter != null) {
            Log.d("Chris", "Stop Scan!!!");
            mBluetoothAdapter.getBluetoothLeScanner().stopScan(scanCallback);
        }
    }

    public void connectWith(Context context, int index){
        stopScan();
        gatt = deviceList.get(index).connectGatt(context, true, gattCallback);
        parserStatus = PARSER_STATE_SYNC;
    }

    public void disconnect(){
        gatt.disconnect();
    }

    private ScanCallback scanCallback = new ScanCallback() {
        @Override
        public void onBatchScanResults(List<ScanResult> results) {
            super.onBatchScanResults(results);
            Log.d("Chris", "Device Name One:" + results.get(0).getDevice().getName());
        }

        @Override
        public void onScanFailed(int errorCode) {
            super.onScanFailed(errorCode);
        }

        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            Log.d("Chris", "Device Name:" + result.getDevice().getName());
            super.onScanResult(callbackType, result);

            if (result.getDevice().getName().equalsIgnoreCase("SICHIRAY")){

                if (deviceMACList.contains(result.getDevice().getAddress())){
                    int index = deviceMACList.indexOf(result.getDevice().getAddress());
                    deviceList.remove(index);
                    deviceList.add(index,result.getDevice());
                    deviceNameList.remove(index);
                    deviceNameList.add(index,result.getDevice().getName() + "RSSI:" + result.getRssi());
                }else {
                    deviceMACList.add(result.getDevice().getAddress());
                    deviceList.add(result.getDevice());
                    deviceNameList.add(result.getDevice().getName() + "RSSI:" + result.getRssi());
                }

                listViewAdapter.notifyDataSetChanged();
            }
        }
    };

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


        // pragma mark -Data Parse/Calculate Function
        private void onReceivedDataPacket(byte[] data){

            for (int i = 0; i < data.length; i++) {
                chrisbuffer = data[i];

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
                            Log.d("Chris", "CheckSum Error!!!");
                        } else {
                            parsePacketPayload();
                        }
                        break;

                    default:
                        break;
                }
            }
        }


        private void parsePacketPayload(){

            switch (payload[0]) {
                case (byte) 0x80:{
                    //rawdata
                    raw = getRawValue(payload[2], payload[3]);

                    if(raw > 32768) raw -= 65536;

                    Log.d("Chris", "Rawdata:" + raw);

                }
                break;

                case 0x02:{
                    //big packet
                    //      pqCode     eegCode  length   delta   theta     lowAlpha  highAlpha   lowBeta   highBeta   lowGamma   middleGamma   attCode     medCode
                    //Body:<02     c8  83       18       02753d  1897fb    070df3    069635      01e344    04a030     01be0d     0de203        04      00  05      00>
                    //      0      1   2        3        4 5 6   7 8 9     10        13          16        19         22         25            28      29  30      31

                    poorsignal  = payload[1] & 0xFF;

                    EEGPower eegPower = new EEGPower();
                    eegPower.delta       = (payload[4] << 16) | (payload[5] << 8) | payload[6];
                    eegPower.theta       = (payload[7] << 16) | (payload[8] << 8) | payload[9];
                    eegPower.lowAlpha    = (payload[10] << 16) | (payload[11] << 8) | payload[12];
                    eegPower.highAlpha   = (payload[13] << 16) | (payload[14] << 8) | payload[15];
                    eegPower.lowBeta     = (payload[16] << 16) | (payload[17] << 8) | payload[18];
                    eegPower.highBeta    = (payload[19] << 16) | (payload[20] << 8) | payload[21];
                    eegPower.lowGamma    = (payload[22] << 16) | (payload[23] << 8) | payload[24];
                    eegPower.middleGamma = (payload[25] << 16) | (payload[26] << 8) | payload[27];

                    ESense eSense = new ESense();
                    eSense.attention   = payload[29];
                    eSense.meditation  = payload[31];

                    Log.d("Chris", "PoorSignal:"+ poorsignal);
                    Log.d("Chris", "delta:" + eegPower.delta);
                    Log.d("Chris", "attention:" + eSense.attention);
                    Log.d("Chris", "meditation:" + eSense.meditation);



                }
                break;

                default:
                    break;
            }
        }

        private int getRawValue(byte highByte, byte lowByte){

            int hi = (int)highByte;
            int lo = ((int)lowByte) & 0xFF;

            int return_value = (hi<<8) | lo;

            return return_value;
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
            if (characteristic.getUuid().toString().equalsIgnoreCase(uNotifyCharacteristicUUID)){
                Log.d("Chris", "Value Length:" + characteristic.getValue().length);
                onReceivedDataPacket(characteristic.getValue());
            }

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
