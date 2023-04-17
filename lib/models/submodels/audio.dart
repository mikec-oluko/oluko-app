import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/enums/audio_sate_enum.dart';

class Audio {
  String url;
  AudioStateEnum state;
  String userId;
  DocumentReference userReference;
  String userAvatarThumbnail;
  String id;
  String userName;
  bool deleted;
  bool seen;

  Audio({this.deleted, this.url, this.userName, this.state, this.userId, this.userReference, this.id, this.userAvatarThumbnail,this.seen});

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      deleted: json['deleted'] == null ? false : json['deleted'] as bool,
      url: json['url']?.toString(),
      userName: json['user_name']?.toString(),
      userAvatarThumbnail: json['user_avatar_thumbnail']?.toString(),
      state: json['state'] == null ? null : AudioStateEnum.values[json['state'] as int],
      userId: json['user_id']?.toString(),
      id: json['id']?.toString(),
      userReference: json['user_reference'] != null ? json['user_reference'] as DocumentReference : null,
      seen:json['seen'] == null ? false : json['seen'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'deleted': deleted ?? false,
        'user_name': userName,
        'user_avatar_thumbnail': userAvatarThumbnail,
        'state': state.index,
        'user_id': userId,
        'id': id,
        'user_reference': userReference,
        'seen': seen ?? false,
      };
}
