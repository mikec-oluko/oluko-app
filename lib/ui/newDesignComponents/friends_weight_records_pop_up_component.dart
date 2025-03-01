import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/privacy_options.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/user_utils.dart';

class FriendsWeightRecordsPopUpComponent extends StatefulWidget {
  final Text segmentStep;
  final String segmentId;
  final Widget segmentTitleWidget;
  final Map<UserResponse, List<WeightRecord>> friendsRecords;
  final List<MovementSubmodel> movementsForWeight;
  final bool useImperial;
  final List<WeightRecord> currentUserRecords;
  final BuildContext context;
  final String userId;
  const FriendsWeightRecordsPopUpComponent(
      {Key key,
      this.segmentStep,
      this.segmentId,
      this.segmentTitleWidget,
      this.friendsRecords,
      this.movementsForWeight,
      this.currentUserRecords,
      this.useImperial = true,
      this.context,
      this.userId})
      : super(key: key);

  @override
  State<FriendsWeightRecordsPopUpComponent> createState() => _FriendsWeightRecordsPopUpComponentState();
}

class _FriendsWeightRecordsPopUpComponentState extends State<FriendsWeightRecordsPopUpComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 330,
        height: 500,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: OlukoNeumorphismColors.appBackgroundColor),
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.segmentStep,
                    const SizedBox(
                      height: 10,
                    ),
                    widget.segmentTitleWidget,
                    const SizedBox(
                      height: 10,
                    ),
                    Wrap(
                      children: widget.movementsForWeight.map((movement) => getWorkoutRecordsComponent(currentMovement: movement)).toList(),
                    )
                  ],
                )
              ],
            )));
  }

  Widget getWorkoutRecordsComponent({MovementSubmodel currentMovement}) {
    return Container(
      decoration: const BoxDecoration(
        color: OlukoNeumorphismColors.appBackgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: ScreenUtils.width(context) / 2.5,
                  child: Text(
                    currentMovement.name,
                    maxLines: 2,
                    style: OlukoFonts.olukoBigFont(
                      customColor: OlukoColors.grayColor,
                    ),
                  ),
                ),
                if (widget.currentUserRecords
                    .where((currentUserRecord) => currentUserRecord.movementId == currentMovement.id && currentUserRecord.segmentId == widget.segmentId)
                    .isNotEmpty)
                  getWeightComponent(currentMovement)
                else
                  const SizedBox.shrink(),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              height: 80,
              width: ScreenUtils.width(context),
              child: ListView(
                physics: OlukoNeumorphism.listViewPhysicsEffect,
                scrollDirection: Axis.horizontal,
                children: friendUsersRecords(currentMovement),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> friendUsersRecords(MovementSubmodel currentMovement) {
    List<Widget> contentToReturn = [];
    Widget newFriendRecord = SizedBox.shrink();

    widget.friendsRecords.forEach((friendUser, friendRecords) {
      if (checkMovementRecordInsideFriendRecords(friendRecords, currentMovement).isNotEmpty) {
        if (canShowUserRecords(friendUser)) {
          newFriendRecord = Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      BottomDialogUtils.friendsModal(
                        friendUser,
                        widget.userId,
                        null,
                        widget.context,
                      );
                    },
                    child: friendUser.avatar != null
                        ? CircleAvatar(
                            minRadius: 25,
                            backgroundImage: CachedNetworkImageProvider(friendUser.avatarThumbnail ?? friendUser.avatar),
                          )
                        : UserUtils.avatarImageDefault(maxRadius: 25, name: friendUser.firstName, lastname: friendUser.lastName)),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      getWeight(currentMovement, checkMovementRecordInsideFriendRecords(friendRecords, currentMovement).first.weight),
                      style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w800),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      widget.useImperial ? OlukoLocalizations.get(context, 'lbs') : OlukoLocalizations.get(context, 'kgs'),
                      style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w800),
                    )
                  ],
                )
              ],
            ),
          );
        }
        if (canShowUserRecords(friendUser)) {
          contentToReturn.add(newFriendRecord);
        }
      }
    });
    return contentToReturn;
  }

  bool canShowUserRecords(UserResponse friendUser) => PrivacyOptions.userRequestedPrivacyOption(friendUser) != SettingsPrivacyOptions.anonymous;

  Iterable<WeightRecord> checkMovementRecordInsideFriendRecords(List<WeightRecord> friendRecords, MovementSubmodel currentMovement) =>
      friendRecords.where((weightRecord) => weightRecord.movementId == currentMovement.id && weightRecord.segmentId == widget.segmentId);

  Widget getWeightComponent(MovementSubmodel currentMovement) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(color: OlukoColors.primaryLight, borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/courses/weight_icon.png',
              scale: 3,
              color: OlukoNeumorphismColors.appBackgroundColor,
            ),
            Text(
              getWeight(currentMovement, getUserWeightRecordForMovement(currentMovement).weight),
              style: OlukoFonts.olukoMediumFont(customColor: OlukoNeumorphismColors.appBackgroundColor),
            ),
            const SizedBox(
              width: 2,
            ),
            Text(
              widget.useImperial ? OlukoLocalizations.get(context, 'lbs') : OlukoLocalizations.get(context, 'kgs'),
              style: OlukoFonts.olukoMediumFont(customColor: OlukoNeumorphismColors.appBackgroundColor),
            )
          ],
        ),
      ),
    );
  }

  String getWeight(MovementSubmodel movement, double weight) {
    String result;
    if (widget.useImperial) {
      result = double.parse(weight.toString()).round().toString();
    } else {
      result = (weight * _toKilogramsUnit).round().toString();
    }
    return result;
  }

  double get _toKilogramsUnit => 0.453;
  WeightRecord getUserWeightRecordForMovement(MovementSubmodel movement) => widget.currentUserRecords
      .where((currentUserRecord) => currentUserRecord.movementId == movement.id && currentUserRecord.segmentId == widget.segmentId)
      .first;
}
