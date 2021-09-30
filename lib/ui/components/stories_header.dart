import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/models/dto/story_dto.dart';
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
    BlocProvider.of<StoryListBloc>(context).get(widget.userId);
    return BlocBuilder<StoryListBloc, StoryListState>(builder: (context, storyState) {
      if (storyState is StoryListSuccess) {
        return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: storyState.usersStories.map((userStory) {
              return GestureDetector(onTap:() => {Navigator.pushNamed(context,
                            routeLabels[RouteEnum.story],
                            arguments: {'userStories': userStory})}, child: StoriesItem(stories: userStory.stories, imageUrl: userStory.avatar_thumbnail));
            }).toList())); 
      } else {
        return const SizedBox();
      }
    });
  }
}
