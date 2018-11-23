import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

class Wechat extends StatefulWidget {
  String title;

  Wechat({
    Key key,
    this.title,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new MyStatefulWidgetState();
  }
}

class MyStatefulWidgetState extends State<Wechat>
    with TickerProviderStateMixin {
  ChatMessage message;
  List<ChatMessage> _messages = <ChatMessage>[];
  bool _isComposing = false;
  final TextEditingController _textController = new TextEditingController();
  var width;
  RegExp exp = new RegExp(r"(\d+\.\d+)");
  int time = 1000;
  @override
  void initState() {
    super.initState();
  }

  //定义发送文本事件的处理函数
  void _handleSubmitted(String text) {
    _textController.clear(); //清空输入框
    ChatMessage message = new ChatMessage(
      name: "我",
      text: text,
      type: 0,
      width: 500,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: time),
        vsync: this,
      ),
    );
    setState(() {
      _isComposing = false;
      _messages.insert(0, message); //插入新的消息记录
    });
    message.animationController.forward();
    getMessage();
  }

  void getMessage() {
    ChatMessage message = new ChatMessage(
      name: "Lee",
      text: '这是模拟返回的对话数据',
      type: 1,
      width: 500,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: time),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0, message); //插入新的消息记录
    });
    message.animationController.forward();
  }

  @override
  Widget _buildTextComposer() {
    return new Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Flexible(
            child: new TextField(
              controller: _textController, //载入文本输入控件
              onSubmitted: _handleSubmitted,
              decoration:
                  new InputDecoration.collapsed(hintText: "Send a message"),
              onChanged: (String text) {
                setState(() {
                  _isComposing = text.length > 0;
                });
              },
            ),
          ),
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: new IconButton(
                //发送按钮
                icon: new Icon(Icons.send),
                onPressed: _isComposing
                    ? () => _handleSubmitted(_textController.text)
                    : null),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      //页面脚手架
      appBar: new AppBar(title: new Text("Lee")), //页面标题
      body: new Column(//Column使消息记录和消息输入框垂直排列
          children: <Widget>[
        new Flexible(
            //子控件可柔性填充，如果下方弹出输入框，使消息记录列表可适当缩小高度
            child: new ListView.builder(
          padding: new EdgeInsets.all(8.0),
          reverse: true,
          itemBuilder: (_, int index) => _messages[index],
          itemCount: _messages.length,
        )),
        new Divider(height: 1.0), //聊天记录和输入框之间的分隔
        new Container(
          decoration: new BoxDecoration(color: Theme.of(context).cardColor),
          child: _buildTextComposer(), //页面下方的文本输入控件
        ),
      ]),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage(
      {this.text, this.type, this.name, this.width, this.animationController});
  final AnimationController animationController;
  final String name;
  final String text;
  final int type;
  final double width;
  @override
  Widget buildExpanded(context) {
    return new Expanded(
        child: new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          type == 0 ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        new Text(name),
        LimitedBox(
            maxWidth: width,
            child: new Container(
              margin: const EdgeInsets.only(top: 5.0),
              padding: EdgeInsets.all(10),
              child: new Text(text),
              decoration: new BoxDecoration(
                border: new Border.all(width: 1.0, color: Colors.grey),
                color: type == 0 ? Colors.green[200] : Colors.white,
                borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
              ),
            )),
      ],
    ));
  }

  @override
  Widget buildPortrait() {
    return new Container(
      margin: type == 0
          ? const EdgeInsets.only(left: 16.0)
          : const EdgeInsets.only(right: 16.0),
      child:
          new CircleAvatar(child: new Text(name.length > 1 ? name[0] : name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(animationController),
      child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: type == 0
                  ? <Widget>[buildExpanded(context), buildPortrait()]
                  : <Widget>[buildPortrait(), buildExpanded(context)])),
    );
  }
}
