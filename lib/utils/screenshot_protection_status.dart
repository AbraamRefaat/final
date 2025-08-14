import 'package:flutter/material.dart';
import 'package:untitled2/Service/screenshot_protection_service.dart';

/// Widget to display screenshot protection status
/// This helps verify that protection is properly enabled
class ScreenshotProtectionStatus extends StatefulWidget {
  @override
  _ScreenshotProtectionStatusState createState() => _ScreenshotProtectionStatusState();
}

class _ScreenshotProtectionStatusState extends State<ScreenshotProtectionStatus> {
  bool _isProtected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkProtectionStatus();
  }

  Future<void> _checkProtectionStatus() async {
    try {
      // Force enable protection to test the method channel
      await ScreenshotProtectionService.enableProtection();
      setState(() {
        _isProtected = ScreenshotProtectionService.isProtectionEnabled;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking protection status: $e');
      setState(() {
        _isLoading = false;
        _isProtected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Checking protection...', style: TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isProtected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isProtected ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isProtected ? Icons.security : Icons.security_outlined,
            color: _isProtected ? Colors.green : Colors.red,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            _isProtected ? 'Screenshots Blocked' : 'Protection Disabled',
            style: TextStyle(
              color: _isProtected ? Colors.green[700] : Colors.red[700],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
