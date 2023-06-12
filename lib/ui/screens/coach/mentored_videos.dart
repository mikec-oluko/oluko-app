import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_mentored_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_video_message_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_helper_functions.dart';
import 'package:oluko_app/helpers/coach_personalized_video.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/coach_personalized_video.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/models/coach_media_message.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class MentoredVideosPage extends StatefulWidget {
  final List<Annotation> coachAnnotation;
  final List<CoachMediaMessage> coachVideoMessage;
  const MentoredVideosPage({this.coachAnnotation, this.coachVideoMessage});

  @override
  _MentoredVideosPageState createState() => _MentoredVideosPageState();
}

class _MentoredVideosPageState extends State<MentoredVideosPage> {
  List<CoachPersonalizedVideo> content = [];
  List<CoachPersonalizedVideo> filteredContent;
  bool isFavoriteSelected = false;
  bool isContentFilteredByDate = false;
  List<CoachPersonalizedVideo> _personalizedVideosList = [];
  UserResponse _currentUser;
  List<Annotation> _updatedAnnotations = [];
  List<CoachMediaMessage> _updatedMessageVideos = [];

  @override
  void initState() {
    _personalizedVideosList =
        CoachHelperFunctions.createPersonalizedVideoFromContent(mentoredVideos: widget.coachAnnotation ?? [], videoMessages: widget.coachVideoMessage ?? []);

    setState(() {
      content.addAll(_personalizedVideosList);
      filteredContent = content;
      filteredContent = contentSortedByDate();
      _updatedMessageVideos = widget.coachVideoMessage ?? [];
      _updatedAnnotations = widget.coachAnnotation ?? [];
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoachVideoMessageBloc, CoachVideoMessageState>(builder: (context, state) {
      if (state is CoachVideoMessageSuccess) {
        _updatedMessageVideos = state.coachVideoMessages;
        if (_personalizedVideosList.isNotEmpty) {
          _updatedMessageVideos.forEach((videoMessage) {
            final _videoMatch = _personalizedVideosList
                .where((videoElement) => videoElement.videoMessageContent != null && videoElement.videoMessageContent.id == videoMessage.id);
            CoachPersonalizedVideo previousContent = _videoMatch.isNotEmpty ? _videoMatch.first : null;
            if (previousContent != null) {
              _personalizedVideosList[_personalizedVideosList.indexOf(previousContent)].videoMessageContent = videoMessage;
            }
          });
          content = _personalizedVideosList;
        }
      }
      return BlocBuilder<CoachMentoredVideosBloc, CoachMentoredVideosState>(
        builder: (context, state) {
          if (state is CoachMentoredVideosSuccess) {
            _updatedAnnotations = state.mentoredVideos;
            if (_personalizedVideosList.isNotEmpty) {
              _updatedAnnotations.forEach((annotation) {
                final _videoMatch = _personalizedVideosList
                    .where((videoElement) => videoElement.annotationContent != null && videoElement.annotationContent.id == annotation.id);
                CoachPersonalizedVideo previousContent = _videoMatch.isNotEmpty ? _videoMatch.first : null;
                if (previousContent != null) {
                  _personalizedVideosList[_personalizedVideosList.indexOf(previousContent)].annotationContent = annotation;
                }
              });
              content = _personalizedVideosList;
            }
          }
          filteredContent = contentSortedByDate();
          return Scaffold(
            backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
            appBar: OlukoAppBar(
              showTitle: true,
              showActions: true,
              centerTitle: true,
              title: OlukoLocalizations.get(context, 'annotatedVideos'),
              actions: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: IconButton(
                          icon: OlukoNeumorphism.isNeumorphismDesign
                              ? Image.asset(
                                  'assets/courses/vector_neumorphism.png',
                                  color: isContentFilteredByDate ? Colors.white : Colors.grey,
                                  height: 20,
                                  width: 20,
                                )
                              : Image.asset(
                                  'assets/courses/vector.png',
                                  color: isContentFilteredByDate ? Colors.white : Colors.grey,
                                  height: 20,
                                  width: 20,
                                ),
                          onPressed: () {
                            setState(() {
                              isContentFilteredByDate = !isContentFilteredByDate;
                              contentSortedByDate();
                            });
                          }),
                    ),
                    IconButton(
                        icon: Icon(isFavoriteSelected ? Icons.favorite : Icons.favorite_border, color: OlukoColors.grayColor),
                        onPressed: () {
                          setState(() {
                            isFavoriteSelected = !isFavoriteSelected;
                            isFavoriteSelected ? filteredContent = getFavoriteContent(content) : filteredContent = content;
                          });
                        }),
                  ],
                )
              ],
            ),
            body: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthSuccess) {
                  _currentUser = state.user;
                }
                return Container(
                  width: MediaQuery.of(context).size.width,
                  color: OlukoNeumorphismColors.appBackgroundColor,
                  child: ListView(addAutomaticKeepAlives: false, addRepaintBoundaries: false, children: segmentCard(videoContent: filteredContent)),
                );
              },
            ),
          );
        },
      );
    });
  }

  List<Widget> segmentCard({List<CoachPersonalizedVideo> videoContent}) {
    List<Widget> contentForSection = [];

    videoContent.forEach((video) {
      contentForSection.add(CoachPersonalizedVideoComponent(personalizedVideo: video, currentUser: _currentUser));
    });

    return contentForSection;
  }

  Widget returnCardForSegment(Annotation coachAnnotation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
            color: OlukoColors.listGrayColor,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            image: DecorationImage(
              image: getImage(coachAnnotation),
              fit: BoxFit.fitWidth,
              onError: (exception, stackTrace) {
                return Text('Your error widget...');
              },
            )),
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: Stack(
          children: [
            Align(
                child: TextButton(
                    onPressed: () {
                      var videoUrl = null;
                      if (coachAnnotation.videoHLS != null) {
                        videoUrl = coachAnnotation.videoHLS;
                      } else {
                        videoUrl = coachAnnotation.video.url;
                      }
                      Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                        'videoUrl': videoUrl,
                        'aspectRatio': coachAnnotation.video.aspectRatio,
                        'titleForContent': OlukoLocalizations.get(context, 'annotatedVideos')
                      });
                    },
                    child: OlukoNeumorphism.isNeumorphismDesign
                        ? SizedBox(
                            width: 70,
                            height: 70,
                            child: OlukoBlurredButton(
                              childContent: Image.asset(
                                'assets/self_recording/white_play_arrow.png',
                                color: Colors.white,
                                height: 50,
                                width: 50,
                              ),
                            ),
                          )
                        : Image.asset(
                            'assets/self_recording/play_button.png',
                            color: Colors.white,
                            height: 40,
                            width: 40,
                          ))),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: OlukoColors.blackColorSemiTransparent,
                  width: MediaQuery.of(context).size.width,
                  height: 45,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (OlukoNeumorphism.isNeumorphismDesign)
                          Text(
                            DateFormat.yMMMd().format(coachAnnotation.createdAt.toDate()),
                            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.lightOrange, customFontWeight: FontWeight.w700),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                OlukoLocalizations.get(context, 'date'),
                                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                DateFormat.yMMMd().format(coachAnnotation.createdAt.toDate()),
                                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.lightOrange, customFontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        IconButton(
                            icon: OlukoNeumorphism.isNeumorphismDesign
                                ? Icon(
                                    coachAnnotation.favorite ? Icons.favorite : Icons.favorite_outline,
                                    color: OlukoColors.primary,
                                    size: 30,
                                  )
                                : Icon(coachAnnotation.favorite ? Icons.favorite : Icons.favorite_outline, color: OlukoColors.white),
                            onPressed: () {
                              BlocProvider.of<CoachMentoredVideosBloc>(context).updateCoachAnnotationFavoriteValue(
                                coachAnnotation: coachAnnotation,
                              );
                            })
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  ImageProvider getImage(Annotation coachAnnotation) {
    return coachAnnotation.video.thumbUrl != null
        ? CachedNetworkImageProvider(coachAnnotation.video.thumbUrl)
        : AssetImage("assets/home/mvtthumbnail.png") as ImageProvider;
  }

  List<CoachPersonalizedVideo> contentSortedByDate() {
    isContentFilteredByDate
        ? filteredContent.sort((a, b) => a.createdAt.toDate().compareTo(b.createdAt.toDate()))
        : filteredContent.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
    return filteredContent;
  }

  List<CoachPersonalizedVideo> getFavoriteContent(List<CoachPersonalizedVideo> videoContent) {
    List<CoachPersonalizedVideo> favoriteContent = [];
    if (videoContent.isNotEmpty) {
      videoContent.forEach((personalizedVideo) {
        if (personalizedVideo.annotationContent != null) {
          if (personalizedVideo.annotationContent.favorite) {
            favoriteContent.add(personalizedVideo);
          }
        } else if (personalizedVideo.videoMessageContent != null) {
          if (personalizedVideo.videoMessageContent.favorite) {
            favoriteContent.add(personalizedVideo);
          }
        }
      });
    }
    return favoriteContent;
  }
}
