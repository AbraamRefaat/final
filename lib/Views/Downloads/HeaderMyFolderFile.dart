import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2/utils/file_models.dart';

class HeaderMyFolderFile extends StatelessWidget {
  const HeaderMyFolderFile({
    Key? key,
    required this.scrollController,
    required this.lastPaths,
  }) : super(key: key);

  final ScrollController scrollController;
  final List<String> lastPaths;

  @override
  Widget build(BuildContext context) {
    final style = FileManagerInit.currentStyle;
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.symmetric(horizontal: 14),
      height: style.heightHeader ?? 56.0,
      color: Get.theme.primaryColor,
      child: buildListView(),
    );
  }

  ListView buildListView() {
    return ListView.separated(
      controller: scrollController,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: lastPaths.length,
      itemBuilder: (BuildContext context, int index) {
        String path = lastPaths[index].split('/').last;
        return buildContainer(path, index);
      },
      separatorBuilder: (_, __) => buildContainerSeparator(),
    );
  }

  Container buildContainerSeparator() {
    final style = FileManagerInit.currentStyle;
    return Container(
      alignment: Alignment.center,
      child: Icon(
        Icons.chevron_right,
        color: (style.textColorHeader ?? Colors.black87).withOpacity(0.55),
      ),
    );
  }

  Container buildContainer(String path, int index) {
    final style = FileManagerInit.currentStyle;
    return Container(
      alignment: Alignment.center,
      child: Text(
        path,
        style: TextStyle(
            fontSize: 14,
            color: (index == (lastPaths.length - 1))
                ? (style.textColorHeader ?? Colors.black87)
                : (style.textColorHeader ?? Colors.black87).withOpacity(0.75)),
        textAlign: TextAlign.center,
      ),
    );
  }
}
