import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/enums/audio_sate_enum.dart';

class Audio {
  String url;
  AudioStateEnum state;
  String coachId;
  DocumentReference coachReference;

  Audio({this.url, this.state, this.coachId, this.coachReference});

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      url: json['url']?.toString(),
      state: AudioStateEnum.values[json['state'] as int],
      coachId: json['coach_id']?.toString(),
      coachReference: json['coach_reference'] != null
          ? json['coach_reference'] as DocumentReference
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'state': state,
        'coach_id': coachId,
        'coach_reference': coachReference,
      };
}
