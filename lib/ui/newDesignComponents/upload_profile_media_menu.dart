import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class UploadProfileMediaMenu extends StatefulWidget {
  // final CourseEnrollment actualCourse;
  // final Function() unrolledFunction;
  // final bool deleteContent;
  final Success galleryState;

  const UploadProfileMediaMenu({this.galleryState}) : super();

  //  this.actualCourse,
  //   this.unrolledFunction,
  //   this.deleteContent,

  @override
  _UploadProfileMediaMenuState createState() => _UploadProfileMediaMenuState();
}

enum Actions { uploadFromCamera, uploadFromGallery, deleteImage }

class _UploadProfileMediaMenuState extends State<UploadProfileMediaMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Actions>(
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<Actions>>[
          PopupMenuItem(
            onTap: () {
              // BlocProvider.of<CourseEnrollmentListBloc>(context).unenrollCourseForUser(widget.actualCourse, isUnenrolledValue: true);
              // if (widget.unrolledFunction != null) {
              //   widget.unrolledFunction();
              // }
            },
            // value: Actions.unenroll,
            padding: EdgeInsets.zero,
            child: Container(
                color: OlukoNeumorphismColors.appBackgroundColor,
                child: ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.grayColor : OlukoColors.white,
                  ),
                  title: Text(OlukoLocalizations.get(context, 'camera'), style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
                )),
            // child: Center(child: Text('Unenroll', style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white))),
          ),
          PopupMenuItem(
            onTap: () {
              // BlocProvider.of<CourseEnrollmentListBloc>(context).unenrollCourseForUser(widget.actualCourse, isUnenrolledValue: true);
              // if (widget.unrolledFunction != null) {
              //   widget.unrolledFunction();
              // }
            },
            // value: Actions.unenroll,
            padding: EdgeInsets.zero,
            child: Container(
                color: OlukoNeumorphismColors.appBackgroundColor,
                child: ListTile(
                  leading: imageWrapper(),
                  // leading: const Icon(
                  //   Icons.image,
                  //   color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.grayColor : OlukoColors.white,
                  // ),
                  title: Text(OlukoLocalizations.get(context, 'fromGallery'), style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
                )),
            // child: Center(child: Text('Unenroll', style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white))),
          ),
          PopupMenuItem(
            onTap: () {
              // BlocProvider.of<CourseEnrollmentListBloc>(context).unenrollCourseForUser(widget.actualCourse, isUnenrolledValue: true);
              // if (widget.unrolledFunction != null) {
              //   widget.unrolledFunction();
              // }
            },
            // value: Actions.unenroll,
            padding: EdgeInsets.zero,
            child: Container(
                color: OlukoNeumorphismColors.appBackgroundColor,
                child: ListTile(
                  leading: Image.asset(
                    'assets/neumorphic/bin.png',
                    color: Colors.red,
                    scale: 4.5,
                  ),
                  title: Text(OlukoLocalizations.get(context, 'deleteImage'), style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
                )),
            // child: Center(child: Text('Unenroll', style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white))),
          ),
        ];
      },
      color: OlukoNeumorphismColors.appBackgroundColor,
      icon: const Icon(
        Icons.more_vert,
        color: Colors.white,
        size: 36,
      ),
      iconSize: 36,
      padding: EdgeInsets.zero,
    );
  }

  Widget imageWrapper() {
    if (widget.galleryState is Success) {
      return Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          image: DecorationImage(fit: BoxFit.cover, image: MemoryImage(widget.galleryState.firstImage)),
        ),
      );
    } else {
      return Container(
        width: 25,
        height: 25,
        child: const Icon(
          Icons.image,
          size: 20,
          color: OlukoColors.grayColor,
        ),
      );
    }
    //   },
    // );
  }
}
