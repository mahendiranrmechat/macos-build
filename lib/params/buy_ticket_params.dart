class BuyParams {
  final String drawId;
  final String drawPlayGroupId;
  final String gameId;
  final List<String> ticketNos;

  BuyParams({
    required this.drawId,
    required this.drawPlayGroupId,
    required this.gameId,
    required this.ticketNos,
  });
}
