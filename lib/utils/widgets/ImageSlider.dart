import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/utils/responsive_helper.dart';

class ImageSlider extends StatelessWidget {
  const ImageSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> imgList = [
      'images/design.png',
      'images/design1.png',
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: ResponsiveHelper.getAdaptiveHeight(context, 200.0),
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        viewportFraction: ResponsiveHelper.isDesktop(context) ? 0.8 : 1.0,
      ),
      items: imgList
          .map((item) => Container(
                margin: EdgeInsets.symmetric(
                    horizontal:
                        ResponsiveHelper.getAdaptiveSpacing(context, 5.0)),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: Image.asset(
                    item,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ))
          .toList(),
    );
  }
}
