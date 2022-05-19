import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/coach/coach_audio_messages_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_audio_panel_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_media_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_audio_message.dart';
import 'package:oluko_app/models/coach_media.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/coach_audio_sent_component.dart';
import 'package:oluko_app/ui/components/coach_confirm_delete_component.dart';
import 'package:oluko_app/ui/components/coach_cover_image.dart';
import 'package:oluko_app/ui/components/coach_information_component.dart';
import 'package:oluko_app/ui/components/coach_media_carousel_gallery.dart';
import 'package:oluko_app/ui/components/coach_media_grid_gallery.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_video_preview.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/sound_recorder.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class CoachProfile extends StatefulWidget {
  final CoachUser coachUser;
  final UserResponse currentUser;
  const CoachProfile({this.coachUser, this.currentUser});
  @override
  _CoachProfileState createState() => _CoachProfileState();
}

class _CoachProfileState extends State<CoachProfile> {
  final SoundRecorder _recorder = SoundRecorder();
  final PanelController _panelController = PanelController();
  final int _audioMessageRangeValue = 5;
  Timer _timer;
  bool _isVideoPlaying = false;
  bool _recordingAudio = false;
  bool _audioRecorded = false;
  int _groupedElementCount = 0;
  double _audioPanelMaxSize = 100.0;
  Duration duration = Duration();
  Duration _durationToSave = Duration();
  List<CoachAudioMessage> _coachAudioMessages = [];
  List<CoachAudioMessage> _groupedAudioMessages = [];
  List<CoachMedia> _coachUploadedContent = [];
  List<String> _audiosRecorded = [];
  Widget _audioRecordedElement;
  Widget _panelNewContent;
  Widget _audioMessageSection;

  @override
  void initState() {
    !_recorder.isInitialized ? _recorder.init() : null;
    BlocProvider.of<CoachMediaBloc>(context).getStream(widget.coachUser.id);
    BlocProvider.of<CoachAudioMessageBloc>(context).getStream(userId: widget.currentUser.id, coachId: widget.coachUser.id);
    BlocProvider.of<CoachAudioPanelBloc>(context).emitDefaultState();
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
    return Scaffold(
      body: coachProfileView(context),
    );
  }

  Widget coachProfileView(BuildContext context) {
    return BlocBuilder<CoachAudioPanelBloc, CoachAudioPanelState>(
      buildWhen: (CoachAudioPanelState previous, CoachAudioPanelState current) => previous != current,
      builder: (context, state) {
        if (state is CoachAudioPanelDefault) {
          _audioPanelMaxSize = state.panelMaxSize;
          _audiosRecorded.clear();
          _recordingAudio = _recorder.isRecording;
          _panelNewContent = askCoachPanelComponent();
        }
        if (state is CoachAudioPanelDeleted) {
          _audioPanelMaxSize = state.panelMaxSize;
          _audioRecorded = !_audioRecorded;
          _audiosRecorded.clear();
          _panelNewContent = askCoachPanelComponent(recordedAudioWidget: _audioRecordedElement);
        }
        if (state is CoachAudioPanelRecorded) {
          _audioPanelMaxSize = state.panelMaxSize;
          _audioRecordedElement = state.audioRecoded;
          _panelController.animatePanelToPosition(1);
          _panelNewContent = askCoachPanelComponent(recordedAudioWidget: _audioRecordedElement);
        }
        if (state is CoachAudioPanelConfirmDelete) {
          _audioPanelMaxSize = state.panelMaxSize;
          _panelController.panelPosition != 1 ? _panelController.animatePanelToPosition(1) : null;
          _panelNewContent = confirmDeleteComponent(
              context: context, isPreviewContent: state.isAudioPreview, audioMessage: !state.isAudioPreview ? state.audioMessage : null);
        }
        return SlidingUpPanel(
          parallaxEnabled: true,
          isDraggable: false,
          controller: _panelController,
          color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
          maxHeight: _audioPanelMaxSize,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          panel: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Expanded(child: _panelNewContent)],
          ),
          body: BlocBuilder<CoachAudioMessageBloc, CoachAudioMessagesState>(
            builder: (context, state) {
              if (state is CoachAudioMessagesSuccess) {
                if (_coachAudioMessages.isEmpty) {
                  _coachAudioMessages = state.coachAudioMessages;
                  _coachAudioMessages.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
                } else {
                  _checkAudioMessageStream(audioMessages: state.coachAudioMessages);
                }
                manageAudioGroupList();
                _audioMessageSection = _coachAudioMessages.isNotEmpty ? audioMessageListComponent(context) : const SizedBox.shrink();
              }
              return Container(
                width: ScreenUtils.width(context),
                color: OlukoNeumorphismColors.appBackgroundColor,
                constraints: const BoxConstraints.expand(),
                child: ListView(
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    coachBannerAndInfoSection(context),
                    SizedBox(
                      height: ScreenUtils.height(context) / 12,
                    ),
                    coachGallery(context),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: _audioMessageSection,
                    ),
                    if (_coachAudioMessages.isNotEmpty)
                      const SizedBox(
                        height: 110,
                      )
                    else
                      const SizedBox.shrink()
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void manageAudioGroupList() {
    if (_groupedAudioMessages.isEmpty && _coachAudioMessages.isNotEmpty) {
      if (_getAudioListsDifference > _audioMessageRangeValue) {
        _groupedAudioMessages = _coachAudioMessages.getRange(0, _audioMessageRangeValue).toList();
      } else {
        _groupedAudioMessages = _coachAudioMessages;
      }
      _groupedElementCount = _groupedAudioMessages.length;
    } else {
      if (_groupedElementCount >= _coachAudioMessages.length) {
        _groupedAudioMessages = _coachAudioMessages;
      } else {
        _groupedAudioMessages = _coachAudioMessages.getRange(0, _groupedElementCount).toList();
      }
    }
    if (_groupedAudioMessages.where((audioElement) => audioElement.createdAt == null).toList().isEmpty) {
      _groupedAudioMessages.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
    }
  }

  void _checkAudioMessageStream({List<CoachAudioMessage> audioMessages}) {
    List<CoachAudioMessage> _newAudioElements = [];
    List<CoachAudioMessage> _deletedAudioElements = [];
    List<CoachAudioMessage> _coachAudioListToUpdate = _coachAudioMessages;

    _coachAudioMessages.forEach((currentAudioMessage) {
      if (audioMessages.where((newAudioMessage) => newAudioMessage.id == currentAudioMessage.id).toList().isEmpty) {
        _deletedAudioElements.add(currentAudioMessage);
      }
    });
    audioMessages.forEach((newAudioElement) {
      if (_coachAudioMessages.where((currentAudioMessage) => currentAudioMessage.id == newAudioElement.id).toList().isEmpty) {
        _newAudioElements.add(newAudioElement);
      }
    });
    if (_newAudioElements.isNotEmpty) {
      _coachAudioListToUpdate = [..._coachAudioListToUpdate, ..._newAudioElements];
    }
    if (_deletedAudioElements.isNotEmpty) {
      _deletedAudioElements.forEach((audioRemoved) {
        _coachAudioListToUpdate.removeAt(_coachAudioListToUpdate.indexOf(audioRemoved));
      });
    }
    _coachAudioMessages = _coachAudioListToUpdate;

    if (_coachAudioMessages.where((audioElement) => audioElement.createdAt == null).toList().isEmpty) {
      _coachAudioMessages.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
    }
  }

  Stack coachBannerAndInfoSection(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (true)
          coachBannerVideo(context)
        else
          CoachCoverImage(
            coachUser: widget.coachUser,
          ),
        coachInformationComponent(context),
        uploadCoverButton(context),
      ],
    );
  }

  Widget coachGallery(BuildContext context) {
    return BlocBuilder<CoachMediaBloc, CoachMediaState>(
      builder: (context, state) {
        if (state is CoachMediaContentUpdate) {
          _coachUploadedContent = state.coachMediaContent;
        }
        if (state is CoachMediaContentSuccess) {
          _coachUploadedContent = state.coachMediaContent;
        }
        if (state is CoachMediaDispose) {
          _coachUploadedContent = state.coachMediaDisposeValue;
        }
        return _coachUploadedContent.isNotEmpty
            ? _coachAudioMessages.isNotEmpty
                ? CoachMediaCarouselGallery(
                    coachMedia: _coachUploadedContent,
                    coachUser: widget.coachUser,
                  )
                : coachMediaGridComponent(context)
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 300,
              );
      },
    );
  }

  Column coachMediaGridComponent(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            const Expanded(child: SizedBox()),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _coachUploadedContent.isNotEmpty
                  ? GestureDetector(
                      onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.aboutCoach],
                          arguments: {'coachBannerVideo': widget.coachUser != null ? widget.coachUser.bannerVideo : null}),
                      child: Text(OlukoLocalizations.get(context, 'viewAll'),
                          style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500)),
                    )
                  : const SizedBox.shrink(),
            )
          ],
        ),
      ),
      CoachMediaGridGallery(
        coachMedia: _coachUploadedContent,
        limitedContent: true,
      ),
    ]);
  }

  Column audioMessageListComponent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: _hasMoreThanRange
              ? GestureDetector(
                  onTap: () {
                    if (_getAudioListsDifference > 0) {
                      if (_getAudioListsDifference > _audioMessageRangeValue) {
                        setState(() {
                          _groupedElementCount = _groupedElementCount + _audioMessageRangeValue;
                        });
                      } else {
                        setState(() {
                          _groupedElementCount = _coachAudioMessages.length;
                        });
                      }
                    }
                  },
                  child: _getAudioListsDifference > 0
                      ? Text(
                          _getAudioListsDifference >= _audioMessageRangeValue
                              ? _seeMoreAudios(nextRangeValue: _audioMessageRangeValue)
                              : _seeMoreAudios(nextRangeValue: _getAudioListsDifference),
                          style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500))
                      : const SizedBox.shrink(),
                )
              : const SizedBox.shrink(),
        ),
        Column(
            children: !_hasMoreThanRange
                ? _coachAudioMessages
                    .map((audioMessageItem) => audioSentComponent(
                        context: context,
                        audioPath: audioMessageItem.audioMessage.url,
                        isPreview: false,
                        audioMessageItem: audioMessageItem))
                    .toList()
                : _groupedAudioMessages
                    .map((audioMessageItem) => audioSentComponent(
                        context: context,
                        audioPath: audioMessageItem.audioMessage.url,
                        isPreview: false,
                        audioMessageItem: audioMessageItem))
                    .toList()),
      ],
    );
  }

  int get _getAudioListsDifference => _coachAudioMessages.length - _groupedAudioMessages.length;

  bool get _hasMoreThanRange => _coachAudioMessages.length > _audioMessageRangeValue;

  String _seeMoreAudios({@required int nextRangeValue}) =>
      '${OlukoLocalizations.get(context, 'see')} $nextRangeValue ${OlukoLocalizations.get(context, 'more')}';

  Padding confirmDeleteComponent({BuildContext context, bool isPreviewContent, CoachAudioMessage audioMessage}) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: CoachConfirmDeleteComponent(
          allowAction: () {
            if (isPreviewContent) {
              setState(() {
                _audioRecordedElement = null;
              });
              BlocProvider.of<CoachAudioPanelBloc>(context).emitDeleteState();
            } else {
              BlocProvider.of<CoachAudioMessageBloc>(context).markCoachAudioAsDeleted(audioMessage);
              BlocProvider.of<CoachAudioPanelBloc>(context).emitDefaultState();
            }
          },
          denyAction: () {
            if (isPreviewContent) {
              setState(() {
                BlocProvider.of<CoachAudioPanelBloc>(context).emitRecordedState(
                    audioWidget: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: audioSentComponent(context: context, audioPath: _recorder.audioUrl, isPreview: true),
                ));
              });
            } else {
              BlocProvider.of<CoachAudioPanelBloc>(context).emitDefaultState();
            }
          },
          isPreviewContent: isPreviewContent,
        ));
  }

  Container coachBannerVideo(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3,
        child: OlukoVideoPreview(
          video:widget.coachUser.bannerVideo,
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
          onPlay: () => isVideoPlaying(),
          videoVisibilty: _isVideoPlaying,
          bannerVideo: true,
        ));
  }

  Widget askCoachPanelComponent({Widget recordedAudioWidget}) {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Container(width: ScreenUtils.width(context), child: askCoachPanelContent(audioRecorded: recordedAudioWidget))
        : askCoachPanelContent(audioRecorded: recordedAudioWidget);
  }

  Padding askCoachPanelContent({Widget audioRecorded}) {
    final askCoachText = Text(
      _recordingAudio
          ? '${OlukoLocalizations.get(context, 'recordingCapitalText')} ${TimeConverter.durationToString(duration)}'
          : OlukoLocalizations.get(context, 'askYourCoach'),
      style: OlukoFonts.olukoMediumFont(
          customColor: OlukoNeumorphism.isNeumorphismDesign
              ? _recordingAudio
                  ? OlukoColors.primary
                  : OlukoColors.listGrayColor
              : OlukoColors.white,
          custoFontWeight: FontWeight.w500),
    );
    return recordAudioElement(audioRecorded, askCoachText);
  }

  Padding recordAudioElement(Widget audioRecorded, Text askCoachText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (audioRecorded != null) audioRecorded else const SizedBox.shrink(),
          if (audioRecorded == null) recordAudioTextAndButton(askCoachText) else saveAudioButton()
        ],
      ),
    );
  }

  Container saveAudioButton() {
    return Container(
        width: ScreenUtils.width(context) - 40,
        child: OlukoNeumorphicPrimaryButton(
            isExpanded: false,
            title: OlukoLocalizations.get(context, 'saveAudioCoach'),
            onPressed: () {
              BlocProvider.of<CoachAudioMessageBloc>(context).saveAudioForCoach(
                  audioRecorded: File(_recorder.audioUrl),
                  coachId: widget.coachUser.id,
                  userId: widget.currentUser.id,
                  audioDuration: _durationToSave);
              BlocProvider.of<CoachAudioPanelBloc>(context).emitDefaultState();
              setState(() {
                _audioRecorded = !_audioRecorded;
                _recordingAudio = !_recordingAudio;
              });
            }));
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

  addTime() {
    final addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }

  Row recordAudioTextAndButton(Text askCoachText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (OlukoNeumorphism.isNeumorphismDesign)
          Expanded(
              child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: !_recordingAudio
                        ? null
                        : Border.all(
                            width: 2.0,
                            color: OlukoColors.primary,
                          ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                  ),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: askCoachText,
                      ))))
        else
          askCoachText,
        const SizedBox(
          width: 20,
        ),
        Container(
          clipBehavior: Clip.none,
          width: 40,
          height: 40,
          child: OlukoNeumorphism.isNeumorphismDesign
              ? Neumorphic(
                  style: OlukoNeumorphism.getNeumorphicStyleForCirclePrimaryColor(),
                  child: microphoneIconButtonContent(
                      iconForContent: Icon(_recordingAudio ? Icons.stop : Icons.mic, size: 23, color: OlukoColors.white)))
              : microphoneIconButtonContent(
                  iconForContent: Icon(_recordingAudio ? Icons.stop : Icons.mic, size: 23, color: OlukoColors.black)),
        )
      ],
    );
  }

  Widget microphoneIconButtonContent({Icon iconForContent}) {
    return GestureDetector(
        onTap: () async {
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

  Widget audioSentComponent({BuildContext context, String audioPath, bool isPreview, CoachAudioMessage audioMessageItem}) {
    return CoachAudioSentComponent(
      record: audioPath,
      audioMessageItem: audioMessageItem,
      isPreviewContent: isPreview,
      durationFromRecord: isPreview ? _durationToSave : Duration(milliseconds: audioMessageItem?.audioMessage?.duration),
      onDelete: () => BlocProvider.of<CoachAudioPanelBloc>(context)
          .emitConfirmDeleteState(isPreviewContent: isPreview, audioMessageItem: !isPreview ? audioMessageItem : null),
    );
  }

  Positioned uploadCoverButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height / 5,
      right: 10,
      child: Visibility(
        visible: false,
        child: Container(
          width: 40,
          height: 40,
          child: TextButton(onPressed: () {}, child: Image.asset('assets/profile/uploadImage.png')),
        ),
      ),
    );
  }

  Widget coachInformationComponent(BuildContext context) {
    return CoachInformationComponent(
      coachUser: widget.coachUser,
    );
  }

  void isVideoPlaying() {
    return setState(() {
      _isVideoPlaying = !_isVideoPlaying;
    });
  }

  void _onRecordCompleted() {
    setState(() {
      _audioRecorded = true;
      _recordingAudio = false;
      _audiosRecorded.add(_recorder.audioUrl);
      BlocProvider.of<CoachAudioPanelBloc>(context).emitRecordedState(
          audioWidget: Padding(
        padding: const EdgeInsets.all(8.0),
        child: audioSentComponent(context: context, audioPath: _recorder.audioUrl, isPreview: true),
      ));
    });
  }
}
