package com.chris.thinkgearble_androidstudio;

import android.annotation.TargetApi;
import android.app.Service;
import android.os.Build;
import android.os.IBinder;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.*;
import android.content.*;
import android.view.*;

import java.util.ArrayList;

@TargetApi(Build.VERSION_CODES.LOLLIPOP)
public class ScanListActivity extends AppCompatActivity implements ThinkGearBLEService.IThinkGearConnectionListener{

    ThinkGearBLEService thinkGearService;
    ThinkGearBLEService.MyBinder binder;

    private final static int REQUEST_ENABLE_BT = 1;

    private ArrayList<String> deviceNameList;

    private ArrayAdapter listViewAdapter;
    private Button scanButton;

    private ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
            binder = (ThinkGearBLEService.MyBinder)iBinder;
            thinkGearService = binder.getThinkGearService();
            thinkGearService.setThinkGearConnectionListener(ScanListActivity.this);
            Log.d("Chris", "onServiceConnected!!");
            Log.d("Chris", thinkGearService.toString());
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {

        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_scan_list);

        deviceNameList = new ArrayList<>();

        ListView deviceListView = (ListView)findViewById(R.id.device_list);
        scanButton = (Button)findViewById(R.id.scan_button);
        scanButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                onStartScanClicked(view);
            }
        });

        listViewAdapter = new ArrayAdapter<String>(this,
                android.R.layout.simple_list_item_1, deviceNameList);

        deviceListView.setAdapter(listViewAdapter);

        deviceListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                Log.d("Chris", "Clicked Index:" + i + " lll:" + l );
                thinkGearService.connectWith(i);
            }
        });

        Intent intent = new Intent(ScanListActivity.this,ThinkGearBLEService.class);
        bindService(intent,serviceConnection, Service.BIND_AUTO_CREATE);

    }

    public void onStartScanClicked(View view){
        Log.d("Chris", "onStartScanClicked!!");
        if (thinkGearService != null) {
            thinkGearService.startScan();
        }
    }

    @Override
    protected void onStart() {
        super.onStart();
        //thinkGearService.startScan();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        thinkGearService.disconnect();
        unbindService(serviceConnection);
    }

    public void onDeviceScanning(ThinkGearBLEService thinkGearBLEService, ArrayList<String> deviceNameList){
        this.deviceNameList.clear();
        this.deviceNameList.addAll(deviceNameList);
        listViewAdapter.notifyDataSetChanged();
        Log.d("Chris", "On Device Scanning");
    }
    public void onDeviceConnected(ThinkGearBLEService thinkGearBLEService){
        Intent intent = new Intent(this,DeviceDetailActivity.class);
        startActivity(intent);
        Log.d("Chris", "On Device Connected");
    }
    public void onDeviceDisconnected(ThinkGearBLEService thinkGearBLEService){

    }


}
