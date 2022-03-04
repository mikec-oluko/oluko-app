import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/coach/coach_audio_panel_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_media_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_media.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/coach_audio_sent_component.dart';
import 'package:oluko_app/ui/components/coach_cover_image.dart';
import 'package:oluko_app/ui/components/coach_information_component.dart';
import 'package:oluko_app/ui/components/coach_media_carousel_gallery.dart';
import 'package:oluko_app/ui/components/coach_media_grid_gallery.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_video_preview.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/sound_recorder.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class CoachProfile extends StatefulWidget {
  final CoachUser coachUser;
  const CoachProfile({this.coachUser});
  @override
  _CoachProfileState createState() => _CoachProfileState();
}

class _CoachProfileState extends State<CoachProfile> {
  final String _defaultCoachPic = '';
  bool _isVideoPlaying = false;
  List<Audio> _coachAudioList = [];
  List<CoachMedia> _coachUploadedContent = [];
  final SoundRecorder _recorder = SoundRecorder();
  bool _recordingAudio = false;
  bool _audioRecorded = false;
  List<String> _audiosRecorded = [];
  double _audioPanelMaxSize = 100.0;
  Widget _audioRecordedElement;
  final PanelController _panelController = PanelController();

  @override
  void initState() {
    _recorder.init();
    BlocProvider.of<CoachMediaBloc>(context).getStream(widget.coachUser.id);
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
        }
        if (state is CoachAudioPanelDeleted) {
          _audioPanelMaxSize = state.panelMaxSize;
        }
        if (state is CoachAudioPanelRecorded) {
          _audioPanelMaxSize = state.panelMaxSize;
          _audioRecordedElement = state.audioRecoded;
          _panelController.animatePanelToPosition(1);
        }

        if (state is CoachAudioPanelConfirmDelete) {
          _audioPanelMaxSize = state.panelMaxSize;
        }
        return SlidingUpPanel(
          isDraggable: false,
          controller: _panelController,
          minHeight: 100.0,
          color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
          maxHeight: _audioPanelMaxSize,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          panel: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [askCoachMicComponent(recordedAudioWidget: _audioRecordedElement ?? null)],
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
                askCoachComponent(context),
                if (_audiosRecorded.isNotEmpty)
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
        //VIDEO LIKE COVER IMAGE
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

  Widget askCoachComponent(BuildContext context) {
    return _audiosRecorded.isNotEmpty
        ? Column(children: _audiosRecorded.map((audioPath) => audioSentComponent(context, audioPath)).toList())
        : const SizedBox.shrink();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          if (audioRecorded != null) audioRecorded else const SizedBox.shrink(),
          Row(
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
          ),
        ],
      ),
    );
  }

  _onRecordCompleted() {
    //TERMINO DE GRABAR
    setState(() {
      _audioRecorded = true;
      _recordingAudio = false;
      _audiosRecorded.add(_recorder.audioUrl);
      BlocProvider.of<CoachAudioPanelBloc>(context).emitRecordedState(audioWidget: audioSentComponent(context, _recorder.audioUrl));
    });
  }

  Widget microphoneIconButtonContent({Icon iconForContent}) {
    return GestureDetector(
        onTap: () async {
          //TODO: EMPIEZA A GRABAR / PARAR VIDEO
          final isRecording = await _recorder.toggleRecording();
          setState(() {
            _recordingAudio = !_recordingAudio;
          });

          if (_recorder.isStopped) {
            //SALVA LA GRABACION
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
    return _audioRecorded
        ? CoachAudioSentComponent(
            record: audioPath,
          )
        : SizedBox.shrink();
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
            ? _audiosRecorded.isNotEmpty
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
