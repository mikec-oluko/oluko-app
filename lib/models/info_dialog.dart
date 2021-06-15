class InfoDialog {
  InfoDialog({this.content, this.title});

  String content;
  String title;

  InfoDialog.fromJson(Map json)
      : content = json['content'],
        title = json['title'];

  Map<String, dynamic> toJson() => {
        'content': content,
        'title': title,
      };
}
