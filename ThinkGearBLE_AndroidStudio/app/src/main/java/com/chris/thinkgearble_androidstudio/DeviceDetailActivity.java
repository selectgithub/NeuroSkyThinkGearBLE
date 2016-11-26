package com.chris.thinkgearble_androidstudio;

import android.app.Activity;
import android.app.Service;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.widget.TextView;

/**
 * Created by mac on 14/11/2016.
 */

public class DeviceDetailActivity extends Activity implements ThinkGearBLEService.IThinkGearDataListener{
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

    public void onPoorSignalReceived(ThinkGearBLEService thinkGearBLEService, int poorSignal){
        poorSignalTextView.setText("PoorSignal: " + poorSignal);
    }
    public void onRawdataReceived(ThinkGearBLEService thinkGearBLEService, int rawdata){
        rawdataTextView.setText("Rawdata: " + rawdata);
    }
    public void onEEGPowerReceived(ThinkGearBLEService thinkGearBLEService, EEGPower eegPower){
        eegPowerTextView.setText("Delta: " + eegPower.delta + "\nTheta: " + eegPower.theta +
                "\nLowAlpha: " + eegPower.lowAlpha + "\nHighAlpha: " + eegPower.highAlpha +
        "\nLowBeta: " + eegPower.lowBeta + "\nHighBeta: " + eegPower.highBeta +
        "\nLowGamma: " + eegPower.lowGamma + "\nMiddleGamma: " + eegPower.middleGamma);
    }
    public void onESenseReceived(ThinkGearBLEService thinkGearBLEService, ESense eSense){
        eSenseTextView.setText("Attention: " + eSense.attention + " Meditation: " + eSense.meditation);
    }
}
