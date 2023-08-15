import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:io' show Platform;
import 'package:window_size/window_size.dart';
// import 'package:window_manager/window_manager.dart';
// import 'package:flutter_acrylic/flutter_acrylic.dart';
// import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:flutter_acrylic/widgets/visual_effect_subview_container/visual_effect_subview_container.dart';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;
  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO( r + ((ds < 0 ? r : (255 - r)) * ds).round(), g + ((ds < 0 ? g : (255 - g)) * ds).round(), b + ((ds < 0 ? b : (255 - b)) * ds).round(), 1, ); });
  return MaterialColor(color.value, swatch);
}

// const borderColor = Color(0xFF805306);
var mainColor = Color(0xFF1b390e);
var darkColor = Color(0xFF102208);
var fontColor = Colors.green.withAlpha(200);
// var mainColor = Color(0xFF38761d);
//
//1b390e

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Robin AI chat');
    const minmaxWidth = 500.0;
    setWindowMaxSize(const Size(minmaxWidth, 800));
    setWindowMinSize(const Size(minmaxWidth, 600));
  }
  // await Window.initialize();
  runApp(
    MaterialApp(
        theme: ThemeData( primarySwatch: createMaterialColor(mainColor), ),
        home: MyApp()
    ),
  );

  // doWhenWindowReady(() {
    // const initialSize = Size(600, 450);
    // appWindow.minSize = initialSize;
    // appWindow.size = initialSize;
    // appWindow.alignment = Alignment.center;
    // appWindow.show();
  //   final win = appWindow;
  //   const initialSize = Size(500, 450);
  //   win.minSize = initialSize;
  //   win.size = initialSize;
  //   win.alignment = Alignment.centerLeft;
  //   win.title = "Custom window with Flutter";
  //   win.show();
  // });

  // await Window.setEffect(
  //   effect: WindowEffect.transparent, color: Color(0xCC222222),
  // );
  // windowManager.waitUntilReadyToShow().then((_) async{
  //   // await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  //   // await windowManager.setAsFrameless();
  // });
}

class ChatMessage {
  String messageContent;
  String messageType;

  ChatMessage({required this.messageContent, required this.messageType});
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ScrollController _controller = ScrollController();
  final fieldText = TextEditingController();

  void clearText() {
    fieldText.clear();
  }

  late final FocusNode myFocusNode;

  @override
  void initState() {
    myFocusNode = FocusNode();
    super.initState();
  }

// This is what you're looking for!
  void _scrollDown() {
    // Timer(Duration(milliseconds: 500), () { _controller.jumpTo(_controller.position.maxScrollExtent); });
    // _controller.jumpTo(_controller.position.maxScrollExtent*1.8);
    if (_controller.hasClients) {
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        _controller.animateTo(
          _controller.position.maxScrollExtent * 1.8,
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
        );
      });
    }
    // _controller.animateTo(
    //   _controller.position.maxScrollExtent,
    //   duration: Duration(seconds: 2),
    //   curve: Curves.fastOutSlowIn,
    // );
  }

  // Localhost for android - 10.0.2.2
  // Localhost for iOS - 127.0.0.1
  final IOWebSocketChannel channel =
      IOWebSocketChannel.connect(Uri.parse('ws://127.0.0.1:8765'));
  //IOWebSocketChannel.connect( Uri.parse('ws://192.168.0.104:6785'));
  // connect('ws://127.0.0.1:6785');

  var userInput;
  List<ChatMessage> messages = <ChatMessage>[];

  // @override
  // void initState(){
  //   super.initState();
  //   channel.stream.listen((message){
  //     print(message);
  //     setState(() { messages.add(message); });
  //   },
  //   onDone: () {
  //
  //   },
  // );}

  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  send2WebSocket() {
    // print("send to websocket: $userInput");
    channel.sink.add(userInput);
  }

  void submitMessage(String value) {
    setState(() {
       messages.add(ChatMessage(messageContent: value, messageType: 'me'));
    });
    userInput = value;
    myFocusNode.requestFocus();
    send2WebSocket();
    clearText();
    _scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: const Text("Robin Chat"),
      // ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                // The data is being pulled from the websocket
                // _scrollDown();
                  if (!snapshot.hasError && snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
                    // print(snapshot.data);
                    if (messages.length > 1) {
                      if (messages.elementAt(messages.length - 2).messageContent != snapshot.data) {
                        messages.add(ChatMessage(
                            messageContent: snapshot.data,
                            messageType: 'receiver'));
                      }}
                    else
                      messages.add(ChatMessage(
                          messageContent: snapshot.data,
                          messageType: 'receiver'));
                  return ListView.builder(
                      controller: _controller,
                      // reverse: true,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 10, bottom: 10),
                          child: Align(
                            alignment: messages[index].messageType == "receiver"
                                ? Alignment.topLeft
                                : Alignment.topRight,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color:
                                      messages[index].messageType == "receiver"
                                          ? darkColor
                                          : fontColor.withAlpha(350)),
                              padding: const EdgeInsets.all(25),
                              child: Text(
                                messages[index].messageContent,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: messages[index].messageType == "receiver"
                                        ? fontColor
                                        : fontColor.withAlpha(250)
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                } else {
                  return const Center(
                      child: Text('No messages yet, start typing...'));
                }
              },
            ),
          ),
          Row(
            children: <Widget>[
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  controller: fieldText,
                  style: TextStyle(color: fontColor),
                  autofocus: true,
                  focusNode: myFocusNode,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    hintStyle: TextStyle(color: Colors.grey[700]),
                    hintText: "Write message...",
                  ),
                  // hintStyle: TextStyle(color: Colors.black54),
                  // border: InputBorder.none),
                  onChanged: (value) => userInput = value,
                  onSubmitted: (value) => submitMessage(value),
                  textInputAction: TextInputAction.go,
                ),
              ),
              const SizedBox(
                width: 1,
              ),
              FloatingActionButton(
                onPressed: () {
                  submitMessage(fieldText.value.text);
                },
                child: const Icon(
                  Icons.send,
                  color: Colors.lightGreenAccent,
                  size: 18,
                ),
                backgroundColor: mainColor,
                elevation: 0,
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
