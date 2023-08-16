import 'dart:async';
import 'dart:ui';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:io' show Platform;
// import 'package:window_size/window_size.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

import 'messages.dart';
// /import 'package:window_manager/window_manager.dart';
// import 'package:flutter_acrylic/flutter_acrylic.dart';
// import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
// import 'dart:io' show Platform;
// import 'dart:math' as math;
// import 'package:window_size/window_size.dart' as window_size;
// import 'package:flutter_acrylic/widgets/visual_effect_subview_container/visual_effect_subview_container.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';..

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;
  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

// const borderColor = Color(0xFF805306);
var mainColor = const Color(0xFF1b390e);
var darkColor = const Color(0xFF102208);
var fontColor = Colors.green.withAlpha(200);
// var mainColor = Color(0xFF38761d);
//
//1b390e

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  // setWindowTitle('Robin AI chat');
  // const minMaxWidth = 450.0;
  // setWindowMaxSize(const Size(minMaxWidth, 700));
  // setWindowMinSize(const Size(minMaxWidth, 560));
  // }
  // await windowManager.ensureInitialized();
  // WindowOptions windowOptions = const WindowOptions(
  //   size: Size(450, 700),
  //   center: true,
  //   backgroundColor: Colors.transparent,
  //   skipTaskbar: false,
  //   // titleBarStyle: TitleBarStyle.hidden,
  // );

  // // var screen_width = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  //   // var o = await windowManager.getPosition();
  //
  // });
  // await Window.initialize();
  // windowManager.setAlignment(Alignment(500.0, 500.0));
  // windowManager.setPosition(const Offset(0, 0));
  // var window = await window_size.getWindowInfo();
  // if (window.screen != null) {
  //   final screenFrame = window.screen?.visibleFrame;
  //   final width = 400.0;
  //   final height = 600.0;
  //   final left = ((screenFrame!.width - width) / 2).roundToDouble();
  //   final top = ((screenFrame.height - height) / 3).roundToDouble();
  //   final frame = Rect.fromLTWH(left, top, width, height);
  //   window_size.setWindowFrame(frame);
  //   window_size.setWindowMinSize(Size(1.0 * width, 1.0 * height));
  //   window_size.setWindowMaxSize(Size(1.0 * width, 1.0 * height));
  // }
  runApp(
    MaterialApp(
        theme: ThemeData(
          primarySwatch: createMaterialColor(mainColor),
        ),
        debugShowCheckedModeBanner: false,
        home: const MyApp()),
  );

  // FlutterView view = PlatformDispatcher.instance.views.first;
  // double physicalWidth = view.physicalSize.width;
  // double physicalHeight = view.physicalSize.height;
  // double devicePixelRatio = view.devicePixelRatio;
  // double screenWidth = physicalWidth / devicePixelRatio;
  // double screenHeight = physicalHeight / devicePixelRatio;

  // var screen_width = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
  // Size screenSize = WidgetsBinding.instance.window.physicalSize;
  // var screen_width = screenSize.width;
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(400, 450);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.bottomRight;
    var left = 1550.0;
    var top = 300.0;
    win.position = Offset(left, top);
    win.title = "Robin Client";
    // win .position(Offset(500,500));
    win.show();
    win.position = Offset(left, top);
  });

  // await Window.setEffect(
  //   effect: WindowEffect.transparent, color: Color(0xCC222222),
  // );
  // windowManager.waitUntilReadyToShow().then((_) async{
  // await windowManager.setAlignment(Alignment(500.0, 500.0));
  // await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  // await windowManager.setAsFrameless();
  // await windowManager.setPosition(const Offset(560, 500));
  // });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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

  void _scrollDown() {
    if (_controller.hasClients) {
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        _controller.animateTo(
          _controller.position.maxScrollExtent * 1.8,
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
        );
      });
    }
  }

  // Localhost for android - 10.0.2.2
  // Localhost for iOS - 127.0.0.1
  final IOWebSocketChannel channel =
      IOWebSocketChannel.connect(Uri.parse('ws://127.0.0.1:8765'));

  var userInput;
  List<ChatMessage> messages = <ChatMessage>[];

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  send2WebSocket() {
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
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          WindowTitleBarBox(
            child: Row(
              children: [Expanded(child: MoveWindow()), const WindowButtons()],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                T? cast<T>(x) => x is T ? x : null;
                if (!snapshot.hasError &&
                    snapshot.connectionState == ConnectionState.active &&
                    snapshot.hasData) {
                  if (messages.length > 1) {
                    if (messages
                            .elementAt(messages.length - 2)
                            .messageContent !=
                        snapshot.data) {
                messages.add(ChatMessage(
                    messageContent: snapshot.data,
                    messageType: 'receiver'));
                    }
                  } else {
                    messages.add(ChatMessage(
                        messageContent: snapshot.data,
                        messageType: 'receiver'));
                  }
                  _scrollDown();
                  // windowManager.setPosition(Offset(500.0, 500.0));
                  return ListView.builder(
                      controller: _controller,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 10, left: 25, right: 25),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return messages[index].messageType == 'receiver'
                            ? ChatBubble(
                                clipper: ChatBubbleClipper5(
                                    type: BubbleType.sendBubble),
                                alignment: Alignment.topRight,
                                margin: EdgeInsets.only(top: 20),
                                backGroundColor: mainColor,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  child: Text(
                                    messages[index].messageContent,
                                    style: TextStyle(
                                        fontSize: 15, color: fontColor),
                                  ),
                                ),
                              )
                            : ChatBubble(
                                clipper: ChatBubbleClipper5(
                                    type: BubbleType.receiverBubble),
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(top: 20),
                                backGroundColor: darkColor,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  child: Text(
                                    messages[index].messageContent,
                                    style: TextStyle(color: fontColor),
                                  ),
                                ),
                              );
                        // Container(
                        //   padding: const EdgeInsets.only(
                        //       left: 16, right: 16, top: 10, bottom: 10),
                        //   child: Align(
                        //     alignment: messages[index].messageType == "receiver"
                        //         ? Alignment.topLeft
                        //         : Alignment.topRight,
                        //     child: Container(
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(20),
                        //         color: messages[index].messageType == "receiver"
                        //             ? darkColor
                        //             : Colors.black,
                        //         // fontColor.withAlpha(350)
                        //         border:
                        //             messages[index].messageType == "receiver"
                        //                 ? Border.all(
                        //                     color: Colors.blueAccent,
                        //                     style: BorderStyle.none,
                        //                   )
                        //                 : Border.all(
                        //                     color: mainColor,
                        //                     style: BorderStyle.solid,
                        //                     width: 2,
                        //                   ),
                        //       ),
                        //       padding: const EdgeInsets.all(25),
                        //       child: Text(
                        //
                        //         style: TextStyle(
                        //             fontSize: 16,
                        //             color: messages[index].messageType ==
                        //                     "receiver"
                        //                 ? fontColor
                        //                 : fontColor.withAlpha(250)),
                        //       ),
                        //     ),
                        //   ),
                        // );
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
                width: 8,
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
              SizedBox(
                width: 10,
              ),
            ],
          ),
          SizedBox(
            width: 10,
            height: 10,
          ),
        ],
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: fontColor, //const Color(0xFF805306),
    mouseOver: mainColor,
    mouseDown: Colors.white, //const Color(0xFF805306),
    iconMouseOver: Colors.white,// const Color(0xFF805306),
    iconMouseDown: mainColor);

final closeButtonColors = WindowButtonColors(
    mouseOver: darkColor,
    mouseDown: darkColor,
    iconNormal: fontColor, //const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  _WindowButtonsState createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        appWindow.isMaximized
            ? RestoreWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              )
            : MaximizeWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              ),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
