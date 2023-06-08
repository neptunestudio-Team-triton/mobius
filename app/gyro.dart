//자이로값 보고 틀렸다 or 맞았다 체크해주는 페이지
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart' show Client;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/material.dart';
import 'Login.dart';
import 'main.dart';
import 'eversize.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:flutter_application_1/Login.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:io';

class FiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '각도 변경',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FiveAppPage(),
    );
  }
}

class FiveAppPage extends StatefulWidget {
  @override
  _FiveAppPageState createState() => _FiveAppPageState();
}

class _FiveAppPageState extends State<FiveAppPage> {

  double containerAngle = 0.0;
  TextEditingController angleController = TextEditingController();
  int _seconds = 0;
  bool _isRunning = false;
  late Timer _timer;

  String battery5value = '';
  String gyro5value = '';
  String wifi5data = '';
  String wifi3value = '';
  Timer? countdownTimer;
  Duration myDuration = Duration(days: 5);

  MQTTClientManager mqttClientManager = MQTTClientManager();
  final String pubTopic = "/oneM2M/req/ae_test/Mobius2/json";

  void _initState() {
    setupMqttClient();
    setupUpdatesListener();
    super.initState();
  }
  
  void _incrementCounter() {
    setState(() {
      mqttClientManager.publishMessage(pubTopic, '{ ""num"" : 1}');
    });
  }         

  void _batteryChange(String batteryvalue) {
    setState(() {
      battery5value = batteryvalue;
    });
  }

  void _gyroChange(String gyrovalue) {
    setState(() {
      gyro5value = gyrovalue;
    });
  }

  void _wifiName(String Wifivalue) {
    setState(() {
      wifi5data = Wifivalue;
    });
  }

  void _startTimer() {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => _setCountDown());
  }

  // Step 4
  void _stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  // Step 5
  void resetTimer() {
    _stopTimer();
    setState(() => myDuration = Duration(days: 5));
  }

  // Step 6
  void _setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds + reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  void _wifiIcons(String wifiIcondata) {
    setState(() {
      wifi3value = wifiIcondata;
    });
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    String gyroData;
    String Wifivalue;
    IconData wifiIcondata;

    //배터리값 입력받을곳(A 대신 변수받아야됨)
    if (battery5value == 'A') {
      iconData = Icons.battery_1_bar;
    } else if (battery5value == 'B') {
      iconData = Icons.battery_3_bar;
    } else if (battery5value == 'C') {
      iconData = Icons.battery_5_bar;
    } else if (battery5value == 'D') {
      iconData = Icons.battery_full;
    } else {
      iconData = Icons.battery_unknown;
    }
    //자이로값 입력받을곳(A대신 변수받아야됨)
    if (gyro5value == 'A') {
      gyroData = 'Great';
    } else if (gyro5value == 'B') {
      gyroData = 'good';
    } else {
      gyroData = 'Bad';
    }
    //와이파이 이름 변수받는곳
    if (wifi5data == 'A') {
      Wifivalue = 'A';
    } else {
      Wifivalue = 'X';
    }
    //와이파이 아이콘 변수 받는곳
    if (wifi3value == 'A') {
      wifiIcondata = Icons.network_wifi_1_bar;
    } else if (wifi3value == 'B') {
      wifiIcondata = Icons.network_wifi_3_bar;
    } else if (wifi3value == 'C') {
      wifiIcondata = Icons.signal_wifi_4_bar;
    } else {
      wifiIcondata = Icons.wifi_off;
    }

    String strDigits(int n) => n.toString().padLeft(2, '0');
    final days = strDigits(myDuration.inDays);
    final hours = strDigits(myDuration.inHours.remainder(24));
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    return Scaffold(
      appBar: AppBar(
        title: Text('Container 각도 변경'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 120,
              //정확한 값이면 초록색
              color: Colors.amber,
              child: Transform.rotate(
                angle: containerAngle * (math.pi / 180),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 5,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    Positioned(
                      top: 90,
                      child: Text(
                        '${containerAngle.toStringAsFixed(2)}°',
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 47, 105, 199)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text('A,B,C,D'),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
              Icon(
                iconData,
                size: 30,
              ),
            ]),
            TextFormField(
              onChanged: _batteryChange,
            ),
            TextFormField(
              onChanged: _gyroChange,
            ),
            Text(
              gyroData,
              style: TextStyle(fontSize: 20),
            ),
            Text('$hours:$minutes:$seconds', style: TextStyle(fontSize: 35)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              ElevatedButton(
                  onPressed: _startTimer,
                  child: Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  )),
              ElevatedButton(
                onPressed: () {
                  if (countdownTimer == null || countdownTimer!.isActive) {
                    _stopTimer();
                  }
                },
                child: Text(
                  'Stop',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    resetTimer();
                  },
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ))
            ]),
            TextFormField(
              onChanged: _wifiName,
            ),
            Text(
              Wifivalue,
              style: TextStyle(fontSize: 20),
            ),
            TextFormField(
              onChanged: _wifiIcons,
            ),
            Icon(
              wifiIcondata,
              size: 20,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> setupMqttClient() async {
    await mqttClientManager.connect();
    mqttClientManager.subscribe(pubTopic);
  }

 void setupUpdatesListener() {
    mqttClientManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      
      String decodeMessage = Utf8Decoder().convert(pt.codeUnits);

      Map<String, dynamic> parsedData = jsonDecode(decodeMessage);

      Map<String, dynamic> m2mRqp = parsedData['m2m:rqp'];

      String fr = m2mRqp['fr'];
      String to = m2mRqp['to'];
      int op = m2mRqp['op'];
      int rqi = m2mRqp['rqi'];

      Map<String, dynamic> pc = m2mRqp['pc'];

      Map<String, dynamic> m2mCnt = pc['m2m:cnt'];

      String rn = m2mCnt['rn'];
      
      print('fr: $fr');
      print('to: $to');
      print('op: $op');
      print('rqi: $rqi');
      print('rn: $rn');

      
    });
  }

  @override
  void dispose() {
    mqttClientManager.disconnect();
    super.dispose();
  }
}
