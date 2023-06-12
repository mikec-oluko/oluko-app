import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/views_bloc/faq_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/expansion_panel_list.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/screen_utils.dart';

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
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      appBar: OlukoAppBar(
        title: ProfileViewConstants.profileOptionsHelpAndSupport,
        showTitle: true,
        showBackButton: true,
      ),
      body: BlocBuilder<FAQBloc, FAQState>(
        builder: (context, state) {
          if (state is FAQSuccess) {
            return Container(
                color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
                child: ListView(
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    SizedBox(
                        height: OlukoNeumorphism.isNeumorphismDesign ? ScreenUtils.height(context) * 0.6 : ScreenUtils.height(context) * 0.65,
                        child: ExpansionPanelListWidget(faqList: state.faqList)),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 5,
                          color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
                          child: ListView(
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: false,
                            clipBehavior: Clip.none,
                            children: [
                              OlukoNeumorphism.isNeumorphismDesign
                                  ? Center(
                                      child: TitleBody(
                                        ProfileViewConstants.profileHelpAndSupportSubTitle,
                                        bold: true,
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(left: 15.0),
                                      child: TitleBody(
                                        ProfileViewConstants.profileHelpAndSupportSubTitle,
                                        bold: true,
                                      ),
                                    ),
                              SizedBox(height: 20.0),
                              Container(
                                  color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
                                  child: Padding(
                                    padding: OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.all(20) : const EdgeInsets.all(15),
                                    child: OlukoNeumorphism.isNeumorphismDesign
                                        ? OlukoNeumorphicPrimaryButton(
                                            customHeight: 55,
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
                      ),
                    )
                  ],
                ));
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
