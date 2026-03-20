class ClaimParams2D {
  final int categoryId;
  final String drawId;
  final String gameId;
  final String ticketId;
  final int fromDate;
  final int toDate;

  ClaimParams2D(
      {required this.categoryId,
      required this.drawId,
      required this.gameId,
      required this.ticketId,
      required this.fromDate,
      required this.toDate});
}
