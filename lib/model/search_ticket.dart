import 'dart:convert';

/// gameId : "winwin"
/// drawId : "90"
/// tickets : ["123453-1"]
/// errorCode : 0

SearchTicket searchTicketFromJson(String str) =>
    SearchTicket.fromJson(json.decode(str));
String searchTicketToJson(SearchTicket data) => json.encode(data.toJson());

class SearchTicket {
  SearchTicket({
    this.gameId,
    this.drawId,
    this.tickets,
    this.errorCode,
  });

  SearchTicket.fromJson(dynamic json) {
    gameId = json['gameId'];
    drawId = json['drawId'];
    tickets = json['tickets'] != null ? json['tickets'].cast<String>() : [];
    errorCode = json['errorCode'];
  }
  String? gameId;
  String? drawId;
  List<String>? tickets;
  int? errorCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['gameId'] = gameId;
    map['drawId'] = drawId;
    map['tickets'] = tickets;
    map['errorCode'] = errorCode;
    return map;
  }
}
