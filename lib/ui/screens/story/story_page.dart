import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/story_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/dto/story_dto.dart';
import 'package:oluko_app/models/dto/user_stories.dart';
import 'package:video_player/video_player.dart';

class StoryPage extends StatefulWidget {
  UserStories userStories;
  String userId;
  StoryPage({@required this.userStories, @required this.userId});
  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> with SingleTickerProviderStateMixin {
  PageController _pageController;
  AnimationController _animController;
  VideoPlayerController _videoController;
  Future<void> _initializeVideoPlayerFuture;
  int _currentIndex = 0;

  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(vsync: this);
    findFirstStory();
    final Story firstStory = widget.userStories.stories[_currentIndex];
    _loadStory(story: firstStory, animateToPage: false);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setStoryAsSeen();
        setState(() {
          if (_currentIndex + 1 < widget.userStories.stories.length) {
            _currentIndex += 1;
            _loadStory(story: widget.userStories.stories[_currentIndex]);
          } else {
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  void findFirstStory() {
    final firstStoryIndex = widget.userStories.stories.indexWhere((element) => !element.seen);
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
    final Story story = widget.userStories.stories[_currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) => _onTapDown(details, story),
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.userStories.stories.length,
              itemBuilder: (context, i) {
                final Story story = widget.userStories.stories[i];
                switch (story.content_type) {
                  case 'image':
                    var img = Image.network(
                      story.url,
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
                            value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
                          ),
                        );
                      },
                    );
                    return Padding(
                      padding: const EdgeInsets.only(top: 170),
                      child: Column(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Container(width: 248, height: 350, child: img),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          widget.userStories.stories[_currentIndex].description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]),
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
                          });
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
                      children: widget.userStories.stories
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
                          .toList()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 1.5,
                      vertical: 10.0,
                    ),
                    child: UserInfo(
                      avatar_thumbnail: widget.userStories.avatar_thumbnail,
                      name: widget.userStories.name,
                      userId: widget.userId,
                      hour: '1hr',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details, Story story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex -= 1;
          _loadStory(story: widget.userStories.stories[_currentIndex]);
        }
      });
    } else if (dx > 2 * screenWidth / 3) {
      setState(() {
        setStoryAsSeen();
        if (_currentIndex + 1 < widget.userStories.stories.length) {
          _currentIndex += 1;
          _loadStory(story: widget.userStories.stories[_currentIndex]);
        } else {
          Navigator.of(context).pop();
        }
      });
    } else {
      if (story.content_type == 'video') {
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
    if (!widget.userStories.stories[_currentIndex].seen) {
      widget.userStories.stories[_currentIndex].seen = true;
      BlocProvider.of<StoryBloc>(context).setStoryAsSeen(widget.userId, widget.userStories.id, widget.userStories.stories[_currentIndex].id);
    }
  }

  void _loadStory({Story story, bool animateToPage = true}) {
    _animController.stop();
    _animController.reset();
    _videoController?.dispose();
    switch (story.content_type) {
      case 'image':
        _animController.duration = Duration(seconds: story.duration);
        _animController.forward();
        break;
      case 'video':
        _videoController = null;
        _videoController = VideoPlayerController.network(story.url);
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
              children: <Widget>[
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
              ],
            );
          },
        ),
      ),
    );
  }
}

class UserInfo extends StatelessWidget {
  final String avatar_thumbnail;
  final String name;
  final String userId;
  final String hour;

  const UserInfo({
    Key key,
    @required this.avatar_thumbnail,
    @required this.name,
    @required this.userId,
    @required this.hour,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 22.0,
          backgroundColor: Colors.grey[300],
          backgroundImage: Image.network(
            avatar_thumbnail,
          ).image,
        ),
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
                hour,
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
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
