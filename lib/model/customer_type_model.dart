// To parse this JSON data, do
//
//     final customerType = customerTypeFromJson(jsonString);

import 'dart:convert';

CustomerType customerTypeFromJson(String str) =>
    CustomerType.fromJson(json.decode(str));

String customerTypeToJson(CustomerType data) => json.encode(data.toJson());

class CustomerType {
  int? menuId;
  List<CustomerTypeList>? customerTypeViewList;
  List<CustomerTypeList>? customerTypeEditList;
  int? errorCode;

  CustomerType({
    this.menuId,
    this.customerTypeViewList,
    this.customerTypeEditList,
    this.errorCode,
  });

  CustomerType copyWith({
    int? menuId,
    List<CustomerTypeList>? customerTypeViewList,
    List<CustomerTypeList>? customerTypeEditList,
    int? errorCode,
  }) =>
      CustomerType(
        menuId: menuId ?? this.menuId,
        customerTypeViewList: customerTypeViewList ?? this.customerTypeViewList,
        customerTypeEditList: customerTypeEditList ?? this.customerTypeEditList,
        errorCode: errorCode ?? this.errorCode,
      );

  factory CustomerType.fromJson(Map<String, dynamic> json) => CustomerType(
        menuId: json["menuId"],
        customerTypeViewList: json["customerTypeViewList"] == null
            ? []
            : List<CustomerTypeList>.from(json["customerTypeViewList"]!
                .map((x) => CustomerTypeList.fromJson(x))),
        customerTypeEditList: json["customerTypeEditList"] == null
            ? []
            : List<CustomerTypeList>.from(json["customerTypeEditList"]!
                .map((x) => CustomerTypeList.fromJson(x))),
        errorCode: json["errorCode"],
      );

  Map<String, dynamic> toJson() => {
        "menuId": menuId,
        "customerTypeViewList": customerTypeViewList == null
            ? []
            : List<dynamic>.from(customerTypeViewList!.map((x) => x.toJson())),
        "customerTypeEditList": customerTypeEditList == null
            ? []
            : List<dynamic>.from(customerTypeEditList!.map((x) => x.toJson())),
        "errorCode": errorCode,
      };
}

class CustomerTypeList {
  int? customerTypeId;
  String? customerTypeName;

  CustomerTypeList({
    this.customerTypeId,
    this.customerTypeName,
  });

  CustomerTypeList copyWith({
    int? customerTypeId,
    String? customerTypeName,
  }) =>
      CustomerTypeList(
        customerTypeId: customerTypeId ?? this.customerTypeId,
        customerTypeName: customerTypeName ?? this.customerTypeName,
      );

  factory CustomerTypeList.fromJson(Map<String, dynamic> json) =>
      CustomerTypeList(
        customerTypeId: json["customerTypeId"],
        customerTypeName: json["customerTypeName"],
      );

  Map<String, dynamic> toJson() => {
        "customerTypeId": customerTypeId,
        "customerTypeName": customerTypeName,
      };
}
