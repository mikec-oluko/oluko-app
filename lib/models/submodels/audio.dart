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

  Audio({this.url, this.userName, this.state, this.userId, this.userReference, this.id, this.userAvatarThumbnail});

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      url: json['url']?.toString(),
      userName: json['user_name']?.toString(),
      userAvatarThumbnail: json['user_avatar_thumbnail']?.toString(),
      state: json['state'] == null ? null : AudioStateEnum.values[json['state'] as int],
      userId: json['user_id']?.toString(),
      id: json['id']?.toString(),
      userReference: json['user_reference'] != null ? json['user_reference'] as DocumentReference : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'user_name': userName,
        'user_avatar_thumbnail': userAvatarThumbnail,
        'state': state,
        'user_id': userId,
        'id': id,
        'user_reference': userReference,
      };
}
