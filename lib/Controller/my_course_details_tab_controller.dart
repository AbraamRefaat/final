// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

class MyCourseDetailsTabController extends GetxController
    with GetTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    Tab(
      child: Container(
        padding: const EdgeInsets.only(left: 12.0, right: 12),
        child: Text("Curriculum"),
      ),
    ),
  ];

  TabController? controller;

  @override
  void onInit() {
    super.onInit();
    controller = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void onClose() {
    controller?.dispose();
    super.onClose();
  }
}
