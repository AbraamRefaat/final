import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final FormFieldValidator<String>? validator; // Change to String
  final ValueChanged<String>? onChanged;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = 16.0;
    double hintFontSize = 14.0;

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.only(left: 15, top: 3, bottom: 3, right: 15),
          filled: true,
          fillColor: Theme.of(context).canvasColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: Color.fromRGBO(142, 153, 183, 0.4),
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: Color.fromRGBO(142, 153, 183, 0.4),
              width: 1.0,
            ),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Color(0xff8E99B7),
            fontSize: hintFontSize,
          ),
          suffixIcon: (suffixIcon != null && onSuffixIconTap != null)
              ? GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onSuffixIconTap,
                  child: Icon(
                    obscureText ? Icons.lock_rounded : Icons.lock_open,
                    size: iconSize,
                    color: Color.fromRGBO(142, 153, 183, 0.5),
                  ),
                )
              : suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      size: iconSize,
                      color: Color.fromRGBO(142, 153, 183, 0.5),
                    )
                  : null,
        ),
        validator: validator,
      ),
    );
  }
}
