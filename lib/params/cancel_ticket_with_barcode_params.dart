class CancelTicketWithBarcodeParams {
  final int categoryId;
  final String gameId;
  final String barcode;

  CancelTicketWithBarcodeParams({
    required this.categoryId,
    required this.gameId,
    required this.barcode,
  });
}
