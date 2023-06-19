import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/coach/coach_audio_messages_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_audio_panel_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_audio_message.dart';
import 'package:oluko_app/ui/components/audio_sent_component.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/sound_recorder.dart';
import 'package:oluko_app/utils/time_converter.dart';

class CoachAppBarRecordAudioComponent extends StatefulWidget {
  final String userId;
  final String coachId;
  // final SoundRecorder audioRecorder;
  const CoachAppBarRecordAudioComponent({this.userId, this.coachId}) : super();

  @override
  State<CoachAppBarRecordAudioComponent> createState() => _CoachAppBarRecordAudioComponentState();
}

class _CoachAppBarRecordAudioComponentState extends State<CoachAppBarRecordAudioComponent> {
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
    Widget recordAudioContent = _sendAudioToCoachComponent(context);
    return BlocBuilder<GenericAudioPanelBloc, GenericAudioPanelState>(
      builder: (context, state) {
        if (state is GenericAudioPanelDefault) {
          recordAudioContent = _sendAudioToCoachComponent(context);
          _audiosRecorded.clear();
          recordAudioContent = recordAudioContent;
        }
        if (state is GenericAudioPanelDeleted) {
          _audioRecorded = !_audioRecorded;
          _audiosRecorded.clear();
          recordAudioContent = _sendAudioToCoachComponent(context);
        }
        if (state is GenericAudioPanelRecorded) {
          _audioRecordedElement = state.audioRecoded;
          recordAudioContent = Padding(
            padding: const EdgeInsets.only(top: 20, right: 10),
            child: Row(
              children: [_audioRecordedElement, _audioRecordMessageButtonComponentSentAction()],
            ),
          );
        }
        if (state is GenericAudioPanelConfirmDelete  && state.audioMessage?.id == null) {
          recordAudioContent = _confirmDeleteComponent(context, state);
        }

        return recordAudioContent;
      },
    );
  }

  Widget _confirmDeleteComponent(BuildContext context, GenericAudioPanelConfirmDelete state) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtils.smallScreen(context) ? 20 : 50),
      child: Container(
        width: ScreenUtils.width(context) / 1.2,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
              child: Wrap(children: [
                Text(OlukoLocalizations.get(context, 'deleteMessageConfirm'), style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor))
              ]),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
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
                  child: Text(OlukoLocalizations.get(context, 'cancel')),
                ),
                Container(
                    width: 80,
                    height: 40,
                    child: OlukoNeumorphicPrimaryButton(
                        thinPadding: true,
                        isExpanded: false,
                        title: OlukoLocalizations.get(context, 'delete'),
                        onPressed: () {
                          if (state.isAudioPreview) {
                            setState(() {
                              _audioRecordedElement = null;
                            });
                            BlocProvider.of<GenericAudioPanelBloc>(context).emitDeleteState();
                          } else {
                            BlocProvider.of<CoachAudioMessageBloc>(context).markCoachAudioAsDeleted(state.audioMessage);
                            BlocProvider.of<GenericAudioPanelBloc>(context).emitDefaultState();
                          }
                        }))
              ],
            )
          ],
        ),
      ),
    );
  }

  Container _sendAudioToCoachComponent(BuildContext context) {
    return Container(
      width: ScreenUtils.width(context) / 1.2,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
        child: recordAudioContainer(context),
      ),
    );
  }

  Container recordAudioContainer(BuildContext context) {
    return recordAudioInsideContent(context);
  }

  Container recordAudioInsideContent(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: OlukoNeumorphismColors.appBackgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      width: ScreenUtils.width(context) / 1.6,
      height: 80,
      child: Padding(
        padding: EdgeInsets.fromLTRB(5, ScreenUtils.height(context) * 0.02, 0, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [const SizedBox(width: 0), _recordAudioTextComponent(context), const SizedBox(width: 10), _audioRecordMessageButtonComponent()],
        ),
      ),
    );
  }

  Container _recordAudioTextComponent(BuildContext context) {
    return Container(
      width: ScreenUtils.width(context) / 1.6,
      height: 50,
      decoration: BoxDecoration(
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
        borderRadius: const BorderRadius.all(Radius.circular(25)),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              _recordingAudio
                  ? '${OlukoLocalizations.get(context, 'recordingCapitalText')} ${TimeConverter.durationToString(duration)}'
                  : OlukoLocalizations.get(context, 'askYourCoach'),
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
    );
  }

  Container _audioRecordMessageButtonComponent() {
    return Container(
      clipBehavior: Clip.none,
      width: 50,
      height: 50,
      child: OlukoNeumorphism.isNeumorphismDesign
          ? Neumorphic(
              style: OlukoNeumorphism.getNeumorphicStyleForCirclePrimaryColor(),
              child: microphoneIconButtonContent(iconForContent: Icon(_recordingAudio ? Icons.stop : Icons.mic, size: 23, color: OlukoColors.white)))
          : microphoneIconButtonContent(iconForContent: Icon(_recordingAudio ? Icons.stop : Icons.mic, size: 23, color: OlukoColors.black)),
    );
  }

  Container _audioRecordMessageButtonComponentSentAction() {
    return Container(
      clipBehavior: Clip.none,
      width: 50,
      height: 50,
      child: OlukoNeumorphism.isNeumorphismDesign
          ? Neumorphic(style: OlukoNeumorphism.getNeumorphicStyleForCirclePrimaryColor(), child: sendAudioIconButtonContent())
          : sendAudioIconButtonContent(),
    );
  }

  Widget microphoneIconButtonContent({Icon iconForContent}) {
    return NeumorphicButton(
      padding: EdgeInsets.zero,
      style: OlukoNeumorphism.getNeumorphicStyleForCirclePrimaryColor(),
      onPressed: ()async {
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
      child: iconForContent
    );
  }

  Widget sendAudioIconButtonContent() {
    return NeumorphicButton(
        padding: EdgeInsets.zero,
      style: OlukoNeumorphism.getNeumorphicStyleForCirclePrimaryColor(),
      onPressed:() async {
          BlocProvider.of<CoachAudioMessageBloc>(context)
              .saveAudioForCoach(audioRecorded: File(_recorder.audioUrl), coachId: widget.coachId, userId: widget.userId, audioDuration: _durationToSave);
          BlocProvider.of<GenericAudioPanelBloc>(context).emitDefaultState();
        } ,
        child:  Stack(alignment: Alignment.center, children: [
          if (OlukoNeumorphism.isNeumorphismDesign)
            Image.asset(
              'assets/neumorphic/audio_circle.png',
              scale: 1,
            )
          else
            const SizedBox.shrink(),
          Image.asset(
            'assets/courses/green_circle.png',
            scale: 1,
          ),
          const Icon(Icons.send, color: Colors.white)
        ])
    );
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
