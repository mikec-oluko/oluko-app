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

class ProfileSettingsPage extends StatefulWidget {
  final UserResponse profileInfo;
  ProfileSettingsPage({this.profileInfo});
  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  UserResponse _authUser;
  bool _notificationNewValue;
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
    _notificationNewValue ??= NotificationSettingsBloc.notificationSettings?.globalNotifications ?? true;
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
      appBar: OlukoAppBar(
        title: ProfileViewConstants.profileSettingsTitle,
        showSearchBar: false,
        showBackButton: true,
        showTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
        child: _settingsOptionsSection(context),
      ),
    );
  }

  Column _settingsOptionsSection(BuildContext context) {
    return Column(
      children: [
        createNotificationSwitch(context),
        Column(
          children: PrivacyOptions.privacyOptionsList.map((option) => _buildOptionTiles(context, option)).toList(),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
          child: Column(
            children: [
              ListTile(
                title: Text(ProfileViewConstants.weightMeasurement, style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor)),
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

  Container createNotificationSwitch(BuildContext context) {
    return notificationSwitch(context);
  }

  Container notificationSwitch(BuildContext context) {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Container(
            width: MediaQuery.of(context).size.width,
            color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
            child: Column(children: [olukoSwitch(), OlukoNeumorphicDivider()]),
          )
        : Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(width: 1.0, color: OlukoColors.grayColor), bottom: BorderSide(width: 1.0, color: OlukoColors.grayColor)),
              color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
            ),
            child: olukoSwitch(),
          );
  }

  MergeSemantics olukoSwitch() {
    return MergeSemantics(
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        title: Text(ProfileViewConstants.profileSettingsNotification, style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor)),
        trailing: BlocListener<NotificationSettingsBloc, NotificationSettingsState>(
          listener: (context, state) {
            if (state is NotificationSettingsUpdate && state.notificationSettings != null) {
              setState(() {
                _notificationNewValue = state.notificationSettings.globalNotifications;
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
                      shadowDarkColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                      shadowLightColorEmboss: OlukoColors.black,
                      surfaceIntensity: 1,
                      shadowLightColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
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
                          disableDepth: true),
                      value: _notificationNewValue,
                      onChanged: (bool value) => _setValueForNotifications(value),
                    ),
                  ),
                )
              : Switch(
                  value: _notificationNewValue,
                  onChanged: (bool value) => _setValueForNotifications(value),
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
            style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
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
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                OlukoLocalizations.get(context, returnOption(option.title.toString())),
                style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
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
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
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

  void _setValueForNotifications(bool value) {
    setState(() {
      _notificationNewValue = value;
    });
    BlocProvider.of<NotificationSettingsBloc>(context).update(NotificationSettings(globalNotifications: value, userId: _authUser.id));
  }

  void _setValueForWeightMeasure(bool useImperial) {
    setState(() {
      _useImperial = useImperial;
    });
    BlocProvider.of<ProfileBloc>(context).updateSettingsForWeights(userToUpdate: _authUser, useImperialSystem: _useImperial);
  }

  String returnOption(String option) => option.split(".")[1];
}
