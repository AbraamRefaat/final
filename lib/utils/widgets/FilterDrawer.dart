// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/home_controller.dart';
import 'package:untitled2/Model/AllCategories.dart';
import 'package:untitled2/Model/Settings/Languages.dart';

class FilterDrawer extends StatefulWidget {
  const FilterDrawer({Key? key}) : super(key: key);

  @override
  _FilterDrawerState createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  final HomeController controller = Get.put(HomeController());

  double width = 0;
  double percentageWidth = 0;
  double height = 0;
  double percentageHeight = 0;

  Future<CategoryList>? allCategory;
  Future<CategoryList>? allSubCategory;
  Future<LevelList>? allLevel;
  Future<LanguageList>? allLanguage;

  String? selectedCategoryName;
  int? selectedCategoryId = 0;

  // String selectedSubCategoryName;
  // int selectedSubCategoryId;

  String? selectedLevelName;
  int? selectedLevelId = 0;

  String? selectedLanguageName;
  int? selectedLanguageId = 0;

  String? selectedPrice;
  String? selectedPriceParameter = '';

  List<Price> price = [
    Price("Paid"),
    Price("Free"),
  ];

  @override
  void didChangeDependencies() {
    setState(() {
      allCategory = getCategories();

      allLevel = getLevels();

      allLanguage = getLanguages();
    });

    super.didChangeDependencies();
  }

  Future<CategoryList> getCategories() async {
    try {
      Uri myAddressUrl = Uri.parse(baseUrl + '/categories');
      var response = await http.get(
        myAddressUrl,
      );
      var jsonString = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return CategoryList.fromJson(jsonString['data']);
      } else {
        Get.snackbar(
          "${stctrl.lang["Error"]}",
          jsonString['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          borderRadius: 5,
        );
        return CategoryList();
      }
    } finally {}
  }

  Future<LevelList> getLevels() async {
    try {
      Uri myAddressUrl = Uri.parse(baseUrl + '/levels');
      var response = await http.get(
        myAddressUrl,
      );
      var jsonString = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return LevelList.fromJson(jsonString['data']);
      } else {
        Get.snackbar(
          "${stctrl.lang["Error"]}",
          jsonString['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          borderRadius: 5,
        );
        return LevelList();
      }
    } finally {}
  }

  Future<LanguageList> getLanguages() async {
    try {
      Uri myAddressUrl = Uri.parse(baseUrl + '/languages');
      var response = await http.get(
        myAddressUrl,
      );
      var jsonString = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return LanguageList.fromJson(jsonString['data']);
      } else {
        Get.snackbar(
          "${stctrl.lang["Error"]}",
          jsonString['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          borderRadius: 5,
        );
        return LanguageList();
      }
    } finally {}
  }

  Widget getCategoryDropDown(List<AllCategory> category) {
    return Container(
      width: percentageWidth * 45,
      margin: EdgeInsets.only(right: 10, left: 10),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton(
            hint: Text(stctrl.lang["Select Category"] ?? 'Select Catetory'),
            elevation: 1,
            isExpanded: true,
            underline: Container(),
            items: category.map((item) {
              print(item);
              return DropdownMenuItem<String>(
                value: item.name ?? "",
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(item.name ?? ""),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCategoryName = '$value';
                selectedCategoryId =
                    getCode(category, selectedCategoryName ?? '');

                debugPrint(
                    'User select category $selectedCategoryName == $selectedCategoryId');
              });
            },
            value: selectedCategoryName,
          ),
        ),
      ),
    );
  }

  Widget getLevelDropDown(List<Level> level) {
    return Container(
      width: percentageWidth * 45,
      margin: EdgeInsets.only(right: 10, left: 10),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton(
            hint: Text(stctrl.lang["Skill Level"] ?? 'Skill Level'),
            elevation: 1,
            isExpanded: true,
            underline: Container(),
            items: level.map((item) {
              return DropdownMenuItem<String>(
                value: item.title ?? "",
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(item.title ?? ""),
                ),
              );
            }).toList(),
            onChanged: (value) {
              print("Changed value:${value}");
              setState(() {
                selectedLevelName = '$value';
                selectedLevelId = getLevelCode(level, selectedLevelName ?? '');

                debugPrint(
                    'User select Level $selectedLevelName == $selectedLevelId');
              });
            },
            value: selectedLevelName,
          ),
        ),
      ),
    );
  }

  Widget getLanguageDropDown(List<Language> language) {
    return Container(
      width: percentageWidth * 45,
      margin: EdgeInsets.only(right: 10, left: 10),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton(
            hint: Text(stctrl.lang["Select Language"] ?? 'Select Language'),
            elevation: 1,
            isExpanded: true,
            underline: Container(),
            items: language.map((item) {
              return DropdownMenuItem<String>(
                value: item.native,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(item.native.toString()),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedLanguageName = '$value';
                selectedLanguageId =
                    getLanguageCode(language, selectedLanguageName ?? '');

                debugPrint(
                    'User select Level $selectedLanguageName == $selectedLanguageId');
              });
            },
            value: selectedLanguageName,
          ),
        ),
      ),
    );
  }

  Widget getPriceDropDown(List<Price> price) {
    return Container(
      width: percentageWidth * 45,
      margin: EdgeInsets.only(right: 10, left: 10),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton(
            hint: Text(stctrl.lang["Price"] ?? 'Select Price'),
            elevation: 1,
            isExpanded: true,
            underline: Container(),
            items: price.map((item) {
              return DropdownMenuItem<String>(
                value: item.name,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(item.name),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedPrice = '$value';
                selectedPriceParameter = selectedPrice;
              });
            },
            value: selectedPrice,
          ),
        ),
      ),
    );
  }

  int? getCode<T>(List<AllCategory> t, String title) {
    int? code;
    for (var cls in t) {
      if (cls.name == title) {
        print('object ::: ');
        code = cls.id;
        break;
      }
    }
    print('CategoryCode :::: $code');
    return code;
  }

  int? getLevelCode<T>(List<Level> t, String title) {
    print(
        "Called get level code. title:$title level:${t.map((e) => e.id)}  level:${t.map((e) => e.title)}");
    int? code;
    for (var cls in t) {
      if ('${cls.title ?? cls.title}' == title) {
        code = cls.id ?? 0;
        break;
      }
    }
    return code;
  }

  int? getLanguageCode<T>(List<Language> t, String title) {
    int? code;
    for (var cls in t) {
      if (cls.native == title) {
        code = cls.id;
        break;
      }
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    percentageWidth = width / 100;
    height = MediaQuery.of(context).size.height;
    percentageHeight = height / 100;
    final HomeController homeController = Get.put(HomeController());

    return Container(
        height: percentageHeight * 100,
        width: percentageWidth * 100,
        color: Get.theme.scaffoldBackgroundColor,
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            SizedBox(
              height: 55,
            ),
            Row(
              children: [
                Container(
                    margin: EdgeInsets.only(
                      left: 30.56,
                      right: 20,
                    ),
                    alignment: Alignment.centerLeft,
                    width: 108,
                    height: 22,
                    child: Text(
                      "${stctrl.lang["Filter Courses"]}",
                      style: Get.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    )),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            FutureBuilder<CategoryList>(
              future: allCategory,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              margin: EdgeInsets.only(
                                left: 30.56,
                                right: 20,
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "${stctrl.lang["Category"]}",
                                style: Get.textTheme.titleSmall,
                                textAlign: TextAlign.center,
                              )),
                          getCategoryDropDown(snapshot.data?.categories ?? []),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: 30.56,
                              right: 20,
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "${stctrl.lang["Category"]}",
                              style: Get.textTheme.titleSmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            width: percentageWidth * 45,
                            height: percentageHeight * 6,
                            margin: EdgeInsets.only(right: 10, left: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton(
                                  elevation: 1,
                                  isExpanded: true,
                                  underline: Container(),
                                  items: null,
                                  onChanged: (value) {},
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(
              height: 20,
            ),
            FutureBuilder<LevelList>(
              future: allLevel,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          margin: EdgeInsets.only(
                            left: 30.56,
                            right: 20,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${stctrl.lang["Skill Level"]}",
                            style: Get.textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          )),
                      getLevelDropDown(snapshot.data?.levels ?? []),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          margin: EdgeInsets.only(
                            left: 30.56,
                            right: 20,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${stctrl.lang["Skill Level"]}",
                            style: Get.textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          )),
                      Container(
                        width: percentageWidth * 45,
                        height: percentageHeight * 6,
                        margin: EdgeInsets.only(right: 10, left: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton(
                              elevation: 1,
                              isExpanded: true,
                              underline: Container(),
                              items: null,
                              onChanged: (value) {},
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(
              height: 20,
            ),
            FutureBuilder<LanguageList>(
              future: allLanguage,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          margin: EdgeInsets.only(
                            left: 30.56,
                            right: 20,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${stctrl.lang["Language"]}",
                            style: Get.textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          )),
                      getLanguageDropDown(snapshot.data?.languages ?? []),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          margin: EdgeInsets.only(
                            left: 30.56,
                            right: 20,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${stctrl.lang["Language"]}",
                            style: Get.textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          )),
                      Container(
                        width: percentageWidth * 45,
                        height: percentageHeight * 6,
                        margin: EdgeInsets.only(right: 10, left: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton(
                              elevation: 1,
                              isExpanded: true,
                              underline: Container(),
                              items: null,
                              onChanged: (value) {},
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.only(
                      left: 30.56,
                      right: 20,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${stctrl.lang["Price"]}",
                      style: Get.textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    )),
                getPriceDropDown(price),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.only(top: 24.7),
                    alignment: Alignment.center,
                    width: 88,
                    height: 46,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        border: Border.all(
                            // width: .1,
                            color: Color(0xFFD7598F),
                            style: BorderStyle.none),
                        color: Color(0xFFD7598F),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    // color: Color(0xFFD7598F),
                    child: TextButton(
                      child: Text(
                        "${stctrl.lang["Reset"]}",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'AvenirNext',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFFFF)),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        homeController.filterDrawer.currentState?.openDrawer();
                        controller.allCourse.value = [];
                        controller.allCourseText.value =
                            "${stctrl.lang["All Courses"]}";
                        controller.courseFiltered.value = false;
                        controller.fetchAllCourse();
                        setState(() {
                          this.didChangeDependencies();
                        });
                      },
                    )),
                Container(
                    margin: EdgeInsets.only(left: 14.88, top: 24.7, right: 14),
                    alignment: Alignment.center,
                    width: 88,
                    height: 46,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        border: Border.all(
                            color: Get.theme.primaryColor,
                            style: BorderStyle.none),
                        color: Get.theme.primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: GestureDetector(
                      child: Text(
                        "${stctrl.lang["Apply"]}",
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        homeController.filterDrawer.currentState?.openDrawer();
                        // homeController.filterCourse(
                        //     selectedCategoryId,
                        //     selectedLevelId,
                        //     selectedLanguageId,
                        //     selectedPriceParameter);
                      },
                    )),
              ],
            ),
            SizedBox(
              height: 125,
            ),
          ],
        ));
  }
}

class Price {
  String name;
  Price(this.name);
}
