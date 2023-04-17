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
  
static int getUnseenAudios(List<Audio> audios)  { 
      int unseenAudios = 0;
      if (audios != null) {
        audios.forEach((audio) {
          if (!audio.seen) {
            unseenAudios++;
          }
        });
      }
      return unseenAudios;
  }
}
