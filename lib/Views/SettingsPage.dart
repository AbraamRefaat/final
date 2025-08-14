// Dart imports:

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Package imports:

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Service/language_service.dart';
import 'package:untitled2/utils/restart_app.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:untitled2/utils/widgets/AppBarWidget.dart';

import '../Model/Settings/Languages.dart';
import '../Views/Account/change_password.dart';

// ignore: must_be_immutable
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DashboardController dashboardController =
      Get.put(DashboardController());
  final LanguageService languageService = Get.find<LanguageService>();

  bool active = true;

  final box = GetStorage();

  List<Language> _languages = [];
  Language? _tempSelectedLanguage;

  @override
  void initState() {
    super.initState();
    _initLanguages();
  }

  Future<void> _initLanguages() async {
    final languages = await languageService.getAllLanguages();
    if (languages != null &&
        languages.languages != null &&
        languages.languages!.isNotEmpty) {
      _languages = List<Language>.from(languages.languages!);
      _tempSelectedLanguage = _languages.firstWhere(
        (p0) => p0.code == languageService.code.value,
        orElse: () => _languages.first,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        appBar: AppBarWidget(
          showSearch: false,
          goToSearch: false,
          showFilterBtn: false,
          showBack: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              dashboardController.loggedIn.value
                  ? ListTile(
                      onTap: () async {
                        Get.bottomSheet(
                          Material(
                            child: Container(
                              height: Get.height * 0.4,
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        TranslationHelper.tr("Change Language"),
                                        style: Get.textTheme.titleSmall,
                                        textAlign: TextAlign.center,
                                      )),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: ButtonTheme(
                                        alignedDropdown: true,
                                        child: StatefulBuilder(
                                          builder: (BuildContext context,
                                              StateSetter setState) {
                                            return DropdownButton(
                                              elevation: 1,
                                              isExpanded: true,
                                              underline: Container(),
                                              items: _languages.map((item) {
                                                return DropdownMenuItem<
                                                    Language>(
                                                  value: item,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(
                                                        item.native.toString()),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (Language? value) {
                                                setState(() {
                                                  _tempSelectedLanguage = value;
                                                });
                                              },
                                              value: _tempSelectedLanguage,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_tempSelectedLanguage != null) {
                                        Navigator.pop(context);
                                        await languageService.setLanguage(
                                            langCode:
                                                _tempSelectedLanguage!.code);
                                        RestartApp.restartApp(context);
                                      }
                                    },
                                    child: Text(
                                      TranslationHelper.tr("Confirm"),
                                      style: Get.textTheme.titleSmall
                                          ?.copyWith(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      leading: Icon(Icons.language),
                      title: Text(TranslationHelper.tr("Language")),
                    )
                  : SizedBox.shrink(),
              dashboardController.loggedIn.value
                  ? ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangePassword(),
                            ));
                      },
                      leading: Icon(Icons.lock),
                      title: Text(TranslationHelper.tr("Change Password")),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
