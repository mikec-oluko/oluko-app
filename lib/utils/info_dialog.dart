class InfoDialog {
  InfoDialog({this.content, this.title});

  String content;
  String title;

  InfoDialog.fromJson(Map json)
      : content = json['content'].toString(),
        title = json['title'].toString();

  Map<String, dynamic> toJson() => {
        'content': content,
        'title': title,
      };
}
