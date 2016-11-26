package com.chris.thinkgearble_androidstudio;

import android.app.Activity;
import android.app.Service;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.util.Log;
import android.widget.TextView;

/**
 * Created by mac on 14/11/2016.
 */

public class DeviceDetailActivity extends Activity implements ThinkGearBLEService.IThinkGearDataListener{
    private final int MSG_TYPE_POORSIGNAL = 1;
    private final int MSG_TYPE_RAWDATA    = 2;
    private final int MSG_TYPE_EEGPOWER   = 3;
    private final int MSG_TYPE_ESENSE     = 4;

    ThinkGearBLEService thinkGearService;
    ThinkGearBLEService.MyBinder binder;

    private TextView poorSignalTextView;
    private TextView rawdataTextView;
    private TextView eSenseTextView;
    private TextView eegPowerTextView;

    private ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
            binder = (ThinkGearBLEService.MyBinder)iBinder;
            thinkGearService = binder.getThinkGearService();
            thinkGearService.setThinkGearDataListener(DeviceDetailActivity.this);
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {

        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_device_detail);
        poorSignalTextView = (TextView)findViewById(R.id.poorSignalTextView);
        rawdataTextView = (TextView)findViewById(R.id.rawdataTextView);
        eSenseTextView = (TextView)findViewById(R.id.eSenseTextView);
        eegPowerTextView = (TextView)findViewById(R.id.EEGPowerTextView);
        poorSignalTextView.setText("PoorSignal: 200");

        Intent intent = new Intent(DeviceDetailActivity.this,ThinkGearBLEService.class);
        bindService(intent,serviceConnection, Service.BIND_AUTO_CREATE);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unbindService(serviceConnection);
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    private Handler dataHandler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            switch (msg.what){
                case MSG_TYPE_POORSIGNAL:
                    poorSignalTextView.setText("PoorSignal: " + msg.arg1);
                    break;
                case MSG_TYPE_RAWDATA:
                    rawdataTextView.setText("Rawdata: " + msg.arg1);
                    break;
                case MSG_TYPE_EEGPOWER:
                    eegPowerTextView.setText(msg.obj.toString());
                    break;
                case MSG_TYPE_ESENSE:
                    eSenseTextView.setText(msg.obj.toString());
                    break;
            }
        }
    };

    public void onPoorSignalReceived(ThinkGearBLEService thinkGearBLEService, int poorSignal){
        Message msg = new Message();
        msg.what = MSG_TYPE_POORSIGNAL;
        msg.arg1 = poorSignal;
        dataHandler.sendMessage(msg);
        Log.d("Chris","-----onPoorSignalReceived: " + poorSignal);
    }
    public void onRawdataReceived(ThinkGearBLEService thinkGearBLEService, int rawdata){
        Message msg = new Message();
        msg.what = MSG_TYPE_RAWDATA;
        msg.arg1 = rawdata;
        dataHandler.sendMessage(msg);
        //Log.d("Chris","-----onRawdataReceived: " + rawdata);
    }
    public void onEEGPowerReceived(ThinkGearBLEService thinkGearBLEService, EEGPower eegPower){
        Message msg = new Message();
        msg.what = MSG_TYPE_EEGPOWER;
        msg.obj = eegPower;
        dataHandler.sendMessage(msg);
        //Log.d("Chris","-----onEEGPowerReceived" + eegPower.toString());
    }
    public void onESenseReceived(ThinkGearBLEService thinkGearBLEService, ESense eSense){
        Message msg = new Message();
        msg.what = MSG_TYPE_ESENSE;
        msg.obj = eSense;
        dataHandler.sendMessage(msg);
        //Log.d("Chris","-----onESenseReceived: " + eSense.toString());
    }
}
