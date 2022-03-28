import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/audio_message_submodel.dart';

class CoachAudioMessage extends Base {
  String userId;
  DocumentReference userReference;
  String coachId;
  DocumentReference coachReference;
  Timestamp seenAt;
  AudioMessageSubmodel audioMessage;

  CoachAudioMessage(
      {this.userId,
      this.userReference,
      this.coachId,
      this.coachReference,
      this.seenAt,
      this.audioMessage,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(
          id: id,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
          updatedBy: updatedBy,
          isDeleted: isDeleted,
          isHidden: isHidden,
        );

  factory CoachAudioMessage.fromJson(Map<String, dynamic> json) {
    CoachAudioMessage coachAudioMessage = CoachAudioMessage(
      userId: json['user_id'] != null ? json['user_id'].toString() : null,
      userReference: json['user_reference'] as DocumentReference,
      coachId: json['coach_id'] != null ? json['coach_id'].toString() : null,
      coachReference: json['coach_reference'] as DocumentReference,
      seenAt: json['seen_at'] != null ? json['seen_at'] as Timestamp : null,
      audioMessage: json['audio_message'] != null ? AudioMessageSubmodel.fromJson(json['audio_message'] as Map<String, dynamic>) : null,
    );
    coachAudioMessage.setBase(json);
    return coachAudioMessage;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> coachAudioMessageJson = {
      'user_id': userId,
      'user_reference': userReference,
      'coach_id': coachId,
      'coach_reference': coachReference,
      'seen_at': seenAt,
      'audio_message': audioMessage.toJson()
    };
    coachAudioMessageJson.addEntries(super.toJson().entries);
    return coachAudioMessageJson;
  }
}
