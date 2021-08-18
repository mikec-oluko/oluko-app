import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/friends_card.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/title_body.dart';

class FriendsListPage extends StatefulWidget {
  // final List<User> friends;
  // FriendsListPage({this.friends});
  final String userImage;
  FriendsListPage({this.userImage});
  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  AuthSuccess _authStateData;

  @override
  void initState() {
    super.initState();
  }

  //TODO: Use from widget
  List<User> friends;
  final _title = "Starred";
  List<String> userImages = [
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrpM3UTTyyqIwGsPYB1gCDhfl3XVv0Cex2Lw&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlCzsqcGBluOOUtgQahXtISLTM3Wb2tkpsoeMqwurI2LEP6pCS0ZgCFLQGiv8BtfJ9p2A&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEMWzdlSputkYso9dJb4VY5VEWQunXGBJMgGys7BLC4MzPQp6yfLURe-9nEdGrcK6Jasc&usqp=CAU',
    'https://mdbcdn.b-cdn.net/img/Photos/Avatars/img%20%2820%29.jpg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRHNX4Bb1o5JWY91Db6I4jf_wmw24ajOdaOPgRCqFlnEnxcAlQ42pyWJxM9klp3E8JoT0k&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTF-rBV5pmJhYA8QbjpPcx6s9SywnXGbvsaxWyFi47oDf9JuL4GruKBY5zl2tM4tdgYdQ0&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRF1L_s4YJh7RHSIag8CxT0LTuJQo-XQnTJkVApDXar4b0A57U_TnAMrK_l4Fd_Nzp65Bg&usqp=CAU'
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess && _authStateData == null) {
        _authStateData = authState;
        BlocProvider.of<FriendBloc>(context)
            .getFriendsByUserId(authState.user.id);
      }
      return SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: OlukoColors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_title, style: OlukoFonts.olukoBigFont()),
              ),
              // BlocListener<FriendBloc, FriendState>(
              //   listener: (context, state) {
              //     if (state is GetFriendsSuccess) {
              //       friends = state.friendUsers;
              //     }
              //   },
              //   child: Column(
              //       children: friends
              //           .map((friend) => FriendCard(
              //                 userData: friend,
              //               ))
              //           .toList()),
              // ),

              BlocBuilder<FriendBloc, FriendState>(
                  builder: (context, friendState) {
                return Column(children: generateFriendList(friendState));
              }),
            ],
          ),
        ),
      );
    });
  }

  ///Manage friends retrieval state
  List<Widget> generateFriendList(FriendState friendState) {
    if (friendState is FriendLoading) {
      return [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OlukoCircularProgressIndicator(),
        )
      ];
    } else if (friendState is FriendFailure) {
      return [TitleBody('There was an error retrieving your Friends')];
    } else if (friendState is GetFriendsSuccess) {
      return friendState.friendData.friends.length == 0
          ? [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [TitleBody('No Friends.')]),
              )
            ]
          : friendState.friendData.friends.map((friend) {
              UserResponse friendUser = friendState.friendUsers
                  .where((fuser) => fuser.id == friend.id)
                  .first;
              return FriendCard(
                name: friendUser.firstName,
                lastName: friendUser.lastName,
                userName: friendUser.username,
                imageUser: friendUser.avatar,
              );
            }).toList();
    } else {
      return [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OlukoCircularProgressIndicator(),
        )
      ];
    }
  }
}
