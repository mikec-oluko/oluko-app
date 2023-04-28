import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/dto/user_stories.dart';
import 'package:oluko_app/ui/components/stories_item.dart';

class StoriesHeader extends StatefulWidget {
  final String userId;
  final double maxRadius;
  final Color color;
  final Function onTap;

  const StoriesHeader(this.userId, {this.maxRadius, this.color, this.onTap});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<StoriesHeader> {
  List<UserStories> stories;

  @override
  Widget build(BuildContext context) {
    if (GlobalConfiguration().getString('showStories') == 'true') {
      //BlocProvider.of<StoryListBloc>(context).getStream(widget.userId);
      BlocProvider.of<StoryListBloc>(context).get(widget.userId);
      return BlocBuilder<StoryListBloc, StoryListState>(
        buildWhen: (_, state) {
          return state is! StoryListUpdate;
        },
        builder: (context, storyState) {
          if (storyState is StoryListSuccess && storyState.usersStories.isNotEmpty) {
            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: storyState.usersStories.map((userStory) {
                      if (userStory.stories.isNotEmpty && userStory.name != null) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          child: StoriesItem(
                            onTap: widget.onTap ?? () {},
                            from: StoriesItemFrom.neumorphicHome,
                            stories: userStory.stories,
                            imageUrl: userStory.getAvatarThumbnail(),
                            maxRadius: widget.maxRadius ?? 35,
                            itemUserId: userStory.id,
                            name: userStory.name,
                            currentUserId: widget.userId,
                            showName: true,
                            color: widget.color,
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    }).toList(),
                  ),
                )
              ],
            );
          } else {
            return const SizedBox();
          }
        },
      );
    } else {
      return const SizedBox();
    }
  }
}
