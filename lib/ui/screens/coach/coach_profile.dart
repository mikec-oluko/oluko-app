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
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/coach_audio_sent_component.dart';
import 'package:oluko_app/ui/components/coach_cover_image.dart';
import 'package:oluko_app/ui/components/coach_information_component.dart';
import 'package:oluko_app/ui/components/coach_media_carousel_gallery.dart';
import 'package:oluko_app/ui/components/coach_media_grid_gallery.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_video_preview.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/sound_recorder.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class CoachProfile extends StatefulWidget {
  final CoachUser coachUser;
  final UserResponse currentUser;
  const CoachProfile({this.coachUser, this.currentUser});
  @override
  _CoachProfileState createState() => _CoachProfileState();
}

class _CoachProfileState extends State<CoachProfile> {
  final String _defaultCoachPic = '';
  bool _isVideoPlaying = false;
  List<CoachAudioMessage> _coachAudioMessages = [];
  List<CoachMedia> _coachUploadedContent = [];
  final SoundRecorder _recorder = SoundRecorder();
  bool _recordingAudio = false;
  bool _audioRecorded = false;
  List<String> _audiosRecorded = [];
  double _audioPanelMaxSize = 100.0;
  Widget _audioRecordedElement;
  Widget _panelNewContent;
  final PanelController _panelController = PanelController();

  @override
  void initState() {
    _recorder.init();
    BlocProvider.of<CoachMediaBloc>(context).getStream(widget.coachUser.id);
    BlocProvider.of<CoachAudioMessageBloc>(context).getStream(widget.currentUser.id, widget.coachUser.id);
    BlocProvider.of<CoachAudioPanelBloc>(context).emitDefaultState();
    _recordingAudio = _recorder.isRecording;
    super.initState();
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
          _panelNewContent = askCoachMicComponent(recordedAudioWidget: _audioRecordedElement ?? null);
        }
        if (state is CoachAudioPanelDeleted) {
          _audioPanelMaxSize = state.panelMaxSize;
          _audioRecorded = !_audioRecorded;
          _audiosRecorded.clear();
          _panelNewContent = askCoachMicComponent(recordedAudioWidget: _audioRecordedElement ?? null);
        }
        if (state is CoachAudioPanelRecorded) {
          _audioPanelMaxSize = state.panelMaxSize;
          _audioRecordedElement = state.audioRecoded;
          _panelController.animatePanelToPosition(1);
          _panelNewContent = askCoachMicComponent(recordedAudioWidget: _audioRecordedElement ?? null);
        }
        if (state is CoachAudioPanelConfirmDelete) {
          _audioPanelMaxSize = state.panelMaxSize;
          _panelNewContent = confirmDeleteComponent(context);
        }
        return SlidingUpPanel(
          parallaxEnabled: true,
          backdropEnabled: false,
          isDraggable: false,
          controller: _panelController,
          minHeight: 100.0,
          color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
          maxHeight: _audioPanelMaxSize,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          panel: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Expanded(child: _panelNewContent)],
          ),
          body: Container(
            width: ScreenUtils.width(context),
            height: ScreenUtils.height(context),
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
                coachAudioMessagesList(context),
                if (_coachAudioMessages.isNotEmpty)
                  const SizedBox(
                    height: 110,
                  )
                else
                  const SizedBox.shrink()
              ],
            ),
          ),
        );
      },
    );
  }

  //TODO: QUITAR COMO WIDGET
  Padding confirmDeleteComponent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(OlukoLocalizations.get(context, 'cancelVoiceMessage'),
                  style: OlukoFonts.olukoSubtitleFont(customColor: OlukoColors.white)),
              Text(OlukoLocalizations.get(context, 'deleteMessageConfirm'),
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor))
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      BlocProvider.of<CoachAudioPanelBloc>(context).emitRecordedState(
                          audioWidget: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: audioSentComponent(context, _recorder.audioUrl),
                      ));
                    });
                  },
                  child: Text('Deny'),
                ),
                Container(
                    width: 80,
                    height: 50,
                    child: OlukoNeumorphicPrimaryButton(
                        isExpanded: false,
                        title: 'Allow',
                        onPressed: () {
                          setState(() {
                            _audioRecordedElement = null;
                          });
                          BlocProvider.of<CoachAudioPanelBloc>(context).emitDeleteState();
                        }))
              ],
            ),
          )
        ],
      ),
    );
  }

  Stack coachBannerAndInfoSection(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (widget.coachUser.bannerVideo != null)
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

  Container coachBannerVideo(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3,
        child: OlukoVideoPreview(
          video: widget.coachUser.bannerVideo,
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
          onPlay: () => isVideoPlaying(),
          videoVisibilty: _isVideoPlaying,
          bannerVideo: true,
        ));
  }

  Widget coachAudioMessagesList(BuildContext context) {
    return BlocBuilder<CoachAudioMessageBloc, CoachAudioMessagesState>(
        buildWhen: (CoachAudioMessagesState previous, CoachAudioMessagesState current) => previous != current,
        builder: (context, state) {
          if (state is CoachAudioMessagesSuccess) {
            _coachAudioMessages = state.coachAudioMessages;
          }
          return _coachAudioMessages.isNotEmpty
              ? Column(
                  children: _coachAudioMessages.map((audioMessage) => audioSentComponent(context, audioMessage.audioMessage.url)).toList())
              : const SizedBox.shrink();
        });
  }

  Widget askCoachMicComponent({Widget recordedAudioWidget}) {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Container(width: ScreenUtils.width(context), child: askCoachMicContent(audioRecorded: recordedAudioWidget))
        : askCoachMicContent(audioRecorded: recordedAudioWidget);
  }

  Padding askCoachMicContent({Widget audioRecorded}) {
    final askCoachText = Text(
      OlukoLocalizations.get(context, 'askYourCoach'),
      style: OlukoFonts.olukoMediumFont(
          customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.listGrayColor : OlukoColors.white,
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
          if (audioRecorded == null)
            recordAudioTextAndButton(askCoachText)
          else
            Container(
                width: ScreenUtils.width(context) - 40,
                child: OlukoNeumorphicPrimaryButton(
                    isExpanded: false,
                    title: 'Save audio for coach',
                    onPressed: () {
                      BlocProvider.of<CoachAudioMessageBloc>(context)
                          .saveAudioForCoach(File(_recorder.audioUrl), widget.currentUser.id, widget.coachUser.id);
                      BlocProvider.of<CoachAudioPanelBloc>(context).emitDefaultState();
                    }))
        ],
      ),
    );
  }

  Row recordAudioTextAndButton(Text askCoachText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (OlukoNeumorphism.isNeumorphismDesign)
          Expanded(
              child: Container(
                  height: 40,
                  decoration: const BoxDecoration(
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
                      iconForContent: Icon(_recordingAudio ? Icons.stop : Icons.mic,
                          size: 23, color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.black)))
              : microphoneIconButtonContent(
                  iconForContent: Icon(_recordingAudio ? Icons.stop : Icons.mic,
                      size: 23, color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.black)),
        )
      ],
    );
  }

  _onRecordCompleted() {
    setState(() {
      _audioRecorded = true;
      _recordingAudio = false;
      _audiosRecorded.add(_recorder.audioUrl);
      BlocProvider.of<CoachAudioPanelBloc>(context).emitRecordedState(
          audioWidget: Padding(
        padding: const EdgeInsets.all(8.0),
        child: audioSentComponent(context, _recorder.audioUrl),
      ));
    });
  }

  Widget microphoneIconButtonContent({Icon iconForContent}) {
    return GestureDetector(
        onTap: () async {
          final isRecording = await _recorder.toggleRecording();

          setState(() {
            _recordingAudio = !_recordingAudio;
          });

          if (_recorder.isStopped) {
            _onRecordCompleted();
          }
        },
        child: Stack(alignment: Alignment.center, children: [
          OlukoNeumorphism.isNeumorphismDesign
              ? Image.asset(
                  'assets/neumorphic/audio_circle.png',
                  scale: 4,
                )
              : SizedBox(),
          Image.asset(
            'assets/courses/green_circle.png',
            scale: 6,
          ),
          iconForContent
        ]));
  }

  Widget audioSentComponent(BuildContext context, String audioPath) {
    return CoachAudioSentComponent(
      record: audioPath,
      isPreviewContent: true,
      onDelete: () => BlocProvider.of<CoachAudioPanelBloc>(context).emitConfirmDeleteState(),
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
        return _coachUploadedContent.isNotEmpty
            ? _coachAudioMessages.isNotEmpty
                ? CoachMediaCarouselGallery(
                    coachMedia: _coachUploadedContent,
                    coachUser: widget.coachUser,
                  )
                : Column(children: [
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
                  ])
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 300,
              );
      },
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
}
