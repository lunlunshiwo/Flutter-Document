> 相信web前端的开发者都或多或少的遇到过节流与防抖的问题。函数节流和函数防抖，两者都是优化执行代码效率的一种手段。在一定时间内，代码执行的次数不一定是越多越好。相反，频繁的触发或者执行代码，会造成大量的重绘等问题，影响浏览器或者机器资源。因此把代码的执行次数控制在合理的范围。既能节省浏览器CPU资源，又能让页面浏览更加顺畅，不会因为js的执行而发生卡顿。这就是函数节流和函数防抖要做的事。

在最近由我为国内某航空开发的某空货管理App中，简单的使用了一下关于节流与防抖的思路对流程进行了优化。

## 节流与防抖

函数节流是指一定时间内js方法只跑一次。比如人的眨眼睛，就是一定时间内眨一次。

而函数防抖是指频繁触发的情况下，只有足够的空闲时间，才执行代码一次。比如生活中的坐公交，就是一定时间内，如果有人陆续刷卡上车，司机就不会开车。只有别人没刷卡了，司机才开车。

## Flutter的节流

函数节流，简单地讲，就是让一个函数无法在很短的时间间隔内连续调用，只有当上一次函数执行后过了你规定的时间间隔，才能进行下一次该函数的调用。

放到业务中分析节流函数：
```dart
class MyStatefulWidgetState extends State<OrderPageEdit> {
  bool canScanning; //是否可以扫描
  //扫描控制流
  final Stream<dynamic> _barScanner =
      EventChannel('com.freshport.freshport/barcode').receiveBroadcastStream();
  StreamSubscription<dynamic> _barScannerSubscription;

  @override
  void initState() {
    super.initState();
    _barScannerSubscription = _barScanner.listen((data) {
      if (!canScanning) return;
      setState(() {
        canScanning = false;
      });
      scanning(data);
    });
  }

  @override
  void dispose() {
    _barScannerSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Widget;
  }

  //扫面获取
  scanning(goodsCode) async {
    final result = await fetch.fetch(url: 'www.nicai.com');
    setState(() {
      canScanning = true;
    });
    if (result.result) {
    } else {}
  }
}
```
解释一下这段代码，因为这个项目是有扫描条形码进行货物移库的操作，我们的期望是扫描一次，从数据库中读取完成增加到列表中一个货物。因此，在此之前即使扫描也无法读取。因此我在```_barScanner```的监听函数中增加一个flag标志位的判断，这个标志位用于判断是否在读取中，读取完成后将flag置成```true```。此时就可以继续扫描。
当然，我这个节流函数并未像有些截留函数那样带有明显的不可触发时间，这个函数的不可触发时间为加载的时间。

## Flutter的防抖

防抖函数的定义为多次触发事件后，事件处理函数只执行一次，并且是在触发操作结束时执行。其原理是对处理函数进行延时操作，若设定的延时到来之前，再次触发事件，则清除上一次的延时操作定时器，重新定时。

防抖函数多用于处理实时搜索，拖拽，登录用户名密码格式验证。在js的环境中，我们一般使用定时函数setTimeout进行防抖处理。同样的原理，在Flutter中，我们会原则定时函数（或者叫延时函数进行处理）。

在一个输入框对应的时时搜索中，我使用了防抖处理：
```dart
class MyStatefulWidgetState extends State<GoodsCodeList> {
  //检索输入
  final TextEditingController _textController = TextEditingController();
  //设置防抖周期为3s
  Duration durationTime = Duration(seconds: 3);
  Timer timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.clear();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: _textController,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.all(5.0),
            hintText: "请输入商品编码",
            prefixIcon: Icon(Icons.search, color: Colors.black),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(3.0))),
        onChanged: (String text) {
          //限制加节流
          if (text.trim().length < 5) return;
          setState(() {
            timer?.cancel();
            timer = new Timer(durationTime, () {
              //搜索函数
            });
          });
        });
  }
}
```
如代码所示，先设置一个 **Timer** 对象,当输入框**TextField**持续输入时，会一直触发 **Timer**对象的**cancel**事件，既取消，然后会重新给**Timer**赋值新的周期为**3s**的定时函数。当**3s**中内不输入信息时，这个定时函数会触发。但是三秒钟内**再次输入**，这个定时函数又会被取消然后赋值新的周期为**3s**的定时函数。

这就是防抖函数的实际应用。

## 收尾
我们在js的代码中会经常接触到函数节流与防抖，是因为在js中，DOM操作(onresize, onscroll等等操作)是最消耗性能的，但是一些场景中同一事件会多次触发，为了减少操作，从而有了防抖和节流的概念。其实在很多开发中，我们还是可以使用防抖和节流减少不必要的一些操作和ajax请求的。