import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/coach/coach_media_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/coach_media.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/carousel_small_section.dart';
import 'package:oluko_app/ui/components/coach_information_component.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_video_preview.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoachProfile extends StatefulWidget {
  final CoachUser coachUser;
  const CoachProfile({this.coachUser});

  @override
  _CoachProfileState createState() => _CoachProfileState();
}

class _CoachProfileState extends State<CoachProfile> {
  String _userLocation;
  String defaultCoachPic = '';
  bool _isVideoPlaying = false;
  List<CoachMedia> coachUploadedContent = [];

  @override
  void initState() {
    BlocProvider.of<CoachMediaBloc>(context).getStream(widget.coachUser.id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: CHECK APP BAR WHEN USE DEFAULT APP THEME, NEED APPBAR (DONE: X)
      // extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   elevation: 0.0,
      //   backgroundColor: Colors.transparent,
      //   leading: IconButton(
      //     icon: Icon(
      //       Icons.arrow_back_ios,
      //       color: Colors.white,
      //     ),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      // ),
      body: Container(
        color: OlukoNeumorphismColors.appBackgroundColor,
        constraints: BoxConstraints.expand(),
        child: ListView(
          clipBehavior: Clip.none,
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  widget.coachUser.bannerVideo != null ? coachBannerVideo(context) : coachCover(context),
                  coachInformationComponent(context),
                  uploadCoverButton(context),
                  coachGallery(context),
                  askCoachComponent(context)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container coachCover(BuildContext context) {
    return Container(
      //VIDEO LIKE COVER IMAGE
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3,
      child: widget.coachUser.coverImage == null
          ? SizedBox()
          : Image(
              image: CachedNetworkImageProvider(widget.coachUser.coverImage),
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.colorBurn,
              height: MediaQuery.of(context).size.height,
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
          height: ScreenUtils.height(context) / 2.5,
          // color: Colors.red,
          child: Stack(
            children: [
              //TODO: CHECK NEUMORPHIC, CHECK EMPTY FOR SIZE, ADD STYLE TO AUDIO
              Container(
                width: MediaQuery.of(context).size.width,
                height: ScreenUtils.height(context) / 3.5,
                child: ListView(
                  children: [
                    audioSentComponent(context),
                    audioSentComponent(context),
                    audioSentComponent(context),
                  ],
                ),
              ),
              Align(alignment: Alignment.bottomCenter, child: askCoachMicComponent())
            ],
          )),
    );
  }

  Widget askCoachMicComponent() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
            ),
            width: ScreenUtils.width(context),
            height: 100,
            child: askCoachMicContent())
        : askCoachMicContent();
  }

  Padding askCoachMicContent() {
    final askCoachText = Text(
      "Ask your coach",
      style: OlukoFonts.olukoMediumFont(
          customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.listGrayColor : OlukoColors.white,
          custoFontWeight: FontWeight.w500),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OlukoNeumorphism.isNeumorphismDesign
              ? Expanded(
                  child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                      ),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: askCoachText,
                          ))))
              : askCoachText,
          SizedBox(
            width: 20,
          ),
          Container(
            clipBehavior: Clip.none,
            width: 40,
            height: 40,
            child: OlukoNeumorphism.isNeumorphismDesign
                ? Neumorphic(style: OlukoNeumorphism.getNeumorphicStyleForCirclePrimaryColor(), child: microphoneIconButtonContent())
                : microphoneIconButtonContent(),
          )
        ],
      ),
    );
  }

  TextButton microphoneIconButtonContent() {
    return TextButton(
        onPressed: () {},
        child: Icon(
          Icons.mic_rounded,
          color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.primary,
        ));
  }

  Container audioSentComponent(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Visibility(
          visible: true,
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/assessment/play.png',
                      scale: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Image.asset(
                        'assets/courses/coach_audio.png',
                        width: 150,
                        fit: BoxFit.fill,
                        scale: 5,
                      ),
                    ),
                  ],
                ),
                VerticalDivider(color: OlukoColors.grayColor),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/courses/coach_delete.png',
                        scale: 5,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Image.asset(
                        'assets/courses/coach_tick.png',
                        scale: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        return Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: CarouselSmallSection(
                  userToGetData: widget.coachUser as UserResponse,
                  routeToGo: RouteEnum.aboutCoach,
                  title: '',
                  children: coachUploadedContent
                      .map((mediaContent) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ImageAndVideoContainer(
                                backgroundImage: mediaContent.video.thumbUrl,
                                isContentVideo: true,
                                videoUrl: mediaContent.video.url,
                                displayOnViewNamed: ActualProfileRoute.transformationJourney,
                                originalContent: mediaContent,
                                isCoachMediaContent: true),
                          ))
                      .toList(),
                )),
          ),
        );
      },
    );
  }

//

  Positioned uploadCoverButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height / 5,
      right: 10,
      child: Visibility(
        visible: false,
        child: Container(
          clipBehavior: Clip.none,
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
