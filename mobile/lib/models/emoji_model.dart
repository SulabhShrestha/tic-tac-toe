class EmojiModel {
  final String senderUid;
  final String emojiPath;

  EmojiModel({required this.senderUid, required this.emojiPath});

  factory EmojiModel.empty() {
    return EmojiModel(senderUid: "", emojiPath: "");
  }
}
