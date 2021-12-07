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
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
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
  @override
  Widget build(BuildContext context) {
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
                color: OlukoColors.black,
                child: Stack(
                  children: [
                    userInformationSection(),
                    buildOptionsList(),
                  ],
                )),
          ),
        ));
  }

  Widget userInformationSection() {
    Widget returnWidget;
    returnWidget = Column(
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
                  connectStatus: null,
                  userStats: userStats,
                );
              },
            )),
      ],
    );
    return returnWidget;
  }

  Padding buildOptionsList() {
    return Padding(
      padding: const EdgeInsets.only(top: 170),
      child: ListView.builder(
          itemCount: ProfileOptions.profileOptions.length, itemBuilder: (_, index) => profileOptions(ProfileOptions.profileOptions[index])),
    );
  }

  Widget profileOptions(ProfileOptions option) {
    return currentOption(option);
  }

  Container currentOption(ProfileOptions option) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1.0, color: OlukoColors.grayColor))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
                        AppMessages.showSnackbarTranslated(context, 'loggedOut');
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                        setState(() {});
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
      ),
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
