package com.chris.thinkgearble_androidstudio;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

/**
 * Created by mac on 14/11/2016.
 */

public class DeviceDetailActivity extends Activity {
    private TextView poorSignalTextView;
    private TextView rawdataTextView;
    private TextView eSenseTextView;
    private TextView eegPowerTextView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_device_detail);
        poorSignalTextView = (TextView)findViewById(R.id.poorSignalTextView);
        rawdataTextView = (TextView)findViewById(R.id.rawdataTextView);
        eSenseTextView = (TextView)findViewById(R.id.eSenseTextView);
        eegPowerTextView = (TextView)findViewById(R.id.EEGPowerTextView);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    protected void onStart() {
        super.onStart();
    }
}
