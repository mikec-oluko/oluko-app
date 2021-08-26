import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/profile_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/ui/components/uploading_modal_success.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class UploadingModalLoader extends StatefulWidget {
  final UploadFrom toUpload;
  UploadingModalLoader(this.toUpload);
  @override
  _UploadingModalLoaderState createState() => _UploadingModalLoaderState();
}

class _UploadingModalLoaderState extends State<UploadingModalLoader> {
  @override
  Widget build(BuildContext context) {
    Widget _widgetToReturn;
    if (widget.toUpload == UploadFrom.transformationJourney) {
      return BlocBuilder<TransformationJourneyBloc, TransformationJourneyState>(
        builder: (context, state) {
          if (state is TransformationJourneyLoading) {
            _widgetToReturn = LoaderAndUploadingText();
          } else if (state is TransformationJourneyNoUploads) {
            _widgetToReturn = Container();
          } else if (state is TransformationJourneySuccess) {
            _widgetToReturn = MultiBlocProvider(providers: [
              BlocProvider.value(value: BlocProvider.of<AuthBloc>(context)),
              BlocProvider.value(
                  value: BlocProvider.of<TransformationJourneyBloc>(context)),
            ], child: UploadingModalSuccess(widget.toUpload));
          } else {
            _widgetToReturn = Container();
            Navigator.pop(context);
          }
          return _widgetToReturn;
        },
      );
    } else if (widget.toUpload == UploadFrom.profileImage ||
        widget.toUpload == UploadFrom.profileCoverImage) {
      return BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is Loading) {
            _widgetToReturn = LoaderAndUploadingText();
          } else if (state is Failure) {
            _widgetToReturn = Container();
            Navigator.pop(context);
          } else if (state is ProfileUploadSuccess) {
            _widgetToReturn = MultiBlocProvider(providers: [
              BlocProvider.value(value: BlocProvider.of<ProfileBloc>(context)),
              BlocProvider.value(value: BlocProvider.of<AuthBloc>(context)),
            ], child: UploadingModalSuccess(widget.toUpload));
          }
          return _widgetToReturn;
        },
      );
    }
  }
}

class LoaderAndUploadingText extends StatelessWidget {
  const LoaderAndUploadingText({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Transform.scale(
              scale: 2,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  backgroundColor: OlukoColors.grayColor,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(OlukoColors.primary)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0).copyWith(top: 50),
            child: Text(
              OlukoLocalizations.of(context).find('uploadingWithDots'),
              style:
                  OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
    );
  }
}
