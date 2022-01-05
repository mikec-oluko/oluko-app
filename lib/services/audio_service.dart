import 'package:oluko_app/models/submodels/audio.dart';

class AudioService {
  static List<Audio> getNotDeletedAudios(List<Audio> audios) {
    if(audios == null){
      return null;
    }
    List<Audio> notDeletedAudios = audios.where((element) => element.deleted != true).toList();
    return notDeletedAudios;
  }
}
