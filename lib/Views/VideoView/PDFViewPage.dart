import 'package:flutter/material.dart';
import 'package:untitled2/utils/widgets/AppBarWidget.dart';
import 'package:untitled2/utils/widgets/connectivity_checker_widget.dart';

class PDFViewPage extends StatefulWidget {
  final String? pdfLink;
  PDFViewPage({this.pdfLink});

  @override
  _PDFViewPageState createState() => _PDFViewPageState();
}

class _PDFViewPageState extends State<PDFViewPage> {
  @override
  Widget build(BuildContext context) {
    return ConnectionCheckerWidget(
      child: Scaffold(
        appBar: AppBarWidget(
          showSearch: false,
          goToSearch: false,
          showFilterBtn: false,
          showBack: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'PDF Viewer Temporarily Unavailable',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'pdfrx dependency is disabled',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 