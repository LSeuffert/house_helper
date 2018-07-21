import 'package:flutter/foundation.dart';

/// [OnlineDevice] holds the state of an online device.
class OnlineDevice {
  // The name of the device.
  final String name;

  // Whether the device is blocked or allowed.
  final String status;

  // The ip of the device.
  final String ip;

  // The mac address of the device.
  final String mac;

  // Whether the device is connected via ethernet, 2.4 ghz channel, or 5 ghz channel.
  final String connection;

  // The [name], [status], [ip], [mac], and [connection] arguments must not be null.
  OnlineDevice({
    @required this.name,
    @required this.status,
    @required this.ip,
    @required this.mac,
    @required this.connection,
  }) : assert(name != null),
       assert(status != null),
       assert(ip != null),
       assert(mac != null),
       assert(connection != null);
}

/// [OfflineDevice] holds the state of a blocked, offline device.
class OfflineDevice {
  // The name of the device.
  final String name;

  // The mac address of the device.
  final String mac;

  // Whether the device is connected via ethernet, 2.4 ghz channel, or 5 ghz channel.
  final String connection;

  // The [name], [mac], and [connection] arguments must not be null.
  OfflineDevice({
    @required this.name,
    @required this.mac,
    @required this.connection,
  }) : assert(name != null),
       assert(mac != null),
       assert(connection != null);
}