class WasteLog {
  int wasteId;
  int userId;
  DateTime week;
  DateTime logdate;
  double amount;
  double composted;
  double inedibleParts;

  WasteLog({
    required this.wasteId,
    required this.userId,
    required this.week,
    required this.logdate,
    required this.amount,
    required this.composted,
    required this.inedibleParts,
  });
}
