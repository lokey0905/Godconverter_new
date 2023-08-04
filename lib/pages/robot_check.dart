import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NotARobotView extends StatefulWidget {
  const NotARobotView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(
    builder: (context) => const NotARobotView(),
  );

  @override
  State<NotARobotView> createState() => _NotARobotViewState();
}

class _NotARobotViewState extends State<NotARobotView> {
  late WebViewController controller;
  Map<String, dynamic>? arguments;
  bool _initialized = true;

  @override
  void initState() {
    super.initState();
    // Retrieve the arguments in the addPostFrameCallback callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      setState(() {
        _initialized = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        // Placeholder widget while waiting for initialization to complete
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final clearData = false;

    String? userAgent;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..runJavaScriptReturningResult('navigator.userAgent').then((currentUserAgent) {
        userAgent = currentUserAgent.toString().replaceAll('"','');
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) async {
            if (clearData) {
              final WebViewCookieManager cookieManager = WebViewCookieManager();
              await cookieManager.clearCookies();
            }
          },
          onUrlChange: (change) async {
            if (change.url == "https://nhentai.net/") {
              final realCookieManager = WebviewCookieManager();
              final gotCookies = await realCookieManager.getCookies("https://nhentai.net/");

              final prefs = await SharedPreferences.getInstance();

              print("Got user agent: $userAgent");
              print("Got cookies: $gotCookies");

              prefs.setString("userAgent", userAgent!);

              for (var cookie in (gotCookies ?? [])) {
                prefs.setString("Cookies", cookie.value);
                print("Got cookies: ${cookie.value}");
                break;
              }

              if (userAgent == null || userAgent == 'null' || gotCookies.toString() == '[]') {
                debugPrint("Could not save user data");
                return;
              }

              (() => Navigator.pop(context))();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://nhentai.net/'));

    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}