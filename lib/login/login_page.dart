import 'package:flutter/material.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';

typedef MainRouter = void Function(int value);

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.switchMainRouter}) : super(key: key);

  final MainRouter switchMainRouter;

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  //static const String clientId = 'SjUvT9xx-DqV9ig65JTCmA';
  //static const String clientSecret = 'ra2dL8KdqufMIiPXfRnMnHeVk0NJCw';
  static const String clientId = 'PVEFd7uKmnLKgvlq040c7w';
  static const String clientSecret = 'rUPBHGyJxjpxc4FD6OWj_1yGmxmDHg';
  static const String scope =
      'identity+read+account+mysubreddits+subscribe+vote+save+history';
  final LocalStorage storage = LocalStorage('user');

  bool isOnApi = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  Future<void> requestToken(String url) async {
    var uri = Uri.parse(url);
    var urlAccess = Uri.parse('https://www.reddit.com/api/v1/access_token');
    String code = '';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret'));

    uri.queryParameters.forEach((k, v) async {
      if (k == "code") {
        code = v;
        debugPrint('Code for token = $code');
        final response = await post(urlAccess, body: {
          'redirect_uri': 'https://www.google.com',
          'grant_type': 'authorization_code',
          'code': code,
        }, headers: <String, String>{
          'authorization': basicAuth
        });
        print(response.statusCode);
        final parsedJson = jsonDecode(response.body);
        print('Token : ${parsedJson['access_token']}');
        storage.setItem('token', parsedJson['access_token']);
        widget.switchMainRouter(1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isOnApi) {
      return WebView(
        initialUrl:
            'https://www.reddit.com/api/v1/authorize.compact?client_id=$clientId&response_type=code&redirect_uri=https://www.google.com&duration=temporary&scope=$scope&state=code_authorize',
        onProgress: (int progress) {
          debugPrint("WebView is loading (progress : $progress%)");
        },
        onPageFinished: (String url) async {
          await requestToken(url);
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        elevation: 0,
        title: const Text(
          "Login",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
          child: Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height / 2 - 380),
        child: Column(
          children: [
            Container(
              width: 350.0,
              height: 350.0,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/Redditech.png'),
                    fit: BoxFit.fill),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 100,
              height: 60.0,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    isOnApi = true;
                  });
                },
                style: OutlinedButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    side: const BorderSide(width: 1.0, color: Colors.black)),
                child: const Text('Login on reddit',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
