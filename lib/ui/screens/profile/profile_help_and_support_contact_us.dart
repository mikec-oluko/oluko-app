import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/profile/mail_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ProfileContacUsPage extends StatefulWidget {
  const ProfileContacUsPage();

  @override
  _ProfileContacUsPageState createState() => _ProfileContacUsPageState();
}

class _ProfileContacUsPageState extends State<ProfileContacUsPage> {
  TextEditingController messageController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  UserResponse profileInfo;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthSuccess) {
        profileInfo = state.user;
        return Scaffold(
          backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
          appBar: OlukoAppBar(title: ProfileViewConstants.profileHelpAndSupportButtonText, showTitle: true, showBackButton: true),
          body: BlocListener<MailBloc, MailState>(
            listener: (context, state) {
              if (state is MailSuccess) {
                AppMessages.clearAndShowSnackbarTranslated(context, 'submitted');
              } else {
                AppMessages.clearAndShowSnackbarTranslated(context, 'messageRequired');
              }
            },
            child: buildFormContactUs(context),
          ),
        );
      } else {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: OlukoCircularProgressIndicator(),
        );
      }
    });
  }

  SingleChildScrollView buildFormContactUs(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                buildInput(
                    context: context,
                    titleForLabel: OlukoLocalizations.get(context, 'name'),
                    contentForInput: profileInfo.firstName + " " + profileInfo.lastName,
                    enableInput: false),
                const SizedBox(
                  height: 20,
                ),
                buildInput(context: context, titleForLabel: OlukoLocalizations.get(context, 'email'), contentForInput: profileInfo.email, enableInput: false),
                const SizedBox(
                  height: 20,
                ),
                buildInput(
                    context: context, titleForLabel: OlukoLocalizations.get(context, 'phone'), controller: phoneController, inputType: TextInputType.phone),
                const SizedBox(
                  height: 20,
                ),
                buildInput(context: context, titleForLabel: OlukoLocalizations.get(context, 'message'), isTextMaxLine: true, controller: messageController),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 60, 10, 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: OlukoNeumorphism.isNeumorphismDesign
                        ? OlukoNeumorphicPrimaryButton(
                            isExpanded: false,
                            thinPadding: true,
                            title: OlukoLocalizations.get(context, 'submit'),
                            onPressed: () {
                              BlocProvider.of<MailBloc>(context)
                                  .sendContactUsMail(profileInfo.username, profileInfo.email, messageController.text, phoneController.text);
                            },
                          )
                        : OlukoPrimaryButton(
                            title: OlukoLocalizations.get(context, 'submit'),
                            onPressed: () {
                              BlocProvider.of<MailBloc>(context)
                                  .sendContactUsMail(profileInfo.username, profileInfo.email, messageController.text, phoneController.text);
                            },
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildInput(
      {BuildContext context,
      String titleForLabel,
      String contentForInput,
      bool isTextMaxLine = false,
      TextEditingController controller,
      bool enableInput = true,
      TextInputType inputType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
          color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat : OlukoColors.black,
          borderRadius:
              OlukoNeumorphism.isNeumorphismDesign ? const BorderRadius.all(const Radius.circular(15.0)) : const BorderRadius.all(const Radius.circular(5.0)),
          border: OlukoNeumorphism.isNeumorphismDesign ? const Border.symmetric() : Border.all(width: 1.0, color: OlukoColors.primary)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            child: Text(
              titleForLabel,
              style: OlukoFonts.olukoMediumFont(customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.grayColor : OlukoColors.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              keyboardType: inputType,
              enabled: enableInput,
              controller: controller ?? null,
              maxLines: isTextMaxLine ? 10 : 1,
              initialValue: contentForInput,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  focusColor: OlukoColors.primary,
                  filled: false,
                  hintStyle: TextStyle(color: Colors.grey[800]),
                  // hintText: OlukoLocalizations.get(context, ''),
                  fillColor: OlukoColors.primary,
                  labelStyle: TextStyle(color: Colors.grey[800])),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return OlukoLocalizations.get(context, 'required');
                }
                return null;
              },
              onSaved: (value) {},
            ),
          ),
        ],
      ),
    );
  }
}
