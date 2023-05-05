import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/coach/coach_audio_messages_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_audio_panel_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_audio_message.dart';
import 'package:oluko_app/ui/components/audio_sent_component.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/sound_recorder.dart';
import 'package:oluko_app/utils/time_converter.dart';

class GenericAudioRecorder extends StatefulWidget {
  final String userId;
  final Function() onRecord;
  final Function(File audio, String userId, Duration  audioDuration) onSave;

  const GenericAudioRecorder ({
    this.userId, 
    this.onRecord, 
    this.onSave,}) : super();

  @override
  State<GenericAudioRecorder> createState() => _GenericAudioRecorderState();
}

class _GenericAudioRecorderState extends State<GenericAudioRecorder> {
  final SoundRecorder _recorder = SoundRecorder();
  bool _recordingAudio = false;
  Timer _timer;
  bool _isAudioPlaying = false;
  bool _audioRecorded = false;
  Duration duration = Duration();
  Duration _durationToSave = Duration();
  List<String> _audiosRecorded = [];
  Widget _audioRecordedElement;

  @override
  void initState() {
    !_recorder.isInitialized ? _recorder.init() : null;
    _recordingAudio = _recorder.isRecording;
    super.initState();
  }

  @override
  void dispose() {
    _recorder.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget recordAudioContent = _sendAudioComponent(context);
    return BlocBuilder<GenericAudioPanelBloc, GenericAudioPanelState>(
      builder: (context, state) {
        if (state is GenericAudioPanelDefault) {
          recordAudioContent = _sendAudioComponent(context);
          _audiosRecorded.clear();
        }
        if (state is GenericAudioPanelDeleted) {
          _audioRecorded = !_audioRecorded;
          _audiosRecorded.clear();
          recordAudioContent = _sendAudioComponent(context);
        }
        if (state is GenericAudioPanelRecorded) {
          _audioRecordedElement = state.audioRecoded;
          recordAudioContent = Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Row(
              children: [_audioRecordedElement, _audioRecordMessageButtonComponentSentAction()],
            ),
          );
        }
        if (state is GenericAudioPanelConfirmDelete) {
          recordAudioContent = _confirmDeleteComponent(context, state);
        }

        return recordAudioContent;
      },
    );
  }

  Widget _showTextToAllowOrDeny(BuildContext context, GenericAudioPanelConfirmDelete state){
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
      child: Wrap(children: [
        Text(OlukoLocalizations.get(context, 'deleteMessageConfirm'), style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor))
      ]),
    );
  }

  Widget _showAllowButton(BuildContext context, GenericAudioPanelConfirmDelete state){
    return Container(
        width: 80,
        height: 40,
        child: OlukoNeumorphicPrimaryButton(
            thinPadding: true,
            isExpanded: false,
            title: OlukoLocalizations.get(context, 'allow'),
            onPressed: () {
              if (state.isAudioPreview) {
                setState(() {
                  _audioRecordedElement = null;
                });
                widget.onRecord();
                BlocProvider.of<GenericAudioPanelBloc>(context).emitDeleteState();
              } else {
                BlocProvider.of<GenericAudioPanelBloc>(context).emitDefaultState();
              }
            }));
  }

  Widget _showDenyButton(BuildContext context, GenericAudioPanelConfirmDelete state){
    return TextButton(
      onPressed: () {
        if (state.isAudioPreview) {
          setState(() {
            BlocProvider.of<GenericAudioPanelBloc>(context).emitRecordedState(
              audioWidget: audioSentComponent(context: context, audioPath: _recorder.audioUrl, isPreview: true),
            );
          });
        } else {
          BlocProvider.of<GenericAudioPanelBloc>(context).emitDefaultState();
        }
      },
      child: Text(OlukoLocalizations.get(context, 'deny')),
    );
  }

  Container _confirmDeleteComponent(BuildContext context, GenericAudioPanelConfirmDelete state) {
    return Container(
      width: ScreenUtils.width(context) / 1.2,
      height: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _showTextToAllowOrDeny(context, state),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _showDenyButton(context, state),
              _showAllowButton(context, state)
            ],
          )
        ],
      ),
    );
  }

  Container _sendAudioComponent(BuildContext context) {
    return Container(height: 100, child: recordAudioInsideContent(context));
  }

  Container recordAudioInsideContent(BuildContext context) {
    return Container(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 0),
            _recordAudioTextComponent(context),
            const SizedBox(width: 0),
            _audioRecordMessageButtonComponent(),
          ],
        ),
      ),
    );
  }

  Container _recordAudioTextComponent(BuildContext context) {
    if (!_recordingAudio) {
      return Container();
    }
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: ScreenUtils.width(context) / 1.6,
          height: 40,
          decoration: BoxDecoration(
            color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
            borderRadius: const BorderRadius.all(Radius.circular(25)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    _recordingAudio ? '${OlukoLocalizations.get(context, 'recordingCapitalText')} ${TimeConverter.durationToString(duration)}' : '',
                    style: OlukoFonts.olukoMediumFont(
                        customColor: OlukoNeumorphism.isNeumorphismDesign
                            ? _recordingAudio
                                ? OlukoColors.primary
                                : OlukoColors.grayColor
                            : OlukoColors.white,
                        customFontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _audioRecordMessageButtonComponent() {
    return Container(
      clipBehavior: Clip.none,
      width: 40,
      height: 40,
      child: OlukoNeumorphism.isNeumorphismDesign
          ? Neumorphic(
              style: OlukoNeumorphism.getNeumorphicStyleForCirclePrimaryColor(),
              child: microphoneIconButtonContent(iconForContent: Icon(_recordingAudio ? Icons.stop : Icons.mic, size: 25, color: OlukoColors.white)))
          : microphoneIconButtonContent(iconForContent: Icon(_recordingAudio ? Icons.stop : Icons.mic, size: 25, color: OlukoColors.black)),
    );
  }

  Container _audioRecordMessageButtonComponentSentAction() {
    return Container(
      clipBehavior: Clip.none,
      width: 40,
      height: 40,
      child: OlukoNeumorphism.isNeumorphismDesign
          ? Neumorphic(style: OlukoNeumorphism.getNeumorphicStyleForCirclePrimaryColor(), child: sendAudioIconButtonContent())
          : sendAudioIconButtonContent(),
    );
  }

  Widget microphoneIconButtonContent({Icon iconForContent}) {
    return GestureDetector(
        onTap: () async {
          if (!_recordingAudio) {
            widget.onRecord();
          }
          !_recorder.isInitialized ? _recorder.init() : null;
          await _recorder.toggleRecording();

          setState(() {
            _recordingAudio = !_recordingAudio;
            startTimer();
          });

          if (_recorder.isStopped) {
            _onRecordCompleted();
          }
        },
        child: Stack(alignment: Alignment.center, children: [
          if (OlukoNeumorphism.isNeumorphismDesign)
            Image.asset(
              'assets/neumorphic/audio_circle.png',
              scale: 4,
            )
          else
            const SizedBox.shrink(),
          Image.asset(
            'assets/courses/green_circle.png',
            scale: 6,
          ),
          iconForContent
        ]));
  }

  Widget sendAudioIconButtonContent() {
    return GestureDetector(
      onTap: () async {
        widget.onSave(File(_recorder.audioUrl), widget.userId,  _durationToSave);
        widget.onRecord();
        BlocProvider.of<GenericAudioPanelBloc>(context).emitDefaultState();
      },
        child: Stack(alignment: Alignment.center, children: [
          if (OlukoNeumorphism.isNeumorphismDesign)
            Image.asset(
              'assets/neumorphic/audio_circle.png',
              scale: 4,
            )
          else
            const SizedBox.shrink(),
          Image.asset(
            'assets/courses/green_circle.png',
            scale: 6,
          ),
          const Icon(Icons.send, color: Colors.white)
        ]));
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    if (!_recordingAudio) {
      setState(() {
        _timer.cancel();
        _durationToSave = duration;
        duration = Duration.zero;
      });
    } else {
      _timer = Timer.periodic(oneSec, (_) => addTime());
    }
  }

  void _onRecordCompleted() {
    setState(() {
      _audioRecorded = true;
      _recordingAudio = false;
      _audiosRecorded.add(_recorder.audioUrl);
      BlocProvider.of<GenericAudioPanelBloc>(context).emitRecordedState(
        audioWidget: audioSentComponent(context: context, audioPath: _recorder.audioUrl, isPreview: true),
      );
    });
  }

  addTime() {
    final addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }

  Widget audioSentComponent({BuildContext context, String audioPath, bool isPreview, CoachAudioMessage audioMessageItem}) {
    return AudioSentComponent(
      valueNotifier: widget.onRecord,
      record: audioPath,
      audioMessageItem: audioMessageItem,
      isPreviewContent: isPreview,
      onAudioPlaying: (bool playing) => _onPlayAudio(playing),
      onStartPlaying: () => _canStartPlaying(),
      durationFromRecord: isPreview ? _durationToSave : Duration(milliseconds: audioMessageItem?.audioMessage?.duration),
      onDelete: () => BlocProvider.of<GenericAudioPanelBloc>(context)
          .emitConfirmDeleteState(isPreviewContent: isPreview, audioMessageItem: !isPreview ? audioMessageItem : null),
    );
  }

  void _onPlayAudio(bool isPlaying) {
    if (isPlaying != null) {
      setState(() {
        _isAudioPlaying = isPlaying;
      });
    }
  }

  bool _canStartPlaying() => _isAudioPlaying;
}
