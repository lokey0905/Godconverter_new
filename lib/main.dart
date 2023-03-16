import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:seo_renderer/seo_renderer.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
      RobotDetector(
        debug: false, // you can set true to enable robot mode
        child: MaterialApp(
          builder: FToastBuilder(),
          title: "神的語言轉換器by lokey0905",
          home: MyApp(),
          navigatorKey: navigatorKey,
        ),
      )
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _selectedOption = 'Nhentai';
  TextEditingController _inputController = TextEditingController();
  String _output = '';
  late FToast fToast;

  void _convert(String input) {
    input = input.trim();

    switch (_selectedOption) {
      case 'Nhentai':
        _output = 'https://nhentai.net/g/$input';
        break;
      case 'Wnacg':
        _output = 'https://www.Wnacg.org/photos-slide-aid-$input.html';
        break;
      case '18comic':
        _output = 'https://18comic.vip/photo/$input';
        break;
      case 'Pixiv':
        _output = 'https://www.pixiv.net/artworks/$input';
        break;
      default:
        _output = '';
    }
    setState(() {});
  }

  void _openDownloadUrl() async {
    const url = 'https://lokey0905.wixsite.com/download';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _openWebUrl() async {
    const url = 'https://lokey0905.github.io/Godconverter_new/';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _openOutputUrl() async {
    if (_output.isNotEmpty) {
      if (await canLaunch(_output)) {
        await launch(_output);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    // if you want to use context from globally instead of content we need to pass navigatorKey.currentContext!
    fToast.init(context);
    _showToast('歡迎使用神的語言轉換器', duration: const Duration(seconds: 5));
  }

  void _showToast(String text, {Duration duration = const Duration(seconds: 2)}) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12.0,
          ),
          Text(text),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: duration,
    );
  }

  Future<void> _showFeedbackDialog() async {
    String? feedbackText = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('請輸入您的反饋'),
          content: TextField(
            onChanged: (value) {
              feedbackText = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: (){
                if (feedbackText != null && feedbackText!.isNotEmpty) {
                  _sendFeedback(feedbackText ?? '');
                  Navigator.pop(context);
                  _showToast('已提交反饋，感謝您的支持！請勿重複提交！', duration: const Duration(seconds: 5));
                }
              },
              child: const Text('提交'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendFeedback(String feedbackText) async {
    String platform = '';
    if (kIsWeb) {
      platform = 'WEB';
    } else {
      if (Platform.isAndroid) {
        platform = 'Android';
      } else if (Platform.isIOS) {
        platform = 'iOS';
      } else if (Platform.isLinux) {
        platform = 'Linux';
      } else if (Platform.isMacOS) {
        platform = 'Mac';
      } else if (Platform.isWindows) {
        platform = 'Windows';
      }
    }

    final String url = 'https://maker.ifttt.com/trigger/app/with/key/bInYP_q7K-R3F2RVymuvcE?value1=<br>平台:$platform<br>內容:$feedbackText';
    await http.get(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '神的語言轉換器by lokey0905',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('神的語言轉換器by lokey0905'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.feedback),
              onPressed: () {
                _showFeedbackDialog();
              },
            ),
          ],
        ),

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const TextRenderer(
                    child: Text(
                      '選擇轉換神的語言: ',
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOption = newValue!;
                        _output = '';
                      });
                    },
                    items: <String>['Nhentai', 'Wnacg', '18comic', 'Pixiv']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextField(
                    controller: _inputController,
                    onChanged: (String input) {
                      _convert(input);
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '神的語言',
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 60),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _output,
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _inputController.clear();
                          _output = '';
                        });
                        _showToast('已清除');
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _output));
                        _showToast('已複製輸出結果');
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        _showToast('此功能僅限APP版本使用');
                        Share.share(_output);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: ElevatedButton(
                        onPressed: _openOutputUrl,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const TextRenderer(
                          child: Text(
                            '在外部開啟',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: _openDownloadUrl,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const TextRenderer(
                          child: Text(
                            '下載APP',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: _openWebUrl,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const TextRenderer(
                          child: Text(
                            '開啟網頁版',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
