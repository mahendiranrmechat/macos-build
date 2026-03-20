class ClaimWithBarCodeParams {
  final String barCode;
  final int fromDate;
  final int toDate;

  ClaimWithBarCodeParams({
    required this.fromDate,
    required this.toDate,
    required this.barCode,
  });
}
