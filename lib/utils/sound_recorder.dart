import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class SoundRecorder {
  FlutterSoundRecorder _audioRecorder;
  bool _isRecordedInitialised = false;

  bool get isRecording => _audioRecorder.isRecording;

  bool get isStopped => _audioRecorder.isStopped;

  String _audioUrl = "";
  //DEVUELVE LA URL
  String get audioUrl => _audioUrl;

  Future init() async {
    _audioRecorder = FlutterSoundRecorder();
    /*final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please allow recording from settings.'),
        ));
      throw RecordingPermissionException('Microphone permission denied');
    }*/
    await _audioRecorder.openAudioSession();
    _isRecordedInitialised = true;
  }

  Future dispose() async {
    _audioRecorder.closeAudioSession();
    _audioRecorder = null;
    _isRecordedInitialised = false;
  }

  Future _record() async {
    if (!_isRecordedInitialised) return;
    await _audioRecorder.startRecorder(toFile: '${Timestamp.now().millisecondsSinceEpoch}.aac');
  }

  Future _stop() async {
    if (!_isRecordedInitialised) return;
    String url = await _audioRecorder.stopRecorder();
    _audioUrl = url;
  }

  Future toggleRecording() async {
    if (_audioRecorder.isStopped) {
      await _record();
    } else {
      await _stop();
    }
  }
}
