class InitGameOthersParams {
  final int categoryId;
  final String gameId;
  final String drawId;
  final String drawPlayGroupId;

  InitGameOthersParams({
    required this.drawPlayGroupId,
    required this.categoryId,
    required this.gameId,
    required this.drawId,
  });
}
