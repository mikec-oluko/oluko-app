import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_audio_messages_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_audio_panel_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_media_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_user_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_audio_message.dart';
import 'package:oluko_app/models/coach_media.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/audio_sent_component.dart';
import 'package:oluko_app/ui/components/audio_sent_component.dart';
import 'package:oluko_app/ui/components/coach_cover_image.dart';
import 'package:oluko_app/ui/components/coach_information_component.dart';
import 'package:oluko_app/ui/components/coach_media_carousel_gallery.dart';
import 'package:oluko_app/ui/components/coach_media_grid_gallery.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_video_preview.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoachProfile extends StatefulWidget {
  final CoachUser coachUser;
  final UserResponse currentUser;
  const CoachProfile({this.coachUser, this.currentUser});
  @override
  _CoachProfileState createState() => _CoachProfileState();
}

class _CoachProfileState extends State<CoachProfile> {
  final int _audioMessageRangeValue = 5;
  Timer _timer;
  bool _isVideoPlaying = false;
  int _groupedElementCount = 0;
  double _audioPanelMaxSize = 100.0;
  Duration duration = Duration();
  Duration _durationToSave = Duration();
  List<CoachAudioMessage> _coachAudioMessages = [];
  List<CoachAudioMessage> _groupedAudioMessages = [];
  List<CoachMedia> _coachUploadedContent = [];
  Widget _audioMessageSection;
  bool _isAudioPlaying = false;
  CoachUser _coachUser;

  @override
  void initState() {
    BlocProvider.of<GenericAudioPanelBloc>(context).emitDefaultState();
    BlocProvider.of<CoachMediaBloc>(context).dispose();
    BlocProvider.of<CoachUserBloc>(context).get(widget.coachUser.id);
    BlocProvider.of<CoachMediaBloc>(context).getStream(widget.coachUser.id);
    BlocProvider.of<CoachAudioMessageBloc>(context).getStream(userId: widget.currentUser.id, coachId: widget.coachUser.id);
    BlocProvider.of<CoachAssignmentBloc>(context).getCoachAssignmentStatusStream(widget.currentUser.id);
    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: coachProfileView(context));
  }

  Widget coachProfileView(BuildContext context) {
    return BlocBuilder<CoachAssignmentBloc, CoachAssignmentState>(
      builder: (context, state) {
        if (state is CoachAssignmentResponse && _coachUser != null && state.coachAssignmentResponse.coachId != _coachUser.id) {
          BlocProvider.of<CoachMediaBloc>(context).dispose();
          BlocProvider.of<CoachUserBloc>(context).get(state.coachAssignmentResponse.coachId);
          BlocProvider.of<CoachMediaBloc>(context).getStream(state.coachAssignmentResponse.coachId);
          BlocProvider.of<CoachAudioMessageBloc>(context).getStream(userId: widget.currentUser.id, coachId: state.coachAssignmentResponse.coachId);
        }
        return BlocBuilder<CoachUserBloc, CoachUserState>(
          builder: (context, state) {
            if (state is CoachUserSuccess) {
              _coachUser = state.coach;
              return BlocBuilder<CoachAudioMessageBloc, CoachAudioMessagesState>(
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
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false,
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
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      },
    );
    // },
    // );
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
        if (_coachUser.bannerVideo != null)
          coachBannerVideo(context)
        else
          CoachCoverImage(
            coachUser: _coachUser,
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
                    coachUser: _coachUser,
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
                      onTap: () => Navigator.pushNamed(
                        context,
                        routeLabels[RouteEnum.aboutCoach],
                        arguments: {'coachBannerVideo': _coachUser != null ? _coachUser.bannerVideo : null},
                      ),
                      child: Text(OlukoLocalizations.get(context, 'viewAll'),
                          style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, customFontWeight: FontWeight.w500)),
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
                          style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, customFontWeight: FontWeight.w500))
                      : const SizedBox.shrink(),
                )
              : const SizedBox.shrink(),
        ),
        Column(
            children: !_hasMoreThanRange
                ? _coachAudioMessages
                    .map((audioMessageItem) => audioSentComponent(
                        context: context, audioPath: audioMessageItem.audioMessage.url, isPreview: false, audioMessageItem: audioMessageItem))
                    .toList()
                : _groupedAudioMessages
                    .map((audioMessageItem) => audioSentComponent(
                        context: context, audioPath: audioMessageItem.audioMessage.url, isPreview: false, audioMessageItem: audioMessageItem))
                    .toList()),
      ],
    );
  }

  int get _getAudioListsDifference => _coachAudioMessages.length - _groupedAudioMessages.length;

  bool get _hasMoreThanRange => _coachAudioMessages.length > _audioMessageRangeValue;

  String _seeMoreAudios({@required int nextRangeValue}) =>
      '${OlukoLocalizations.get(context, 'see')} $nextRangeValue ${OlukoLocalizations.get(context, 'more')}';

  Container coachBannerVideo(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3,
        child: OlukoVideoPreview(
          video: _coachUser.bannerVideo,
          image: _coachUser.coverImage,
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
          onPlay: () => isVideoPlaying(),
          videoVisibilty: _isVideoPlaying,
          bannerVideo: true,
        ));
  }

  addTime() {
    final addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }

  Widget audioSentComponent({BuildContext context, String audioPath, bool isPreview, CoachAudioMessage audioMessageItem}) {
    return BlocBuilder<GenericAudioPanelBloc, GenericAudioPanelState>(
      builder: (context, state) {
     if (state is GenericAudioPanelConfirmDelete && state.audioMessage.id == audioMessageItem.id) {
          return _confirmDeleteComponent(context, state);
     }
      return AudioSentComponent(
        key: UniqueKey(),
        record: audioPath,
        audioMessageItem: audioMessageItem,
        isPreviewContent: isPreview,
        isForList: true,
        onAudioPlaying: (bool playing) => _onPlayAudio(playing),
        onStartPlaying: () => _canStartPlaying(),
        durationFromRecord: isPreview ? _durationToSave : Duration(milliseconds: audioMessageItem?.audioMessage?.duration),
        onDelete: () => BlocProvider.of<GenericAudioPanelBloc>(context)
            .emitConfirmDeleteState(isPreviewContent: isPreview, audioMessageItem: !isPreview ? audioMessageItem : null),
      );
      },
    );
  }

    Widget _confirmDeleteComponent(BuildContext context, GenericAudioPanelConfirmDelete state) {
    return Container(
      width: ScreenUtils.width(context) / 1.2,
      height: 80,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                    BlocProvider.of<GenericAudioPanelBloc>(context).emitDefaultState();
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
                          BlocProvider.of<CoachAudioMessageBloc>(context).markCoachAudioAsDeleted(state.audioMessage);
                          BlocProvider.of<GenericAudioPanelBloc>(context).emitDefaultState();
                      }))
            ],
          )
        ],
      ),
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
      coachUser: _coachUser,
    );
  }

  void isVideoPlaying() {
    return setState(() {
      _isVideoPlaying = !_isVideoPlaying;
    });
  }
}
