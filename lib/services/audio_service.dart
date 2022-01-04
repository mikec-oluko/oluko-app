import 'package:oluko_app/models/submodels/audio.dart';

class AudioService {
  static int getAudiosLength(List<Audio> audios) {
    if (audios == null) {
      return 0;
    }
    List<Audio> notDeletedAudios = audios.where((element) => element.deleted != true).toList();
    return notDeletedAudios.length;
  }
}
