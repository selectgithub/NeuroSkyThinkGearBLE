using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MainActivity : MonoBehaviour {
    public static MainActivity instance;
    public Button scanBtn;
    public Text text;
    private AndroidJavaClass unity;

    public GameObject scanListPanel, dataPanel;
    public Text rawDataText, poorSignalDataText, eegPowerDataText, eSenseDataText;
    public GameObject devicePrefab;
    public Transform content;
    void Awake()
    {
        instance = this;
    }
    // Use this for initialization
    void Start () {

        ThinkGearManager.instance.RSSIEvent += OnRSSIUpdate;


        if (unity == null)
        {
            unity = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
            
        }
        scanBtn.onClick.AddListener(()=>{
            AndroidJavaObject currentActivity = unity.GetStatic<AndroidJavaObject>("currentActivity");
            currentActivity.Call("StartScan");
            //text.text = currentActivity.Get<int>("testValue").ToString();
        });
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    void OnRSSIUpdate(string content) {
        text.text = content;
    }

    public void OnConnectBtnClick(string index)
    {
        AndroidJavaObject currentActivity = unity.GetStatic<AndroidJavaObject>("currentActivity");
        currentActivity.Call("OnClickScanDevice",index);
    }

    public void DataListen() {
        scanListPanel.SetActive(false);
        dataPanel.SetActive(true);
    }


    public void SetRawDataText(string c) {
        rawDataText.text = c;
    }
    public void SetPoorSignalDataText(string c)
    {
        poorSignalDataText.text = c;
    }
    public void SetEegPowerDataText(string c)
    {
        eegPowerDataText.text = c;
    }
    public void SetESenseDataText(string c)
    {
        eSenseDataText.text = c;
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
            MainActivity.instance.OnConnectBtnClick(btn.name);
        }
        );
    }
    public void ClearList() {
        for (int i = 0; i < content.childCount; i++)
        {
            DestroyImmediate(content.GetChild(i).gameObject);
        }
    }
}
