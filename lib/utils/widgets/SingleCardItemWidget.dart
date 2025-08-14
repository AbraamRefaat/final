import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/utils/CustomText.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:untitled2/utils/responsive_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class SingleItemCardWidget extends StatelessWidget {
  final bool? showPricing;
  final String? image;
  final String? title;
  final String? subTitle;
  final VoidCallback? onTap;
  final dynamic price;
  final dynamic discountPrice;
  SingleItemCardWidget({
    this.showPricing,
    this.image,
    this.title,
    this.subTitle,
    this.onTap,
    this.price,
    @required this.discountPrice,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: Get.theme.shadowColor,
              blurRadius: 10.0,
              offset: Offset(2, 3),
            ),
          ],
        ),
        margin: EdgeInsets.only(bottom: ResponsiveHelper.getAdaptiveSpacing(context, 20)),
        width: ResponsiveHelper.getAdaptiveWidth(context, 174),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: Container(
                      width: Get.width,
                      height: ResponsiveHelper.getAdaptiveHeight(context, 120),
                      child: (image != null && image!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: image!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Get.theme.cardColor,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Get.theme.disabledColor,
                                    size: 30,
                                  ),
                                ),
                              ),
                              memCacheWidth: 300,
                              memCacheHeight: 300,
                              maxWidthDiskCache: 300,
                              maxHeightDiskCache: 300,
                            )
                          : Container(
                              color: Get.theme.cardColor,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Get.theme.disabledColor,
                                  size: 30,
                                ),
                              ),
                            ),
                    ),
                  ),
                  showPricing == true
                      ? discountPrice != 0
                          ? Positioned(
                              top: 0,
                              right: 0,
                              child: Align(
                                  alignment: Alignment.topRight,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(5),
                                    ),
                                    child: Container(
                                      color: Color(0xFFD7598F),
                                      padding: EdgeInsets.all(4),
                                      alignment: Alignment.center,
                                      child: Row(
                                        children: [
                                          Text(
                                            "$appCurrency${price.toString()}",
                                            style: Get.textTheme.titleSmall
                                                ?.copyWith(
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationThickness: 2,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "$appCurrency${discountPrice.toString()}",
                                            style: Get.textTheme.titleSmall
                                                ?.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            )
                          : Positioned(
                              top: 0,
                              right: 0,
                              child: Align(
                                  alignment: Alignment.topRight,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(5),
                                    ),
                                    child: Container(
                                      color: Color(0xFFD7598F),
                                      padding: EdgeInsets.all(4),
                                      alignment: Alignment.center,
                                      child: double.parse(price.toString()) > 0
                                          ? Text(
                                              "$appCurrency${price.toString()}",
                                              style: Get.textTheme.titleSmall
                                                  ?.copyWith(
                                                      color: Colors.white),
                                            )
                                          : Text(
                                              "${TranslationHelper.tr("Free")}",
                                              style: Get.textTheme.titleSmall
                                                  ?.copyWith(
                                                      color: Colors.white),
                                            ),
                                    ),
                                  )),
                            )
                      : Container(),
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    courseTitle(title ?? ''),
                    SizedBox(
                      height: 4,
                    ),
                    courseTPublisher(subTitle ?? ''),
                  ],
                )),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
