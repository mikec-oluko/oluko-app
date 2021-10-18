class UserSubmodel {
  String id;
  String firstName;
  String lastName;
  String avatar;
  String avatarThumbnail;

  UserSubmodel({this.avatar, this.avatarThumbnail, this.firstName, this.id, this.lastName});

  factory UserSubmodel.fromJson(Map<String, dynamic> json) {
    if (json != null) {
      return UserSubmodel(
          id: json['id'].toString(),
          firstName: json['first_name'].toString(),
          lastName: json['last_name'].toString(),
          avatar: json['avatar'].toString(),
          avatarThumbnail: json['avatar_thumbnail'].toString());
    }
    return null;
  }

  Map<String, dynamic> toJson() => {'id': id, 'first_name': firstName, 'last_name': lastName, 'avatar': avatar, 'avatar_thumbnail': avatarThumbnail};
}
