import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClientManager {
  final String mBroker;
  static String myString = 'broker.emqx.io';
  late MqttServerClient client;

  bool mqttConnected = false;

  MQTTClientManager({required this.mBroker}) {
    myString = mBroker;
    print('Current Broker is  $myString');
  }

  Future<int> connect() async {
    client = MqttServerClient.withPort(
        myString, 'mobile_client', 1883); //'broker.emqx.io'

    client.logging(on: true);
    client.keepAlivePeriod = 60;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMessage =
        MqttConnectMessage().startClean().withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      print('MQTTClient::Client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('MQTTClient::Socket exception - $e');
      client.disconnect();
    }

    return 0;
  }

  void onConnected() {
    print('MQTTClient::Connected');
    mqttConnected = true;
  }

  void onDisconnected() {
    print('MQTTClient::Disconnected');
    mqttConnected = false;
  }

  void onSubscribed(String topic) {
    print('MQTTClient::Subscribed to topic: $topic');
  }

  void pong() {
    print('MQTTClient::Ping response received');
  }

  void disconnect() {
    client.disconnect();
  }

  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atLeastOnce);
  }

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    if (mqttConnected) {
      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    }
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>>? getMessagesStream() {
    return client.updates;
  }
}
