import '../utils/localization_helper.dart';

class AllCategory {
  String? name;
  int? id;
  int? courseCount;

  AllCategory({this.name, this.id, this.courseCount});

  factory AllCategory.fromJson(Map<String, dynamic> json) {
    return AllCategory(
      id: json['id'],
      name: LocalizationHelper.extractLocalizedText(json['name']),
      courseCount: json['courseCount'] ?? json['courses_count'] ?? 0,
    );
  }
}

class CategoryList {
  List<AllCategory>? categories = [];

  CategoryList({this.categories});

  factory CategoryList.fromJson(List<dynamic> json) {
    List<AllCategory> categoryList;

    categoryList = json.map((i) => AllCategory.fromJson(i)).toList();

    return CategoryList(categories: categoryList);
  }
}

class Level {
  String? title;
  int? id;
  int? courseCount;

  Level({this.title, this.id, this.courseCount});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'],
      title: json['title'],
      courseCount: json['courseCount'],
    );
  }
}

class LevelList {
  List<Level>? levels = [];

  LevelList({this.levels});

  factory LevelList.fromJson(List<dynamic> json) {
    List<Level> levelList;

    levelList = json.map((i) => Level.fromJson(i)).toList();

    return LevelList(levels: levelList);
  }
}
