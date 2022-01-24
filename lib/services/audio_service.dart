import 'package:oluko_app/models/enrollment_audio.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/class_audio.dart';

class AudioService {
  static List<Audio> getNotDeletedAudios(List<Audio> audios) {
    if(audios == null){
      return null;
    }
    List<Audio> notDeletedAudios = audios.where((element) => element.deleted != true).toList();
    return notDeletedAudios;
  }

    static List<Audio> getClassAudios(EnrollmentAudio enrollmentAudio, String classId) {
    if(enrollmentAudio == null || enrollmentAudio.classAudios == null){
      return null;
    }
    for (ClassAudio classAudio in enrollmentAudio.classAudios) {
      if(classAudio.classId == classId){
        return classAudio.audios;
      }
    }
    return null;
  }
}
