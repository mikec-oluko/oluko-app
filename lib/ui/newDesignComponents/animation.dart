import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/animation_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/views_bloc/hi_five_bloc.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class Animated extends StatefulWidget {
  Animated({Key key}) : super(key: key);
  BuildContext context;
  @override
  State<Animated> createState() => _AnimatedState();
}

class _AnimatedState extends State<Animated> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> animation;
  bool hideAnimation = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    animation = Tween(begin: Offset(0.0, 2.0), end: Offset(0.0, -2.0)).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          BlocProvider.of<AnimationBloc>(context).pause();
          _controller.reset();
        }
      });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimationBloc, AnimationState>(
      builder: (context, state) {
        if (state is HiFiveAnimationSuccess && !state.animationDisabled) {
          _controller.forward();
          return Stack(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                getHandIcon(0.2),
                getHandIcon(0.5),
                getHandIcon(0.3),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                getHandIcon(0.1),
                getHandIcon(0.6),
                getHandIcon(0.25),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                getHandIcon(0.4),
                getHandIcon(0.35),
                getHandIcon(0.65),
              ]),
            ],
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  Widget getHandIcon(double heightFactor) {
    return SizedBox(
      height: ScreenUtils.height(context) * heightFactor,
      child: SlideTransition(
        position: animation,
        child: SizedBox(height: 60, width: 60, child: Image.asset('assets/profile/hiFive.png')),
      ),
    );
  }
}
