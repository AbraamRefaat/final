import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:untitled2/Config/app_config.dart';

Future generateVdoCipherOtp(url) async {
  Uri apiUrl = Uri.parse('https://dev.vdocipher.com/api/videos/$url/otp');

  var response = await http.post(
    apiUrl,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Apisecret $vdoCipherApiKey'
    },
  );

  var decoded = jsonDecode(response.body);
  return decoded;
}
