import 'package:flutter/material.dart';
// import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer';

onBackgroundMessage(SmsMessage message) async {
  print(message.address); //+977981******67, sender nubmer
  print(message.body); //sms text
  print(message.date); //1659690242000, timestamp
  String text = splitMoneyNumbers(message.body.toString());
  await sendMessage(text);
}

String splitMoneyNumbers(String string) {
  String convertString =
      string.replaceFirst('GIAM ', '-').replaceFirst('TANG ', '+');
  final splitted = convertString.split(' ');
  List<String> numbers = [];

  for (String item in splitted) {
    if (item.contains(',')) {
      numbers.add(item);
    }
  }
  String firstMoney = numbers[1];
  String totalMoney = numbers[2];
  var startIndex = string.lastIndexOf('(') + 1;
  var endIndex = string.lastIndexOf(')');
  String description = string.substring(startIndex, endIndex);
  String text =
      'Biến động: $firstMoney\nSố dư: $totalMoney\nNội dung: $description\nNgân hàng: Test';

  return text;
}

Future<void> sendMessage(text) async {
  // Create the URL for the POST request.
  final url = Uri.parse(
      'https://api.telegram.org/bot6403871579:AAG4dYo2azVir4xRfW0s1ZxfTO9YXH2n6xg/sendMessage');

  // Create the body of the POST request.
  final body = jsonEncode({
    'chat_id': -1001921764223,
    'text': text,
  });

  // Make the POST request.
  final response = await http.post(
    url,
    body: body,
    headers: {'Content-Type': 'application/json'},
  );

  // Check the status code of the response.
  if (response.statusCode == 200) {
    // The message was sent successfully.
    print('Message sent successfully.');
  } else {
    // There was an error sending the message.
    print('Error sending message: ${response.statusCode}');
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String sms = "";
  Telephony telephony = Telephony.instance;

  @override
  initState() {
    telephony.listenIncomingSms(
      onNewMessage: onBackgroundMessage,
      listenInBackground: true,
      onBackgroundMessage: onBackgroundMessage,
    );
    super.initState();
    // fetchSms();
  }

  void testSendMessage() {
    String string =
        "TK 41344480001 NGAY 06/10/22 08:46 SD DAU 21,694,456 TANG 20,000,000 SD CUOI 41,694,456 VND (MONEY AND FAME)";
    String text = splitMoneyNumbers(string);
    sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // const Text(
            //   'Click button to test send message to telegram',
            // ),
            const Text(
              'Link join telegram to receive notification about money in banking',
              textAlign: TextAlign.center,
            ),
            InkWell(
              onTap: () =>
                  launchUrl(Uri.parse('https://t.me/+FNNg8jg7g_E3N2I1'), mode: LaunchMode.externalApplication),
              child: const Text(
                'https://t.me/+FNNg8jg7g_E3N2I1',
                style: TextStyle(
                    decoration: TextDecoration.underline, color: Colors.blue, decorationColor: Colors.blue),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: testSendMessage,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
