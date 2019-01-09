using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.UI;

public class ThinkGearManager : MonoBehaviour
{
    [DllImport("__Internal")]
    private static extern void iOSStartScan();
    [DllImport("__Internal")]
    private static extern void iOSOnClickScanDevice(int index);
    [DllImport("__Internal")]
    private static extern void iOSStopScan();
    [DllImport("__Internal")]
    private static extern void iOSDisConnect();

    private AndroidJavaClass unity;

    public static ThinkGearManager instance;//单例

    /*回调事件*/
    public delegate void DataReceiveDelegate(Dictionary<string, int> dataList);
    public event DataReceiveDelegate DataReceiveEvent;//数据接收事件
    public delegate void DeviceReceiveDelegate(List<string> data);
    public event DeviceReceiveDelegate DeviceReceiveEvent;//设备更新事件
    public delegate void TiggerDelegate();
    public event TiggerDelegate ConnectedEvent;//连接成功事件
    public event TiggerDelegate DisConnectedEvent;//丢失连接事件
    public event TiggerDelegate BlueToothOpenEvent;//蓝牙打开事件
    public event TiggerDelegate BlueToothCloseEvent;//蓝牙关闭事件
    public event TiggerDelegate FailToConnectEvent;//连接失败事件
    List<string> deviceList;//设备列表
    Dictionary<string, int> dataList;//数据列表
    void Awake()
    {
        instance = this;
        deviceList = new List<string>();
        dataList = new Dictionary<string, int>();

        //Android初始化
        if (unity == null)
        {
            unity = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
        }
        //iSO初始化
        try
        {
            iOSStartScan();
        }
        catch { }
    }
    #region 主动方法
    //主动开启设备扫描
    public void StartScan()
    {

        AndroidJavaObject currentActivity = unity.GetStatic<AndroidJavaObject>("currentActivity");
        if (currentActivity != null)
        {
            currentActivity.Call("StartScan");
        }

        try
        {
            iOSStartScan();
        }
        catch { }
    }
    //主动停止扫描
    public void StopScan()
    {
        AndroidJavaObject currentActivity = unity.GetStatic<AndroidJavaObject>("currentActivity");
        if (currentActivity != null)
        {
            currentActivity.Call("StopScan");
        }
        try
        {
            iOSStopScan();
        }
        catch { }
        deviceList.Clear();
    }
    //主动断开连接
    public void Disconnect()
    {
        AndroidJavaObject currentActivity = unity.GetStatic<AndroidJavaObject>("currentActivity");
        if (currentActivity != null)
        {
            currentActivity.Call("DisconnectBLE");
        }
        try
        {
            iOSDisConnect();
        }
        catch { }
    }

    //在设备列表中，连接某索引对应的设备
    public void ConnectDevice(string index)
    {
        AndroidJavaObject currentActivity = unity.GetStatic<AndroidJavaObject>("currentActivity");
        if (currentActivity != null)
        {
            currentActivity.Call("OnClickScanDevice", index);
        }
        try
        {
            iOSOnClickScanDevice(int.Parse(index));
        }
        catch { }

    }
    #endregion
    #region 回调方法
    //设备列表更新回调
    void onScanResult(string deviceListStr)
    {
        deviceList.Clear();//清空列表


        /**解析数据*/
        string[] stringSeparators = new string[] { ";;" };
        string[] list = deviceListStr.Split(stringSeparators, StringSplitOptions.RemoveEmptyEntries);
        foreach (var e in list)
        {
            string str = e.Trim(' ').Trim('\t');
            deviceList.Add(str);
        }
        //触发事件
        if (DeviceReceiveEvent != null)
        {
            DeviceReceiveEvent(deviceList);
        }
    }
    //蓝牙关闭回调
    void onBlueToothClose(string isTrue)
    {
        if (BlueToothCloseEvent != null)
        {
            BlueToothCloseEvent();
        }
        deviceList.Clear();
    }
    //蓝牙打开回调
    void onBlueToothOpen(string isTrue)
    {
        if (BlueToothOpenEvent != null)
        {
            BlueToothOpenEvent();
        }
    }
    //设备连接成功回调
    void onServicesDiscovered(string isTrue)
    {
        if (ConnectedEvent != null)
        {
            ConnectedEvent();
        }
    }
    //设备连接失败回调
    void onFailToConnect(string isTrue)
    {
        if (FailToConnectEvent != null)
        {
            FailToConnectEvent();
        }
    }
    //丢失连接回调
    void onDisconnected(string isTrue)
    {
        if (DisConnectedEvent != null)
        {
            DisConnectedEvent();
        }
    }
    //数据回调
    void DataParse(string dataStr)
    {
        /**解析数据*/
        if (!dataStr.EndsWith("\n"))
        {
            dataStr += "\n";
        }
        string[] rowList = dataStr.Split(new string[] { "\n" }, StringSplitOptions.RemoveEmptyEntries);
        foreach (var ele in rowList)
        {
            string[] row = ele.Split(new string[] { ":" }, StringSplitOptions.RemoveEmptyEntries);//用':'把每一行数据拆分成标签和值两部分
            string label = row[row.Length - 2].Trim(' ').Trim('\t');
            string value = row[row.Length - 1].Trim(' ').Trim('\t');
            if (dataList.ContainsKey(label))
            {
                dataList[label] = int.Parse(value);
            }
            else
            {
                dataList.Add(label, int.Parse(value));
            }
        }
        if (DataReceiveEvent != null)
        {
            DataReceiveEvent(dataList);
        }
    }
    #endregion
}
