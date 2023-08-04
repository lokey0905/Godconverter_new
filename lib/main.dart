import 'dart:math';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart';
import 'package:nhentai/before_request_add_cookies.dart';
import 'package:nhentai/nhentai.dart';
import 'package:seo_renderer/seo_renderer.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/pages/robot_check.dart';
import 'package:untitled/routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/src/widgets/image.dart' as prefix;
import 'package:nhentai/nhentai.dart' as nh;

import 'dart:io' show Cookie, Platform;

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
  final TextEditingController _inputController = TextEditingController();
  String intput = '';
  String _output = '';
  bool showCover = false;
  String Cover='';
  String bookImformation='';
  late FToast fToast;

  static final _defaultLightColorScheme =
  ColorScheme.fromSwatch(primarySwatch: Colors.blue);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue, brightness: Brightness.dark);


  Future<void> _convert(String input) async {
    input = input.trim();
    switch (_selectedOption) {
      case 'N站 nhentai':
        _output = 'https://nhentai.net/g/$input';
        break;
      case 'W站 紳士漫畫 wnacg':
        _output = 'https://www.wnacg.com/photos-slide-aid-$input.html';
        break;
      case 'JM 禁漫 18comic':
        _output = 'https://18comic.vip/photo/$input';
        break;
      case 'P站 Pixiv':
        _output = 'https://www.pixiv.net/artworks/$input';
        break;
      default:
        _output = '';
    }
    setState(() {});
  }

  Future<void> _cover(String input) async {
    input = input.trim();
    String bookName='';
    String Artists='';
    String Languages='';
    String pageNumber = '';
    switch (_selectedOption) {
      case 'N站 nhentai':
        if(!kIsWeb){
          if (Platform.isAndroid || Platform.isIOS) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NotARobotView()));

            final prefs = await SharedPreferences.getInstance();

            final userAgent = prefs.getString('userAgent') ?? '';
            final cfClearance = prefs.getString('Cookies') ?? '';

            final api = nh.API(
              userAgent: userAgent,
              beforeRequest: beforeRequestAddCookiesStatic([
                Cookie('cf_clearance', cfClearance),
              ]),
            );

            final nh.Book book = await api.getBook(int.parse(intput));

            Cover= book.cover.getUrl(api: api).toString();
            bookName=book.title.pretty;
            pageNumber = book.pages.length.toString();
            Artists=book.tags.artists.join(', ');
            Languages=book.tags.languages.join(', ');
          }
        }
        else{
          bookName=('因N網禁止機器人 無法獲取預覽圖 可使用手機預覽');
          Cover='https://pbs.twimg.com/profile_images/733172726731415552/8P68F-_I_400x400.jpg';
        }
        break;

      case 'W站 紳士漫畫 wnacg':
        Cover = 'https://mz4.qy0.ru/data/${input.substring(0, 4)}/${input.substring(4, 6)}/01.jpg';
        if(!kIsWeb){
          final response = await http.get(Uri.parse("https://www.wnacg.com/photos-index-aid-214438.html"));
          if (response.statusCode == 200) {
            var document = parse(response.body);
            Languages = document.querySelector('.asTBcell.uwconn label')!.text;
            pageNumber = document.querySelector('.asTBcell.uwconn label+label')!.text;
            bookName = document.querySelector('.userwrap h2')?.text ?? '';
            print(bookName);
          }
          else {
            throw Exception('Request failed with status code ${response.statusCode}');
          }
        }
        Artists='';
        break;

      case 'JM 禁漫 18comic':
        if(kIsWeb) {
          Cover = 'https://cdn-msp.jmcomic.me/media/albums/$input.jpg';
        } else{
          List<String> url=[
            '18comic.vip',
            '18comic.org',
            'jmcomic.me',
            'jmcomic1.me'];
          for(int i=0;i<url.length;i++){
            final response = await http.get(Uri.parse("https://${url[i]}/album/$input"));
            if (response.statusCode == 200) {
              Cover = 'https://cdn-msp.${url[i]}/media/albums/$input.jpg';
              final document = parse(response.body);
              bookName = document.querySelector('#book-name')!.text;
              break;
            }
            else if(response.statusCode == 403){
              if (kDebugMode) {
                print('找不到此本本子$i');
              }
            }
            else {
              throw Exception('Request failed with status code ${response.statusCode}');
            }
          }
        }
        Artists='';
        Languages = '';
        break;

      case 'P站 Pixiv':
        Cover = 'https://embed.pixiv.net/decorate.php?illust_id=$input';
        break;

      default:
        Cover = '';
    }
    showCover=true;
    if(kIsWeb) {
      bookImformation="網頁預覽只能預覽圖片 下載APP可預覽其他資訊";
    } else {
      bookImformation=bookName +
        (Artists!='' ? "\n作者:$Artists" : '') +
        (Languages!='' ? "\n語言:$Languages" : '')+
        (pageNumber!='' ? "\n頁數:$pageNumber" : '');
    }
    setState(() {});
  }

  void _openUrl(url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openDownloadUrl() async {
    const url = 'https://lokey0905.wixsite.com/download';
    _openUrl(url);
  }

  void _openWebUrl() async {
    const url = 'https://lokey0905.github.io/Godconverter_new/';
    _openUrl(url);
  }

  void _openOutputUrl() async {
    if (_output.isNotEmpty) {
      _openUrl(_output);
    }
  }

  void _openGithubUrl() async {
    const url = 'https://github.com/lokey0905/Godconverter_new';
    _openUrl(url);
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
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: '神的語言轉換器by lokey0905',
        theme: ThemeData(
          colorScheme: lightColorScheme ?? _defaultLightColorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
          useMaterial3: true,
        ),
        routes: routes,
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
          body: SingleChildScrollView(
            child: Center(
              child: Padding( // 增加邊距
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * (orientation == 'Orientation.portrait' ? 0.9 : 0.6),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          elevation: 10,// 陰影大小
                          child: Column (
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              DropdownButton<String>(
                              value: _selectedOption,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedOption = newValue!;
                                    //_output = '';
                                    _convert(_inputController.text);
                                  });
                                },
                                items: <String>[
                                  'N站 nhentai',
                                  'W站 紳士漫畫 wnacg',
                                  'JM 禁漫 18comic',
                                  'P站 Pixiv'
                                ]
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: _inputController,
                                      keyboardType: TextInputType.number,
                                      onChanged: (String input) {
                                        _convert(input);
                                        intput = input;
                                      },
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '神的語言',
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      style: const TextStyle(fontSize: 54),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Column (
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _inputController.clear();
                                            _output = '';
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.shuffle),
                                        onPressed: () {
                                          _inputController.text = Random().nextInt(999999).toString();
                                          _convert(_inputController.text);
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ]
                          ),
                        ),
                      )
                    ),

                    const SizedBox(width: 16),

                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: SizedBox(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width *
                            (orientation == 'Orientation.portrait' ? 0.9 : 0.6),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          elevation: 10,// 阴影大小
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            //crossAxisAlignment:CrossAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                //crossAxisAlignment:CrossAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(_output,
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Column (
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: _output));
                                          _showToast('已複製輸出結果');
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.share),
                                        onPressed: () {
                                          if(!kIsWeb){
                                            if (Platform.isAndroid || Platform.isIOS) {
                                              Share.share(_output);
                                            }
                                          }
                                          else{
                                            _showToast('此功能僅限APP版本使用');
                                          };
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  const SizedBox(width: 8),
                                  /*Offstage(
                                    offstage: true,
                                    child: Flexible(
                                      flex: 3,
                                      child: ElevatedButton(
                                        onPressed: _openOutputUrl,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const TextRenderer(
                                          child: Column(
                                            children: <Widget>[
                                              Icon(Icons.visibility),
                                              Text(
                                                '閱讀',
                                                style: TextStyle(fontSize: 18),
                                                textAlign: TextAlign.center
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),*/
                                  //const SizedBox(width: 8),
                                  Flexible(
                                    flex: 3,
                                    child: ElevatedButton(
                                      onPressed:() async {
                                        showCover=false;
                                        _cover(intput);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const TextRenderer(
                                        child: Column(
                                          children: <Widget>[
                                            Icon(Icons.preview),
                                            Text(
                                              '預覽',
                                              style: TextStyle(fontSize: 18),
                                              textAlign: TextAlign.center
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    flex: 3,
                                    child: ElevatedButton(
                                      onPressed: _openOutputUrl,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const TextRenderer(
                                        child: Column(
                                          children: <Widget>[
                                            Icon(Icons.open_in_new),
                                            Text(
                                              '跳轉',
                                              style: TextStyle(fontSize: 18),
                                              textAlign: TextAlign.center
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                              const Padding(padding: EdgeInsets.all(8.0)),
                              Offstage(
                                offstage: !showCover,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * (orientation == 'Orientation.portrait' ? 0.7 : 0.4),
                                  child:Column(
                                    children: <Widget>[
                                      Text(
                                        bookImformation,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      prefix.Image.network(Cover),
                                      const Padding(padding: EdgeInsets.all(8.0)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const SizedBox(width: 16),
                          Flexible(
                            child: ElevatedButton(
                              onPressed: _openDownloadUrl,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
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
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const TextRenderer(
                                child: Text(
                                  '網頁版',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: ElevatedButton(
                              onPressed: _openGithubUrl,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const TextRenderer(
                                child: Text(
                                  '原始碼',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
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
    });
  }
}
