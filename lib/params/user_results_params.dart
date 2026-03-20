class UserResultsParams {
  final int categoryId;
  final String gameId;
  final int resultType;
  final int fromDate;
  final int claimStatus;
  final int page;
  final int toDate;

  UserResultsParams({
    required this.categoryId,
    required this.gameId,
    required this.resultType,
    required this.claimStatus,
    required this.fromDate,
    required this.page,
    required this.toDate,
  });
}
