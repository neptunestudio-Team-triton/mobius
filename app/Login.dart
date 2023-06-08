//로그인페이지
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mqttmain.dart';
import 'Signup.dart';
import 'main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool shouldNavigate = false;

  final storage = new FlutterSecureStorage();

  Future<void> sendDataToServer() async {
    final url = Uri.parse('https://apis.neptunestudio.one/api/triton/login');
    var emails = emailController.text;
    final password = passwordController.text;

    var res = await http.post(
      url,
      body: jsonEncode({'email': emails, 'pass': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      String jsonsDataString = res.body.toString();


      final onedata = jsonDecode(jsonsDataString);

      final superdata = onedata["result"];

      final tokendata = onedata["token"];

      final refreshdata = onedata["refresh"];

      final alldata = superdata[0];

      final iddata = alldata["id"];
      final idxdata = alldata["idx"];
      final emaildata = alldata["email"];
      final teldata = alldata["tel"];
      final passdata = alldata["pass"];
      final kgdata = alldata["kg"];
      final kiidata = alldata["kii"];

      await storage.write(key: '1', value: iddata);
      

      setState(() {
        shouldNavigate = true;
      });

    } else {
      print('서버 요청 실패: ${res.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인 페이지'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: '이메일',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: '패스워드',
              ),
              obscureText: true,
            ),
            SizedBox(
              height: 100,
            ),
            ElevatedButton(
              child: Text('로그인'),
              onPressed: () {
                final _email = emailController.text;
                final _pass = passwordController.text;

                if (_email != null && _pass != null) {
                  sendDataToServer();
                  Future.delayed(Duration(milliseconds: 500), () {

                    if (shouldNavigate) {

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    }

                  });
                }
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyAppGood()),
                );
              },
              child: const Text('회원이 아니신가요?'),
            ),
          ],
        ),
      ),
    );
  }
}