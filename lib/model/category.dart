import 'dart:convert';

/// categoryList : [{"categoryId":1,"categoryName":"Lotto","categoryOrder":1,"categoryStatus":1}]
/// errorCode : 0

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));
String categoryToJson(Category data) => json.encode(data.toJson());

class Category {
  Category({
    this.categoryList,
    this.errorCode,
  });

  Category.fromJson(dynamic json) {
    if (json['categoryList'] != null) {
      categoryList = [];
      json['categoryList'].forEach((v) {
        categoryList?.add(CategoryList.fromJson(v));
      });
    }
    errorCode = json['errorCode'];
  }
  List<CategoryList>? categoryList;
  int? errorCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (categoryList != null) {
      map['categoryList'] = categoryList?.map((v) => v.toJson()).toList();
    }
    map['errorCode'] = errorCode;
    return map;
  }
}

/// categoryId : 1
/// categoryName : "Lotto"
/// categoryOrder : 1
/// categoryStatus : 1

CategoryList categoryListFromJson(String str) =>
    CategoryList.fromJson(json.decode(str));
String categoryListToJson(CategoryList data) => json.encode(data.toJson());

class CategoryList {
  CategoryList({
    this.categoryId,
    this.categoryName,
    this.categoryOrder,
    this.categoryStatus,
  });

  CategoryList.fromJson(dynamic json) {
    categoryId = json['categoryId'];
    categoryName = json['categoryName'];
    categoryOrder = json['categoryOrder'];
    categoryStatus = json['categoryStatus'];
  }
  int? categoryId;
  String? categoryName;
  int? categoryOrder;
  int? categoryStatus;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['categoryId'] = categoryId;
    map['categoryName'] = categoryName;
    map['categoryOrder'] = categoryOrder;
    map['categoryStatus'] = categoryStatus;
    return map;
  }
}
