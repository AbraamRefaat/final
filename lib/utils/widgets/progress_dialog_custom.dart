import 'package:flutter/material.dart';

enum ValuePosition { center, right }
enum ProgressType { normal, valuable }

class ProgressDialog {
  final ValueNotifier<int> _progress = ValueNotifier(0);
  final ValueNotifier<String> _msg = ValueNotifier('');
  bool _dialogIsOpen = false;
  late BuildContext _context;

  ProgressDialog({required BuildContext context}) {
    _context = context;
  }

  void update({required int value, String? msg}) {
    _progress.value = value;
    if (msg != null) _msg.value = msg;
  }

  void close() {
    if (_dialogIsOpen) {
      Future.microtask(() {
        if (_dialogIsOpen) {
          Navigator.of(_context, rootNavigator: true).pop('dialog');
          _dialogIsOpen = false;
        }
      });
    }
  }

  bool isOpen() {
    return _dialogIsOpen;
  }

  Widget _valueProgress({Color? valueColor, Color? bgColor, required double value}) {
    return CircularProgressIndicator(
      backgroundColor: bgColor,
      valueColor: AlwaysStoppedAnimation<Color>(valueColor ?? Colors.white),
      value: value / 100,
    );
  }

  Widget _normalProgress({Color? valueColor, Color? bgColor}) {
    return CircularProgressIndicator(
      backgroundColor: bgColor,
      valueColor: AlwaysStoppedAnimation<Color>(valueColor ?? Colors.white),
    );
  }

  void show({
    required int max,
    required String msg,
    ProgressType progressType = ProgressType.normal,
    ValuePosition valuePosition = ValuePosition.right,
    Color backgroundColor = Colors.white,
    Color barrierColor = Colors.transparent,
    Color progressValueColor = Colors.blueAccent,
    Color progressBgColor = Colors.blueGrey,
    Color valueColor = Colors.black87,
    Color msgColor = ThemeMode.light == true ? Colors.black87 : Colors.white,
    FontWeight msgFontWeight = FontWeight.bold,
    FontWeight valueFontWeight = FontWeight.normal,
    double valueFontSize = 15.0,
    double msgFontSize = 17.0,
    int msgMaxLines = 1,
    double elevation = 5.0,
    double borderRadius = 15.0,
    bool barrierDismissible = false,
    VoidCallback? stopButton,
  }) {
    _dialogIsOpen = true;
    _msg.value = msg;

    showDialog(
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      context: _context,
      builder: (context) => WillPopScope(
        onWillPop: () => Future.value(barrierDismissible),
        child: AlertDialog(
          backgroundColor: backgroundColor,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
          content: ValueListenableBuilder<int>(
            valueListenable: _progress,
            builder: (BuildContext context, int value, Widget? child) {
              if (value == max) close();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 35.0,
                        height: 35.0,
                        child: progressType == ProgressType.normal
                            ? _normalProgress(
                          bgColor: progressBgColor,
                          valueColor: progressValueColor,
                        )
                            : value == 0
                            ? _normalProgress(
                          bgColor: progressBgColor,
                          valueColor: progressValueColor,
                        )
                            : _valueProgress(
                          valueColor: progressValueColor,
                          bgColor: progressBgColor,
                          value: (value / max) * 100,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15.0,
                            top: 8.0,
                            bottom: 8.0,
                          ),
                          child: Text(
                            _msg.value,
                            maxLines: msgMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: msgFontSize,
                              color: msgColor,
                              fontWeight: msgFontWeight,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: valuePosition == ValuePosition.right
                            ? Alignment.bottomRight
                            : Alignment.bottomCenter,
                        child: Text(
                          value <= 0 ? '' : '${_progress.value}%',
                          style: TextStyle(
                            fontSize: valueFontSize,
                            color: valueColor,
                            fontWeight: valueFontWeight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            ElevatedButton(
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: stopButton,
            ),
          ],
        ),
      ),
    );
  }
}
