class BuyTicketOthersParams {
  // {String? gameId, String? drawId, List<Map<String, dynamic>>? types}
  final String gameId;
  final String drawId;
  final List<Map<String, dynamic>> types;

  BuyTicketOthersParams(
      {required this.gameId, required this.drawId, required this.types});
}
