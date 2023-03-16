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
  String _selectedOption = 'N站 nhentai';
  TextEditingController _inputController = TextEditingController();
  String _output = '';
  List<String> _imageUrls = ['https://icons.veryicon.com/png/o/commerce-shopping/soft-designer-online-tools-icon/delete-77.png'];
  late FToast fToast;
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _convert(String input) {
    input = input.trim();
    switch (_selectedOption) {
      case 'N站 nhentai':
        _output = 'https://nhentai.net/g/$input';
        break;
      case 'W站 紳士漫畫 wnacg':
        _output = 'https://www.wnacg.org/photos-slide-aid-$input.html';
        if (input.length > 5) {
          _imageUrls = ['https://img4.qy0.ru/data/${input.substring(0, 4)}/${input.substring(4, 6)}/00A.jpg'];
        }
        break;
      case 'JM 禁漫 18comic':
        _output = 'https://18comic.vip/photo/$input';
        _imageUrls = ['https://cdn-msp.18comic.org/media/albums/$input.jpg'];
        break;
      case 'P站 Pixiv':
        _output = 'https://www.pixiv.net/artworks/$input';
        _imageUrls = ['https://embed.pixiv.net/decorate.php?illust_id=$input'];
        break;
      default:
        _output = '';
        _imageUrls = ['https://icons.veryicon.com/png/o/commerce-shopping/soft-designer-online-tools-icon/delete-77.png'];
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
    final orientation = MediaQuery.of(context).orientation.toString();
    return MaterialApp(
      title: '神的語言轉換器by lokey0905',
      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('神的語言轉換器by lokey0905'),
          actions: <Widget>[
            Switch(
              value: _isDarkMode,
              onChanged: (value) {
                _toggleTheme();
              },
            ),
            IconButton(
              icon: const Icon(Icons.feedback),
              onPressed: () {
                _showFeedbackDialog();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding( // 增加邊距
              padding: const EdgeInsets.all(16.0),
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
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _selectedOption,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedOption = newValue!;
                            //_output = '';
                            _convert(_inputController.text);
                          });
                        },
                        items: <String>['N站 nhentai', 'W站 紳士漫畫 wnacg', 'JM 禁漫 18comic', 'P站 Pixiv']
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
                      width: MediaQuery.of(context).size.width * (orientation=='Orientation.portrait'?0.9:0.6),
                      child: TextField(
                        controller: _inputController,
                        onChanged: (String input) {
                          _convert(input);
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '神的語言',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16), // 增加內部間距
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(fontSize: 60),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * (orientation=='Orientation.portrait'?0.9:0.6),
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
                        const SizedBox(width: 16),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () {
                              _showToast('因N網禁止機器人 無法獲取預覽圖');
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.network(_imageUrls[0]),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                // 關閉對話框
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const TextRenderer(
                              child: Text(
                                '預覽縮圖',
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
        ),
      ),
    );
  }
}
