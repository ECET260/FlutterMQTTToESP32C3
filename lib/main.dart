import 'package:flutter/material.dart';
import 'package:mqtt/MQTTClientManager.dart';

import 'package:mqtt_client/mqtt_client.dart';
import 'constants.dart';
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter MQTT to ESP32C3',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyMQTT(title: 'Flutter MQTT to ESP32C3'),
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
//  MQTTClientManager mqttClientManager = MQTTClientManager();
  MQTTClientManager mqttClientManager =
      MQTTClientManager(mBroker: 'broker.hivemq.com');

  final String pubTopic = 'esp32c3/led';
  final String subTopic = 'esp32c3/button';
  // late dynamic client;

  double brightValue = 10.0;
  double redValue = 0.0;
  double greenValue = 0.0;
  double blueValue = 0.0;
  int bulbColor = 0x0a000000;
  String buttonString = '';
  bool newButtonStatus = false;
  String dropdownValue = 'Select a Broker';
  String incomingData = '{ "buttonStatus": false }';

  @override
  void initState() {
    //setupMqttClient();
    //setupUpdatesListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bulbColor = (255 << 24) + //was (brightValue.toInt() << 24)
        (redValue.toInt() << 16) +
        (greenValue.toInt() << 8) +
        blueValue.toInt();
    //print(bulbColor);

    //client = MqttServerClient(dropdownValue, '');

    return Scaffold(
      backgroundColor: Colors.blueGrey[600],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.white70),
                dropdownColor: Colors.blueGrey,
                underline: Container(
                  height: 2,
                  color: Colors.white70,
                ),
                onChanged: (String? newValue) async {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                  //await disconnectMQTT();
                  //client = MqttServerClient(dropdownValue, '');
                  MQTTClientManager mqttClientManager = MQTTClientManager(
                    mBroker: dropdownValue,
                  );
                  mqttClientManager.disconnect;
                  setupMqttClient();
                  setupUpdatesListener();

                  setState(() {
                    mqttClientManager.mqttConnected;
                  });
                  //await mqttClientManager.connect();
                },
                items: <String>[
                  'Select a Broker',
                  'broker.hivemq.com',
                  'test.mosquitto.org',
                  'broker.emqx.io'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: kTextValues,
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.wifi,
                  color: mqttClientManager.mqttConnected
                      ? Colors.white70
                      : Colors.black38,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'MQTT',
                  style: kTextValues,
                ),
              ),
            ],
          ),
          const Center(
            child: SizedBox(
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'WS2812',
                  style: kTextValues,
                ),
              ),
            ),
          ),
          Slider(
            value: brightValue,
            min: 0,
            max: 255,
            label: brightValue.toString(),
            thumbColor: Colors.orange,
            activeColor: Colors.orangeAccent,
            inactiveColor: Colors.grey[400],
            onChanged: (double newValue) {
              setState(() {
                brightValue = newValue;
              });
            },
            onChangeEnd: (double newValue) {
              if (mqttClientManager.mqttConnected) {
                mqttClientManager.publishMessage(pubTopic,
                    '{ "bright": ${brightValue.round()}, "red": ${redValue.round()}, "green": ${greenValue.round()}, "blue": ${blueValue.round()} }');
              }
            },
          ),
          Text(
            '0x${brightValue.round().toRadixString(16).toUpperCase().padLeft(2, '0')}',
            style: kTextValues,
          ),
          const SizedBox(
            height: 10.0,
          ),
          Slider(
            value: redValue,
            min: 0,
            max: 255,
            thumbColor: Colors.red,
            activeColor: Colors.redAccent,
            inactiveColor: Colors.grey[400],
            onChanged: (double newValue) {
              setState(() {
                redValue = newValue;
              });
            },
            onChangeEnd: (double newValue) {
              if (mqttClientManager.mqttConnected) {
                mqttClientManager.publishMessage(pubTopic,
                    '{ "bright": ${brightValue.round()}, "red": ${redValue.round()}, "green": ${greenValue.round()}, "blue": ${blueValue.round()} }');
              }
            },
          ),
          Text(
            '0x${redValue.round().toRadixString(16).toUpperCase().padLeft(2, '0')}',
            style: kTextValues,
          ),
          const SizedBox(
            height: 10.0,
          ),
          Slider(
            value: greenValue,
            min: 0,
            max: 255,
            thumbColor: Colors.green,
            activeColor: Colors.greenAccent,
            inactiveColor: Colors.grey[400],
            onChanged: (double newValue) {
              setState(() {
                greenValue = newValue;
              });
            },
            onChangeEnd: (double newValue) {
              if (mqttClientManager.mqttConnected) {
                mqttClientManager.publishMessage(pubTopic,
                    '{ "bright": ${brightValue.round()}, "red": ${redValue.round()}, "green": ${greenValue.round()}, "blue": ${blueValue.round()} }');
              }
            },
          ),
          Text(
            '0x${greenValue.round().toRadixString(16).toUpperCase().padLeft(2, '0')}',
            style: kTextValues,
          ),
          const SizedBox(
            height: 10.0,
          ),
          Slider(
            value: blueValue,
            min: 0,
            max: 255,
            thumbColor: Colors.blue,
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.grey[400],
            onChanged: (double newValue) {
              setState(() {
                blueValue = newValue;
              });
            },
            onChangeEnd: (double newValue) {
              if (mqttClientManager.mqttConnected) {
                mqttClientManager.publishMessage(pubTopic,
                    '{ "bright": ${brightValue.round()}, "red": ${redValue.round()}, "green": ${greenValue.round()}, "blue": ${blueValue.round()} }');
              }
            },
          ),
          Text(
            '0x${blueValue.round().toRadixString(16).toUpperCase().padLeft(2, '0')}',
            style: kTextValues,
          ),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * .4,
                    child: Icon(
                      Icons.lightbulb,
                      size: 40 + brightValue.toInt() / 4, //was 120.0
                      color: Color(bulbColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 15.0,
              ),
              Column(
                children: [
                  Icon(
                    newButtonStatus
                        ? Icons.radio_button_on
                        : Icons.radio_button_off,
                    size: 80.0,
                    color: Colors.white70,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    newButtonStatus.toString().toUpperCase(),
                    style: kTextValues,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> setupMqttClient() async {
    await mqttClientManager.connect();

    if (mqttClientManager.mqttConnected) {
      mqttClientManager.subscribe(subTopic);
    }
  }

  void setupUpdatesListener() {
    mqttClientManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');

      incomingData = pt;

      Map<String, dynamic> buttonStatusMap = jsonDecode(incomingData);

      //  print(buttonStatusMap);
      setState(() {
        newButtonStatus =
            buttonStatusMap['buttonStatus']; //active lo pushbutton
      });

      print(newButtonStatus);
    });
  }

  @override
  void dispose() {
    mqttClientManager.disconnect();
    super.dispose();
  }
}
