// TODO: Find command for sorting this.
import 'dart:convert';
import 'package:http/http.dart';
import 'package:house_helper/constants/private.dart';
import 'package:html/parser.dart';
import 'package:house_helper/util/device.dart';
import 'package:html/dom.dart';
import 'package:house_helper/util/request.dart';
import 'package:house_helper/util/parser.dart';
import 'package:house_helper/constants/blocked.dart';

// TODO: Simplify code.
class Network {  
  // The authentication token
  static String _authToken;

  // The basic authentication for the admin.
  static String _auth = 'Basic ' + base64Encode(utf8.encode('$USERNAME:$PASSWORD'));

  // Route to obtain device 
  final String _deviceAccessRoute = 'http://192.168.1.1/AccessControl_show.htm';

  /// Block users who are in the list of banned mac addresses, names, and IP addresses.
  void blockUsers() async {
    Response response = await Req.getPage(_deviceAccessRoute, _auth, _authToken);
    
    Document document = parse(response.body);
    
    List<String> script = document.getElementById('main').getElementsByTagName('script')[0].innerHtml.split('\n');

    List<OnlineDevice> devices = Parser.listOnline(script);
    
    // Timestamp is required for making a post request to access control.
    String timestamp = Parser.extractTimestamp(document);

    Map<String,String> postBody = generateBlockBody(devices);

    Map<String,String> headers = {'Authorization': _auth};

    if (_authToken != null) headers['Cookie'] = _authToken;

    Req.postAccessControl(timestamp, postBody, headers);
  }

  /// Create the post body block information.
  Map<String,String> generateBlockBody(List<OnlineDevice> devices) {
    Map<String,String> postBody = {
      'submit_flag': 'acc_control_block',
    };

    String changeList = '';

    int count = 0;

    Map<String,String> fakeChecks = Map<String,String>();

    for (var device in devices) {
      if (BANNED_MACS.contains(device.mac.toUpperCase()) || BANNED_NAMES.contains(device.name.toUpperCase()) || BANNED_IPS.contains(device.ip)) {
        count++;
        changeList += device.mac + '#';
        fakeChecks['check_device' + count.toString()] = device.mac;
      }
    }

    postBody['hidden_change_list'] = changeList;
    postBody['hidden_change_num'] = count.toString();
    postBody.addAll(fakeChecks);

    return postBody;
  }

  void unblockUsers() async {
    Response response = await Req.getPage(_deviceAccessRoute, _auth, _authToken);
    
    Document document = parse(response.body);
    
    List<String> script = document.getElementById('main').getElementsByTagName('script')[0].innerHtml.split('\n');

    List<OnlineDevice> devices = Parser.listOnline(script);
    
    // Timestamp is required for making a post request to access control.
    String timestamp = Parser.extractTimestamp(document);

    Map<String,String> postBody = generateUnblockConnected(devices);

    Map<String,String> headers = {'Authorization': _auth};

    if (_authToken != null) headers['Cookie'] = _authToken;

    await Req.postAccessControl(timestamp, postBody, headers);

    response = await Req.getPage(_deviceAccessRoute, _auth, _authToken);

    document = parse(response.body);

    script = document.getElementById('main').getElementsByTagName('script')[0].innerHtml.split('\n');

    List<OfflineDevice> offlineDevices = Parser.listBlockedOffline(script);

    generateUnblockOffline(offlineDevices);

    await Req.postAccessControl(timestamp, postBody, headers);
  }

  /// Create the post body to unblock connected users.
  Map<String,String> generateUnblockConnected(List<OnlineDevice> devices) {
    Map<String,String> postBody = {
      'submit_flag': 'acc_control_allow',
    };

    String changeList = '';

    int count = 0;

    Map<String,String> fakeChecks = Map<String,String>();

    for (var device in devices) {
      if (device.status == 'Blocked') {
        count++;
        changeList += device.mac + '#';
        fakeChecks['check_device' + count.toString()] = device.mac;
      }
    }

    postBody['hidden_change_list'] = changeList;
    postBody['hidden_change_num'] = count.toString();
    postBody.addAll(fakeChecks);

    return postBody;
  }

  /// Create the post body to unblock offline devices.
  Map<String,String> generateUnblockOffline(List<OfflineDevice> devices) {
    Map<String,String> postBody = {
      'submit_flag': 'acc_control_allow',
    };

    String changeList = '';

    int count = 0;

    Map<String,String> fakeChecks = Map<String,String>();

    for (var device in devices) {
      fakeChecks['block_not_connect' + count.toString()] = device.mac;
      count++;
      changeList += device.mac + '#';
    }

    postBody['hidden_del_list'] = changeList;
    postBody['hidden_del_num'] = count.toString();
    postBody.addAll(fakeChecks);

    return postBody;
  }
}