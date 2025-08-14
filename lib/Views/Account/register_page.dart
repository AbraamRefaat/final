// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:

import 'package:get/get.dart';
import 'package:untitled2/Config/app_config.dart';

// Project imports:
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Views/Account/widgets/auth_textfield.dart';
import 'package:untitled2/utils/translation_helper.dart';

class RegisterPage extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CupertinoActivityIndicator());
        } else {
          return ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Container(
                height: 70,
                width: 70,
                child: Image.asset('images/signin_img.png'),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    TranslationHelper.tr("Register"),
                    style: Get.textTheme.titleMedium?.copyWith(fontSize: 24),
                  ),
                ),
              ),
              AuthTextField(
                controller: controller.registerFullName,
                hintText: TranslationHelper.tr("Name"),
                suffixIcon: Icons.person,
              ),
              AuthTextField(
                controller: controller.registerStudentPhone,
                hintText: TranslationHelper.tr("Student phone number"),
                suffixIcon: Icons.phone,
              ),
              AuthTextField(
                controller: controller.registerStudentWhatsApp,
                hintText: TranslationHelper.tr("student_whatsapp_number"),
                suffixIcon: Icons.phone,
              ),
              AuthTextField(
                controller: controller.registerGuardianNumber,
                hintText: TranslationHelper.tr("guardian_number"),
                suffixIcon: Icons.phone,
              ),
              
              // Study Type Selection
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationHelper.tr("Study Type"),
                      style: Get.textTheme.titleMedium?.copyWith(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Obx(() => Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.selectStudyType("online"),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: controller.selectedStudyType.value == "online"
                                    ? Get.theme.primaryColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: controller.selectedStudyType.value == "online"
                                      ? Get.theme.primaryColor
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  TranslationHelper.tr("Online"),
                                  style: TextStyle(
                                    color: controller.selectedStudyType.value == "online"
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.selectStudyType("offline"),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: controller.selectedStudyType.value == "offline"
                                    ? Get.theme.primaryColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: controller.selectedStudyType.value == "offline"
                                      ? Get.theme.primaryColor
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  TranslationHelper.tr("Offline"),
                                  style: TextStyle(
                                    color: controller.selectedStudyType.value == "offline"
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
              
              // Student Code Field (conditional)
              Obx(() => controller.showStudentCode.value
                  ? AuthTextField(
                      controller: controller.registerStudentCode,
                      hintText: TranslationHelper.tr("Student Code"),
                      suffixIcon: Icons.numbers,
                    )
                  : SizedBox.shrink()),
              AuthTextField(
                controller: controller.registerPassword,
                hintText: TranslationHelper.tr("Password"),
                obscureText: controller.obscureNewPass.value,
                suffixIcon: controller.obscureNewPass.value
                    ? Icons.lock_rounded
                    : Icons.lock_open,
                onSuffixIconTap: () {
                  controller.obscureNewPass.value =
                      !controller.obscureNewPass.value;
                },
              ),
              AuthTextField(
                controller: controller.registerConfirmPassword,
                hintText: TranslationHelper.tr("Confirm Password"),
                obscureText: controller.obscureConfirmPass.value,
                suffixIcon: controller.obscureConfirmPass.value
                    ? Icons.lock_rounded
                    : Icons.lock_open,
                onSuffixIconTap: () {
                  controller.obscureConfirmPass.value =
                      !controller.obscureConfirmPass.value;
                },
              ),
              Container(
                height: 70,
                margin: EdgeInsets.symmetric(horizontal: 100),
                alignment: Alignment.center,
                child: GestureDetector(
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(TranslationHelper.tr("Register")),
                  ),
                  onTap: () async {
                    await controller.fetchUserRegister();
                  },
                ),
              ),
              Center(
                child: InkWell(
                  onTap: () {
                    controller.showRegisterScreen();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 15),
                    child: Text(
                      TranslationHelper.tr(
                          "Already have an account? Login now"),
                      style: Get.textTheme.titleMedium?.copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100),
            ],
          );
        }
      }),
    );
  }
}
