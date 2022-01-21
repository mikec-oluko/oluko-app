import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/expansion_panel_list.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

import '../../../routes.dart';

class ProfileHelpAndSupportPage extends StatefulWidget {
  const ProfileHelpAndSupportPage() : super();

  @override
  _ProfileHelpAndSupportPageState createState() => _ProfileHelpAndSupportPageState();
}

class _ProfileHelpAndSupportPageState extends State<ProfileHelpAndSupportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoAppBar(
        title: ProfileViewConstants.profileOptionsHelpAndSupport,
        showTitle: true,
        showBackButton: true,
      ),
      body: Container(
          color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
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
                  color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
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
                          color: OlukoNeumorphism.isNeumorphismDesign
                              ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark
                              : OlukoColors.black,
                          child: Padding(
                            padding: OlukoNeumorphism.isNeumorphismDesign
                                ? const EdgeInsets.fromLTRB(20, 20, 20, 20)
                                : const EdgeInsets.fromLTRB(15, 0, 15, 15),
                            child: OlukoNeumorphism.isNeumorphismDesign
                                ? OlukoNeumorphicPrimaryButton(
                                    isExpanded: false,
                                    title: ProfileViewConstants.profileHelpAndSupportButtonText,
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        routeLabels[RouteEnum.profileContactUs],
                                      );
                                    },
                                  )
                                : OlukoPrimaryButton(
                                    title: ProfileViewConstants.profileHelpAndSupportButtonText,
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        routeLabels[RouteEnum.profileContactUs],
                                      );
                                    },
                                  ),
                          ))
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
