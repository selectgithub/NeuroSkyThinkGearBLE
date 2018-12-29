1、AndroidManifest和ThinkGearPlugin文件，保持导入的位置不动，不可修改；
2、ThinkGearManager脚本提供4个主动方法，7个回调事件：
3、ThinkGearManager必须挂在ThinkGearManager游戏对象上，保持active
4、发布成Android，要求package路径必须改为com.lcy.thinkgear，与manifest一致。
5、发布成iOS，需要在打包后的xcode工程的Build Phases->Link Binary With Libraries中添加CoreBluetooth.frameword依赖。
