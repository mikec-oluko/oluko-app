import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/selected_tags_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ClearAllButton extends StatefulWidget {
  const ClearAllButton();

  @override
  _State createState() => _State();
}

class _State extends State<ClearAllButton> {
  bool _showClearAll = false;
  @override
  Widget build(BuildContext context) {
    return BlocListener<SelectedTagsBloc, SelectedTagState>(
        listener: (context, selectedTagState) {
          if (selectedTagState is SelectedTagsUpdated && selectedTagState.tagsQty > 0) {
            setState(() {
              _showClearAll = true;
            });
          } else {
            setState(() {
              _showClearAll = false;
            });
          }
        },
        child: _showClearAll
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    OlukoLocalizations.get(context, 'clearAll'),
                    style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary),
                  ),
                ],
              )
            : SizedBox());
  }
}
