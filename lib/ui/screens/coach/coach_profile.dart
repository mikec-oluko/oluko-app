import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
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
  String defaultCoachPic = '';
  bool _isVideoPlaying = false;
  List<Audio> coachAudioList = [];
  List<CoachMedia> coachUploadedContent = [];
  final SoundRecorder recorder = SoundRecorder();
  bool recordingAudio = false;
  bool audioRecorded = false;
  List<String> audiosRecorded = [];
  @override
  void initState() {
    recorder.init();
    BlocProvider.of<CoachMediaBloc>(context).getStream(widget.coachUser.id);
    recordingAudio = recorder.isRecording;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: coachProfileView(context),
    );
  }

  Widget coachProfileView(BuildContext context) {
    return SlidingUpPanel(
      color: OlukoNeumorphismColors.appBackgroundColor,
      maxHeight: 100,
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      panel: askCoachComponent(context),
      body: Container(
        color: OlukoNeumorphismColors.appBackgroundColor,
        constraints: const BoxConstraints.expand(),
        child: ListView(
          clipBehavior: Clip.none,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
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
                  coachGallery(context),
                  // askCoachComponent(context)
                ],
              ),
            ),
          ],
        ),
      ),
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
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          // color: Colors.red,
          child: Stack(
            children: [
              if (audiosRecorded.isNotEmpty)
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: ScreenUtils.height(context) / 3.5,
                  child: audiosRecorded.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.zero,
                          child: ListView(children: audiosRecorded.map((audioPath) => audioSentComponent(context, audioPath)).toList()),
                        )
                      : SizedBox.shrink(),
                )
              else
                const SizedBox.shrink(),
              Align(alignment: Alignment.bottomCenter, child: askCoachMicComponent())
            ],
          )),
    );
  }

  Widget askCoachMicComponent() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
            ),
            width: ScreenUtils.width(context),
            height: 100,
            child: askCoachMicContent())
        : askCoachMicContent();
  }

  Padding askCoachMicContent() {
    final askCoachText = Text(
      OlukoLocalizations.get(context, 'askYourCoach'),
      style: OlukoFonts.olukoMediumFont(
          customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.listGrayColor : OlukoColors.white,
          custoFontWeight: FontWeight.w500),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
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
                        iconForContent: Icon(recordingAudio ? Icons.stop : Icons.mic,
                            size: 23, color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.black)))
                : microphoneIconButtonContent(
                    iconForContent: Icon(recordingAudio ? Icons.stop : Icons.mic,
                        size: 23, color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.black)),
          )
        ],
      ),
    );
  }

  _onRecordCompleted() {
    //TERMINO DE GRABAR
    setState(() {
      audioRecorded = true;
      recordingAudio = false;

      audiosRecorded.add(recorder.audioUrl);
    });
  }

  Widget microphoneIconButtonContent({Icon iconForContent}) {
    return GestureDetector(
        onTap: () async {
          //TODO: EMPIEZA A GRABAR / PARAR VIDEO
          final isRecording = await recorder.toggleRecording();
          setState(() {
            recordingAudio = !recordingAudio;
          });

          if (recorder.isStopped) {
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
    return audioRecorded
        ? CoachAudioSentComponent(
            record: audioPath,
          )
        : SizedBox.shrink();
  }

  Widget coachGallery(BuildContext context) {
    return BlocBuilder<CoachMediaBloc, CoachMediaState>(
      builder: (context, state) {
        if (state is CoachMediaContentUpdate) {
          coachUploadedContent = state.coachMediaContent;
        }
        if (state is CoachMediaContentSuccess) {
          coachUploadedContent = state.coachMediaContent;
        }
        return coachUploadedContent.isNotEmpty
            ? Align(
                child: Padding(
                  padding: EdgeInsets.only(top: audiosRecorded.isNotEmpty ? 100 : 300),
                  child: audiosRecorded.isNotEmpty
                      ? CoachMediaCarouselGallery(
                          coachMedia: coachUploadedContent,
                          coachUser: widget.coachUser,
                        )
                      : ListView(physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            child: Row(
                              children: [
                                const Expanded(child: SizedBox()),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: coachUploadedContent.isNotEmpty
                                      ? GestureDetector(
                                          onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.aboutCoach], arguments: {
                                            'coachBannerVideo': widget.coachUser != null ? widget.coachUser.bannerVideo : null
                                          }),
                                          child: Text(OlukoLocalizations.get(context, 'viewAll'),
                                              style: OlukoFonts.olukoBigFont(
                                                  customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500)),
                                        )
                                      : const SizedBox.shrink(),
                                )
                              ],
                            ),
                          ),
                          CoachMediaGridGallery(
                            coachMedia: coachUploadedContent,
                            limitedContent: true,
                          ),
                        ]),
                ),
              )
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
