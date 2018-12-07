using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ThinkGearManager : MonoBehaviour {
    public static ThinkGearManager instance;
    public delegate void DataRecieveDelegate(string aa);
    public event DataRecieveDelegate RSSIEvent;
    public List<string> deviceList;//设备列表
    void Awake () {
        instance = this;
        deviceList = new List<string>();
    }
	
	// Update is called once per frame
	void Update () {
		
	}




    public void onScanResult(string deviceListStr)
    {
        Debug.Log(deviceListStr);
        deviceList.Clear();
        MainActivity.instance.ClearList();

        string[] stringSeparators = new string[] { ";;" };
        string[] list= deviceListStr.Split(stringSeparators, StringSplitOptions.RemoveEmptyEntries);
        foreach (var e in list) {
//           stringSeparators = new string[] { "add:" };
  //         string[] item=e.Split(stringSeparators,StringSplitOptions.RemoveEmptyEntries);
            deviceList.Add(e);
        }
        for(int i=0;i<deviceList.Count;i++) {
            MainActivity.instance.GenerateListUnit(i, deviceList[i]);
        }

        if (RSSIEvent != null) {
            RSSIEvent(deviceListStr);
        }
    }


    public void onServicesDiscovered(string isTrue) {
                   MainActivity.instance.DataListen();
          }






    

    public void onRawdataReceive(string rawData) {
        MainActivity.instance.SetRawDataText(rawData);
    }

    public void onPoorSignalReceive(string poorSignalData)
    {
        MainActivity.instance.SetPoorSignalDataText(poorSignalData);
    }
    public void onEegPowerReceive(string eegPowerData)
    {
        MainActivity.instance.SetEegPowerDataText(eegPowerData);
    }
    public void onESenseReceive(string eSenseData)
    {
        MainActivity.instance.SetESenseDataText(eSenseData);
    }




}
