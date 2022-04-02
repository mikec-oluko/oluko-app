import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AnimationState {}

class AnimationLoading extends AnimationState {}

class HiFiveAnimationSuccess extends AnimationState {
  bool animationDisabled;
  HiFiveAnimationSuccess({this.animationDisabled});
}

class HiFiveAnimationClosed extends AnimationState {
  HiFiveAnimationClosed();
}

class AnimationBloc extends Cubit<AnimationState> {
  AnimationBloc() : super(AnimationLoading());
  String lastId;
  bool animationDisabled = false;
  play(String newId) {
    if (newId != lastId) {
      lastId = newId;
      emit(HiFiveAnimationSuccess(animationDisabled: animationDisabled));
    }
  }

  pause() {
    emit(HiFiveAnimationClosed());
  }
  playPauseAnimation() {
   animationDisabled= !animationDisabled;
  }
}
