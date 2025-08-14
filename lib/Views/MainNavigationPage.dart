// Flutter imports:
import 'dart:io';

// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Package imports:

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Service/theme_service.dart';
import 'package:untitled2/Service/language_service.dart';
import 'package:untitled2/Model/Settings/Languages.dart';
import 'package:untitled2/utils/restart_app.dart';
import 'package:untitled2/Views/Account/sign_in_page.dart';
import 'package:untitled2/Views/Account/change_password.dart';
import 'package:untitled2/Views/Home/home_page.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyCourses/myCourse_page.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyQuiz/quiz_archive_page.dart';
import 'package:untitled2/Views/SettingsPage.dart';
import 'package:untitled2/Views/Account/account_page.dart';
import 'package:untitled2/utils/styles.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:untitled2/utils/widgets/connectivity_checker_widget.dart';
import 'package:untitled2/utils/responsive_helper.dart';
import 'package:octo_image/octo_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import 'Downloads/DownloadsFolder.dart';
import 'package:untitled2/Views/Home/Course/course_details_page/course_details_page.dart';

class MainNavigationPage extends StatefulWidget {
  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  // FirebaseMessaging? messaging;
  late final DashboardController dashboardController;

  bool _handledGoToCourse = false;

  @override
  void initState() {
    super.initState();
    // Ensure DashboardController is available, create if not exists
    try {
      dashboardController = Get.find<DashboardController>();
    } catch (e) {
      dashboardController = Get.put(DashboardController());
    }
    
    // Initialize Firebase Messaging if available
    // Temporarily disabled due to Firebase initialization issues
    // try {
    //   messaging = FirebaseMessaging.instance;
    // } catch (e) {
    //   print('Firebase Messaging not available: $e');
    // }
    
    // Handle goToCourseId navigation after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (!_handledGoToCourse && args != null && args['goToCourseId'] != null) {
        _handledGoToCourse = true;
        Get.to(() => CourseDetailsPage(),
            arguments: {'courseId': args['goToCourseId']});
        // Clear arguments so future taps work normally
      }
    });
  }

  List<PersistentBottomNavBarItem> items() {
    if (Platform.isIOS) {
      return [
        PersistentBottomNavBarItem(
          inactiveIcon: SvgPicture.asset(
            "images/icon_home_inactive.svg",
            color: AppStyles.bottomNavigationInActiveColor,
          ),
          icon: SvgPicture.asset(
            "images/icon_home_active.svg",
            color: AppStyles.bottomNavigationActiveColor,
          ),
          title: TranslationHelper.tr('Home'),
          activeColorPrimary: AppStyles.bottomNavigationActiveColor,
          inactiveColorPrimary: AppStyles.bottomNavigationInActiveColor,
        ),
        PersistentBottomNavBarItem(
          inactiveIcon: SvgPicture.asset(
            "images/icon_course_inactive.svg",
            color: AppStyles.bottomNavigationInActiveColor,
          ),
          icon: SvgPicture.asset(
            "images/icon_course_active.svg",
            color: AppStyles.bottomNavigationActiveColor,
          ),
          title: TranslationHelper.tr("Courses"),
          activeColorPrimary: AppStyles.bottomNavigationActiveColor,
          inactiveColorPrimary: AppStyles.bottomNavigationInActiveColor,
        ),
        PersistentBottomNavBarItem(
          inactiveIcon: SvgPicture.asset(
            "images/icon_quiz.svg",
            color: AppStyles.bottomNavigationInActiveColor,
          ),
          icon: SvgPicture.asset(
            "images/icon_quiz.svg",
            color: AppStyles.bottomNavigationActiveColor,
          ),
          title: TranslationHelper.tr("Quiz Archive"),
          activeColorPrimary: AppStyles.bottomNavigationActiveColor,
          inactiveColorPrimary: AppStyles.bottomNavigationInActiveColor,
        ),
        PersistentBottomNavBarItem(
          inactiveIcon: SvgPicture.asset(
            "images/icon_account_inactive.svg",
            color: AppStyles.bottomNavigationInActiveColor,
          ),
          icon: SvgPicture.asset(
            "images/icon_account_active.svg",
            color: AppStyles.bottomNavigationActiveColor,
          ),
          title: TranslationHelper.tr("Account"),
          activeColorPrimary: AppStyles.bottomNavigationActiveColor,
          inactiveColorPrimary: AppStyles.bottomNavigationInActiveColor,
        ),
      ];
    }
    return [
      PersistentBottomNavBarItem(
        inactiveIcon: SvgPicture.asset(
          "images/icon_home_inactive.svg",
          color: AppStyles.bottomNavigationInActiveColor,
        ),
        icon: SvgPicture.asset(
          "images/icon_home_active.svg",
          color: AppStyles.bottomNavigationActiveColor,
        ),
        title: TranslationHelper.tr('Home'),
        activeColorPrimary: AppStyles.bottomNavigationActiveColor,
        inactiveColorPrimary: AppStyles.bottomNavigationInActiveColor,
      ),
      PersistentBottomNavBarItem(
        inactiveIcon: SvgPicture.asset(
          "images/icon_course_inactive.svg",
          color: AppStyles.bottomNavigationInActiveColor,
        ),
        icon: SvgPicture.asset(
          "images/icon_course_active.svg",
          color: AppStyles.bottomNavigationActiveColor,
        ),
        title: TranslationHelper.tr("Courses"),
        activeColorPrimary: AppStyles.bottomNavigationActiveColor,
        inactiveColorPrimary: AppStyles.bottomNavigationInActiveColor,
      ),
      PersistentBottomNavBarItem(
        inactiveIcon: SvgPicture.asset(
          "images/icon_quiz.svg",
          color: AppStyles.bottomNavigationInActiveColor,
        ),
        icon: SvgPicture.asset(
          "images/icon_quiz.svg",
          color: AppStyles.bottomNavigationActiveColor,
        ),
        title: TranslationHelper.tr("Quiz Archive"),
        activeColorPrimary: AppStyles.bottomNavigationActiveColor,
        inactiveColorPrimary: AppStyles.bottomNavigationInActiveColor,
      ),
      PersistentBottomNavBarItem(
        inactiveIcon: SvgPicture.asset(
          "images/icon_account_inactive.svg",
          color: AppStyles.bottomNavigationInActiveColor,
        ),
        icon: SvgPicture.asset(
          "images/icon_account_active.svg",
          color: AppStyles.bottomNavigationActiveColor,
        ),
        title: TranslationHelper.tr("Account"),
        activeColorPrimary: AppStyles.bottomNavigationActiveColor,
        inactiveColorPrimary: AppStyles.bottomNavigationInActiveColor,
      ),
    ];
  }

  List<Widget> _screens(controller) {
    // Always check login status first and return SignInPage for protected routes if not logged in
    if (Platform.isIOS) {
      return [
        HomePage(),
        // Courses tab - always show SignInPage if not logged in
        !controller.loggedIn.value ? SignInPage() : MyCoursePage(),
        // Quiz Archive tab - always show SignInPage if not logged in
        !controller.loggedIn.value ? SignInPage() : QuizArchivePage(),
        // Account tab - show AccountPage for logged in users, SignInPage for not logged in
        !controller.loggedIn.value ? SignInPage() : AccountPage(),
      ];
    }
    return [
      HomePage(),
      // Courses tab - always show SignInPage if not logged in
      !controller.loggedIn.value ? SignInPage() : MyCoursePage(),
      // Quiz Archive tab - always show SignInPage if not logged in
      !controller.loggedIn.value ? SignInPage() : QuizArchivePage(),
      // Account tab - show AccountPage for logged in users, SignInPage for not logged in
      !controller.loggedIn.value ? SignInPage() : AccountPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.responsiveWrapper(
      context: context,
      child: ConnectionCheckerWidget(
      child: Obx(() {
        if (dashboardController.isLoading.value) {
          return Scaffold(body: Center(child: CupertinoActivityIndicator()));
        } else {
          return SafeArea(
            child: Scaffold(
              key: dashboardController.scaffoldKey,
              drawerScrimColor: Colors.black.withOpacity(0.7),
              onEndDrawerChanged: (isOpened) {
                if (!isOpened) {
                  if (!dashboardController.loggedIn.value) {
                    dashboardController.persistentTabController.jumpToTab(2);
                  } else {
                    dashboardController.persistentTabController.jumpToTab(0);
                  }
                }
              },
              endDrawer: CustomDrawer(),
              body: GestureDetector(
                onTap: () {
                  Get.focusScope?.unfocus();
                },
                child: PersistentTabView(
                  context,
                  controller: dashboardController.persistentTabController,
                  screens: _screens(dashboardController),
                  items: items(),
                  hideNavigationBar: false,
                  navBarHeight: ResponsiveHelper.isDesktop(context) ? 80 : 70,
                  margin: EdgeInsets.all(0),
                  padding: NavBarPadding.symmetric(horizontal: 5),
                  onItemSelected: dashboardController.changeTabIndex,
                  confineInSafeArea: true,
                  backgroundColor: context.theme.scaffoldBackgroundColor,
                  handleAndroidBackButtonPress: true,
                  resizeToAvoidBottomInset: true,
                  stateManagement: true,
                  hideNavigationBarWhenKeyboardShows: true,
                  decoration: NavBarDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    colorBehindNavBar: context.theme.scaffoldBackgroundColor,
                  ),
                  popAllScreensOnTapOfSelectedTab: true,
                  popActionScreens: PopActionScreensType.all,
                  itemAnimationProperties: ItemAnimationProperties(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.ease,
                  ),
                  screenTransitionAnimation: ScreenTransitionAnimation(
                    animateTabTransition: false,
                    curve: Curves.ease,
                    duration: Duration(milliseconds: 200),
                  ),
                  navBarStyle: NavBarStyle.style6,
                ),
              ),
            ),
          );
        }
      }),
    ));
  }
}

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final DashboardController dashboardController = Get.find();
  final LanguageService languageService = Get.find<LanguageService>();

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
    return Drawer(
      child: Obx(
        () => dashboardController.loggedIn.value
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(Icons.arrow_back_ios_new),
                      ),
                      Container(
                        child: Text(
                          "${TranslationHelper.tr("Account")}",
                          style: Get.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Obx(() {
                        if (dashboardController.isLoading.value) {
                          return Container();
                        } else {
                          return Container(
                            margin: EdgeInsets.only(
                              left: 20,
                              top: 20,
                              bottom: 30,
                              right: 20,
                            ),
                            child: Text(
                              dashboardController.profileData.name ?? '',
                              style: Get.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                  showDownloadsFolder
                      ? GestureDetector(
                          onTap: () async {
                            Directory applicationSupportDir =
                                await getApplicationSupportDirectory();
                            String path = applicationSupportDir.path;

                            Get.to(
                              () => DownloadsFolder(
                                filePath: path,
                                title:
                                    "${TranslationHelper.tr("My Downloads")}",
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 20,
                              top: 12.5,
                              bottom: 10,
                            ),
                            margin: EdgeInsets.only(
                              left: 20,
                              right: 30,
                              top: 5,
                              bottom: 5,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Get.theme.cardColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Get.theme.shadowColor,
                                  blurRadius: 10.0,
                                  offset: Offset(2, 3),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 6),
                                Icon(
                                  Icons.downloading_rounded,
                                  color: Get.theme.primaryColor,
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "${TranslationHelper.tr("Downloads")}",
                                  style: Get.textTheme.titleSmall,
                                ),
                                Expanded(child: Container()),
                                Icon(Icons.arrow_forward_ios, size: 16),
                                SizedBox(width: 10),
                              ],
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                  GestureDetector(
                    onTap: ThemeService().switchTheme,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 20,
                        top: 12.5,
                        bottom: 10,
                      ),
                      margin: EdgeInsets.only(
                        left: 20,
                        right: 30,
                        top: 5,
                        bottom: 5,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Get.theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Get.theme.shadowColor,
                            blurRadius: 10.0,
                            offset: Offset(2, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 6),
                          Icon(
                            Get.theme.brightness == Brightness.dark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            color: Get.theme.primaryColor,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            Get.theme.brightness == Brightness.dark
                                ? "${TranslationHelper.tr("Light Theme")}"
                                : "${TranslationHelper.tr("Dark Theme")}",
                            style: Get.textTheme.titleSmall,
                          ),
                          Expanded(child: Container()),
                          // Icon(
                          //   Icons.arrow_forward_ios,
                          //   size: 16,
                          // ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                  // Language Change Option
                  GestureDetector(
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
                                SizedBox(height: 30),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    TranslationHelper.tr("Change Language"),
                                    style: Get.textTheme.titleSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 15),
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
                                              return DropdownMenuItem<Language>(
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
                                SizedBox(height: 30),
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
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 20,
                        top: 12.5,
                        bottom: 10,
                      ),
                      margin: EdgeInsets.only(
                        left: 20,
                        right: 30,
                        top: 5,
                        bottom: 5,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Get.theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Get.theme.shadowColor,
                            blurRadius: 10.0,
                            offset: Offset(2, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 6),
                          Icon(
                            Icons.language,
                            color: Get.theme.primaryColor,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "${TranslationHelper.tr("Language")}",
                            style: Get.textTheme.titleSmall,
                          ),
                          Expanded(child: Container()),
                          Icon(Icons.arrow_forward_ios, size: 16),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),

                  // Change Password Option
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePassword(),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 20,
                        top: 12.5,
                        bottom: 10,
                      ),
                      margin: EdgeInsets.only(
                        left: 20,
                        right: 30,
                        top: 5,
                        bottom: 5,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Get.theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Get.theme.shadowColor,
                            blurRadius: 10.0,
                            offset: Offset(2, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 6),
                          Icon(
                            Icons.lock,
                            color: Get.theme.primaryColor,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "${TranslationHelper.tr("Change Password")}",
                            style: Get.textTheme.titleSmall,
                          ),
                          Expanded(child: Container()),
                          Icon(Icons.arrow_forward_ios, size: 16),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: drawerListItem(
                      "images/icon_signout.svg",
                      "${TranslationHelper.tr("Sign Out")}",
                    ),
                    onTap: () async {
                      await dashboardController.removeToken('token');
                    },
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(Icons.arrow_back_ios_new),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      "${TranslationHelper.tr("Account")}",
                      style: Get.textTheme.titleMedium,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          left: 20,
                          top: 20,
                          bottom: 30,
                          right: 20,
                        ),
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: OctoImage(
                            fit: BoxFit.cover,
                            height: 40,
                            width: 40,
                            image: AssetImage('images/fcimg.png'),
                            // placeholderBuilder: OctoPlaceholder.blurHash(
                            //   'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                            // ),
                            placeholderBuilder:
                                OctoPlaceholder.circularProgressIndicator(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      "${TranslationHelper.tr("Please Log in")}",
                      style: Get.textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: ThemeService().switchTheme,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 20,
                        top: 12.5,
                        bottom: 10,
                      ),
                      margin: EdgeInsets.only(
                        left: 20,
                        right: 30,
                        top: 5,
                        bottom: 5,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Get.theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Get.theme.shadowColor,
                            blurRadius: 10.0,
                            offset: Offset(2, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 6),
                          Icon(
                            Get.theme.brightness == Brightness.dark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            color: Get.theme.primaryColor,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            Get.theme.brightness == Brightness.dark
                                ? "${TranslationHelper.tr("Light Theme")}"
                                : "${TranslationHelper.tr("Dark Theme")}",
                            style: Get.textTheme.titleSmall,
                          ),
                          Expanded(child: Container()),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      Get.to(() => SettingsPage());
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 20,
                        top: 12.5,
                        bottom: 10,
                      ),
                      margin: EdgeInsets.only(
                        left: 20,
                        right: 30,
                        top: 5,
                        bottom: 5,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Get.theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Get.theme.shadowColor,
                            blurRadius: 10.0,
                            offset: Offset(2, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 6),
                          Icon(
                            Icons.settings,
                            color: Get.theme.primaryColor,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "${TranslationHelper.tr('Settings')}",
                            style: Get.textTheme.titleSmall,
                          ),
                          Expanded(child: Container()),
                          Icon(Icons.arrow_forward_ios, size: 16),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

Widget drawerListItem(icon, txt) {
  return Container(
    padding: EdgeInsets.only(left: 20, top: 15, bottom: 10),
    margin: EdgeInsets.only(left: 20, right: 30, top: 5, bottom: 5),
    decoration: BoxDecoration(
      color: Get.theme.cardColor,
      boxShadow: [
        BoxShadow(
          color: Get.theme.shadowColor,
          blurRadius: 10.0,
          offset: Offset(2, 3),
        ),
      ],
      borderRadius: BorderRadius.circular(5.0),
    ),
    child: Row(
      children: [
        SizedBox(width: 10),
        Container(
          height: 16,
          width: 16,
          child: SvgPicture.asset(icon, color: Get.theme.primaryColor),
        ),
        SizedBox(width: 10),
        Text(txt, style: Get.textTheme.titleSmall),
        Expanded(child: Container()),
        Icon(Icons.arrow_forward_ios, size: 16),
        SizedBox(width: 10),
      ],
    ),
  );
}
