import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/enums/audio_sate_enum.dart';

class Audio {
  String url;
  AudioStateEnum state;
  String userId;
  DocumentReference userReference;
  String id;

  Audio({this.url, this.state, this.userId, this.userReference, this.id});

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      url: json['url']?.toString(),
      state: json['state'] == null
          ? null
          : AudioStateEnum.values[json['state'] as int],
      userId: json['user_id']?.toString(),
      id: json['id']?.toString(),
      userReference: json['user_reference'] != null
          ? json['user_reference'] as DocumentReference
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'state': state,
        'user_id': userId,
        'id': id,
        'user_reference': userReference,
      };
}
