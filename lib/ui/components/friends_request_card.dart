import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class FriendRequestCard extends StatefulWidget {
  // final UserResponse userToDisplay;
  // final User userData;
  // FriendRequestCard({this.userToDisplay, this.userData});

  final UserResponse friendUser;
  final Function(UserResponse) onFriendConfirmation;
  final Function(UserResponse) onFriendRequestIgnore;
  FriendRequestCard({this.friendUser, this.onFriendConfirmation, this.onFriendRequestIgnore});

  @override
  _FriendRequestCardState createState() => _FriendRequestCardState();
}

/**
 * TODO:
 * List of user from Friends bloc
 * get data to display (firstName, LastName, image)
 * attribute to set star button 
 */

class _FriendRequestCardState extends State<FriendRequestCard> {
  bool _loadImageError = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: OlukoNeumorphismColors.appBackgroundColor),
      height: OlukoNeumorphism.isNeumorphismDesign ? 130 : 120,
      child: Padding(
        padding: const EdgeInsets.only(left: OlukoNeumorphism.isNeumorphismDesign ? 15 : 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                GestureDetector(
                  child: OlukoNeumorphism.isNeumorphismDesign
                      ? Neumorphic(
                          style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
                          child: CircleAvatar(
                            backgroundImage: getUserImg(widget.friendUser.avatar),
                            onBackgroundImageError: _loadImageError
                                ? null
                                : (dynamic exception, StackTrace stackTrace) {
                                    print('Error loading image! $exception');
                                    setBackgroundImageAsError();
                                  },
                            backgroundColor: OlukoColors.userColor(widget.friendUser.firstName, widget.friendUser.lastName),
                            radius: 30,
                            child: _loadImageError
                                ? Text(
                                    widget.friendUser.firstName.characters.first.toString().toUpperCase(),
                                    style: OlukoFonts.olukoBigFont(
                                      customColor: OlukoColors.white,
                                      customFontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                : const Text(' '),
                          ),
                        )
                      : CircleAvatar(
                          backgroundImage: getUserImg(widget.friendUser.avatar),
                          onBackgroundImageError: _loadImageError
                              ? null
                              : (dynamic exception, StackTrace stackTrace) {
                                  print('Error loading image! $exception');
                                  setBackgroundImageAsError();
                                },
                          backgroundColor: OlukoColors.userColor(widget.friendUser.firstName, widget.friendUser.lastName),
                          radius: 30,
                          child: _loadImageError
                              ? Text(
                                  widget.friendUser.firstName.characters.first.toString().toUpperCase(),
                                  style: OlukoFonts.olukoBigFont(
                                    customColor: OlukoColors.white,
                                    customFontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : const Text(' '),
                        ),
                  onTap: () {
                    BlocProvider.of<TransformationJourneyBloc>(context).emitTransformationJourneyDefault(noValues: true);
                    BlocProvider.of<TaskSubmissionBloc>(context).setTaskSubmissionDefaultState();
                    //BlocProvider.of<CourseEnrollmentBloc>(context).setCourseEnrollmentChallengesDefaultValue();
                    Navigator.pushNamed(
                      context,
                      routeLabels[RouteEnum.profileViewOwnProfile],
                      arguments: {'userRequested': widget.friendUser},
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            // widget.userToDisplay.firstName,
                            widget.friendUser.firstName,
                            style: OlukoFonts.olukoMediumFont(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              // widget.userToDisplay.lastName,
                              widget.friendUser.lastName,
                              style: OlukoFonts.olukoMediumFont(),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        UserHelper.printUsername(widget.friendUser.username, widget.friendUser.id) ?? '',
                        style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: OlukoNeumorphism.isNeumorphismDesign ? 115 : 120,
                    height: OlukoNeumorphism.isNeumorphismDesign ? 45 : 30,
                    child: OlukoNeumorphism.isNeumorphismDesign
                        ? OlukoNeumorphicPrimaryButton(
                            isExpanded: false,
                            title: OlukoLocalizations.get(context, 'confirm'),
                            thinPadding: true,
                            onPressed: () => widget.onFriendConfirmation(widget.friendUser),
                          )
                        : TextButton(
                            onPressed: () => widget.onFriendConfirmation(widget.friendUser),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(OlukoColors.primary),
                            ),
                            child: Text(
                              OlukoLocalizations.get(context, 'confirm'),
                              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.black),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: SizedBox(
                      width: OlukoNeumorphism.isNeumorphismDesign ? 115 : 120,
                      height: OlukoNeumorphism.isNeumorphismDesign ? 45 : 30,
                      child: OlukoNeumorphism.isNeumorphismDesign
                          ? OlukoNeumorphicSecondaryButton(
                              isExpanded: false,
                              title: OlukoLocalizations.get(context, 'ignore'),
                              thinPadding: true,
                              textColor: OlukoColors.primary,
                              onPressed: () => widget.onFriendRequestIgnore(widget.friendUser),
                            )
                          : OutlinedButton(
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: OlukoColors.grayColor)),
                              onPressed: () => widget.onFriendRequestIgnore(widget.friendUser),
                              child: Text(
                                OlukoLocalizations.get(context, 'ignore'),
                                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 15),
              child: OlukoNeumorphicDivider(
                isForList: true,
              ),
            )
          ],
        ),
      ),
    );
  }

  void setBackgroundImageAsError() {
    setState(() {
      _loadImageError = true;
    });
  }

  ImageProvider<Object> getUserImg(String avatarUrl) {
    if (_loadImageError) {
      return null;
    } else if (avatarUrl == null) {
      setBackgroundImageAsError();
      return null;
    } else {
      return CachedNetworkImageProvider(avatarUrl);
    }
  }
}
