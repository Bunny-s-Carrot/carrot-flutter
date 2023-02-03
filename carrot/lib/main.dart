import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:carrot_flutter/geolocation.dart';

final InAppLocalhostServer localhostServer = InAppLocalhostServer();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await localhostServer.start();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,

  ));
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({ super.key });

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();
  
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    geolocationEnabled: true,
    javaScriptEnabled: true,
    supportZoom: false,
  );

  bool _canPop = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {



    Future<bool> onWillPop() async {
      if (_canPop) {
        return true;
      } else {
        String url = (await webViewController!.getUrl()).toString();
        bool mainPage =
            url == 'https://app.bunnyscarrot.com/home' ||
            url == 'https://app.bunnyscarrot.com/neighborhood' ||
            url == 'https://app.bunnyscarrot.com/around' ||
            url == 'https://app.bunnyscarrot.com/chat' ||
            url == 'https://app.bunnyscarrot.com/mycarrot';

        if (mainPage) {
          setState(() {
            _canPop = true;
          });
          Timer(const Duration(seconds: 2), () {
            setState(() {
              _canPop = false;
            });
          });
          Fluttertoast.showToast(
              msg: "뒤로가기를 한번 더 누르면 종료됩니다.",
              backgroundColor: Colors.black,
              textColor: Colors.white);
          return false;
        }

        bool canGoBack = await webViewController!.canGoBack();
        if (canGoBack) {
          setState(() {
            _canPop = false;
          });
          await webViewController!.goBack();
          return false;
        }
      }
      return false;
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              body: InAppWebView(
                  key: webViewKey,
                  initialUrlRequest:
                  URLRequest(url: WebUri("https://app.bunnyscarrot.com")),
                  initialSettings: settings,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onGeolocationPermissionsShowPrompt: (
                      InAppWebViewController controller, String origin) async {
                    final result = await getPermission();

                    if (result == 'always') {
                      return Future.value(
                          GeolocationPermissionShowPromptResponse(
                              origin: origin, allow: true, retain: true
                          ));
                    } else if (result == 'askEveryTime') {
                      return Future.value(
                          GeolocationPermissionShowPromptResponse(
                              origin: origin, allow: true, retain: false
                          ));
                    } else if (result == 'denied') {
                      return Future.value(
                          GeolocationPermissionShowPromptResponse(
                              origin: origin, allow: false, retain: false
                          ));
                    } else if (result == 'deniedForever') {
                      return Future.value(
                          GeolocationPermissionShowPromptResponse(
                              origin: origin, allow: false, retain: true
                          ));
                    } else {
                      return null;
                    }
                  }
              )
            );
          }
        )
      );
  }
}