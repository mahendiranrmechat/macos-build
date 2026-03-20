// To parse this JSON data, do
//
//     final priceStructure = priceStructureFromJson(jsonString);

import 'dart:convert';

PriceStructure priceStructureFromJson(String str) => PriceStructure.fromJson(json.decode(str));

String priceStructureToJson(PriceStructure data) => json.encode(data.toJson());

class PriceStructure {
    List<Result> results;
    num errorCode;

    PriceStructure({
        required this.results,
        required this.errorCode,
    });

    PriceStructure copyWith({
        List<Result>? results,
        num? errorCode,
    }) => 
        PriceStructure(
            results: results ?? this.results,
            errorCode: errorCode ?? this.errorCode,
        );

    factory PriceStructure.fromJson(Map<String, dynamic> json) => PriceStructure(
        results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
        errorCode: json["errorCode"],
    );

    Map<String, dynamic> toJson() => {
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
        "errorCode": errorCode,
    };
}

class Result {
    num winPrice;
    num totalNo;
    num totalNoPrice;
    String winDescription;

    Result({
        required this.winPrice,
        required this.totalNo,
        required this.totalNoPrice,
        required this.winDescription,
    });

    Result copyWith({
        num? winPrice,
        num? totalNo,
        num? totalNoPrice,
        String? winDescription,
    }) => 
        Result(
            winPrice: winPrice ?? this.winPrice,
            totalNo: totalNo ?? this.totalNo,
            totalNoPrice: totalNoPrice ?? this.totalNoPrice,
            winDescription: winDescription ?? this.winDescription,
        );

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        winPrice: json["winPrice"],
        totalNo: json["totalNo"],
        totalNoPrice: json["totalNoPrice"],
        winDescription: json["winDescription"],
    );

    Map<String, dynamic> toJson() => {
        "winPrice": winPrice,
        "totalNo": totalNo,
        "totalNoPrice": totalNoPrice,
        "winDescription": winDescription,
    };
}
