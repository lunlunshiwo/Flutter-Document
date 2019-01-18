> 题接上篇的文章的项目，还是那个空货管理app。本篇文章用于讲解基于Flutter的app项目的升级方案。

在我接触Flutter之前，做过一个比较失败的基于DCloud的HTML5+技术的app，做过几个RN项目。在这两种不同机制的app升级方案中，RN采用的是微软的CodePush技术。而那个比较失败的项目采用的是检查版本号，下载安装包的方法。而在这个Flutter项目中，我在写app更新方法时，查资料的时候查到一篇文章，文章大概意思讲解了一下Flutter实行CodePush的可能性。但是，我并未找到可能实现的方法。因此，采用了简单粗暴的进行app升级。

## 服务器的操作

为了检验版本号和下载app安装包，我们在服务器某文件夹下放置两个文件，第一个为**version.json**文件，内容为：
```json
{
    "android": "1.0.1"
}
```
这个文件用于保存版本号，我们可以写一个读取方法来读取这个版本号：
```dart
Future<bool> checkNewVersion() async {
  try {
    final res = await http.get(downLoadUrl + '/version.json');
    if (res.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(res.body);
      if (defaultTargetPlatform == TargetPlatform.android) {
        final packageInfo = await PackageInfo.fromPlatform();
        final newVersion = body['android'];
        return (newVersion.compareTo(packageInfo.version) == 1);
      }
    }
  } catch (e) {
    return false;
  }
  return false;
}
```
第二个文件为app安装包，用来下载之后安装。

## app端的操作

在app端需要增加的方法比较多，有需要处理app的权限和处理版本号读取以及app安装包下载和安装等方法。

### 权限的获取

在**targetSdkVersion < 24**之前，我们可以通过在**AndroidManifest.xml**这个文件中写入获取读写权限：
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```
但是当Flutter更新到1.0.0版本之后，现阶段的targetSdkVersion为27。API 23之前的版本都是自动获取权限，而从 Android 6.0 开始添加了权限申请的需求，更加安全。因此，我们需要做一下额外的才做来获取权限。

我在[stackoverflow](https://stackoverflow.com/questions/38200282/android-os-fileuriexposedexception-file-storage-emulated-0-test-txt-exposed)上找到了一篇文章了解了一下这个问题的解决方案。这篇文章中赞最高的方法比较负责，因为时间比较短，暂时没有研究，不过项目组大佬说如果要完美地解决这个问题还是要会过来研究一下。

我在本次项目中采用了第二种方法，在**MainActivity.java的onCreate方法**中添加
```java
StrictMode.VmPolicy.Builder builder = new StrictMode.VmPolicy.Builder();
StrictMode.setVmPolicy(builder.build());
```
然后引入**simple_permissions**这个依赖查询app的权限和询问是否开启权限。具体方法为：
```dart
  //是否有权限
  Future<bool> checkPermission() async {
    bool res = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);
    return res;
  }

  //打开权限
  Future<PermissionStatus> requestPermission() async {
    return SimplePermissions.requestPermission(Permission.WriteExternalStorage);
  }
```
### 版本号的获取

我们在服务器上放置了一个名为**version.json**的文件，我们可以获取一下这个文件的内容访问写在里面的版本号：
```dart
Future<bool> checkNewVersion() async {
  try {
    final res = await http.get(downLoadUrl + '/version.json');
    if (res.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(res.body);
      if (defaultTargetPlatform == TargetPlatform.android) {
        // 获取此时版本
        final packageInfo = await PackageInfo.fromPlatform();
        final newVersion = body['android'];
        // 此处比较版本
        return (newVersion.compareTo(packageInfo.version) == 1);
      }
    }
  } catch (e) {
    return false;
  }
  return false;
}
```

因为这个项目是基于安卓7.0的手持终端的项目，此处做了是否为安卓的查询处理。

### 安装包下载

在下载安装包这个功能中，我们安装了**flutter_downloader**这个依赖。先获取一下下载地址，在下载安装包：
```dart
// 获取安装地址
Future<String> get _apkLocalPath async {
  final directory = await getExternalStorageDirectory();
  return directory.path;
}
// 下载
Future<void> executeDownload() async {
  final path = await _apkLocalPath;
  //下载
  final taskId = await FlutterDownloader.enqueue(
      url: downLoadUrl + '/app-release.apk',
      savedDir: path,
      showNotification: true,
      openFileFromNotification: true);
  FlutterDownloader.registerCallback((id, status, progress) {
    // 当下载完成时，调用安装
    if (taskId == id && status == DownloadTaskStatus.complete) {
      _installApk();
    }
  });
}
// 安装
Future<Null> _installApk() async {
  // XXXXX为项目名
  const platform = const MethodChannel(XXXXX);
  try {
    final path = await _apkLocalPath;
    // 调用app地址
    await platform.invokeMethod('install', {'path': path + '/app-release.apk'});
  } on PlatformException catch (_) {}
}
```
安装完成。

## 总结

以上为Flutter项目的更新步骤。在以上步骤中比较坑人的部分时权限获取至一块中，如果不设置，则会无法成功下载安装包。相信在不久的将来，Flutter可能也会用上CodePush。

顺便说一下那个被我称为失败的项目，我去那个项目组的时候这个项目已经做了一半了。而让我十分震惊的是作为一个基于vue的项目，项目进行了一多半还没人使用状态管理，vuex引入了，但是没人用。嗯，强行carray，发现carry不动。只能尽力补救之后，眼睁睁地看着这个项目走向深渊。当时我还是个萌新，想进去学技术的，结果发现一群自称三年经验以上的人还需要我和另一个刚进公司的同事带。当时还是很绝望的，只能一边绝望一边带着他们加班。现在觉得项目组的水平和氛围真的重要！！！

![image](http://wx3.sinaimg.cn/large/7280659bgy1firilrffnpj20c80c8dg4.jpg)