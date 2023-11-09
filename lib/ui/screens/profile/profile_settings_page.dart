import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/notification_settings_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/privacy_options.dart';
import 'package:oluko_app/models/notification_settings.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/helpers/enum_collection.dart';

class ProfileSettingsPage extends StatefulWidget {
  final UserResponse profileInfo;
  ProfileSettingsPage({this.profileInfo});
  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  UserResponse _authUser;
  bool _globalNotificationsValue;
  bool _coachResponseNotificationsValue;
  bool _appOpeningReminderValue;
  bool _workoutNotificationsValue;
  bool _useImperial;
  int _userPrivacyValue;
  int _privacyNewValue;

  void initState() {
    BlocProvider.of<AuthBloc>(context).checkCurrentUser();
    setValuesFromUserProfile();

    super.initState();
  }

  void setValuesFromUserProfile() {
    _privacyNewValue = widget.profileInfo.privacy;
    _useImperial = widget.profileInfo.useImperialSystem;
    _globalNotificationsValue ??= NotificationSettingsBloc.notificationSettings?.globalNotifications ?? true;
    _coachResponseNotificationsValue ??= NotificationSettingsBloc.notificationSettings?.coachResponseNotifications ?? true;
    _workoutNotificationsValue ??= NotificationSettingsBloc.notificationSettings?.workoutReminderNotifications ?? true;
    _appOpeningReminderValue ??= NotificationSettingsBloc.notificationSettings?.appOpeningReminderNotifications ?? true;
    _authUser = widget.profileInfo;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthSuccess) {
        _authUser = state.user;
        return buildSettingsView(context);
      } else {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: OlukoCircularProgressIndicator(),
        );
      }
    });
  }

  Scaffold buildSettingsView(BuildContext context) {
    return Scaffold(
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      appBar: OlukoAppBar(
        title: ProfileViewConstants.profileSettingsTitle,
        showSearchBar: false,
        showBackButton: true,
        showTitle: true,
      ),
      body: SingleChildScrollView(
        physics: OlukoNeumorphism.listViewPhysicsEffect,
        child: Container(
            width: MediaQuery.of(context).size.width,
            color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
            child: Column(
              children: [
                _settingsOptionsSection(context),
              ],
            )),
      ),
    );
  }

  Column _settingsOptionsSection(BuildContext context) {
    return Column(
      children: [
        _addSectionTitle(titleForSection: OlukoLocalizations.get(context, 'pushNotifications')),
        Column(
          children: NotificationSettings.notificationSettingsList.map((option) => createNotificationSwitch(context, option)).toList(),
        ),
        _addSectionTitle(titleForSection: OlukoLocalizations.get(context, 'privacy')),
        Column(
          children: PrivacyOptions.privacyOptionsList.map((option) => _buildOptionTiles(context, option)).toList(),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                title: Text(ProfileViewConstants.weightMeasurement, style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white)),
              ),
              const OlukoNeumorphicDivider(),
              Column(
                children: [
                  Column(children: [
                    weightOption(title: OlukoLocalizations.get(context, 'useKilograms'), isSelected: !_useImperial),
                    const OlukoNeumorphicDivider()
                  ]),
                  Column(
                      children: [weightOption(title: OlukoLocalizations.get(context, 'usePounds'), isSelected: _useImperial), const OlukoNeumorphicDivider()])
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _addSectionTitle({@required String titleForSection}) {
    return Align(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(alignment: Alignment.centerLeft),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 35, 15, 35),
            child: Text(
              titleForSection,
              style: OlukoFonts.olukoBigFont(),
            ),
          ),
          OlukoNeumorphicDivider()
        ],
      ),
    );
  }

  Widget createNotificationSwitch(BuildContext context, NotificationSettings option) {
    return notificationSwitch(context, option);
  }

  Widget notificationSwitch(BuildContext context, NotificationSettings option) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      child: Column(children: [olukoSwitch(option), const OlukoNeumorphicDivider()]),
    );
  }

  MergeSemantics olukoSwitch(NotificationSettings option) {
    return MergeSemantics(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        title: Text(OlukoLocalizations.get(context, returnOption(option.title.toString())), style: OlukoFonts.olukoBigFont()),
        subtitle: Text(
          OlukoLocalizations.get(context, returnOption(option.subtitle.toString())),
          style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor),
        ),
        trailing: BlocListener<NotificationSettingsBloc, NotificationSettingsState>(
          listener: (context, state) {
            if (state is NotificationSettingsUpdate && state.notificationSettings != null) {
              setState(() {
                _globalNotificationsValue = state.notificationSettings.globalNotifications;
                _appOpeningReminderValue = state.notificationSettings.appOpeningReminderNotifications;
                _coachResponseNotificationsValue = state.notificationSettings.coachResponseNotifications;
                _workoutNotificationsValue = state.notificationSettings.workoutReminderNotifications;
              });
            }
          },
          child: OlukoNeumorphism.isNeumorphismDesign
              ? Neumorphic(
                  style: const NeumorphicStyle(
                      depth: 3,
                      intensity: 1,
                      color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                      shape: NeumorphicShape.flat,
                      lightSource: LightSource.bottom,
                      boxShape: NeumorphicBoxShape.stadium(),
                      shadowDarkColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
                      shadowLightColorEmboss: OlukoColors.black,
                      surfaceIntensity: 1,
                      shadowLightColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
                      shadowDarkColor: OlukoColors.black),
                  child: Container(
                    width: 50,
                    height: 30,
                    child: NeumorphicSwitch(
                      style: const NeumorphicSwitchStyle(
                        inactiveThumbColor: OlukoColors.primary,
                        activeThumbColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                        activeTrackColor: OlukoColors.primary,
                        inactiveTrackColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                        thumbShape: NeumorphicShape.flat,
                        thumbDepth: 1,
                        disableDepth: true,
                      ),
                      value: NotificationSettingsBloc.notificationSettings.getNotificationValue(option.type),
                      onChanged: (bool value) => _setValueForNotifications(option.type, value),
                    ),
                  ),
                )
              : Switch(
                  value: NotificationSettingsBloc.notificationSettings.getNotificationValue(option.type),
                  onChanged: (bool value) => _setValueForNotifications(option.type, value),
                  trackColor: MaterialStateProperty.all(OlukoColors.grayColor),
                  activeColor: OlukoColors.primary,
                ),
        ),
      ),
    );
  }

  Widget _buildOptionTiles(BuildContext context, PrivacyOptions option) {
    Widget widgetToReturn = Container();
    if (!option.isSwitch) {
      widgetToReturn = OlukoNeumorphism.isNeumorphismDesign
          ? Column(children: [neumorphicOptionContent(option), const OlukoNeumorphicDivider()])
          : Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(width: 1.0, color: OlukoColors.grayColor)),
                color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
              ),
              child: radioButton(option, context));
    }
    return widgetToReturn;
  }

  Theme radioButton(PrivacyOptions option, BuildContext context) {
    return Theme(
      data: ThemeData(unselectedWidgetColor: OlukoColors.primary),
      child: RadioListTile(
          toggleable: true,
          activeColor: OlukoColors.primary,
          selectedTileColor: OlukoColors.black,
          controlAffinity: ListTileControlAffinity.trailing,
          selected: _userPrivacyValue == option.option.index,
          title: Text(
            OlukoLocalizations.get(context, returnOption(option.title.toString())),
            style: OlukoFonts.olukoBigFont(),
          ),
          subtitle: option.showSubtitle
              ? Text(
                  OlukoLocalizations.get(context, returnOption(option.subtitle.toString())),
                  style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor),
                )
              : SizedBox(),
          value: option.option.index,
          groupValue: _privacyNewValue,
          onChanged: (value) {
            _setValueForPrivacy(index: value as int);
          }),
    );
  }

  Widget neumorphicOptionContent(PrivacyOptions option) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                OlukoLocalizations.get(context, returnOption(option.title.toString())),
                style: OlukoFonts.olukoBigFont(),
              ),
              option.showSubtitle
                  ? Container(
                      width: ScreenUtils.width(context) / 1.25,
                      child: Text(
                        OlukoLocalizations.get(context, returnOption(option.subtitle.toString())),
                        style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          Expanded(child: SizedBox()),
          GestureDetector(onTap: () => _setValueForPrivacy(index: option.option.index), child: neumorphicRadioButton(option.option.index == _privacyNewValue))
        ],
      ),
    );
  }

  Widget weightOption({String title, bool isSelected}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: OlukoFonts.olukoBigFont(),
              ),
            ],
          ),
          const Expanded(child: SizedBox()),
          GestureDetector(
              onTap: () {
                _setValueForWeightMeasure(!_useImperial);
              },
              child: neumorphicRadioButton(isSelected))
        ],
      ),
    );
  }

  Widget neumorphicRadioButton(bool isSelected) {
    return SizedBox(
      width: 50,
      height: 50,
      child: isSelected
          ? Image.asset(
              'assets/profile/selected_option.png',
              scale: 3.5,
            )
          : Image.asset(
              'assets/profile/no_selected_option.png',
              scale: 3.5,
            ),
    );
  }

  void _setValueForPrivacy({int index}) {
    if (index != null) {
      setState(() {
        _privacyNewValue = index;
      });
    }
    if (_privacyNewValue != _authUser.privacy) {
      BlocProvider.of<ProfileBloc>(context).updateSettingsPreferences(_authUser, _privacyNewValue);
    }
  }

  void _setValueForNotifications(SettingsNotificationsOptions type, bool value) {
    setState(() {
      switch (type) {
        case SettingsNotificationsOptions.globalNotifications:
          _globalNotificationsValue = value;
          break;
        case SettingsNotificationsOptions.appOpeningReminder:
          _appOpeningReminderValue = value;
          break;
        case SettingsNotificationsOptions.coachResponse:
          _coachResponseNotificationsValue = value;
          break;
        case SettingsNotificationsOptions.workoutReminder:
          _workoutNotificationsValue = value;
          break;
      }
    });
    final NotificationSettings notificationToUpdate = NotificationSettings(
      globalNotifications: _globalNotificationsValue,
      appOpeningReminderNotifications: _appOpeningReminderValue,
      workoutReminderNotifications: _workoutNotificationsValue,
      coachResponseNotifications: _coachResponseNotificationsValue,
      userId: _authUser.id,
    );
    BlocProvider.of<NotificationSettingsBloc>(context).update(notificationToUpdate);
  }

  void _setValueForWeightMeasure(bool useImperial) {
    setState(() {
      _useImperial = useImperial;
    });
    BlocProvider.of<ProfileBloc>(context).updateSettingsForWeights(userToUpdate: _authUser, useImperialSystem: _useImperial);
  }

  String returnOption(String option) => option.split(".")[1];
}
