class User {
  final int userId;
  final String email;
  final String pwhash;
  int preferredPortions;
  String preferredStore;

  User({
    required this.userId,
    required this.email,
    required this.pwhash,
    required this.preferredPortions,
    required this.preferredStore,
  });
}
