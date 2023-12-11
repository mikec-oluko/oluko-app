import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/carrousel_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/story_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/dto/story_dto.dart';
import 'package:oluko_app/models/enums/story_content_enum.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:oluko_app/utils/user_utils.dart';
import 'package:video_player/video_player.dart';
import '../../../helpers/video_player_helper.dart';

class StoryPage extends StatefulWidget {
  List<Story> stories;
  String userId;
  String userStoriesId;
  String name;
  String lastname;
  String avatarThumbnail;
  StoryPage({
    @required this.stories,
    @required this.userId,
    @required this.userStoriesId,
    @required this.name,
    @required this.avatarThumbnail,
    this.lastname,
  });
  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> with SingleTickerProviderStateMixin {
  PageController _pageController;
  AnimationController _animController;
  VideoPlayerController _videoController;
  Future<void> _initializeVideoPlayerFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(vsync: this);
    findFirstStory();
    final Story firstStory = widget.stories[_currentIndex];
    _loadStory(story: firstStory, animateToPage: false);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setStoryAsSeen();
        setState(() {
          if (_currentIndex + 1 < widget.stories.length) {
            _currentIndex += 1;
            _loadStory(story: widget.stories[_currentIndex]);
          } else {
            BlocProvider.of<CarouselBloc>(context).widgetIsHiden(false);
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  void findFirstStory() {
    final firstStoryIndex = widget.stories.indexWhere((element) => !element.seen);
    if (firstStoryIndex != -1) {
      _currentIndex = firstStoryIndex;
    } else {
      _currentIndex = 0;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var loading = false;
    final Story story = widget.stories[_currentIndex];
    return Scaffold(
      backgroundColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
      body: GestureDetector(
        onTapUp: (details) => _onTapDown(details, story),
        onLongPress: () => {_animController.stop()},
        onLongPressUp: () => {_animController.forward()},
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              itemBuilder: (context, i) {
                final Story story = widget.stories[i];
                switch (story.contentType) {
                  case 'image':
                    final img = Image(
                      image: CachedNetworkImageProvider(story.url),
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) {
                          if (loading) {
                            _animController.stop();
                            _animController.reset();
                            _animController.duration = Duration(seconds: story.duration);
                            _animController.forward();
                            loading = false;
                          }
                          return child;
                        } else {
                          loading = true;
                          _animController.stop();
                          _animController.reset();
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
                          ),
                        );
                      },
                    );
                    return Padding(
                      padding: const EdgeInsets.only(top: 170),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: SizedBox(height: ScreenUtils.height(context) * 0.45, child: img),
                          ),
                        ],
                      ),
                    );
                  case 'video':
                    if (_videoController != null && _videoController.value.isInitialized) {
                      return FutureBuilder(
                        future: _initializeVideoPlayerFuture,
                        builder: (context, snapshot) {
                          return FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _videoController.value.size.width,
                              height: _videoController.value.size.height,
                              child: VideoPlayer(_videoController),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                }
                return const SizedBox.shrink();
              },
            ),
            Positioned(
              top: 40.0,
              left: 10.0,
              right: 10.0,
              child: Column(
                children: <Widget>[
                  Row(
                    children: widget.stories
                        .asMap()
                        .map((i, e) {
                          return MapEntry(
                            i,
                            AnimatedBar(
                              animController: _animController,
                              position: i,
                              currentIndex: _currentIndex,
                            ),
                          );
                        })
                        .values
                        .toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 1.5,
                      vertical: 10.0,
                    ),
                    child: UserInfo(
                      avatarThumbnail: widget.avatarThumbnail,
                      name: widget.name,
                      lastname: widget.lastname,
                      userId: widget.userId,
                      timeFromCreation: widget.stories[_currentIndex].timeFromCreation,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: ScreenUtils.height(context) * 0.02,
              right: 0,
              left: 0,
              child: SizedBox(height: ScreenUtils.height(context) * 0.25, child: getBottomWidgets(story.contentType)),
            )
          ],
        ),
      ),
    );
  }

  void _onTapDown(TapUpDetails details, Story story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex -= 1;
          _loadStory(story: widget.stories[_currentIndex]);
        }
      });
    } else if (dx > 2 * screenWidth / 3) {
      setState(() {
        setStoryAsSeen();
        if (_currentIndex + 1 < widget.stories.length) {
          _currentIndex += 1;
          _loadStory(story: widget.stories[_currentIndex]);
        } else {
          BlocProvider.of<CarouselBloc>(context).widgetIsHiden(false);
          Navigator.of(context).pop();
        }
      });
    } else {
      if (story.contentType == storyContentLabels[StoryContentEnum.Video]) {
        if (_videoController.value.isPlaying) {
          _videoController.pause();
          _animController.stop();
        } else {
          _videoController.play();
          _animController.forward();
        }
      }
    }
  }

  void setStoryAsSeen() {
    if (!widget.stories[_currentIndex].seen) {
      widget.stories[_currentIndex].seen = true;
      BlocProvider.of<StoryBloc>(context).setStoryAsSeen(widget.userId, widget.userStoriesId, widget.stories[_currentIndex].id);
      BlocProvider.of<StoryListBloc>(context).get(widget.userId);
    }
  }

  void _loadStory({Story story, bool animateToPage = true}) {
    _animController.stop();
    _animController.reset();
    switch (story.contentType) {
      case 'image':
        _animController.duration = Duration(seconds: story.duration);
        _animController.forward();
        break;
      case 'video':
        _videoController = null;
        _videoController = VideoPlayerHelper.videoPlayerControllerFromNetwork(story.url);
        _initializeVideoPlayerFuture = _videoController.initialize().then((_) {
          setState(() {});
          if (_videoController.value.isInitialized) {
            _animController.duration = _videoController.value.duration;
            _videoController.play();
            _animController.forward();
          }
        });
        break;
    }
    if (animateToPage) {
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget getBottomWidgets(String contentType) {
    if (contentType == storyContentLabels[StoryContentEnum.Video]) {
      return hiFiveWidget();
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.stories[_currentIndex].result != null)
            Text(
              widget.stories[_currentIndex].isDurationRecord ? getDurationRecordString() : widget.stories[_currentIndex].result,
              style: const TextStyle(
                color: OlukoColors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (widget.stories[_currentIndex].segmentTitle != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.stories[_currentIndex].segmentTitle,
                style: const TextStyle(
                  color: OlukoColors.primary,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          if (widget.stories[_currentIndex].description != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                widget.stories[_currentIndex].description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: OlukoColors.grayColor,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          hiFiveWidget()
        ],
      );
    }
  }

  Center hiFiveWidget() {
    return Center(
      child: GestureDetector(
        onTap: () {
          BlocProvider.of<HiFiveSendBloc>(context).set(context, widget.userId, widget.userStoriesId);
          AppMessages().showHiFiveSentDialog(context);
        },
        child: BlocListener<HiFiveSendBloc, HiFiveSendState>(
          bloc: BlocProvider.of(context),
          listener: (hiFiveSendContext, hiFiveSendState) {
            if (hiFiveSendState is HiFiveSendSuccess) {
              AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'hiFiveSent'));
            }
          },
          child: SizedBox(width: 80, height: 80, child: Image.asset('assets/profile/hiFive.png')),
        ),
      ),
    );
  }

  String getDurationRecordString() {
    return '${_splitResultString().first}:  ${TimeConverter.secondsToMinutes(double.parse(_splitResultString().last), oneDigitMinute: true)}';
  }

  List<String> _splitResultString() => widget.stories[_currentIndex].result.split(':');
}

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int currentIndex;

  const AnimatedBar({
    Key key,
    @required this.animController,
    @required this.position,
    @required this.currentIndex,
  }) : super(key: key);

  Container _buildContainer(double width, Color color) {
    return Container(
      height: 5.0,
      width: width,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black26,
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: getTopBars(constraints),
            );
          },
        ),
      ),
    );
  }

  List<Widget> getTopBars(BoxConstraints constraints) {
    if (OlukoNeumorphism.isNeumorphismDesign) {
      return [
        _buildContainer(
          double.infinity,
          position == currentIndex
              ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark
              : position < currentIndex
                  ? OlukoColors.white
                  : Colors.grey.withOpacity(0.5),
        ),
        if (position == currentIndex)
          AnimatedBuilder(
            animation: animController,
            builder: (context, child) {
              return _buildContainer(
                constraints.maxWidth * animController.value,
                OlukoColors.white,
              );
            },
          )
        else
          const SizedBox.shrink(),
      ];
    }
    return [
      _buildContainer(
        double.infinity,
        position < currentIndex ? OlukoColors.primary : Colors.white.withOpacity(0.5),
      ),
      if (position == currentIndex)
        AnimatedBuilder(
          animation: animController,
          builder: (context, child) {
            return _buildContainer(
              constraints.maxWidth * animController.value,
              OlukoColors.primary,
            );
          },
        )
      else
        const SizedBox.shrink(),
    ];
  }
}

class UserInfo extends StatelessWidget {
  final String avatarThumbnail;
  final String name;
  final String userId;
  final String timeFromCreation;
  final String lastname;

  const UserInfo({
    Key key,
    @required this.avatarThumbnail,
    @required this.name,
    @required this.userId,
    @required this.timeFromCreation,
    this.lastname,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        getCircularAvatar(),
        const SizedBox(width: 16.0),
        Expanded(
          child: Row(
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                timeFromCreation,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.close,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: () {
            BlocProvider.of<CarouselBloc>(context).widgetIsHiden(false);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  CircleAvatar getCircularAvatar() {
    if (avatarThumbnail != null) {
      return CircleAvatar(
        radius: 22.0,
        backgroundColor: Colors.grey[300],
        backgroundImage: Image(
          image: CachedNetworkImageProvider(avatarThumbnail),
        ).image,
      );
    } else {
      return UserUtils.avatarImageDefault(maxRadius: 22, name: name, lastname: lastname);
    }
  }
}
