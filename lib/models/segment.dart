import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/enums/challenge_type_enum.dart';
import 'package:oluko_app/models/enums/segment_type_enum.dart';
import 'package:oluko_app/models/submodels/rounds_alerts.dart';
import 'package:oluko_app/models/submodels/section_submodel.dart';

class Segment extends Base {
  String challengeVideo;
  String name;
  String image;
  String video;
  String videoHLS;
  String description;
  int initialTimer;
  SegmentTypeEnum type;
  ChallengeTypeEnum typeOfChallenge;
  int rounds;
  List<RoundsAlerts> roundsAlerts;
  int totalTime;
  bool isPublished;
  List<SectionSubmodel> sections;
  bool isChallenge;
  bool setMaxWeights;
  String challengeImage;
  int likes;
  int dislikes;

  Segment(
      {this.name,
      this.sections,
      this.image,
      this.video,
      this.videoHLS,
      this.rounds,
      this.description,
      this.initialTimer,
      this.isPublished,
      this.totalTime,
      this.isChallenge,
      this.setMaxWeights,
      this.challengeVideo,
      this.challengeImage,
      this.type,
      this.typeOfChallenge,
      this.roundsAlerts,
      this.likes,
      this.dislikes,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  factory Segment.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    // debugger(when: json['total_time'] is! int, message: 'total_time is not int');
    if (json['total_time'] == '') {
      json['total_time'] = null;
    }
    Segment segment = Segment(
      challengeVideo: json['challenge_video'] == null ? null : json['challenge_video'].toString(),
      name: json['name']?.toString(),
      image: json['image']?.toString(),
      video: json['video']?.toString(),
      videoHLS: json['video_hls']?.toString(),
      rounds: json['rounds'] as int,
      description: json['description']?.toString(),
      isChallenge: json['is_challenge'] == null
          ? false
          : json['is_challenge'] is bool
              ? json['is_challenge'] as bool
              : false,
      setMaxWeights: json['sets_max_weights'] == null
          ? false
          : json['sets_max_weights'] is bool
              ? json['sets_max_weights'] as bool
              : false,
      challengeImage: json['challenge_image'] == null ? null : json['challenge_image']?.toString(),
      totalTime: json['total_time'] as int,
      initialTimer: json['initial_timer'] as int,
      isPublished: json['is_published'] as bool,
      type: json['type'] == null ? null : SegmentTypeEnum.values[json['type'] as int],
      typeOfChallenge: json['type_of_challenge'] == null || json['is_challenge'] == false ? null : ChallengeTypeEnum.values[json['type_of_challenge'] as int],
      roundsAlerts: json['rounds_alerts'] == null
          ? null
          : List<RoundsAlerts>.from((json['rounds_alerts'] as Iterable)
              .map((roundAlerts) => roundAlerts == null ? null : RoundsAlerts.fromJson(roundAlerts as Map<String, dynamic>))),
      sections: json['sections'] == null
          ? null
          : List<SectionSubmodel>.from((json['sections'] as Iterable).map((section) => SectionSubmodel.fromJson(section as Map<String, dynamic>))),
      likes: json['likes'] != null ? json['likes'] as int : 0,
      dislikes: json['dislikes'] != null ? json['dislikes'] as int : 0,
    );
    segment.setBase(json);
    return segment;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> segmentJson = {
      'challenge_video': challengeVideo == null ? null : challengeVideo,
      'name': name,
      'image': image,
      'rounds': rounds,
      'total_time': totalTime,
      'description': description,
      'initial_timer': initialTimer,
      'is_published': isPublished,
      'is_challenge': isChallenge,
      'sets_max_weights': setMaxWeights,
      'challenge_image': challengeImage,
      'rounds_alerts': roundsAlerts == null ? null : List<dynamic>.from(roundsAlerts.map((roundAlerts) => roundAlerts.toJson())),
      'type': type == null ? null : type.index,
      'sections': sections == null ? null : List<dynamic>.from(sections.map((section) => section.toJson())),
      'likes': likes ?? 0,
      'dislikes': likes ?? 0,
    };
    segmentJson.addEntries(super.toJson().entries);
    return segmentJson;
  }
}
