class ResultSearchParams {
  final int categoryId;
  final String gameId;
  // final String drawPlayGroupId;
  final int fromDate;
  final int toDate;

  ResultSearchParams({
    required this.categoryId,
    required this.gameId,
    // required this.drawPlayGroupId,
    required this.fromDate,
    required this.toDate,
  });
}
