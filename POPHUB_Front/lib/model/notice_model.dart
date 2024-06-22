class NoticeModel {
  final int id;
  final String title, content, name, time;

  NoticeModel.fromJson(Map<String, dynamic> json)
      : id = json['notice_id'],
        title = json['title'],
        content = json['content'],
        time = json['created_at'],
        name = json['user_name'];

  Map<String, dynamic> toJson() {
    return {
      'notice_id': id,
      'title': title,
      'content': content,
      'created_at': time,
      'user_name': name,
    };
  }
}
