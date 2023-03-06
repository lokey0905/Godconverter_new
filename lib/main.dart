import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _selectedOption = 'Nenhai';
  TextEditingController _inputController = TextEditingController();
  String _output = '';

  void _convert(String input) {
    input = input.trim();

    switch (_selectedOption) {
      case 'Nenhai':
        _output = 'https://nhentai.net/g/$input';
        break;
      case 'wnacg':
        _output = 'https://www.wnacg.org/photos-slide-aid-$input.html';
        break;
      case '18comic':
        _output = 'https://18comic.vip/photo/$input';
        break;
      case 'pivix':
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
    const url = 'https://github.com/your_github_repo';
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '神的語言轉換器',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('神的語言轉換器'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<String>(
                value: _selectedOption,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedOption = newValue!;
                    _output = '';
                  });
                },
                items: <String>['Nenhai', 'wnacg', '18comic', 'pivix']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
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
                width: MediaQuery.of(context).size.width * 0.8,
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
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _output));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已複製輸出結果')),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
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
                          '開啟外部瀏覽器',
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
