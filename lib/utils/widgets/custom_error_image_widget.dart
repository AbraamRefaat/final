import 'package:flutter/material.dart';
import 'package:untitled2/utils/translation_helper.dart';

class CustomErrorImageWidget extends StatelessWidget {
  const CustomErrorImageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(height: 5),
          Text(
            TranslationHelper.tr('Error loading Image'),
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
