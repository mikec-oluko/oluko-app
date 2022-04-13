import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/profile_options.dart';
import 'package:oluko_app/helpers/profile_routes.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import '../../../constants/theme.dart';
import '../../../routes.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage();

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  UserResponse profileInfo;
  UserStatistics userStats;
  final String profileTitle = ProfileViewConstants.profileTitle;
  GlobalService _globalService = GlobalService();

  @override
  void initState() {
    BlocProvider.of<AuthBloc>(context).checkCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _globalService.comesFromCoach = false;

    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthSuccess) {
        profileInfo = state.user;
        BlocProvider.of<TransformationJourneyBloc>(context).getContentByUserId(profileInfo.id);
        BlocProvider.of<UserStatisticsBloc>(context).getUserStatistics(profileInfo.id);
        return profileHomeView();
      } else {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: OlukoCircularProgressIndicator(),
        );
      }
    });
  }

  Widget profileHomeView() {
    return Form(
        key: _formKey,
        child: Scaffold(
          appBar: OlukoAppBar(
            showBackButton: false,
            title: ProfileViewConstants.profileTitle,
            showSearchBar: false,
            showTitle: true,
          ),
          body: WillPopScope(
            onWillPop: () => AppNavigator.onWillPop(context),
            child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    userInformationSection(),
                    buildOptionsList(),
                  ],
                )),
          ),
        ));
  }

  Widget userInformationSection() => Column(
        children: [
          GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, routeLabels[RouteEnum.profileViewOwnProfile], arguments: {'userRequested': profileInfo})
                      .then((value) => onGoBack()),
              child: BlocBuilder<UserStatisticsBloc, UserStatisticsState>(
                builder: (context, state) {
                  if (state is StatisticsSuccess) {
                    userStats = state.userStats;
                  }
                  return UserProfileInformation(
                    userToDisplayInformation: profileInfo,
                    actualRoute: ActualProfileRoute.rootProfile,
                    currentUser: profileInfo,
                    userStats: userStats,
                  );
                },
              )),
        ],
      );

  Widget buildOptionsList() {
    return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ProfileOptions.profileOptions.length,
        itemBuilder: (_, index) => _profileOptions(ProfileOptions.profileOptions[index]));
  }

  Widget _profileOptions(ProfileOptions option) {
    return _currentOption(option);
  }

  Widget _currentOption(ProfileOptions option) {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: buildOptionContent(option),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: OlukoNeumorphicDivider(isFadeOut: true, isForList: true),
            )
          ])
        : Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 1.0, color: OlukoColors.grayColor))),
            child: buildOptionContent(option),
          );
  }

  Column buildOptionContent(ProfileOptions option) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: option.enable
              ? () {
                  switch (option.option) {
                    case ProfileOptionsTitle.settings:
                      Navigator.pushNamed(context, routeLabels[RouteEnum.profileSettings], arguments: {'profileInfo': profileInfo})
                          .then((value) => onGoBack());
                      break;
                    case ProfileOptionsTitle.transformationJourney:
                      Navigator.pushNamed(context, routeLabels[RouteEnum.profileTransformationJourney],
                          arguments: {'profileInfo': profileInfo});
                      break;
                    case ProfileOptionsTitle.logout:
                      BlocProvider.of<AuthBloc>(context).logout(context);
                      AppMessages.clearAndShowSnackbarTranslated(context, 'loggedOut');
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                      setState(() {});
                      break;
                    case ProfileOptionsTitle.assessmentVideos:
                      Navigator.pushNamed(context, routeLabels[RouteEnum.assessmentVideos],
                          arguments: {'isFromProfile': true, 'assessmentsDone': profileInfo.assessmentsCompletedAt != null});
                      break;
                    default:
                      Navigator.pushNamed(context, ProfileRoutes.returnRouteName(option.option));
                  }
                }
              : () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(OlukoLocalizations.get(context, returnOptionString(option.option)),
                    style: option.enable ? OlukoFonts.olukoMediumFont() : OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor)),
              ),
              IconButton(icon: Icon(Icons.arrow_forward_ios, color: OlukoColors.grayColor), onPressed: null)
            ],
          ),
        ),
      ],
    );
  }

  onGoBack() {
    setState(() {
      BlocProvider.of<AuthBloc>(context).checkCurrentUser();
    });
  }

  handleError(AsyncSnapshot snapshot) {}

  handleResult(AsyncSnapshot snapshot) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    });
  }

  String returnOptionString(ProfileOptionsTitle option) => option.toString().split('.')[1];
}
