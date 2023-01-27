import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carrot_flutter/geolocation.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    return SafeArea(
        child: InAppWebView(
          key: webViewKey,
          initialUrlRequest:
          URLRequest(url: WebUri("https://app.bunnyscarrot.com")),
          initialSettings: settings,
          onWebViewCreated: (controller) {
            webViewController = controller;
            controller.addJavaScriptHandler(
                handlerName: 'OpenMap',
                callback: (args) async {
                  print(args);

                  return {

                  };
                });
            },
          onGeolocationPermissionsShowPrompt: (InAppWebViewController controller, String origin) async {
            final result = await getPermission();

            if (result == 'always') {
              return Future.value(GeolocationPermissionShowPromptResponse(
                  origin: origin, allow: true, retain: true
              ));
            } else if (result == 'askEveryTime') {
              return Future.value(GeolocationPermissionShowPromptResponse(
                  origin: origin, allow: true, retain: false
              ));
            } else if (result == 'denied') {
              return Future.value(GeolocationPermissionShowPromptResponse(
                  origin: origin, allow: false, retain: false
              ));
            } else if (result == 'deniedForever') {
              return Future.value(GeolocationPermissionShowPromptResponse(
                  origin: origin, allow: false, retain: true
              ));
            }
          },
        ),
    );
  }
}