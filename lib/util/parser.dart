import 'package:house_helper/util/device.dart';

/// TODO: Handle extracting devices in a smarter way (probably just use document's rows).
///
/// Simple parser to extract data from requests.
class Parser {
  /// Returns a list of connected devices that is not this device.
  static List<OnlineDevice> listOnline(List<String> script) {
    // Holds all currently connected devices except current device.
    List<OnlineDevice> devices = [];

    // Mac address of this device.
    String ownMac;

    // Index of current line.
    int i;

    // Find this device's mac address, then loop until first device is found.
    for (i = 0; i < script.length; i++) {
      if (script[i].contains('wan_remote_mac')) ownMac = _extractString(script[i]);
      if (script[i].contains('access_control_device')) break;
    }

    // Loop through all devices.
    for (; i < script.length; i += 2) {
      if (script[i].contains('access_control_device_num') || !script[i].contains('access_control_device')) break;

      if (script[i + 1].contains('access_control_device_name')) {
        if (!script[i].contains('access_control_device')) break;
        
        var name = _extractString(script[i + 1]);

        var lineInfo = _extractString(script[i]).split('*');

        if (lineInfo[2] != ownMac) {
          devices.add(
              OnlineDevice(
                  name: name,
                  status: lineInfo[0],
                  ip: lineInfo[1],
                  mac: lineInfo[2],
                  connection: lineInfo[3],
              )
          );
        }
      }
    }

    return devices;
  }

  /// Returns the list of blocked, offline devices.
  static List<OfflineDevice> listBlockedOffline(List<String> script) {
    // Holds all blocked, offline devices.
    List<OfflineDevice> devices = [];

    // Extract all offline, blocked devices.
    for (var line in script) {
      if (line.contains('blocked_no_connect')) {
        if (line.contains('blocked_no_connect_num')) break;

        var info = _extractString(line).split(' ');
        devices.add(
            OfflineDevice(
                name: info[0],
                mac: info[1],
                connection: info[2],
            )
        );
      }
    }

    return devices;
  }

  /// Returns the timestamp of the access control page. Timestamp is required for sending
  /// requests to block or unblock both offline and online devices.
  static String extractTimestamp(document) {
    var timestamp = document.getElementsByTagName('form')[0].attributes['action'];
    return timestamp.substring(timestamp.lastIndexOf('=') + 1);
  }
      
  static String _extractString(String line) {
    return line.substring(line.indexOf('"') + 1, line.lastIndexOf('"'));
  }
}