import 'dart:async';
// import 'package:sound_mode/sound_mode.dart';
// import 'package:audioplayers/audio_cache.dart';
import 'package:oluko_app/main.dart';
import './sound_list.dart';

// AudioCache player = AudioCache();

// Task get defaultTask => Task(
//     reps: 3,
//     taskTime: Duration(seconds: 60),
//     repRest: Duration(seconds: 30),
//     sets: 1,
//     setRest: Duration(seconds: 45),
//     delayTime: Duration(seconds: 3));

enum TaskType { DEFAULT, AMRAP }

enum TimerScreen { kabata, stop_watch, emom_timer, amrap }

// enum TimerConfigTitle {
//   totalTimeConfig,
//   repTimeConfig,
//   setTimeConfig,
//   restTimeConfig,
//   taskTimeConfig,
//   repValueConfig,
//   setValueConfig
// }

// class Task {
//   //reps in workout
//   int reps;
//   //Work time per rep
//   Duration taskTime;
//   // rest time between reps
//   Duration repRest;
//   //Sets in workout
//   int sets;
//   //rest between set
//   Duration setRest;
//   //Delay to start
//   Duration delayTime;
//   //Enum task Type
//   TaskType taskType = TaskType.DEFAULT;

//   Task(
//       {this.reps,
//       this.taskTime,
//       this.repRest,
//       this.sets,
//       this.setRest,
//       this.delayTime});

//   Duration totalTime() {
//     return (taskTime * reps * sets) +
//         (repRest * sets * (reps - 1)) +
//         (setRest * (sets - 1));
//   }

//   Task.fromJson(Map<String, dynamic> json)
//       : reps = json['reps'],
//         taskTime = Duration(seconds: json['taskTime']),
//         repRest = Duration(seconds: json['repRest']),
//         sets = json['sets'],
//         setRest = Duration(seconds: json['setRest']),
//         delayTime = Duration(seconds: json['delayTime']);

//   Map<String, dynamic> toJson() => {
//         'reps': reps,
//         'taskTime': taskTime.inSeconds,
//         'repRest': repRest.inSeconds,
//         'sets': sets,
//         'setRest': setRest.inSeconds,
//         'delayTime': delayTime.inSeconds,
//       };
// }

// class AmrapTask extends Task {
//   Duration totalTimeSet;
//   AmrapTask({
//     this.totalTimeSet,
//     Duration taskTime,
//     int reps,
//     Duration repRest,
//     int sets,
//     Duration setRest,
//     Duration delayTime,
//   }) : super(
//             taskTime: taskTime,
//             reps: reps,
//             repRest: repRest,
//             sets: sets,
//             setRest: setRest,
//             delayTime: delayTime);

//   @override
//   Duration totalTime() {
//     return this.totalTimeSet;
//   }
// }

enum WorkState {
  initial,
  starting,
  exercising,
  repResting,
  setResting,
  finished,
  paused
}

// class Work {
//   Timer _timer;
//   Task _task;
//   //callback for work state change
//   Function _onStateChanged;
//   WorkState _step = WorkState.initial;

//   //time left in current stage
//   Duration _timeLeft;
//   //total time left
//   Duration _totalTimeRemaining = Duration(seconds: 0);

//   //actual rep
//   int _rep = 0;
//   //actual set
//   int _set = 0;

//   Work(this._task, this._onStateChanged);

//   //GETTERS
//   get task => _task;
//   get rep => _rep;
//   get repDefault => _task.reps;
//   get set => _set;
//   get setDefault => _task.sets;
//   get step => _step;
//   get timeLeft => _timeLeft;
//   get totalTimeRemaining => _totalTimeRemaining;
//   get isTimerActive => _timer != null && _timer.isActive;
//   get timeLeftSeconds => _timeLeft.inSeconds;
//   get timeRemainingSeconds => _totalTimeRemaining.inSeconds;
//   get taskTime => _task.taskTime.inSeconds;
//   get repRestTime => _task.repRest.inSeconds;
//   get setRestTime => _task.setRest.inSeconds;

//   Duration get totalTime => _task.totalTime();

//   setRep(int newRep) {
//     this._rep = newRep;
//   }

//   percentage() {
//     if (_timer.isActive || !_timer.isActive) {
//       if (_step == WorkState.starting) {
//         return 1 - (timeLeftSeconds / 3);
//       } else if (_step == WorkState.exercising) {
//         return 1 - (timeLeftSeconds / taskTime);
//       } else if (_step == WorkState.repResting) {
//         return 1 - (timeLeftSeconds / repRestTime);
//       } else if (_step == WorkState.setResting) {
//         return 1 - (timeLeftSeconds / setRestTime);
//       } else
//         return 1.0;
//     }
//   }

//   Future _playSound(String sound) async {
//     String ringerStatus = await SoundMode.ringerModeStatus;
//     if (ringerStatus.contains("Normal Mode")) {
//       return await player.play(sound);
//     }
//     return;
//   }

//   _tick(Timer timer) {
//     if (_step != WorkState.starting) {
//       _totalTimeRemaining += Duration(seconds: 1);
//     }

//     if (_timeLeft.inSeconds == 0) {
//       _doNextStep();
//     } else {
//       _timeLeft -= Duration(seconds: 1);
//     }
//     _onStateChanged();
//   }

//   _tickCentiSecond(Timer timer) {
//     if (_step != WorkState.starting) {
//       _totalTimeRemaining += Duration(seconds: 1);
//     }

//     if (_timeLeft.inSeconds == 0) {
//       _doNextStep();
//     } else {
//       _timeLeft -= Duration(milliseconds: 10);
//     }
//     _onStateChanged();
//   }

//   start() {
//     if (_task == null) {
//       _task = defaultTask;
//     }
//     //need to know current work state
//     if (_step == WorkState.initial) {
//       _step = WorkState.starting;

//       if (_task.delayTime.inSeconds == 0) {
//         _doNextStep();
//       } else {
//         _timeLeft = _task.delayTime;
//       }
//     }

//     _timer = Timer.periodic(Duration(seconds: 1), _tick);
//     _onStateChanged();
//   }

//   startCentiSeconds() {
//     if (_task == null) {
//       _task = defaultTask;
//     }
//     //need to know current work state
//     if (_step == WorkState.initial) {
//       _step = WorkState.starting;

//       if (_task.delayTime.inSeconds == 0) {
//         _doNextStep();
//       } else {
//         _timeLeft = _task.delayTime;
//       }
//     }

//     _timer = Timer.periodic(Duration(milliseconds: 10), _tickCentiSecond);
//     _onStateChanged();
//   }

//   pause() {
//     _playSound(pauseSound);
//     _timer.cancel();
//     _onStateChanged();
//   }

//   stop() {
//     _timer.cancel();
//     _step = WorkState.finished;
//     _timeLeft = Duration(seconds: 0);
//   }

//   _doNextStep() {
//     // Need to consider the current state of the workout
//     if (_step == WorkState.exercising) {
//       if (rep == _task.reps) {
//         if (set == _task.sets) {
//           _finish();
//         } else {
//           _startSetRest();
//         }
//       } else {
//         _startRepRest();
//       }
//     } else if (_step == WorkState.repResting) {
//       _startRep();
//     } else if (_step == WorkState.starting || _step == WorkState.setResting) {
//       _startSet();
//     }
//   }

//   _startRep() {
//     _playSound(startRepSound);
//     if (this._task.taskType != TaskType.AMRAP) {
//       _rep++;
//     }
//     _step = WorkState.exercising;
//     _timeLeft = _task.taskTime;
//   }

//   _startRepRest() {
//     _playSound(startRestSound);
//     _step = WorkState.repResting;
//     if (_task.repRest.inSeconds == 0) {
//       _doNextStep();
//       return;
//     }
//     _timeLeft = _task.repRest;
//   }

//   _startSet() {
//     _playSound(startRepSound);
//     _set++;
//     _rep = 1;
//     _step = WorkState.exercising;
//     _timeLeft = _task.taskTime;
//   }

//   _startSetRest() {
//     _playSound(startRestSound);
//     _step = WorkState.setResting;

//     if (_task.setRest.inSeconds == 0) {
//       //TODO: Place sound
//       _doNextStep();
//       return;
//     }
//     _timeLeft = _task.setRest;
//   }

//   _finish() {
//     _playSound(finishTaskSound);
//     _timer.cancel();
//     _step = WorkState.finished;
//     _timeLeft = Duration(seconds: 0);
//   }

//   dispose() {
//     _timer.cancel();
//   }

//   startRepRest() {
//     _step = WorkState.repResting;
//     if (_task.repRest.inSeconds == 0) {
//       _doNextStep();
//       return;
//     }
//     _timeLeft = _task.repRest;
//   }
// }

// StopWatchClass get stopWatchDefault => StopWatchClass(
//     totalTime: Duration(hours: 2),
//     timeElapsed: Duration(seconds: 0),
//     startTime: Duration(seconds: 0),
//     stopCount: [],
//     alarmTime: Duration(seconds: 2),
//     alarms: 0);

// StopWatchClass get emomDefault => StopWatchClass(
//     totalTime: Duration(seconds: 600),
//     alarmTime: Duration(seconds: 60),
//     alarms: 1);

// class StopWatchClass {
//   Duration totalTime;
//   Duration timeElapsed;
//   Duration startTime;
//   List<String> stopCount;
//   Duration alarmTime;
//   int alarms;
//   Duration lastLapTime;

//   StopWatchClass(
//       {this.totalTime,
//       this.timeElapsed,
//       this.startTime,
//       this.stopCount,
//       this.alarmTime,
//       this.alarms,
//       this.lastLapTime});

//   Duration stopWatchTime() {
//     return (totalTime * alarms) + (alarmTime * alarms);
//   }

//   StopWatchClass.fromJson(Map<String, dynamic> json)
//       : totalTime = json['totalTime'],
//         alarmTime = Duration(seconds: json['alarmTime']),
//         alarms = json['alarms'];

//   Map<String, dynamic> toJson() => {
//         'alarms': alarms,
//         'alarmTime': alarmTime.inSeconds,
//         'totalTime': totalTime.inSeconds,
//       };
// }

// enum WatchState { running, alarmFired, finished, runningmotm, reseted }

// class Watch {
//   StopWatchClass _stopWatch;
//   Timer _timer;

//   int _alarm;
//   Function _onWatchStateChanged;
//   WatchState _step = WatchState.running;
//   Duration _watchTimeRemaining;
//   Duration _watchTimeElapsed = Duration(seconds: 0);
//   int _currentRep = 0;
//   int _minuteInSeconds;
//   Duration _minuteToShow;

//   Watch(this._stopWatch, this._onWatchStateChanged);
//   get alarm => _alarm;
//   get stopWatch => _stopWatch;
//   get timeRemaining => _watchTimeRemaining;
//   get timeRemainingInSeconds => _watchTimeRemaining.inSeconds;
//   get timeElapsed => _watchTimeElapsed.inSeconds;
//   get watchTime => _stopWatch.totalTime.inSeconds;
//   get watchTimeInMinutes => _stopWatch.totalTime.inMinutes;
//   get alarmTime => _stopWatch.alarmTime.inSeconds;
//   get isTimerActive => _timer != null && _timer.isActive;
//   get step => _step;
//   get currentRep => _currentRep;
//   List<String> get stopCount => _stopWatch.stopCount;
//   get totalTime => _stopWatch.totalTime;
//   get timeInSeconds => _minuteInSeconds = _stopWatch.alarmTime.inSeconds;
//   get timeToShow => _minuteToShow;
//   get lastLapTime => _stopWatch.lastLapTime;

//   percentage() {
//     if (_timer.isActive || !_timer.isActive) {
//       if (_step == WatchState.running) {
//         return 0 +
//             (_watchTimeElapsed.inSeconds / Duration(seconds: 60).inSeconds);
//       } else if (_step == WatchState.alarmFired) {
//         return 1 - (timeRemainingInSeconds / alarmTime);
//       } else if (_step == WatchState.runningmotm) {
//         return 1 - (_minuteToShow.inSeconds / alarmTime);
//       } else {
//         return 1.0;
//       }
//     }
//   }

//   _tick(Timer timer) {
//     if (_watchTimeRemaining.inSeconds == Duration(seconds: 60).inSeconds) {
//       _nextStep();
//     } else {
//       _watchTimeRemaining += Duration(seconds: 1);
//     }
//     _onWatchStateChanged();
//   }

//   _emomTick(Timer timer) {
//     if (_watchTimeRemaining.inSeconds ==
//         (_stopWatch.totalTime - Duration(seconds: _minuteInSeconds))
//             .inSeconds) {
//       _emomStartAlarm();
//       if (_stopWatch.totalTime.inSeconds == _minuteInSeconds) {
//         finish();
//       } else {
//         _minuteInSeconds +=
//             Duration(seconds: _stopWatch.alarmTime.inSeconds).inSeconds;
//       }
//     } else {
//       _watchTimeRemaining -= Duration(seconds: 1);
//       _minuteToShow -= Duration(seconds: 1);
//     }

//     _onWatchStateChanged();
//   }

//   _nextStep() {
//     if (_step == WatchState.running) {
//       if (_watchTimeRemaining.inSeconds == Duration(seconds: 60).inSeconds) {
//         _step = WatchState.finished;
//       }
//       if (_step == WatchState.finished) {
//         _finish();
//       }
//     }
//   }

//   _nextStepStopWatch() {
//     if (_step == WatchState.running) {
//       if (_watchTimeRemaining.inSeconds == _stopWatch.totalTime.inSeconds) {
//         _step = WatchState.finished;
//       }
//       if (_step == WatchState.finished) {
//         _finish();
//       }
//     }
//   }

//   _tickCentiSecond(Timer timer) {
//     if (_watchTimeRemaining.inSeconds == _stopWatch.totalTime.inSeconds) {
//       _nextStepStopWatch();
//     } else {
//       _watchTimeRemaining += Duration(milliseconds: 30);
//       _watchTimeElapsed += Duration(milliseconds: 30);
//       if (_watchTimeElapsed >= Duration(minutes: 1)) {
//         _watchTimeElapsed = Duration(minutes: 0);
//       }
//     }
//     _onWatchStateChanged();
//   }

//   startCentiSeconds() {
//     if (_stopWatch == null) {
//       _stopWatch = stopWatchDefault;
//     }

//     if (_watchTimeRemaining == null) {
//       _watchTimeRemaining = _stopWatch.startTime;
//     }
//     _step = WatchState.running;
//     _timer = Timer.periodic(Duration(milliseconds: 30), _tickCentiSecond);
//     _onWatchStateChanged();
//   }

//   _emomStartAlarm() {
//     _playSound(alertSound);
//     _currentRep++;
//     _minuteToShow = Duration(seconds: _stopWatch.alarmTime.inSeconds);
//   }

//   _finish() {
//     _timer.cancel();
//     _step = WatchState.finished;
//     _watchTimeRemaining = Duration(seconds: 0);
//   }

//   reset() {
//     _timer.cancel();
//     _step = WatchState.reseted;
//     _watchTimeRemaining = Duration(seconds: 0);
//     _onWatchStateChanged();
//     if (_stopWatch.stopCount != null && _stopWatch.stopCount.length != 0) {
//       _stopWatch.stopCount = [];
//     }
//   }

//   finish() {
//     _timer.cancel();
//     _step = WatchState.finished;
//     _watchTimeRemaining = Duration(seconds: 0);
//     _onWatchStateChanged();
//   }

//   start() {
//     if (_stopWatch == null) {
//       _stopWatch = stopWatchDefault;
//     }

//     if (_watchTimeRemaining == null) {
//       _watchTimeRemaining = _stopWatch.totalTime;
//     }

//     if (_watchTimeRemaining == Duration(seconds: 0)) {
//       _watchTimeRemaining = _stopWatch.totalTime;
//     }

//     _step = WatchState.running;
//     _timer = Timer.periodic(Duration(seconds: 1), _tick);
//     _onWatchStateChanged();
//   }

//   emomStart() {
//     if (_stopWatch == null) {
//       _stopWatch = emomDefault;
//     }

//     if (_watchTimeRemaining == null) {
//       _watchTimeRemaining = _stopWatch.totalTime;
//     }

//     if (_watchTimeRemaining == Duration(seconds: 0)) {
//       _watchTimeRemaining = _stopWatch.totalTime;
//     }

//     _step = WatchState.runningmotm;
//     _minuteInSeconds = _stopWatch.alarmTime.inSeconds;
//     _minuteToShow = _stopWatch.alarmTime;
//     _timer = Timer.periodic(Duration(seconds: 1), _emomTick);
//     _onWatchStateChanged();
//   }

//   pause() {
//     _playSound(pauseSound);
//     _timer.cancel();
//     _onWatchStateChanged();
//   }

//   stop() {
//     _timer.cancel();
//     _step = WatchState.finished;
//     _watchTimeRemaining = Duration(seconds: 0);
//   }

//   saveLap() {
//     _playSound(lapSound);
//     Duration newLap;
//     if (_stopWatch.stopCount.length == 0) {
//       _stopWatch.lastLapTime = _watchTimeRemaining;
//       _stopWatch.stopCount
//           .add(formatTimeWithCentiSeconds(_watchTimeRemaining).toString());
//     } else {
//       newLap = (_watchTimeRemaining - _stopWatch.lastLapTime);
//       _stopWatch.stopCount.add(formatTimeWithCentiSeconds(newLap).toString());
//       _stopWatch.lastLapTime = _watchTimeRemaining;
//     }
//     _onWatchStateChanged();
//   }

//   dispose() {
//     _timer.cancel();
//     if (_stopWatch.stopCount != null && _stopWatch.stopCount.length != 0) {
//       _stopWatch.stopCount = [];
//     }
//   }

//   Future _playSound(String sound) async {
//     String ringerStatus = await SoundMode.ringerModeStatus;
//     if (ringerStatus.contains("Normal Mode")) {
//       return await player.play(sound);
//     }
//     return;
//   }
// }
