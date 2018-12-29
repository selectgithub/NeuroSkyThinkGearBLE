using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Demo : MonoBehaviour
{
    public Button scanBtn;
    public Text text;


    public GameObject scanListPanel, dataPanel;
    public Text dataText;
    public GameObject devicePrefab;
    public Transform content;

    void Start()
    {
        ThinkGearManager.instance.DeviceReceiveEvent += UpdateDeviceList;
        ThinkGearManager.instance.DataReceiveEvent += ShowDataList;
        ThinkGearManager.instance.ConnectedEvent += SwithPage;
        ThinkGearManager.instance.DisConnectedEvent += DisConnected;
        scanBtn.onClick.AddListener(() =>
        {
            ThinkGearManager.instance.StartScan();
            text.text = "扫描中...";
        });
    }

    public void DisConnected() {
        dataText.text = "丢失连接";
     }
    //连接成功，切换界面
    public void SwithPage()
    {
        scanListPanel.SetActive(false);
        dataPanel.SetActive(true);
    }

    //更新数据列表的UI
    public void ShowDataList(Dictionary<string, int> datalist)
    {
        string content = "";
        foreach (var a in datalist)
        {
            content += (a.Key + ":" + a.Value.ToString() + "\n");
        }
        dataText.text = "共" + datalist.Count.ToString() + "条数据\n" + content;
    }

    public void GenerateListUnit(int i, string info)
    {
        //添加房间
        content.GetComponent<RectTransform>().sizeDelta = new Vector2(0, (i + 1) * 110);

        //实例化一个列表子元素
        GameObject o = Instantiate(devicePrefab);
        o.transform.SetParent(content);
        o.SetActive(true);
        //修改信息
        Transform trans = o.transform;
        Text infoText = trans.Find("infoText").GetComponent<Text>();
        infoText.text = info;
        //按钮事件
        Button btn = trans.Find("connectButton").GetComponent<Button>();
        btn.name = i.ToString();   //改变按钮的名字，以便传参
        btn.onClick.AddListener(delegate ()
        {
            text.text = "连接中...";
            ThinkGearManager.instance.ConnectDevice(btn.name);//连接设备
        }
        );
    }

    //更新UI列表
    public void UpdateDeviceList(List<string> deviceList)
    {
        /**清空UI列表*/
        for (int i = 0; i < content.childCount; i++)
        {
            DestroyImmediate(content.GetChild(i).gameObject);
        }
        /**生成UI列表*/
        for (int i = 0; i < deviceList.Count; i++)
        {
            GenerateListUnit(i, deviceList[i]);
        }
    }
}
