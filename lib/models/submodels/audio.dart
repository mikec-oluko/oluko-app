import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/enums/audio_sate_enum.dart';

class Audio {
  String url;
  AudioStateEnum state;
  String userId;
  DocumentReference userReference;

  Audio({this.url, this.state, this.userId, this.userReference});

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      url: json['url']?.toString(),
      state: AudioStateEnum.values[json['state'] as int],
      userId: json['user_id']?.toString(),
      userReference: json['user_reference'] != null
          ? json['user_reference'] as DocumentReference
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'state': state,
        'user_id': userId,
        'user_reference': userReference,
      };
}
