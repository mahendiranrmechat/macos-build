class CancelTicketAlltParams {
  final int categoryId;
  final String gameId;
  final int from;
  final int to;

  CancelTicketAlltParams(
      {required this.categoryId,
      required this.gameId,
      required this.from,
      required this.to});
}
