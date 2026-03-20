import 'dart:convert';

// Function to parse JSON data into a ClaimAll object
ClaimAll claimAllFromJson(String str) => ClaimAll.fromJson(json.decode(str));

// Function to convert ClaimAll object into JSON string
String claimAllToJson(ClaimAll data) => json.encode(data.toJson());

class ClaimAll {
  double? balance;
  List<String>? claimedTicket;  // Changed from dynamic to List<String>
  List<String>? unClaimedTicket; // Changed from dynamic to List<String>
  int? errorCode;

  ClaimAll({
    this.balance,
    this.claimedTicket,
    this.unClaimedTicket,
    this.errorCode,
  });

  // Method to copy the ClaimAll object with optional new values
  ClaimAll copyWith({
    double? balance,
    List<String>? claimedTicket,
    List<String>? unClaimedTicket,
    int? errorCode,
  }) =>
      ClaimAll(
        balance: balance ?? this.balance,
        claimedTicket: claimedTicket ?? this.claimedTicket,
        unClaimedTicket: unClaimedTicket ?? this.unClaimedTicket,
        errorCode: errorCode ?? this.errorCode,
      );

  // Factory method to create a ClaimAll object from JSON
  factory ClaimAll.fromJson(Map<String, dynamic> json) => ClaimAll(
        balance: json["balance"],
        // Parsing claimedTicket as List<String>
        claimedTicket: json["claimedTicket"] == null
            ? []
            : List<String>.from(json["claimedTicket"]!.map((x) => x.toString())),
        // Parsing unClaimedTicket as List<String>
        unClaimedTicket: json["unClaimedTicket"] == null
            ? []
            : List<String>.from(json["unClaimedTicket"]!.map((x) => x.toString())),
        errorCode: json["errorCode"],
      );

  // Method to convert ClaimAll object to JSON
  Map<String, dynamic> toJson() => {
        "balance": balance,
        "claimedTicket": claimedTicket == null
            ? []
            : List<dynamic>.from(claimedTicket!.map((x) => x)),
        "unClaimedTicket": unClaimedTicket == null
            ? []
            : List<dynamic>.from(unClaimedTicket!.map((x) => x)),
        "errorCode": errorCode,
      };
}
