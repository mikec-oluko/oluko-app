import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/expansion_panel_list.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class ProfileHelpAndSupportPage extends StatefulWidget {
  const ProfileHelpAndSupportPage() : super();

  @override
  _ProfileHelpAndSupportPageState createState() =>
      _ProfileHelpAndSupportPageState();
}

class _ProfileHelpAndSupportPageState extends State<ProfileHelpAndSupportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          OlukoAppBar(title: ProfileViewConstants.profileOptionsHelpAndSupport),
      body: Container(
          color: OlukoColors.black,
          child: Expanded(
            child: Stack(
              children: [
                SizedBox(
                  height: 20.0,
                ),
                ExpansionPanelListWidget(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 5,
                    color: OlukoColors.black,
                    child: ListView(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: TitleBody(
                            ProfileViewConstants.profileHelpAndSupportSubTitle,
                            bold: true,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                            child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                          child: OlukoPrimaryButton(
                              title: ProfileViewConstants
                                  .profileHelpAndSupportButtonText),
                        ))
                      ],
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
