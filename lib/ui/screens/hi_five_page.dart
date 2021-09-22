import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/views_bloc/hi_five_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class HiFivePage extends StatefulWidget {
  const HiFivePage({Key key}) : super(key: key);

  @override
  _HiFivePageState createState() => _HiFivePageState();
}

class _HiFivePageState extends State<HiFivePage> {
  List<UserResponse> users = [
    UserResponse(
        avatar:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrpM3UTTyyqIwGsPYB1gCDhfl3XVv0Cex2Lw&usqp=CAU',
        firstName: 'Elena',
        username: 'Ele25_uy',
        id: '2312321321'),
    UserResponse(
        avatar:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrpM3UTTyyqIwGsPYB1gCDhfl3XVv0Cex2Lw&usqp=CAU',
        firstName: 'Elena',
        username: 'Ele25_uy',
        id: '2312322'),
    UserResponse(
        avatar:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrpM3UTTyyqIwGsPYB1gCDhfl3XVv0Cex2Lw&usqp=CAU',
        firstName: 'Elena',
        username: 'Ele25_uy',
        id: '23123')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: Colors.black,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthSuccess) {
            return BlocBuilder<HiFiveBloc, HiFiveState>(
                bloc: BlocProvider.of<HiFiveBloc>(context)
                  ..get(context, authState.user.id),
                builder: (context, snapshot) {
                  return ListView(
                    children: users.map((user) => _listItem(user, 5)).toList(),
                  );
                });
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _listItem(UserResponse user, num hiFives) {
    return Dismissible(
      key: ValueKey<String>(user.id),
      background: Container(color: OlukoColors.primary),
      secondaryBackground: Container(
        color: Colors.red.shade100,
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    StoriesItem(
                      progressValue: 0.6,
                      imageUrl: user.avatar,
                      maxRadius: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.firstName,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                          Text(
                            user.username,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
            Flexible(
              flex: 5,
              child: Column(
                children: [
                  Text(
                    '$hiFives Hi-Fives',
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
            Image.asset(
              'assets/profile/hiFive.png',
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.lighten,
              height: 60,
              width: 60,
            )
          ],
        ),
      ),
    );
  }

  OlukoAppBar _appBar() {
    return OlukoAppBar(
      title: 'Hi Five',
      showLogo: false,
      showBackButton: true,
      actions: [],
    );
  }
}
