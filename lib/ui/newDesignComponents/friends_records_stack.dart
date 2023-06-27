import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/friends_weight_records_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/ui/newDesignComponents/friends_weight_records_pop_up_component.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/user_utils.dart';

class FriendsRecordsStack extends StatefulWidget {
  final List<UserResponse> friendsUsers;
  final List<MovementSubmodel> movementsForWeight;
  final Text segmentStep;
  final Widget segmentTitleWidget;
  final bool useImperial;
  final List<WeightRecord> currentUserRecords;
  final String currentSegmentId;
  final String userId;
  const FriendsRecordsStack(
      {Key key,
      this.friendsUsers,
      this.movementsForWeight,
      this.segmentStep,
      this.segmentTitleWidget,
      this.useImperial = true,
      this.currentUserRecords,
      this.currentSegmentId,
      this.userId})
      : super(key: key);

  @override
  State<FriendsRecordsStack> createState() => _FriendsRecordsStackState();
}

class _FriendsRecordsStackState extends State<FriendsRecordsStack> {
  Map<UserResponse, List<WeightRecord>> myFriendsrecords;

  double userRadius = 25.0;
  @override
  Widget build(BuildContext context) {
    return widget.friendsUsers.isNotEmpty
        ? BlocBuilder<FriendsWeightRecordsBloc, FriendWeightRecordState>(
            builder: (context, state) {
              if (state is FriendsWeightRecordsSuccess) {
                myFriendsrecords = state.records;
              }
              return GestureDetector(
                onTap: () {
                  DialogUtils.getDialog(
                      context,
                      [
                        FriendsWeightRecordsPopUpComponent(
                            segmentStep: widget.segmentStep,
                            segmentTitleWidget: widget.segmentTitleWidget,
                            friendsRecords: myFriendsrecords,
                            movementsForWeight: widget.movementsForWeight,
                            useImperial: widget.useImperial,
                            currentUserRecords: widget.currentUserRecords,
                            segmentId: widget.currentSegmentId,
                            context: context,
                            userId: widget.userId)
                      ],
                      removeHorizontalPadding: true,
                      showBackgroundColor: false,
                      closeIconColor: OlukoColors.primary,
                      addPaddingToCloseButton: true,
                      useAppBackground: true);
                },
                child: Container(
                  height: 60,
                  width: 150,
                  child: Stack(
                    children: getUsersProfilePictures(),
                  ),
                ),
              );
            },
          )
        : const SizedBox.shrink();
  }

  List<Widget> getUsersProfilePictures() {
    List<UserResponse> usersListForRecordStackLimited =
        onlyUsersWithRecord().length > 5 ? onlyUsersWithRecord().getRange(0, 5).toList() : onlyUsersWithRecord();
    return usersListForRecordStackLimited
        .map((friend) => _checkFriendHasRecord(friend)
            ? Positioned(
                left: double.parse((onlyUsersWithRecord().indexOf(friend) * 20).toString()),
                child: friend.avatar != null
                    ? CircleAvatar(
                        minRadius: userRadius,
                        backgroundImage: CachedNetworkImageProvider(friend.avatarThumbnail ?? friend.avatar),
                      )
                    : UserUtils.avatarImageDefault(maxRadius: userRadius, name: friend.firstName, lastname: friend.lastName),
              )
            : const SizedBox.shrink())
        .toList();
  }

  List<UserResponse> onlyUsersWithRecord() {
    return widget.friendsUsers.where((element) => _checkFriendHasRecord(element)).toList();
  }

  bool _checkFriendHasRecord(UserResponse friend) {
    List<WeightRecord> recordsList = [];
    if (myFriendsrecords[friend] != null) {
      myFriendsrecords[friend].forEach((recordElement) {
        if (widget.movementsForWeight
            .where((movement) => movement.id == recordElement.movementId && recordElement.segmentId == widget.currentSegmentId)
            .isNotEmpty) {
          recordsList.add(recordElement);
        }
      });
      return recordsList.isNotEmpty;
    } else {
      return false;
    }
  }
}
