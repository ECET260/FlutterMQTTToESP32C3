import 'package:flutter/material.dart';
import 'package:mqtt/MQTTClientManager.dart';

import 'package:mqtt_client/mqtt_client.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyMQTT(title: "ECET260 - Lab11"),
    );
  }
}

class MyMQTT extends StatefulWidget {
  const MyMQTT({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyMQTT> createState() => _MyMQTTState();
}

class _MyMQTTState extends State<MyMQTT> {
  int _counter = 0;
  MQTTClientManager mqttClientManager = MQTTClientManager();
  final String pubTopic = "test/counter";

  @override
  void initState() {
    setupMqttClient();
    setupUpdatesListener();
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      mqttClientManager.publishMessage(
          pubTopic, "Increment button pushed ${_counter.toString()} times.");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Flexible(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
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
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
    });
  }

  @override
  void dispose() {
    mqttClientManager.disconnect();
    super.dispose();
  }
}
