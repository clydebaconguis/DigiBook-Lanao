// import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CallApi {
  // DLCES RESOURCES
  final String _ckIpv4 = 'https://lms.smsaccess.net/';

  //DLCES DOMAINS
  // final String _domain = 'https://hsa.cklms.ph/api/'; - done
  // final String _domain = 'https://ica.cklms.ph/api/'; - done
  // final String _domain = 'https://saa.cklms.ph/api/'; - done
  // final String _domain = 'https://sja.cklms.ph/api/'; - done
  final String _domain = 'https://sjid.cklms.ph/api/';
  // final String _domain = 'https://sjhs.cklms.ph/api/'; - done
  // final String _domain = 'https://sla.cklms.ph/api/'; - done
  // final String _domain = 'https://saa-bacarra.cklms.ph/api/'; - done
  // final String _domain = 'https://sags.cklms.ph/api/';  - done
  // final String _domain = 'https://sjohs.cklms.ph/api/'; - done
  // final String _domain = 'https://sna.cklms.ph/api/'; - done
  // final String _domain = 'https://sra.cklms.ph/api/'; - done
  // final String _domain = 'https://sjec.cklms.ph/api/'; - done
  // final String _domain = 'https://sgs.cklms.ph/api/'; - done
  // final String _domain = 'https://ses.cklms.ph/api/'; - done

  // LDCU DOMAIN
  // final String _ckIpv4 = 'https://app.cklms.ph/'; - done
  // final String _domain = 'https://app.cklms.ph/api/';

  getHost() {
    // var domain = await _loadSavedDomainName();
    // return '$domain/';
    return _ckIpv4;
  }

  getDomain() {
    return _domain;
  }

  // postData(data, apiUrl) async {
  // var fullUrl = _ckIpv4 + apiUrl;
  // return await http.post(Uri.parse(fullUrl),
  //     body: jsonEncode(data), headers: _setHeaders());
  // }

  // login(data, apiUrl) async {
  //   // var domain = await _loadSavedDomainName();
  //   // if (domain.isNotEmpty) {
  //   //   var fullUrl = '$domain/api/$apiUrl';
  //   //   return await http.post(Uri.parse(fullUrl),
  //   //       body: jsonEncode(data), headers: _setHeaders());
  //   // }
  //   var fullUrl = '$_domain$apiUrl';
  //   return await http.post(
  //     Uri.parse(fullUrl),
  //     body: jsonEncode(data),
  //   );
  // }

  login(data, apiUrl) async {
    // var token = await getToken();
    // var fullUrl =
    //     '$_domain$apiUrl?email=${data['email']}&password=${data['password']}';
    var fullUrl = '$_domain$apiUrl';
    return await http.post(Uri.parse(fullUrl), body: data);
  }

  // getData(apiUrl) async {
  //   var fullUrl = _ckIpv4 + apiUrl + await _getToken();
  //   return await http.get(Uri.parse(fullUrl), headers: _setHeaders());
  // }

  // _setHeaders() => {
  //       'Content-type': 'application/json',
  //       'Accept': 'application/json',
  //     };

  getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    return '?token=$token';
  }

  getPublicData(apiUrl) async {
    // var domain = await _loadSavedDomainName();
    // var fullUrl = '$domain/api/$apiUrl';
    var fullUrl = '$_domain$apiUrl';
    return await http.get(Uri.parse(fullUrl));
  }
}
