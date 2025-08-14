// Flutter imports:
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:untitled2/Views/Account/models/facebook_responce.dart';

class SocialLoginOptions extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  AccessToken? _accessToken;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          child: Text(
            TranslationHelper.tr("Or continue with"),
            style: Get.textTheme.titleMedium?.copyWith(
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              facebookLogin
                  ? InkWell(
                      onTap: () async {
                        final LoginResult result =
                            await FacebookAuth.instance.login();

                        if (result.status == LoginStatus.success) {
                          _accessToken = result.accessToken;

                          final userData =
                              await FacebookAuth.instance.getUserData();
                          _printCredentials();

                          Map data = {
                            "provider_id": userData['id'],
                            "provider_name": "facebook",
                            "name": userData['name'],
                            "email": userData['email'],
                            "token": _accessToken?.tokenString ?? '',
                          };

                          await controller.socialLogin(data);
                        } else {
                          controller.loginMsg.value =
                              TranslationHelper.tr("Login Cancelled");
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Color(0xff969599),
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              child: Image.asset('images/facebook_logo.png'),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              TranslationHelper.tr("Facebook"),
                              style: Get.textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(
                width: 20,
              ),
              googleLogin
                  ? InkWell(
                      onTap: () async {
                        try {
                          GoogleSignInAccount? googleSignInAccount =
                              await _googleSignIn.signIn();

                          log("googleSignInAccount :::: ${googleSignInAccount?.email}");

                          await googleSignInAccount?.authentication
                              .then((value) async {
                            Map data = {
                              "provider_id": googleSignInAccount.id,
                              "provider_name": "google",
                              "name": googleSignInAccount.displayName,
                              "email": googleSignInAccount.email,
                              "token": value.idToken.toString(),
                            };

                            await controller.socialLogin(data).then((value) {
                              if (value == true) {
                                controller.isLoading(false);
                              } else {
                                _googleSignIn.signOut();
                              }
                            });
                          });
                        } catch (e, tr) {
                          controller.loginMsg.value =
                              TranslationHelper.tr("Login Cancelled");
                          log("googleSignInAccount error ---> $e ");
                          tr.printError();
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Color(0xff969599),
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              child: Image.asset('images/google_logo.png'),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              TranslationHelper.tr("Google"),
                              style: Get.textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }

  void _printCredentials() {
    print(prettyPrint(_accessToken?.toJson() ?? {}));
  }
}

String prettyPrint(Map json) {
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String pretty = encoder.convert(json);
  return pretty;
}

FacebookResponse facebookResponseFromJson(String str) =>
    FacebookResponse.fromJson(json.decode(str));

String facebookResponseToJson(FacebookResponse data) =>
    json.encode(data.toJson());
