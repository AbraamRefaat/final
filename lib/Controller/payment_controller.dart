// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Controller/myCourse_controller.dart';
import 'package:untitled2/Model/Settings/Country.dart';
import 'package:untitled2/Model/User/MyAddress.dart';
import 'package:untitled2/Service/RemoteService.dart';

import 'quiz_controller.dart';

class PaymentController extends GetxController {
  final MyCourseController myCourseController = Get.put(MyCourseController());

  final DashboardController dashboardController =
      Get.put(DashboardController());

  final QuizController quizController =
      Get.find<QuizController>(); // Use find instead of put

  RxString paymentAmount = "".obs;

  var trackingId = "".obs;

  var isLoading = false.obs;

  var isCountryLoading = false.obs;

  var isCityLoading = false.obs;

  var tokenKey = "token";
  GetStorage userToken = GetStorage();

  // ignore: deprecated_member_use
  List<MyAddress> myAddress = <MyAddress>[].obs;

  var country = CountryList().obs;

  var city = CountryList().obs;

  var billingAddress = "".obs;
  var oldBilling = 0.obs;
  var firstName = "".obs;
  var lastName = "".obs;
  var countryName = "".obs;
  var cityName = "".obs;
  var address1 = "".obs;
  var phone = "".obs;
  var email = "".obs;
  var tracking = "".obs;
  var zipCode = "".obs;
  var getCountry = Country().obs;

  var countryId = 0.obs;
  var cityId = 0.obs;
  var stateId = 0.obs;

  var isPaymentLoading = false.obs;
  var paymentList = [].obs;

  var selectedGateway = "".obs;

  TextEditingController? firstNameController = TextEditingController();
  TextEditingController? lastNameController = TextEditingController();
  TextEditingController? addressController = TextEditingController();
  TextEditingController? phoneController = TextEditingController();
  TextEditingController? emailController = TextEditingController();

  @override
  void onInit() {
    getMyAddress();
    getPaymentList();
    // firstNameController = TextEditingController();
    // lastNameController = TextEditingController();
    // addressController = TextEditingController();
    // phoneController = TextEditingController();
    // emailController = TextEditingController();

    super.onInit();
  }

  setProfileData() {
    String fullName = dashboardController.profileData.name ?? '';

    List<String> nameParts = fullName.trim().split(' ');

    if (nameParts.isNotEmpty) {
      String firstName = nameParts.sublist(0, nameParts.length - 1).join(' ');

      firstNameController!.text = firstName;
      lastNameController!.text = nameParts.length > 1 ? nameParts.last : '';
    } else {
      firstNameController!.text = '';
      lastNameController!.text = '';
    }

    emailController!.text = dashboardController.profileData.email ?? '';
    phoneController!.text = dashboardController.profileData.phone ?? '';
    print(
        "payment controller-- user name is :${dashboardController.profileData.firstName ?? "null"} ");
  }

  Future<List<MyAddress>?> getMyAddress() async {
    String token = await userToken.read(tokenKey);
    try {
      isLoading(true);
      Uri myAddressUrl = Uri.parse(baseUrl + '/my-billing-address');
      var response = await http.get(
        myAddressUrl,
        headers: header(token: token),
      );
      var jsonString = jsonDecode(response.body);
      if (response.statusCode == 200) {
        myAddress = myAddressFromJson(jsonEncode(jsonString['data']));
        if (myAddress.length > 0) {
          tracking.value = myAddress[0].trackingId ?? '';
          firstName.value = myAddress[0].firstName ?? '';
          lastName.value = myAddress[0].lastName ?? '';
          countryName.value = myAddress[0].country?.name ?? '';
          cityName.value = myAddress[0].city ?? '';
          address1.value = myAddress[0].address1 ?? '';
          zipCode.value = myAddress[0].zipCode ?? '';
          email.value = myAddress[0].email ?? '';
          getCountry.value = myAddress[0].country ?? Country();
          phone.value = myAddress[0].phone ?? '';
          oldBilling.value = myAddress[0].id;
          billingAddress.value = "previous";
        }
        return myAddress;
      } else {
        Get.snackbar(
          "${stctrl.lang["Error"]}",
          jsonString['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          borderRadius: 5,
        );
        return null;
      }
    } finally {
      isLoading(false);
    }
  }

  Future makeOrderNew() async {
    String token = await userToken.read(tokenKey);
    try {
      isLoading(true);

      var postUri = Uri.parse(baseUrl + '/make-order');

      var body = jsonEncode({
        'tracking_id': trackingId.value,
        'billing_address': "new",
        'old_billing': "0",
        'first_name': firstNameController?.text ?? '',
        'last_name': lastNameController?.text ?? '',
        'country': countryId.value.toString(),
        'city': cityId.value.toString(),
        'state': stateId.value.toString(),
        'address1': addressController?.text ?? '',
        'phone': phoneController?.text ?? '',
        'email': emailController?.text ?? ''
      });

      var response = await http.post(
        postUri,
        headers: header(token: token),
        body: body,
      );

      var jsonString = jsonDecode(response.body);
      if (response.statusCode == 200) {
        email.value = emailController?.text ?? '';

        if (jsonString['type'] == 'Free') {
          myCourseController.myCourses.value = [];
          myCourseController.fetchMyCourse();
          Future.delayed(Duration(seconds: 2), () {
            Get.back();
            dashboardController.changeTabIndex(2);
            Get.snackbar(
              "${stctrl.lang["Done"]}",
              jsonString['message'].toString(),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.primaryColor,
              colorText: Colors.white,
              borderRadius: 5,
            );
          }).then((value) async {
            dashboardController.changeTabIndex(2);
            myCourseController.myCourses.clear();
            await myCourseController.fetchMyCourse();

            quizController.allMyQuiz.clear();
            await quizController.fetchAllMyQuiz();
          });
        } else {
          Get.snackbar(
            "${stctrl.lang["Done"]}",
            jsonString['message'].toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.primaryColor,
            colorText: Colors.white,
            borderRadius: 5,
          );
          Future.delayed(Duration(seconds: 4), () {
            getPaymentList();
          });
        }
      } else {
        Get.snackbar(
          "${stctrl.lang["Failed"]}",
          jsonString['message'].toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          borderRadius: 5,
        );
      }
    } finally {
      isLoading(false);
    }
  }

  Future makeOrderOld() async {
    String token = await userToken.read(tokenKey);
    try {
      isLoading(true);

      var postUri = Uri.parse(baseUrl + '/make-order');

      var body = jsonEncode({
        'tracking_id': tracking.value,
        'billing_address': "previous",
        'old_billing': oldBilling.value.toString()
      });

      var response = await http.post(
        postUri,
        headers: header(token: token),
        body: body,
      );

      var jsonString = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonString['type'] == 'Free') {
          myCourseController.myCourses.value = [];
          myCourseController.fetchMyCourse();
          Future.delayed(Duration(seconds: 2), () {
            Get.back();
            dashboardController.changeTabIndex(2);
            Get.snackbar(
              "${stctrl.lang["Done"]}",
              jsonString['message'].toString(),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.primaryColor,
              colorText: Colors.white,
              borderRadius: 5,
            );
          }).then((value) async {
            myCourseController.myCourses.clear();
            await myCourseController.fetchMyCourse();

            quizController.allMyQuiz.clear();
            await quizController.fetchAllMyQuiz();
          });
        } else {
          Get.snackbar(
            "${stctrl.lang["Done"]}",
            jsonString['message'].toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.primaryColor,
            colorText: Colors.white,
            borderRadius: 5,
          );
          Future.delayed(Duration(seconds: 4), () {
            getPaymentList();
          });
        }
      } else {
        Get.snackbar(
          "${stctrl.lang["Failed"]}",
          jsonString['message'].toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          borderRadius: 5,
        );
      }
    } finally {
      isLoading(false);
    }
  }

  Future makePayment(gatewayName, Map resp) async {
    String token = await userToken.read(tokenKey);
    try {
      isLoading(true);
      var postUri = Uri.parse(baseUrl + '/make-payment/$gatewayName');

      var body = jsonEncode({'response': resp.toString()});

      var response = await http.post(
        postUri,
        headers: header(token: token),
        body: body,
      );

      var jsonString = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonString['success'] == true) {
        myCourseController.myCourses.value = [];
        myCourseController.fetchMyCourse();
        Future.delayed(Duration(seconds: 2), () {
          Get.back();
          Get.back();
          dashboardController.changeTabIndex(2);
          Get.snackbar(
            "${stctrl.lang["Done"]}",
            jsonString['message'].toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.primaryColor,
            colorText: Colors.white,
            borderRadius: 5,
          );
        }).then((value) async {
          dashboardController.changeTabIndex(2);
          myCourseController.myCourses.clear();
          await myCourseController.fetchMyCourse();

          quizController.allMyQuiz.clear();
          await quizController.fetchAllMyQuiz();
        });
      } else {
        Get.snackbar(
          "${stctrl.lang["Failed"]}",
          jsonString['message'].toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          borderRadius: 5,
        );
      }
    } finally {
      isLoading(false);
      Get.back();
    }
  }

  void getPaymentList() async {
    try {
      isPaymentLoading(true);
      var payment = await RemoteServices.getPaymentList();
      if (payment != null) {
        paymentList.value = payment;
        // for(int i = 0; i < paymentList.length; i++){
        //   if(paymentList[i].method == 'PayTM'){
        //     paymentList.removeAt(i);
        //   }
        // }
        selectedGateway.value = paymentList[0].method;
      }
    } finally {
      isPaymentLoading(false);
    }
  }

  void getCadList(message) async {
    if (message == 'success') {
      Get.snackbar(
        "Thank you",
        "Payment success",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
        borderRadius: 5,
        duration: Duration(seconds: 5),
      );
      await makePayment('Sslcommerz', {});
    } else if (message == 'failed') {
      Get.snackbar(
        "Oops",
        "Payment failed",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
        borderRadius: 5,
        duration: Duration(seconds: 5),
      );
    } else if (message == 'cancel') {
      Get.snackbar(
        "Oops",
        "Payment failed",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
        borderRadius: 5,
        duration: Duration(seconds: 5),
      );
    }
  }
}
