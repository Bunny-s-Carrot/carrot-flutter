import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';


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

  void requestPermission() async {
    Map<Permission, PermissionStatus> statuses =
    await [Permission.location].request();
  }

  InAppWebViewController? webViewController;

  InAppWebViewSettings settings = InAppWebViewSettings(
    geolocationEnabled: true,
    useShouldOverrideUrlLoading: true,
    javaScriptEnabled: true,
    supportZoom: false,
  );

  @override
  void initState() {
    super.initState();

    requestPermission();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: InAppWebView(
            key: webViewKey,
            initialUrlRequest:
            URLRequest(url: WebUri("https://app.bunnyscarrot.com")),
            initialSettings: settings,
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onGeolocationPermissionsShowPrompt: (InAppWebViewController controller, String origin) async {
              bool result = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Allow access location $origin'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('Allow access location $origin'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Allow'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                        TextButton(
                          child: Text('Denied'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                      ],
                    );
                  });

              if (result) {
                return Future.value(GeolocationPermissionShowPromptResponse(
                  origin: origin, allow: true, retain: true
                ));
              } else {
                return Future.value(GeolocationPermissionShowPromptResponse(
                    origin: origin, allow: false, retain: false
                ));
              }
            },
        )
      )
    );
  }
}