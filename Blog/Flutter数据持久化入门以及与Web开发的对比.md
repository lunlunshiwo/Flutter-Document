> 对于大部分安卓或者IOS开发人员来说，App的数据持久化可能是很平常的一个话题。但是对于Web开发人员来说，可能紧紧意味着localStorage和sessionStorage。

# Web开发
## localStorage和sessionStorage
**localStorage**和**sessionStorage**是相似而又不同的，二者的API接口是极其类似甚至相同。简单地说一下二者的异同点：
- **localStorage**生命周期是永久。这意味着在理论上除非用户显示在浏览器提供的UI上清除**localStorage**信息或者使用js代码命令方式清除，否则这些信息将永远存在。存放数据大小为一般为**5MB**,而且它仅在客户端（即浏览器）中保存，不参与和服务器的通信。
- **sessionStorage**仅在当前会话下有效，关闭页面或浏览器后被清除。存放数据大小为一般为**5MB**,而且它仅在客户端（即浏览器）中保存，不参与和服务器的通信。原生接口可以接受，亦可再次封装来对**Object**和**Array**有更好的支持。
- 不同浏览器无法共享**localStorage**或**sessionStorage**中的信息。相同浏览器的不同页面间可以共享相同的**localStorage**（页面属于相同域名和端口），但是不同页面或标签页间无法共享**sessionStorage**的信息。这里需要注意的是，页面及标签页仅指顶级窗口，如果一个标签页包含多个**iframe**标签且他们属于同源页面，那么他们之间是可以共享**sessionStorage**的。

以上为我在开发Web时用到的知识储备，甚至在我以**vue**为技术栈开发**WebApp**时，也使用**localStorage**作为了数据持久化的技术依赖。
## IndexedDB
虽然 **Web Storage**（**localStorage**和**sessionStorage**）对于存储较少量的数据很有用，但对于存储更大量的结构化数据来说，这种方法不太有用。**IndexedDB**提供了一个解决方案。**IndexedDB**是在浏览器中保存结构化数据的一种数据库，为了替换**WebSQL**（标准已废弃，但被广泛支持）而出现。**IndexedDB**使用**NoSQL**的形式来操作数据库，保存和读取是**JavaScript**对象，同时还支持查询及搜索。
[![c4f64b136786c7f39293d517e85f330.png](https://i.loli.net/2018/11/23/5bf7a5bca1e97.png)](https://i.loli.net/2018/11/23/5bf7a5bca1e97.png)
这个Web数据库在我平常的Web开发中并未大量使用，具体的细节和API可以查看[IndexedDB-MDN文档](https://developer.mozilla.org/zh-CN/docs/Web/API/IndexedDB_API)。

# Flutter开发
> 在一般移动应用开发中，数据存储基本上都是以文件、数据库等方式的存在。比如类似sqlite的数据库，当然Flutter没有提供直接操作数据库的API，但是有第三方的插件可以用，比如sqflite。另外，在简单数据的存储上，我们可以采用shared_preferences这个库进行存储。

## shared_preferences

**shared_preferences**包含**NSUserDefaults**（在**iOS**上）和**SharedPreferences**（在**Android**上），为存储简单数据提供方案。**shared_preferences**使用异步方式将数据保存到磁盘。但两个方法都不能保证在返回后写入将持久保存到磁盘，并且这个库尽量不要用于存储关键数据。

其实**shared_preferences**和**Web**开发中的**localStorage**在使用方法上时是十分相似的。
### 用法
- 安装依赖与在文件中引入库

在在**pubspec.yaml**文件中，加入如下配置：
[![2ec73c538647b8cd67a5d433f228b26.png](https://i.loli.net/2018/11/23/5bf7a5bc67d05.png)](https://i.loli.net/2018/11/23/5bf7a5bc67d05.png)

因为我使用的是配置好的**Vscord**编辑器，当**pubspec.yaml**文件增加配置时，文件会自动执行**flutter packages get**指令。如果其他编辑器未执行，可自行手动执行。

在需要执行的文件中引入这个库：
```Dart
import 'package:shared_preferences/shared_preferences.dart';
```
- 构建sp类并使用

```Dart
main() async {
  // 构建sp类
  SharedPreferences sp = await SharedPreferences.getInstance();
  // 存储
  sp.setString("name", "lee");
  sp.setInt("age", 24);
  // 读取
  sp.getString("name");// "lee"
  sp.getInt("age");// 24
  sp.get("name");// "lee"
  //清除
  sp.clear()
  sp.remove("name")
}
```
具体API接口可查看[shared_preferences的API文档](https://pub.flutter-io.cn/documentation/shared_preferences/latest/shared_preferences/SharedPreferences-class.html)。
## sqflite
研究中，未完待续~