class CancelTicketParams {
  final int categoryId;
  final String gameId;
  final String drawId;
  final String ticketId;

  CancelTicketParams(
      {required this.categoryId,
      required this.gameId,
      required this.drawId,
      required this.ticketId});
}
