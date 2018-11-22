# 跳转
## 命名路由
在文件构建时先设置路由参数：
```Dart
new MaterialApp(
  // 代码
  routes: {
    "secondPage":(BuildContext context)=>new SecondPage(),
  },
);
```
在需要做路由跳转的时候直接使用：
```Dart
Navigator.pushNamed(context, "secondPage");
```
## 构建路由
```Dart
Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context){
  return new SecondPage();
}))
```
## 区别
以上两种路由的优缺点十分明显：
1. 命名路由简明并且系统，但是不能传参。
2. 构建路由可以传参，但比较繁琐。
# 动画
## 构建动画
先在构建一个动画效果，如：
```Dart
static SlideTransition createTransition(
  Animation<double> animation, Widget child) {
    return new SlideTransition(
        position: new Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: const Offset(0.0, 0.0),
    ).animate(animation),
        child: child,
    );
}
```
以上动画意思为跳转时新页面从右边划入，返回时向右边划出。
## 引入动画

```Dart
Navigator.push<String>(
  context,
  new PageRouteBuilder(pageBuilder: (BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation) {
        // 跳转的路由对象
        return new Wechat();
  }, transitionsBuilder: (
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return MyStatefulWidgetState
        .createTransition(animation, child);
  }))
```
# 传参

## 跳转时
### 传
前面我们说过，flutter的命名路由跳转无法传参。因此，我们只能使用构建路由的方式传参:
```Dart
Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context){
  return new SecondPage(
    title:'此处为参数'，
    name:'此处为名字参数'
  );
}))
```
### 收
```Dart
class SecondPage extends StatefulWidget {
  String title;
  String name;

  Wechat({
    Key key,
    this.title,
    this.name
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new MyStatefulWidgetState();
  }
}
```
## 返回时
### 传
当触发路由返回的事件时，传参是十分简单的。和跳转时的方式一样，甚至更简单，只需要：
```Dart
Navigator.of(context).pop('这个是要返回给上一个页面的数据');
```
### 收
但是，在接受返回时的数据需要改造前面触发跳转时的路由：
```Dart
// 命名路由
Navigator.pushNamed<String>(context, "ThirdPage").then( (String value){
   //处理代码
});
// 构建路由
Navigator.push<String>(context, new MaterialPageRoute(builder: (BuildContext context){
    return new ThirdPage(title:"请输入昵称");
})).then( (String result){
   //处理代码
});
```

以上就是Flutter路由的跳转、动画以及传参的相关方法，依葫芦画瓢即可轻松应对。