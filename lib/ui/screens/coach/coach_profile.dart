import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_media_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/coach_media.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/ui/components/carousel_small_section.dart';
import 'package:oluko_app/ui/components/coach_information_component.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_video_preview.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';

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
          onPlay: () => false,
          videoVisibilty: true,
          bannerVideo: true,
        ));
  }

  Widget askCoachComponent(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          //VIDEO LIKE COVER IMAGE
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            // color: Colors.blue,
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Visibility(
                              visible: false,
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
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Ask your coach",
                            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                          ),
                          Container(
                            clipBehavior: Clip.none,
                            width: 40,
                            height: 40,
                            child: TextButton(
                                onPressed: () {},
                                child: Icon(
                                  Icons.mic_rounded,
                                  color: OlukoColors.primary,
                                )),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          )),
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
                  title: '',
                  children: coachUploadedContent
                      .map((mediaContent) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ImageAndVideoContainer(
                                backgroundImage: null,
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
}
