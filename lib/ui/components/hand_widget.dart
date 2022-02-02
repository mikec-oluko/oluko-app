
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/views_bloc/hi_five_bloc.dart';
import 'package:oluko_app/routes.dart';

class HandWidget extends StatelessWidget {
  const HandWidget({
    Key key,
    @required this.authState,
  }) : super(key: key);

  final AuthSuccess authState;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HiFiveBloc, HiFiveState>(
      builder: (context, hiFiveState) {
        return hiFiveState is HiFiveSuccess && hiFiveState.users.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, routeLabels[RouteEnum.hiFivePage])
                      .then((value) => BlocProvider.of<HiFiveBloc>(context).get(authState.user.id));
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0, top: 5),
                  child: Badge(
                    position: const BadgePosition(top: 0, start: 10),
                    badgeContent: Text(hiFiveState.users.length.toString()),
                    child: Image.asset(
                      'assets/home/hand.png',
                      scale: 4,
                    ),
                  ),
                ),
              )
            : const SizedBox();
      },
    );
  }
}