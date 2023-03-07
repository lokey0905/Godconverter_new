import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

void main() {
  runApp(MaterialApp(title: "神的語言轉換器",home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _selectedOption = 'Nhentai';
  TextEditingController _inputController = TextEditingController();
  String _output = '';

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
      case 'Pivix':
        _output = 'https://www.pixiv.net/artworks/$input';
        break;
      default:
        _output = '';
    }
    setState(() {});
  }

  void _openDownloadUrl() async {
    const url = 'https://github.com/your_github_repo';
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

  Future<void> _showFeedbackDialog() async {
    String? feedbackText = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('請輸入您的反饋'),
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
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (feedbackText != null && feedbackText!.isNotEmpty) {
                  await _sendFeedback(feedbackText!);
                }
                Navigator.pop(context);
              },
              child: Text('提交'),
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
      title: '神的語言轉換器',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('神的語言轉換器'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.feedback),
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
                  Text('選擇轉換神的語言: '),
                  DropdownButton<String>(
                    value: _selectedOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOption = newValue!;
                        _output = '';
                      });
                    },
                    items: <String>['Nhentai', 'Wnacg', '18comic', 'Pivix']
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
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _output));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已複製輸出結果')),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
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
                        child: const Text(
                          '在外部開啟',
                          style: TextStyle(fontSize: 14),
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
                        child: const Text(
                          '下載APP',
                          style: TextStyle(fontSize: 14),
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
                        child: const Text(
                          '開啟網頁版',
                          style: TextStyle(fontSize: 14),
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
