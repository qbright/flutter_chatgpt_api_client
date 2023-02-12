import 'package:example/api_key.dart';
import 'package:flutter/material.dart';
import 'package:chatgpt_api_client/chatgpt_api_client.dart';

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
        primarySwatch: Colors.blue,
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
  int listCounter = 3;
  ChatGptApiClient client =
      ChatGptApiClient(api_key, ChatGptModelOption(stream: false));

  TextEditingController textController = TextEditingController();

  void _incrementCounter() {
    // api_key.dart is ignore to commit , just a string for the openai apikey
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.grey.shade100,
                child: ListView.builder(
                  reverse: true,
                  itemCount: listCounter,
                  itemBuilder: (context, index) {
                    return Container(
                      child: Text('$index \n adfasd\n\ndfasdf'),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              alignment: Alignment.bottomLeft,
              height: 60,
              color: Colors.green,
              child: Row(children: [
                SizedBox(
                    width: 300,
                    child: TextField(
                      style: const TextStyle(fontSize: 20),
                      controller: textController,
                    )),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    String text = textController.text;
                    textController.clear();
                    client.sendMessage(text,
                        onData: (ChatGptApiResponse response) {
                      print('rrrrrrrrrr');
                      print(response);
                    });
                    // print(textController.text);
                  },
                )
              ]),
            ),
            // Positioned(
            //   child: Row(children: [Text('23'), Text('444')]),
            //   bottom: 0,
            //   left: 0,
            // )
          ],
        ),
      ),
    );
  }
}
