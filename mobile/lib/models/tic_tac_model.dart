class TicTacModel {
  final int selectedIndex;
  final String uid;

  TicTacModel({
    required this.uid,
    required this.selectedIndex,
  });

  // empty model
  factory TicTacModel.empty() {
    return TicTacModel(
      uid: "",
      selectedIndex: -1,
    );
  }

  // from json
  factory TicTacModel.fromJson(Map<String, dynamic> json) {
    return TicTacModel(
      uid: json['uid'],
      selectedIndex: json['selectedIndex'],
    );
  }

  @override
  bool operator ==(other) =>
      other is TicTacModel && (other.selectedIndex == selectedIndex);

  @override
  int get hashCode => selectedIndex;
}
