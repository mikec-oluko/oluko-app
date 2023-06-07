import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/coach_show_video_content_bloc.dart';
import 'package:oluko_app/blocs/movement_weight_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/enrollment_movement.dart';
import 'package:oluko_app/models/submodels/enrollment_section.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_custom_video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/segment_summary_component.dart';
import 'package:oluko_app/ui/newDesignComponents/segment_details_component.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class CoachShowVideo extends StatefulWidget {
  final String videoUrl;
  final double aspectRatio;
  final String titleForContent;
  final String segmentSubmissionId;
  final UserResponse currentUser;
  const CoachShowVideo({this.videoUrl, this.titleForContent, this.aspectRatio, this.segmentSubmissionId, this.currentUser});

  @override
  _CoachShowVideoState createState() => _CoachShowVideoState();
}

class _CoachShowVideoState extends State<CoachShowVideo> {
  ChewieController _controller;
  bool isMentored = true;
  List<EnrollmentMovement> enrollmentMovements = [];
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentUser != null) {
      BlocProvider.of<CoachShowVideoContentBloc>(context).getContent(widget.segmentSubmissionId, widget.currentUser.id);
      BlocProvider.of<WorkoutWeightBloc>(context).getUserWeightsForWorkout(widget.currentUser.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoAppBar(
        showTitle: true,
        showBackButton: true,
        title: widget.titleForContent,
        onPressed: () {
          if (_controller != null) {
            _controller.pause();
          }
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: OlukoNeumorphismColors.appBackgroundColor,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                  child: widget.aspectRatio != null
                      ? AspectRatio(aspectRatio: widget.aspectRatio, child: showVideoPlayer(widget.videoUrl, widget.aspectRatio))
                      : showVideoPlayer(widget.videoUrl, widget.aspectRatio),
                ),
              ),
              if (widget.currentUser != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: showSegmentDetails(),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget showVideoPlayer(String videoUrl, double aspectRatio) {
    return OlukoCustomVideoPlayer(
      roundedBorder: OlukoNeumorphism.isNeumorphismDesign,
      useConstraints: true,
      videoUrl: videoUrl,
      aspectRatio: aspectRatio,
      autoPlay: false,
      whenInitialized: (ChewieController chewieController) => setState(() {
        _controller = chewieController;
      }),
    );
  }

  Widget showSegmentDetails() {
    return BlocBuilder<CoachShowVideoContentBloc, CoachShowVideoContentState>(
      builder: (context, state) {
        if (state is CoachShowVideoContentStateSuccess) {
          getMovementsWithWeightRequired(state.enrollmentSegment.sections);
          return Container(
            width: ScreenUtils.width(context) - 40,
            decoration: BoxDecoration(
              color: OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _classTitle(state.enrollmentClass),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _segmentTitle(state.segment),
                  Padding(
                    padding: EdgeInsets.only(top: SegmentUtils.hasTitle(state.segment) ? 20 : 0, bottom: 20),
                    child: SegmentDetailsComponent(
                      segmentId: state.segment.id,
                      enrollmentMovements: enrollmentMovements,
                      sectionsFromSegment: state.segment.sections,
                      useImperialSystem: widget.currentUser.useImperialSystem,
                      weightRecords: state.weights ?? [],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  SizedBox _segmentTitle(Segment segment) {
    return SizedBox(
      child: Text(
        segment.name,
        style: OlukoFonts.olukoSuperBigFont(
          customFontWeight: FontWeight.bold,
          customColor: OlukoColors.white,
        ),
        overflow: OlukoNeumorphism.isNeumorphismDesign ? TextOverflow.clip : null,
      ),
    );
  }

  Text _classTitle(EnrollmentClass enrollmentClass) {
    return Text(
      enrollmentClass.name,
      style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w400, customColor: OlukoColors.lightOrange),
    );
  }

  void getMovementsWithWeightRequired(List<EnrollmentSection> enrollmentSections) {
    enrollmentMovements = MovementUtils.getMovementsFromEnrollmentSegment(courseEnrollmentSections: enrollmentSections);
  }
}
