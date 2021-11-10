import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/models/dto/user_stories.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/stories_item.dart';

class StoriesHeader extends StatefulWidget {
  final String userId;

  const StoriesHeader(this.userId);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<StoriesHeader> {
  List<UserStories> stories;

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<StoryListBloc>(context).getStream(widget.userId);
    BlocProvider.of<StoryListBloc>(context).get(widget.userId);
    return BlocBuilder<StoryListBloc, StoryListState>(buildWhen: (_, state) {
      return state is! StoryListUpdate;
    }, builder: (context, storyState) {
      if (storyState is StoryListSuccess && storyState.usersStories.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: storyState.usersStories.map((userStory) {
                return Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: StoriesItem(stories: userStory.stories, imageUrl: userStory.avatar_thumbnail, maxRadius: 35, userStoryId: userStory.id, name: userStory.name),
                );
              }).toList())),
        );
      } else {
        return nil;
      }
    });
  }
}
