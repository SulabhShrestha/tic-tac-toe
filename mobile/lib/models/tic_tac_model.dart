class TicTacModel {
  final String myUID;
  final String otherUID;
  final int selectedIndex;
  final String selectedBy;

  TicTacModel({
    required this.myUID,
    required this.otherUID,
    required this.selectedBy,
    required this.selectedIndex,
  });
}
