import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';

/// Deals with requests
class Req {
  // The post route for blocking and unblocking both offline and online devices.
  static String _accessControlRoute = 'http://192.168.1.1/apply.cgi?/access_control.htm%20timestamp=';
  
  static bool _busy = false;

  /// TODO: Simplify code.
  /// TODO: Add timeout.
  ///
  /// Returns the response to a get request.
  static Future<Response> getPage(String route, String basicAuth, String authToken) async {
    if (_busy) return null;
    
    _busy = true;
    
    Response response;
    
    Map<String,String> headers = {'Authorization': basicAuth};

    bool multiLogin = false;

    bool needStatus = true;

    Response multiPage;

    if (authToken != null) headers['Cookie'] = authToken;

    Stopwatch stopwatch = Stopwatch();

    stopwatch.start();

    // Make the request but try to follow through with the request.
    while (multiLogin || needStatus) {
      if (multiPage != null && multiPage.statusCode == 200) multiLogin = false;
      
      if (response != null) await Future.delayed(const Duration(seconds: 5));

      response = await get(
          route,
          headers: headers,
      );

      if (response.contentLength < 120 && response.body.contains('multi_login.html')) {
        multiLogin = true;
        
        while (multiPage == null || multiPage.statusCode != 200) {
          await Future.delayed(const Duration(seconds: 5));

          multiPage = await get('http://192.168.1.1/change_user.html', headers: headers);
        }

        if (authToken == null && multiPage.headers.containsKey('set-cookie')) {
          authToken = multiPage.headers['set-cookie'];

          headers['Cookie'] = authToken;
        }
      } else {
        multiLogin = false;

        if (response.statusCode == 200) needStatus = false;
      }
    }

    _busy = false;
    
    return response;
  }

  /// Applies a post request to block or allow an offline or online device.
  ///
  /// 'submit_flag': ('acc_control_block', 'acc_control_allow', 'delete_acc')
  static Future<bool> postAccessControl(String timestamp, Map<String,String> blockAllowBody, Map<String,String> headers) async {
    if (_busy) return false;

    _busy = true;
    
    final String route = _accessControlRoute + timestamp;
    
    Map<String,String> postBody = {
      'hid_able_block_device': '',
      'hid_new_device_status': '',
      'hid_allow_no_connect_sta': '',
      'hid_block_no_connect_sta': 'show',
      'hidden_del_list': '',
      'hidden_del_num': '0',
      'hidden_change_list': '',
      'hidden_change_num': '0',
      'block_enable': '1',
      'allow_or_block': 'Allow',
    };

    postBody.addAll(blockAllowBody);

    Response response = await post(route, headers: headers, body: postBody, encoding: AsciiCodec());

    _busy = false;
    
    if (response.statusCode == 200 && !response.body.contains('multi_login.html')) {
      return true;
    }

    return false;
  }
}