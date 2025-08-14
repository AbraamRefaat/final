import 'package:flutter/material.dart';

/// A responsive coupon widget that ensures immediate UI updates
class ResponsiveCouponWidget extends StatefulWidget {
  final bool isCouponApplied;
  final String appliedCoupon;
  final bool isVerifying;
  final VoidCallback onRemove;
  final Widget Function() inputBuilder;
  final Widget Function() appliedBuilder;

  const ResponsiveCouponWidget({
    Key? key,
    required this.isCouponApplied,
    required this.appliedCoupon,
    required this.isVerifying,
    required this.onRemove,
    required this.inputBuilder,
    required this.appliedBuilder,
  }) : super(key: key);

  @override
  _ResponsiveCouponWidgetState createState() => _ResponsiveCouponWidgetState();
}

class _ResponsiveCouponWidgetState extends State<ResponsiveCouponWidget> {
  @override
  Widget build(BuildContext context) {
    // Force rebuild whenever any property changes
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 150), // Faster animation
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: widget.isCouponApplied
          ? widget.appliedBuilder()
          : widget.inputBuilder(),
    );
  }
}
