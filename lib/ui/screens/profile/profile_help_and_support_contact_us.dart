import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ProfileContacUsPage extends StatefulWidget {
  const ProfileContacUsPage();

  @override
  _ProfileContacUsPageState createState() => _ProfileContacUsPageState();
}

class _ProfileContacUsPageState extends State<ProfileContacUsPage> {
  UserResponse profileInfo;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthSuccess) {
        profileInfo = state.user;
        return Scaffold(
          appBar: OlukoAppBar(title: ProfileViewConstants.profileHelpAndSupportButtonText),
          body: buildFormContactUs(context),
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
        color: OlukoColors.black,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                buildInput(
                    context: context,
                    titleForLabel: OlukoLocalizations.get(context, 'name'),
                    contentForInput: profileInfo.firstName + " " + profileInfo.lastName),
                SizedBox(
                  height: 20,
                ),
                buildInput(context: context, titleForLabel: OlukoLocalizations.get(context, 'email'), contentForInput: profileInfo.email),
                SizedBox(
                  height: 20,
                ),
                buildInput(
                  context: context,
                  titleForLabel: OlukoLocalizations.get(context, 'phone'),
                ),
                SizedBox(
                  height: 20,
                ),
                buildInput(context: context, titleForLabel: OlukoLocalizations.get(context, 'message'), isTextMaxLine: true),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Expanded(
                      child: OlukoPrimaryButton(
                        title: OlukoLocalizations.get(context, 'submit'),
                        onPressed: () {
                          print("SUBMITTED");
                        },
                      ),
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

  Container buildInput({BuildContext context, String titleForLabel, String contentForInput, bool isTextMaxLine = false}) {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0)), border: Border.all(width: 1.0, color: OlukoColors.primary)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            child: Text(
              titleForLabel,
              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              maxLines: isTextMaxLine ? 10 : 1,
              initialValue: contentForInput,
              style: TextStyle(color: Colors.white),
              decoration: new InputDecoration(
                  focusColor: OlukoColors.primary,
                  filled: false,
                  hintStyle: new TextStyle(color: Colors.grey[800]),
                  // hintText: OlukoLocalizations.get(context, ''),
                  fillColor: OlukoColors.primary,
                  labelStyle: new TextStyle(color: Colors.grey[800])),
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
